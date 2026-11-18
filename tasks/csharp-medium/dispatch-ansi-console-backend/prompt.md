In Spectre.Console, `AnsiConsoleFacade` (`src/Spectre.Console/Internal/Backends/AnsiConsoleFacade.cs`) writes through an `IAnsiConsoleBackend` chosen by `GetBackend()`. For a console whose profile reports `Capabilities.Ansi == true`, which concrete class's `Write(IRenderable)` runs when `AnsiConsoleFacade.Write(IRenderable)` is called?

Write the fully qualified name of that class (namespace and class name) as the only line of `ANSWER.txt` at the repository root.
