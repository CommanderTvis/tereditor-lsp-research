The helper `bats_trim` in `lib/bats-core/common.bash` takes the name of the output variable first and the string
second (`bats_trim <output-variable> <string>`). We want the string first:

    bats_trim <string> <output-variable>

Change the function and update every caller in the code base (library, scripts and tests) so that bats behaves
exactly as before. Update the parameter comment on the definition too. Do not add a compatibility wrapper for the old
order.
