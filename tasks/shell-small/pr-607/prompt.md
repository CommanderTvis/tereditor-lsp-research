BATS_TMPDIR has a trailing slash depending on OS

**Describe the bug**
Running on Mac, `BATS_TMPDIR` uses the value of `TMPDIR` that has a trailing slash.

This results in `BATS_TMPDIR` having values like 
```
/var/folders/5f/p33sf8dj1317jl051f62h09c0000gp/T//bats-run-6SF0zp/bats-test-tmp-0P8F
```
As per 
https://github.com/bats-core/bats-core/blob/410dd229a5ed005c68167cc90ed0712ad2a1c909/libexec/bats-core/bats#L89,
there is no trimming of the trailing slash and the default is `/tmp` without a trailing slash.

If a test performs string replacements based on paths, the OS would remove those `//` while the `BATS_TMPDIR` will still hold them as a string. This results in test failures since 2 strings do not match.

I.e.

```
/var/folders/5f/p33sf8dj1317jl051f62h09c0000gp/T//bats-run-6SF0zp/bats-test-tmp-0P8F

and

/var/folders/5f/p33sf8dj1317jl051f62h09c0000gp/T/bats-run-6SF0zp/bats-test-tmp-0P8F
```

Similar problem exists for `BATS_TEST_TMPDIR`:
```
/var/folders/5f/p33sf8dj1317jl051f62h09c0000gp/T//bats-run-6SF0zp/test//1
```

Note: this started to appear after upgrade from 1.3.0 to 1.7.0

I have a very extensive test suite that uses helpers (and tests them) + a lot of actual tests running locally and in CI (and failing now).

**To Reproduce**
Steps to reproduce the behavior:
1. Run on MacOS `echo $BATS_TMPDIR` within a test and assert that output contains `//`

**Expected behavior**
No `//` in the path.

**Environment (please complete the following information):**
 - Bats Version: 1.7
 - OS:  MacOS (local), Linux (CI)
 - Bash version: `GNU bash, version 5.1.4(1)-release (x86_64-apple-darwin20.2.0)`

**Additional context**

Others have experienced this as well: https://github.com/golang/go/issues/21318

Some additional info: [How does Linux handle multiple consecutive path separators (/home////username///file)?](https://unix.stackexchange.com/questions/1910/how-does-linux-handle-multiple-consecutive-path-separators-home-username)


