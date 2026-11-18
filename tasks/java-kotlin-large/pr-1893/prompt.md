# Prompt assembly costs 300ms on every LLM call, and none of it is attributed

## Background

Prompt assembly — everything between `respondWithSystemPrompt(...)` being called and the
provider actually being called — costs **240–420ms warm** on a 40-tool chat surface. None of
it is currently instrumented, so it cannot be attributed to a stage.

This surfaced downstream while chasing per-turn chat latency. The application's own assembly
path measured 15ms; the framework's measured 240–420ms on the same turn. Because the cost sits
*inside* the framework call, bounding it from outside makes it look like model latency, which
is how it went unnoticed.

## User value

For typed chat, a few hundred milliseconds reads as thinking. For voice, it is the difference
between talking to something and waiting for it — a spoken turn only feels conversational if
the reply starts arriving in about a second, and this is a fixed tax on every turn before the
model has seen a token.

## Current state

Measured by bracketing `Rendering.respondWithSystemPrompt` against `ChatModelCallEvent`, which
`InstrumentedChatModel` emits at the real `ChatModel.call()` point — i.e. after Spring AI has
built the fully augmented prompt:

| | warm | cold (first call) |
|---|---|---|
| assembly (call → `ChatModelCallEvent`) | 240–420ms | ~440ms |
| provider round trip | 0.94–1.22s | 2.77s |

40 tools, gpt-4.1-mini, a Jinja system-prompt template with several prompt contributors.

Two things worth noting: assembly is nearly as expensive warm as cold, so whatever it is, it is
being redone every call rather than cached. And it does not vary with the user's question — a
three-word greeting pays the same as a complex request.

## Gaps

- **Nothing is instrumented between the `Rendering` entry point and `ChatModelCallEvent`**, so
  the 300ms cannot be attributed. Candidates, all inside `ChatClientLlmOperations`:
  prompt-contributor gathering, system-prompt template rendering, output-converter schema
  generation (`converter.getFormat()` / `buildPromptWithSchema`), and per-tool definition
  resolution feeding `toSpringToolCallbacks()`.
- `SpringToolCallbackAdapter` itself is a thin wrapper, so the cost is more likely in
  *resolving* each `tool.definition` (name/description/schema) than in wrapping it — but that
  is a hypothesis, not a measurement, which is exactly the gap.
- There is no regression gate on assembly cost, so an improvement here has nothing to hold it.

## Direction

1. **Instrument first; do not optimise before the 300ms is attributed.** One timing per stage
   between the `Rendering` entry point and `ChatModelCallEvent`. Include an "unaccounted"
   bucket — omitting one is precisely what let this hide.
2. Then attack whatever dominates. If it is schema generation or tool-definition resolution,
   both look cacheable: neither the tool surface nor the output schema changes between turns of
   one conversation.
3. Land the acceptance test below as the gate.

## Acceptance test

The gate should fail today at ~300ms and go green when assembly is fixed. Sketch — the point is
the shape (mock the `ChatModel` so the measured window is assembly only, and assert a budget),
not the exact API surface, which the implementer should adjust:

```kotlin
/**
 * Prompt assembly is a fixed tax on every LLM call, paid before the model sees a token.
 * This pins it, because an improvement with no gate silently regresses.
 */
class PromptAssemblyPerformanceTest {

    /** Generous enough not to flake on a loaded CI box; still ~6x below today's cost. */
    private val budget = Duration.ofMillis(50)

    @Test
    fun `assembling a 40-tool prompt stays within budget`() {
        // A ChatModel that returns instantly, so the measured window is assembly ONLY —
        // no network, no provider. Capture the prompt to prove assembly really happened.
        val captured = slot<Prompt>()
        val chatModel: ChatModel = mockk()
        every { chatModel.call(capture(captured)) } returns emptyChatResponse()

        val tools = (1..40).map { stubTool("tool_$it") }
        val rendering = renderingFor(chatModel, tools, systemPromptTemplate)

        // Warm up: first call pays one-time template compilation and schema init, which is a
        // real but separate concern from steady-state per-turn cost.
        repeat(3) { rendering.respondWithSystemPrompt(conversation, model) }

        val samples = (1..20).map {
            measureTime { rendering.respondWithSystemPrompt(conversation, model) }
        }

        assertThat(captured.isCaptured).isTrue()
        val median = samples.sorted()[samples.size / 2]
        assertThat(median)
            .describedAs("steady-state prompt assembly for %d tools", tools.size)
            .isLessThan(budget)
    }
}
```

Two things to get right when landing it:

- **Median, not mean, over ≥20 samples after warmup.** A single GC pause otherwise makes this
  flaky, and a flaky perf gate gets deleted rather than fixed.
- **Warm up explicitly.** Cold cost here is ~440ms vs ~300ms warm; conflating the two turns a
  steady-state budget into a one-time-init budget and hides the real regression.

A second case asserting assembly does not scale linearly with tool count (40 tools vs 4 should
not be 10x) would catch the per-tool resolution hypothesis directly.

## Outcome

Prompt assembly is attributed stage by stage, steady-state cost for a large tool surface is
well under 50ms, and a test holds it there.

