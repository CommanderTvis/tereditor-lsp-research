# Attempting to rend very specific output causes the TestConsole to hang.

**Information**
 - OS: MacOS
 - Version: 0.57.2
 - Terminal: ITerm

**Describe the bug**
Attempting to render this very specific output to a TestConsole with a very specific width will cause the application to hang.

**To Reproduce**
Here is an example app
# `issue316-min-repro.csproj`
```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net10.0</TargetFramework>
    <RootNamespace>issue316_min_repro</RootNamespace>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Spectre.Console" Version="0.57.2" />
    <PackageReference Include="Spectre.Console.Testing" Version="0.57.2" />
  </ItemGroup>

</Project>
```

# `Program.cs`
```c#
// Minimal reproduction of a suspected Spectre.Console (v0.57.2) narrow-width non-termination.
//
// Widget shape being constructed:
//
//   rootFrame (Table, 1 col, NoBorder/HideHeaders)
//   +----------------------------------------------+
//   | listFrame (Table, 2 col, NoBorder/HideHdrs)  |
//   | +--------+----------------------------------+|
//   | |   "-"  | paragraphFrame (Table, 1 col,    ||
//   | | (right)| NoBorder/HideHeaders)            ||
//   | |        | +------------------------------+ ||
//   | |        | | Markup("Hello 😄 world 😃")  | ||
//   | |        | +------------------------------+ ||
//   | +--------+----------------------------------+|
//   +----------------------------------------------+
//
// Usage:
//   dotnet run -- [width] [timeoutSeconds]
// Examples:
//   dotnet run -- 10        # width 10, default 10s timeout -> expected to time out
//   dotnet run -- 360       # width 360, default 10s timeout -> expected to complete
//   dotnet run -- 10 5      # width 10, 5s timeout
//
// When run with a width != 10 everything is fine, it completes quickly.  However if you use a width of exactly 10 it will hang

using Spectre.Console;
using Spectre.Console.Testing;

int width = args.Length > 0 && int.TryParse(args[0], out var w) ? w : 10;
int timeoutSeconds = args.Length > 1 && int.TryParse(args[1], out var t) ? t : 10;

Console.WriteLine($"Testing width={width}, timeout={timeoutSeconds}s ...");

var paragraphFrame = new Table().NoBorder().HideHeaders().AddColumn(string.Empty);
paragraphFrame.AddRow(new Markup("Hello 😄 world 😃"));

var listFrame = new Table().NoBorder().HideHeaders().AddColumn(string.Empty).AddColumn(string.Empty);
listFrame.Columns[0].RightAligned();
listFrame.AddRow(new Markup("-"), paragraphFrame);

var rootFrame = new Table().NoBorder().HideHeaders().AddColumn(string.Empty);
rootFrame.AddRow(listFrame);

var console = new TestConsole().Width(width).Interactive();

Console.WriteLine("Rendering ...");

// Run the render on a background thread so a hang there doesn't hang this process; if it doesn't
// finish within the timeout, report and exit without waiting on the stuck thread.
var renderTask = Task.Run(() => console.Write(rootFrame));
var completed = renderTask.Wait(TimeSpan.FromSeconds(timeoutSeconds));

if (!completed)
{
    Console.WriteLine($"TIMEOUT: render did not complete within {timeoutSeconds}s (hang confirmed)");
    Environment.Exit(124);
}

if (renderTask.IsFaulted)
{
    Console.WriteLine($"FAIL: render threw an exception: {renderTask.Exception?.Flatten().InnerException}");
    Environment.Exit(1);
}

Console.WriteLine("PASS: render completed");
Console.WriteLine(console.Output);
```

run the following `dotnet run -- 10`

You will get the following output after letting it run for about 10 seconds
```
~/copilot/scratch/issue316-min-repro > dotnet run -- 10
Testing width=10, timeout=10s ...
Rendering ...
TIMEOUT: render did not complete within 10s (hang confirmed)
```

**Expected behavior**

If you select a different width, things work just fine, these all complete quickly
```
~/copilot/scratch/issue316-min-repro > dotnet run -- 40
Testing width=40, timeout=10s ...
Rendering ...
PASS: render completed
- Hello 😄 world 😃

~/copilot/scratch/issue316-min-repro > dotnet run -- 20
Testing width=20, timeout=10s ...
Rendering ...
PASS: render completed
- Hello 😄
  world 😃

~/copilot/scratch/issue316-min-repro > dotnet run -- 11
Testing width=11, timeout=10s ...
Rendering ...
PASS: render completed
- He
  ll
  o
  😄
  wo
  rl
  d
  😃

~/copilot/scratch/issue316-min-repro > dotnet run -- 9
Testing width=9, timeout=10s ...
Rendering ...
PASS: render completed
-

~/copilot/scratch/issue316-min-repro >
```

**Screenshots**


**Additional context**
This also appear to happen if you use this text `私は**「重要」**だと思う` but not this text `Hello X world X`.  This make me think it has something to do with unicode characters (but I'm speculating)  

---
Please upvote :+1: this issue if you are interested in it.
