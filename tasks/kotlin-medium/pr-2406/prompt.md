# Support companion extensions

**Is your feature request related to a problem? Please describe.**

Companion extensions have been introduced in Kotlin 2.5.0-Beta1. Example:

```kotlin
companion fun Vector.unit(angle: Double) = Vector(cos(angle), sin(angle))
```

**Describe the solution you'd like**

KotlinPoet should allow generating companion extensions.

**Describe alternatives you've considered**

N/A

**Additional context**

KEEP: https://github.com/Kotlin/KEEP/blob/main/proposals/KEEP-0449-companions-block-extension.md
Announcement: https://blog.jetbrains.com/kotlin/2026/09/the-companions-to-come/
