The lint rule class `ModifierReusedDetector` (`compose-lint-checks/src/main/java/slack/lint/compose/ModifierReusedDetector.kt`)
is the only detector in the module whose name does not say what kind of thing it is for: the other rules are named after
the check they implement. We want to call it `ModifierReusedCheck` from now on.

Rename the class `ModifierReusedDetector` to `ModifierReusedCheck` everywhere in the repository: its declaration, the
issue registry, the tests, KDoc references, the documentation and any configuration file that mentions the class by name
or by its file path. Rename its source file to `ModifierReusedCheck.kt` so it keeps matching the class. The test classes
(`ModifierReusedDetectorTest` and `ModifierReusedBranchTest`) are separate classes and keep their names, and the issue
id `ComposeModifierReused` does not change.

The module must still build and the existing tests must pass.
