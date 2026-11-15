Add function to ensure minimal bats version

**Is your feature request related to a problem? Please describe.**
I would like to use a new Bats feature or behavior (specifically the global variable `$BATS_FILE_TMPDIR`) and I want to make sure that the version of Bats that's running the test actually has this capability.

**Describe the solution you'd like**
Add a new global variable (e.g. `$BATS_VERSION`) that can be used in a test to do whatever is needed. It would hold the release version of the Bats executable that's running the test. With it I could write something like this:

```
setup() {
    # require 1.6.0 or later
    batsver=( ${BATS_VERSION//./ } )
    if [[ ((${batsver[0]} -eq 1) && (${batsver[1]} -lt 6)) || (${batsver[0]} -lt 1) ]]; then
        skip "Minimum Bats version required: 1.6.0 (running: $BATS_VERSION)"
    fi
}

```

**Describe alternatives you've considered**
Alternately, there could be a new assertion that could be run to ensure a minimum version is being used to execute the test, similar to Perl's `use 5.008;` mechanism, e.g.

```
@test "Bats version check" {
   assert_version "1.6.0"
}
```

Adding a new assert function is not to be done lightly, though, and the variable allows more control (skipping if used in `setup` as I have it, or aborting if used in `setup_file` with an `exit`).

**Additional context**
none
