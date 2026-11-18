# ProgressContext.IsFinished returns true when tasks exist but none have started

**Information**
- OS: Ubuntu 24.04
- Version: main (current branch)
- Terminal: GNOME Terminal

**Describe the bug**
`ProgressContext.IsFinished` returns `true` when one or more tasks exist in the context but none of them have started yet (for example, when created with `autoStart: false`). This causes any `while (!ctx.IsFinished)` loop to be skipped entirely, even though the intended work was never started.

**To Reproduce**
Steps to reproduce the behavior:

```csharp
using Spectre.Console;

AnsiConsole.Progress().Start(ctx =>
{
    var task = ctx.AddTask("Loading", autoStart: false);

    while (!ctx.IsFinished)
    {
        Thread.Sleep(50);
        task.StartTask();
        Console.WriteLine("Im here");
    }
});
```

1. Run the code above.
2. Observe that `Im here` is never printed.
3. The process exits with code 0, and the progress bar stays frozen at 0%.

Looking at the implementation of `IsFinished`:

```csharp
public bool IsFinished
{
    get
    {
        lock (_taskLock)
        {
            return _tasks.Where(x => x.IsStarted).All(task => task.IsFinished);
        }
    }
}
```

When no task has `IsStarted == true`, `Where(...)` produces an empty sequence, and `.All()` on an empty sequence always returns `true` (vacuous truth in LINQ). So `IsFinished` reports "finished" even though nothing has actually run yet.

**Expected behavior**
There are two reasonable directions here, and I'd like maintainer input on which is intended:

1. `IsFinished` should return `false` when the context has tasks that haven't started yet, since there's still pending work — only a truly empty context (`_tasks.Count == 0`) would return `true`.
2. The current behavior is intentional, and the XML doc should be updated to make this edge case explicit (currently: "Gets a value indicating whether or not all started tasks have completed", which doesn't call out the "no tasks started" case).

I'd lean towards option 1, since it matches the common `while (!ctx.IsFinished)` usage pattern. If this is confirmed as a bug, I'd be happy to work on a PR with regression tests covering both the "no tasks added" and "tasks added but not started" cases.
