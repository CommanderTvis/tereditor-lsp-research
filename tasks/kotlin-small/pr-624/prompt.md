# `ComposeReadOnlyComposable` false negative on read in default argument expression

```kotlin
object MaterialTheme {
    val colorScheme: ColorScheme
        @Composable @ReadOnlyComposable get() = TODO()
}

@Composable
fun fadeHighlightColor(
    backgroundColor: Color = MaterialTheme.colorScheme.surface,
    alpha: Float = 0.3f,
): Color = backgroundColor.copy(alpha = alpha)
```
Not flagged with 1.5.5.
