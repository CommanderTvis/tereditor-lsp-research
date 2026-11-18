`LlmReferenceProvider` (`embabel-agent-api/src/main/kotlin/com/embabel/agent/api/reference/LlmReferenceProvider.kt`) declares `fun reference(): LlmReference` (line 35), and several classes provide it: literal text, web pages, directory references and chat assets.

Consider a call `provider.reference()` where `provider` is statically an `LlmReferenceProvider` and the object it holds is a `LocalDirectoryReference` (`com.embabel.agent.api.reference.LocalDirectoryReference`). Which function runs?

Write the answer to `ANSWER.txt` in the repository root as one line, `path:line`: the path of the source file that defines that function, relative to the repository root, and the line of its definition on which the function's name appears.
