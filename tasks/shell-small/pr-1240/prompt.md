--allow-empty-suite forces a hard dependency on bats >= 1.14

### Describe the bug

Since v1.14.0 (PR #1211) an empty test suite results in an error, which is incompatible with older bats versions. It breaks some existing setups (see below for an example). The suggested workaround is to add `--allow-empty-suite` to get the old behavior back.

Unfortunately, the workaround itself is also incompatible with older bats versions, as any old version will error out with `Bad command line option '--allow-empty-suite'`.

So for a project that legitimately produces an empty suite in some configuration, the choice is:

* add `--allow-empty-suite` and drop support for every bats before 1.14, or
* pin bats to <= 1.13 and stay on an old version.

### To Reproduce

Real-world example, https://github.com/containers/conmon/pull/672: CRI-O's test runner always makes two bats passes, the second one selecting the serial tests:

```
execute bats --jobs "$JOBS" --tap "${TESTS[@]}" --filter-tags '!crio:serial'
execute bats --tap "${TESTS[@]}" --filter-tags 'crio:serial'
```

When the requested test set contains no serial test, the second pass legitimately has nothing to run, and with v1.14.0 CI fails:

```
+ bats --tap critest.bats --filter-tags crio:serial
1..0
ERROR: Found no tests. (Try `--allow-empty-suite`?)
```

Adding `--allow-empty-suite` there would have broken the distro-provided older bats that other jobs use, so we had to pin bats to v1.13.0 instead.

### Expected behavior

A way to opt into the old behavior that older bats versions silently ignore, i.e. an environment variable — `BATS_ALLOW_EMPTY_SUITE=1` — with the same effect as `--allow-empty-suite`. Older versions ignore an unknown `BATS_*` variable and keep exiting 0 on an empty suite, which is exactly the behavior being asked for, so one setting works across versions.

There is precedent for flags having an environment variable equivalent, e.g. `--code-quote-style` / `$BATS_CODE_QUOTE_STYLE`.

### Environment

* bats 1.14.0
