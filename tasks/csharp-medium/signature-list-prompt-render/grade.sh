#!/bin/sh
# Build and tests pass; the interface and both implementations take the console last, none takes it first.
set -eu
sh /project/check.sh
grep -q 'string searchText, IAnsiConsole console)' src/Spectre.Console/Prompts/List/IListPromptStrategy.cs || { echo "interface not changed"; exit 1; }
for f in SelectionPrompt MultiSelectionPrompt; do
  grep -q 'string searchText, IAnsiConsole console)' "src/Spectre.Console/Prompts/$f.cs" || { echo "$f not changed"; exit 1; }
done
if grep -rIE --include='*.cs' 'Render\(IAnsiConsole console, bool scrollable' src | grep -q .; then echo "old parameter order still present"; exit 1; fi
