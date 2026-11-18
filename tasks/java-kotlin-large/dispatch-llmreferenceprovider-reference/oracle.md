# Oracle: dispatch of LlmReferenceProvider#reference for LocalDirectoryReference

Derived by reading the pinned source, no language server. `LocalDirectoryReference` implements `LlmReferenceProvider` and `LlmReference` and declares `override fun reference(): LlmReference = localDirectory` on line 39 of its file. The other implementers (LiteralText, WebPage, the chat assets) are different receivers.
