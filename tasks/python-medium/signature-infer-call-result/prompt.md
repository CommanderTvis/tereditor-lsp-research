`infer_call_result` is implemented on many classes (`UnboundMethod`, `BoundMethod`, `Lambda`, `FunctionDef`, `ClassDef`, the
bound methods of the object model, `PartialFunction`, `Property`, the brain plugins' bound methods, and so on) and is called
through whatever the call target happens to be, so every implementation must keep the same interface.

Add a keyword-only parameter `strict: bool = False` after `context` to `UnboundMethod.infer_call_result` and to every
other implementation of `infer_call_result` in the package, so that they all still accept the same calls. Wherever one
implementation delegates to another `infer_call_result` (through `super()`, a proxied object or a looked-up method), pass
`strict` on. Callers outside the implementations do not need to change. The parameter has no other effect yet.
