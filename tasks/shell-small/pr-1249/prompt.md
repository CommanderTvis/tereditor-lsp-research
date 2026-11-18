`bats_test_function` false "Duplicate test name(s)" when one dynamic test's args are a prefix of another's

**Component:** `libexec/bats-core/bats-gather-tests`
**Version:** bats-core 1.13.0 (also present at `d9faff0`, i.e. `v1.13.0-33-gd9faff0`)
**Affected function:** `bats_test_function` (dedup check added at gather time)

## Summary

When a test file registers dynamically-parametrized tests via `bats_test_function`
(the pattern used for data-driven tests, e.g. one function run with different
argument tuples), bats aborts the whole file with a false
`ERROR: Duplicate test name(s) in file "...": <name>` whenever one registered
call's `function name + args` string happens to be a literal **prefix** of another
call's string for the *same* function. This is a false positive: the two calls have
different arguments and are not duplicates. Whether the bug triggers depends on the
**registration order** of the two calls within the file, which for callers building
the argument list from an associative array (e.g. iterating `"${!some_assoc_array[@]}"`
to call `bats_test_function` in a loop) is effectively bash hash-order-dependent and
not under the test author's control.

## Root cause

In `bats_test_function` (`libexec/bats-core/bats-gather-tests`):

```bash
line="$BATS_TEST_FILENAME"
line+=$'\t'
line+="$*"
...
# dereferencing ${test_names[*]} fails on older bash versions when empty -> check before
if [[ ${#test_names[@]} -gt 0 && " ${test_names[*]} " == *" $line "* ]]; then
    test_dupes+=("$line")
fi
test_names+=("$line")
```

Each test's identity is `<filename>\t<function-name-and-args>`. Duplicate detection
joins all previously-seen identities with spaces and does a **substring** glob
match (`*" $line "*`) instead of an exact per-element comparison. Because `IFS`
(space) also appears *inside* `$*` whenever a call has multiple arguments, a
shorter identity string can end up embedded, padded by spaces, inside a longer one
— even though the two are genuinely different `line` values with different
`$*` args.

Concretely: registering `f --format plain` and then `f` (bare, no args) produces
these two `line` values (tab-separated filename omitted for brevity):

- `f --format plain`
- `f`

Joining as `" f --format plain f "` and searching for `*" f "*` matches, because
`f ` appears right before `--format` — the search string `" f "` is a substring of
`" f --format plain f "` purely by coincidence of word boundaries, not because `f`
(no args) was ever actually registered before.

## Reproduction

```bash
# prefix.bats — longer args registered FIRST, shorter (bare) SECOND
f() { :; }
bats_test_function --description "long one" -- f --format plain
bats_test_function --description "short one" -- f
```

```
$ bats prefix.bats
ERROR: Duplicate test name(s) in file "prefix.bats": f
```

Swapping the registration order makes the false positive disappear, confirming the
substring/order dependency and that this is not a real duplicate:

```bash
# prefix-reversed.bats — same two calls, shorter (bare) registered FIRST
f() { :; }
bats_test_function --description "short one" -- f
bats_test_function --description "long one" -- f --format plain
```

```
$ bats prefix-reversed.bats
1..2
ok 1 short one
ok 2 long one
```

Both files declare the exact same two logical tests; only the registration order
differs, and only one order is (falsely) rejected.

## Impact

Any file that dynamically parametrizes tests over a set of CLI-flag-shaped argument
strings — e.g. building test cases from an associative array and calling
`bats_test_function` in a `for description in "${!cases[@]}"` loop — can hit this
whenever one case's argument string happens to be a prefix of another's for the same
underlying function (a very natural situation: a "default"/bare case next to a case
that adds one more flag on top). Because the loop iterates over hash-table keys,
whether the bug fires can flip between runs/bash versions with no change to the test
file itself, making it read as flaky/nondeterministic when it is really a
registration-order artifact of a substring-match dedup check.

## Related: bats-core#1036

[bats-core#1036](https://github.com/bats-core/bats-core/issues/1036) (open,
confirmed) reports that gathering empty tests scales ~O(n²) with test count (0.24s
at 1 test, 242s at 1000). That's this same dedup check: on every
`bats_test_function` call it rebuilds `" ${test_names[*]} "` (already O(n) in the
tests seen so far) and glob-scans it, so the file-level cost is O(n²) even before
considering correctness. #1036's repro uses unique per-test titles, so it isn't
hitting the prefix false-positive described here — it's the same root design (an
ever-growing collection re-scanned from scratch on every call) surfacing as a
performance bug instead of a correctness one. Worth linking the two when filing.

## Suggested fix

Compare identities exactly instead of via substring/glob match. An associative
array would be the obvious tool, but this file explicitly supports Bash 3 (see the
"avoid unbound variable with set -u Bash 3" comments a few lines above the bug, at
lines 71 and 88) and `declare -A` is Bash-4+ only, so the fix needs to stay
Bash-3-compatible.

**Minimal fix (correctness only):** a plain exact-match scan over the existing
array, no new data structure:

```bash
local is_dupe=false existing
for existing in "${test_names[@]}"; do
    if [[ "$existing" == "$line" ]]; then
        is_dupe=true
        break
    fi
done
"$is_dupe" && test_dupes+=("$line")
test_names+=("$line")
```

This preserves the existing behaviour for genuine duplicates (identical filename +
function + args registered twice) while eliminating false positives from prefix
relationships between distinct argument strings, and removes the order-dependence —
all without raising the Bash version floor. It's still O(n²) per file overall
(one O(n) scan per call), so on its own it does **not** fix #1036 — merely stops it
from also being wrong.

**Fix that also addresses #1036:** move duplicate detection out of the per-call hot
path entirely. Keep `test_names+=("$line")` as the only per-call work, then once at
the end of gathering (e.g. in `bats_gather_tests`, after the file has been fully
sourced), sort the collected array once and scan for adjacent equal entries:

```bash
local sorted_names
IFS=$'\n' sorted_names=($(sort <<<"${test_names[*]}")) # or `sort -z` with a NUL-joined build if names may contain newlines
unset IFS
local i
for ((i = 1; i < ${#sorted_names[@]}; i++)); do
    [[ "${sorted_names[i]}" == "${sorted_names[i-1]}" ]] && test_dupes+=("${sorted_names[i]}")
done
```

This is O(n log n) per file (dominated by `sort`), fixes the same false-positive
(exact-value comparison, no substring search) and directly addresses #1036's
complaint, at the cost of a slightly larger change (duplicate detection moves from
"as you register" to "after the file is fully gathered").

