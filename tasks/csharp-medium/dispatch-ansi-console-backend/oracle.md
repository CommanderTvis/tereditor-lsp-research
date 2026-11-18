# Oracle: backend selected when Capabilities.Ansi is true

Not derived from a language server. `AnsiConsoleFacade.GetBackend()` (src/Spectre.Console/Internal/Backends/AnsiConsoleFacade.cs) returns
`_ansiBackend` when `Profile.Capabilities.Ansi` is true and `_legacyBackend` otherwise; `_ansiBackend` is created as
`new AnsiConsoleBackend(this)` in the constructor. `AnsiConsoleBackend` is declared once, in
src/Spectre.Console/Internal/Backends/Ansi/AnsiConsoleBackend.cs, namespace `Spectre.Console`.
