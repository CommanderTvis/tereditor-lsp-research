# ObservabilityTool tags a returned Tool.Result.Error as success, and the tool span's error.type reads ToolReturnedError

Follow-up from #2068, where @arnabnandy7 raised the first point and @jimador the second. Read from `main` (`1c1e900`), not run.

1. `ObservabilityTool.callWithObservation` only takes its error branch when the delegate throws. A returned `Tool.Result.Error` is tagged `status=success` (`ToolDecorators.kt:106-108`). `MethodTool` turns every exception except `ReplanRequestedException` into `Tool.Result.error(message, cause)` (`MethodTool.kt:66-77`), as do `TypedTool.kt:84-90` and `SpringToolCallbackAdapter.kt:133,147`, so most failures take this path. #2068 changed only the published event (`ToolDecorators.kt:227`); `EventPublishingTool` still returns the `Tool.Result.Error` (`:234`) to the `ObservabilityTool` wrapping it (`DefaultToolDecorator.kt:46-50`).

   Scope: with Embabel's observability autoconfiguration on and tracing enabled (the default), the tier filter drops observations named `tool call` (`ObservabilityAutoConfiguration.java:167-169`), the name `ObservabilityTool` uses (`ToolDecorators.kt:100`). Embabel's own traces never see the span. The wrong status only reaches other handlers in apps without that module or with it turned off (`ObservabilityAutoConfiguration.java:68`), or with `tracing-enabled=false`, where the filter returns earlier (`:159-166`).

2. `EmbabelSpanEventListener` sets `embabel.tool.error.type` from `error.getClass().getSimpleName()` (`EmbabelSpanEventListener.java:491`) on the event's failure as published (`ToolCallOutcomes.kt:34`). Since #2068 that is a `ToolReturnedError` (`ToolDecorators.kt:66`), so every `MethodTool` failure is tagged `ToolReturnedError`. The tool's own exception is on `cause`.

Suggested fix: in `callWithObservation`, tag a returned `Tool.Result.Error` the way the catch block does (`ToolDecorators.kt:110-114`), using its `message` and `cause`, and still return it. In the listener, report the `cause` type when the error is a `ToolReturnedError` that has one, and keep `ToolReturnedError` when it does not (`ScriptTool` errors carry no cause, `ScriptTool.kt:72,147,151`).

Happy to open a PR for both.

