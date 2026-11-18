# V4Pact.mergeInteractions drops metadata.plugins from later @Pact methods

`V4Pact.mergeInteractions` keeps only the first pact's metadata, dropping plugin config from other `@Pact` methods

## Summary

When a JUnit5 (or JUnit4/Spock) consumer test declares multiple `@Pact` methods for the same consumer/provider pair, the extensions merge the resulting pacts by calling `mergeInteractions(interactions: List<Interaction>)` on the first pact with each subsequent pact's interactions. `V4Pact`'s implementation only merges the interaction lists and always keeps `this.metadata`:

```kotlin
// V4Pact.kt
override fun mergeInteractions(interactions: List<Interaction>): Pact {
  return V4Pact(consumer, provider, merge(interactions).toMutableList(), metadata, source)
}
```

Any content stored under `metadata.plugins[].configuration` by a plugin's `ConfigureInteraction` response for a *later* `@Pact` method never reaches the merged pact.

## Impact

The pact-avro-plugin (https://github.com/zirekhq/pact-avro-plugin) stores each interaction's Avro schema pact-wide, keyed by a schema hash, in `metadata.plugins[].configuration`. When a consumer test has one `@Pact` method per `.avsc` file, only the first method's schema survives the merge. Provider verification then fails with:

```
Plugin Avro Schema configuration item with key '<hash>' is required
```

Reproduction: https://github.com/nathandeamer/pact-sample-avro

Confirmed on Slack (thanks @rholshausen) that this also affects the Protobuf plugin, just less visibly, since consumer tests there tend to reuse one proto file across `@Pact` methods, and that the metadata drop is not intentional.

## Root cause

`mergeInteractions(interactions: List<Interaction>): Pact` on the `Pact` interface only receives the other pact's interactions, never its metadata, so no implementation can merge `metadata.plugins` even if it wanted to. This is called directly by:

- `PactConsumerTestExt.kt` (JUnit5) — two call sites
- `BaseProviderRule.java` (JUnit4)
- `PactConsumerSpockExt.kt` (Spock)

## Proposed fix

Add an additive overload to the `Pact` interface:

```kotlin
fun mergeInteractions(other: Pact): Pact = mergeInteractions(other.interactions)
```

`V4Pact` overrides it to also merge `this.metadata` and `other.metadata`'s `plugins` lists by plugin `name`, deep-merging `configuration` for a name present in both (mirroring `PactBuilder.addPluginConfiguration`'s own use of `deepMerge`). `RequestResponsePact`/`MessagePact` (V3, no plugin metadata) keep the default. Then switch the four call sites above to the new overload.

Happy to open a PR with this change if it sounds right.
