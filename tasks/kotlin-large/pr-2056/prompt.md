# toJson() drops row objects when a real "value" column contains only nulls

### Description

`DataFrame.toJson()` incorrectly serializes a multi-column DataFrame as an array of `null` values when a column named `value` contains only nulls, even though other columns contain valid data.

### Minimal reproduction

```kotlin
import org.jetbrains.kotlinx.dataframe.api.dataFrameOf
import org.jetbrains.kotlinx.dataframe.io.toJson

fun main() {
    val df =
        dataFrameOf(
            "value" to listOf<Double?>(null, null),
            "name" to listOf("Alice", "Bob"),
        )

    println(df.toJson())
}
```

### Actual result

```json
[null,null]
```

### Expected result

```json
[
  {
    "value": null,
    "name": "Alice"
  },
  {
    "value": null,
    "name": "Bob"
  }
]
```

### Environment

- Kotlin: 2.2.21
- Kotlin DataFrame: 1.0.0-Beta5
- JDK: 21
- Gradle: 9.4.1
- OS: Windows 11
