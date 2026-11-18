bats exits zero when first argument is empty string

**Describe the bug**
When invoked with an empty first parameter (instead of a file or directory that exists), bats collects 0 tests and exits 0.

**To Reproduce**
Steps to reproduce the behavior:

1. invoke `bats ""`

**Expected behavior**
Exit 1 (or otherwise nonzero) as it would if the first argument were a file path or directory that did not exist.

**Environment (please complete the following information):**
 - Bats version: 1.12.0
 - operating system (including version): macOS 15.5
 - `bash --version`: `GNU bash, version 5.3.3(1)-release (aarch64-apple-darwin24.6.0)`
 - Install method: nixpkgs

**Additional context**
The invocation is, of course, nonsensical. But we ran into this in nixpkgs testing when a change caused something like `bats "$varName"` to start expanding to `bats ""`, and we didn't notice since the tests were still passing.

