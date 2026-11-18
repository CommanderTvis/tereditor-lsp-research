# `ComposeRedundantComposable` false positive on composable lambda invocation

```kotlin
val Lambda = @Composable { }

@Composable
fun Test() {
    Lambda()
}
```
with `com.slack.lint.compose:compose-lint-checks:1.5.4`
