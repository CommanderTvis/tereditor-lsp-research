# eachValue: rules defined below the eachValue path are not applied to the values

## Versions

- `au.com.dius.pact.core:matchers` 4.7.5 (latest), JDK 21
- We first saw it in a Scala provider verified through pact4s 0.18.0 (pact-jvm 4.7.1)
- Code pointers below are against `master` at 8d307da

## Summary

When a map or list is matched with an `eachValue` rule, pact-jvm applies only the rules inside that `eachValue` definition to each value. Any other rule defined below the path, such as `$.chips.*.amount`, is ignored, so a provider can send a value the consumer's matchers reject.

Pacts written through the Rust FFI (pact-js, pact-python, pact-go, ...) put the matchers nested in an `eachValue` example at exactly those paths. pact-foundation/pact-reference#586 has the consumer side. pact-foundation/pact-reference#587 fixes the Rust verifier and also writes the matchers nested in the `eachValue` rules there. pact-jvm still skips all of them.

## Reproduction

Here is a message pact written by pact-js 17.1.4 for `eachValueMatches({ main: like({ amount: integer(1000) }) }, like({ amount: 1000 }))`. The values must be objects whose `amount` is an integer:

```json
{
  "consumer": { "name": "EachClient" },
  "provider": { "name": "EachAPI" },
  "messages": [
    {
      "description": "example holds matchers",
      "contents": { "chips": { "main": { "amount": 1000 } } },
      "matchingRules": {
        "body": {
          "$.chips": {
            "combine": "AND",
            "matchers": [
              {
                "match": "eachValue",
                "rules": [ { "match": "type" } ],
                "value": "{\"main\":{\"pact:matcher:type\":\"type\",\"value\":{\"amount\":{\"pact:matcher:type\":\"integer\",\"value\":1000}}}}"
              }
            ]
          },
          "$.chips.*": { "combine": "AND", "matchers": [ { "match": "type" } ] },
          "$.chips.*.amount": { "combine": "AND", "matchers": [ { "match": "integer" } ] }
        }
      }
    }
  ],
  "metadata": { "pactSpecification": { "version": "3.0.0" } }
}
```

Matching it with pact-jvm's own JSON matcher (Scala 3, `au.com.dius.pact.core:matchers:4.7.5`):

```scala
import au.com.dius.pact.core.matchers.{JsonContentMatcher, MatchingContext}
import au.com.dius.pact.core.model.{ContentType, DefaultPactReader, OptionalBody}
import au.com.dius.pact.core.model.messaging.Message
import scala.jdk.CollectionConverters.*

@main def repro(file: String): Unit =
  val pact = DefaultPactReader.INSTANCE.loadPact(new java.io.File(file))
  for interaction <- pact.getInteractions.asScala do
    val message = interaction.asInstanceOf[Message]
    val context = new MatchingContext(message.getMatchingRules.rulesForCategory("body"), true)
    for body <- Seq("""{"chips":{"main":{"amount":1.5}}}""", """{"chips":{"main":{"amount":500}}}""") do
      val actual = OptionalBody.body(body.getBytes("UTF-8"), ContentType.fromString("application/json"))
      val result = JsonContentMatcher.INSTANCE.matchBody(message.getContents, actual, context)
      println(s"$body -> ${if result.matchedOk() then "PASSED" else result.getMismatches.asScala.map(_.description()).mkString("; ")}")
```

| contract | `amount: 1.5` | `amount: 500` |
|---|---|---|
| `$.chips` eachValue + `$.chips.*.amount` integer (above) | **passes** | passes |
| the same map spelled out per key: `$.chips.main.amount` integer | fails: `Expected 1.5 (Decimal) to be an integer` | passes |

The contract from pact-foundation/pact-reference#587 for `eachValueMatches(example, like({ amount: integer() }))` gives the same result. It holds `$.chips` (eachValue) and `$.chips.*.amount` (integer), and `amount: 1.5` passes.

## Where it happens

[`Matchers.compareMaps`](https://github.com/pact-foundation/pact-jvm/blob/8d307dac3411c34637e8f2473c10a1950c87c8b8/core/matchers/src/main/kotlin/au/com/dius/pact/core/matchers/Matchers.kt#L83-L115) and the [`EachValueMatcher` branch of `compareLists`](https://github.com/pact-foundation/pact-jvm/blob/8d307dac3411c34637e8f2473c10a1950c87c8b8/core/matchers/src/main/kotlin/au/com/dius/pact/core/matchers/Matchers.kt#L206-L237) both match the values with a new `MatchingContext` that holds only `path.*` and the eachValue definition's rules. The rules below `path` in the original context are dropped. `coerceNumbers` is dropped too.

## Expected

The sub-context keeps the context's rules below `path`, and adds the eachValue rules at `path.*`. Rules at `path` and above it can stay out, as now. pact-foundation/pact-reference#587 makes this change in the Rust verifier, so both implementations would then give the same results for the same pact.
