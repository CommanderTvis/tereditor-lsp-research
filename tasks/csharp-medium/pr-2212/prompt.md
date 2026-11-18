# The initially selected value changes when you upgrade from 0.55.1 to 0.55.2

**Information**
 - OS: MacOS - but also repros on all os
 - Version: 0.55.2
 - Terminal: iTerm2 - but also repros on others

**Describe the bug**
Upgrading from 0.55.1 to 0.55.2 will change the initially selected values for a `SelectionPrompt<int>` if one of the values to pick from is `0`

in 0.55.1 it would be the first item, in 0.55.2 it would `0`.

**To Reproduce**

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Spectre.Console" Version="0.55.1" />
  </ItemGroup>

</Project>
```

```C#
using Spectre.Console;

public static class Program
{
    public static int Main()
    {
        var console = AnsiConsole.Console;

        const int done = -1;

        var links = new[]
        {
            new Uri("https://example.com/first"),
            new Uri("https://example.com/second"),
        };

        var prompt = new SelectionPrompt<int>();

        prompt
            .Title("Select an item (press Enter once):")
            .AddChoice(done); // Intended default "Done" at the top

        // Add link choices as 0-based indices (0, 1, 2...).
        // This is what breaks in 0.55.2 because default(int) == 0.
        prompt.AddChoices(Enumerable.Range(0, links.Length));

        prompt.Converter = i => i switch
        {
            -1 => "Done",
            _  => $"Link {i}: {links[i]}",
        };

        var selected = prompt.Show(console);

        // Print what got selected.
        console.WriteLine($"Selected value: {selected}");

        return 0;
    }
}
```

If you run this you get

```
~/Temp/SpectreSelectionPromptDefaultValueRepro > dotnet run
Select an item (press Enter once):

> Done
  Link 0: https://example.com/first
  Link 1: https://example.com/second
```

Changing that to 0.55.2 the output would be

```
~/Temp/SpectreSelectionPromptDefaultValueRepro > dotnet run
Select an item (press Enter once):

  Done
> Link 0: https://example.com/first
  Link 1: https://example.com/second
```

**Expected behavior**
The initially selected item should not change with new version 

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Additional context**
Add any other context about the problem here.

I found this because the update caused some of tests to fail 
https://github.com/boxofyellow/ConsoleMarkdownRenderer/actions/runs/24687514540/job/72365771103?pr=51

I had :copilot:  take a look and it narrowed it down to this oddity

```C#
public static class Program
{
    public static int Main()
    {
        var c = new Class1<int>();
        Console.WriteLine($"[{c.Value}]");
        return 0;
    }
}

public class Class1<T>
{
    public T? Value { get; set; }
}
```
This will output `[0]`, not `[]` as you might expect, and it looks like that tripped up
https://github.com/spectreconsole/spectre.console/commit/b18ccb1b00118b7fb81b8fd03fabbdd2324ad8ee#diff-1bb4e374c5a6be9b1d6e185449ec5e298e02cfc89c20a6eb45338467f358ae16

```C#
    /// <summary>
    /// Gets or sets the choice to show as selected when the prompt is first displayed.
    /// By default the first choice is selected.
    /// </summary>
    public T? DefaultValue { get; set; }

...

    /// <inheritdoc/>
    int IListPromptStrategy<T>.CalculateInitialIndex(IReadOnlyList<ListPromptItem<T>> nodes)
    {
        if (DefaultValue is not null)
        {
            return Tree.IndexOf(DefaultValue) ?? 0;
        }

        return 0;
    }
```

If you don't set DefaultVaue, on a `MultiSelectionPrompt<int>` it won't be `null` it will be `0`.

For the time being I worked around it by not having `0` in my list of values.  I could also just `DefaultVaue`.

---
Please upvote :+1: this issue if you are interested in it.
