# LLM roles should resolve through an SPI to a materialized LlmService, not a static role→model map

## Background

Roles exist so model choice is an ops decision: code asks for `cheap` or `best`, configuration decides
what that means.

## Current state

`embabel.models.llms` is a flat `Map<role, modelName>`. A model belongs to one provider, so a role
pins a provider. Give a deployment only an Anthropic key and every OpenAI-named role is unsatisfiable —
and the context fails at boot, because the map is validated eagerly.

There is nowhere to fix this from outside. `ByRoleModelSelectionCriteria` is a map lookup in
`ConfigurableModelProvider` that consults no strategy, `ModelSelectionCriteria` is `sealed`, and
`AutoLlmSelectionCriteriaResolver` takes no arguments so it cannot know the caller or the active key.
The only way out is `withLlmService(...)`, which skips `ModelProvider` entirely.

## What Guide does now

Guide is BYOK, so it resolves roles itself. Three classes:

```kotlin
enum class LlmProvider(val chatModel: String, val classifierModel: String, /* ...one per role... */) {
    OPENAI(chatModel = OpenAiModels.GPT_41, classifierModel = OpenAiModels.GPT_41_MINI, ...),
    ANTHROPIC(chatModel = AnthropicModels.CLAUDE_SONNET_4_6, classifierModel = AnthropicModels.CLAUDE_HAIKU_4_5, ...),
}

enum class LlmRole(val modelSelector: (LlmProvider) -> String) {
    CHAT({ it.chatModel }), CLASSIFIER({ it.classifierModel }), ...
}

@Service
class UserLlmResolver(...) {
    fun resolve(ctx: OperationContext, userId: String, role: LlmRole): PromptRunner {
        val activeKey = userKeyStore.getActiveKey(userId)
        if (activeKey != null) {
            val (provider, apiKey) = activeKey
            val llmService = userModelFactory.getLlmService(provider, role.modelSelector(provider), apiKey)
            return ctx.ai().withLlmService(llmService)   // bypasses ModelProvider
        }
        serverProvider?.let { return ctx.ai().withLlm(role.modelSelector(it)) }  // different path!
        return ctx.ai().withLlmService(setupRequiredService)  // fake LLM: "add a key"
    }
}
```

Plus `UserModelFactory`, which builds and caches an `LlmService` per (provider, model, key).

What's wrong with it:

- The provider list and every model name are compiled in. Retuning what `chat` means is a redeploy.
- A role yields a `String`, so no temperature, timeout, or thinking budget travels with it.
- BYOK and server-default take different code paths, with different failure modes.
- Only code that injects `UserLlmResolver` participates. RAG enhancement and ranking still use the
  static map and never see the user's key.
- Every provider must name a model for every role. No fallback.

Two things it gets right and the platform should own: a role materializing to an `LlmService` per
request, and booting with no keys instead of dying.

## Direction

Route `ByRole` through a resolver interface, defaulting to today's map lookup.

```kotlin
fun interface RoleResolver {
    /** Return null to delegate to the next resolver. */
    fun resolve(role: String, context: ModelSelectionContext): RoleResolution?
}

/** What the choice actually depends on. Also the missing argument on AutoLlmSelectionCriteriaResolver. */
data class ModelSelectionContext(val userId: String?, val credential: ProviderCredential?)

sealed interface RoleResolution {
    /** Configured options — model plus temperature, timeout, thinking budget. */
    data class Options(val llmOptions: LlmOptions) : RoleResolution

    /** A key: the platform looks up the role for that provider and builds/caches the service. */
    data class Credential(val credential: ProviderCredential) : RoleResolution

    /** An already-built service, for callers that construct their own. */
    data class Service(val llmService: LlmService<*>) : RoleResolution
}
```

With a config shape for deployments that don't need a bean:

```yaml
embabel:
  models:
    roles:
      chat:
        openai:    { model: gpt-4.1 }
        anthropic: { model: claude-sonnet-4-6, temperature: 0.3 }
      classifier:
        openai:    { model: gpt-4.1-mini }
        anthropic: { model: claude-haiku-4-5 }
```

A role with no entry for the active provider falls back to the default LLM rather than failing at boot.
An unkeyed deployment gets a platform-supplied "add a key" LLM instead of a dead context.

## What Guide becomes

`LlmProvider`, `LlmRole`, `UserLlmResolver` and `UserModelFactory` all go. The role table moves to the
yaml above. Guide keeps one bean — the only thing that is genuinely Guide's business, which is whose
key is active:

```kotlin
@Component
class ByokRoleResolver(
    private val userKeyStore: UserKeyStore,
) : RoleResolver {

    override fun resolve(role: String, context: ModelSelectionContext): RoleResolution? =
        context.userId
            ?.let { userKeyStore.getActiveKey(it) }
            ?.let { (provider, apiKey) -> ProviderCredential(provider.name, apiKey) }
            ?.let { RoleResolution.Credential(it) }   // platform resolves + caches the LlmService
}
```

and every call site loses its resolver injection:

```kotlin
// before
userLlmResolver.resolve(ctx, userId, LlmRole.CHAT).createObject(prompt)

// after
ctx.ai().withLlmByRole("chat").createObject(prompt)
```

That last line is the point: it is provider-agnostic, it works the same for BYOK and server-keyed
deployments, and framework-internal LLM users get the user's key for free.

## Outcome

A role resolves against whichever provider is active, for the deployment or for the user. Swapping
platform is a config change. Applications stop shipping their own role→model selectors.

