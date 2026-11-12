Bug report: request exception handlers registered for the base `System.Exception` type are never called any more.

We register a catch-all `IRequestExceptionHandler<MyRequest, MyResponse, Exception>` that calls `state.SetHandled(...)`
with a fallback response. When the request handler throws (for example an `InvalidOperationException`), the exception
now escapes from `mediator.Send(...)` instead of the fallback response being returned, and the catch-all handler is not
even invoked. Exception handlers registered for a specific exception type (such as `InvalidOperationException`) still
work, and catch-all `IRequestExceptionAction<MyRequest, Exception>` actions still run as before.

Find the cause and fix it in the library code. Keep the change minimal.
