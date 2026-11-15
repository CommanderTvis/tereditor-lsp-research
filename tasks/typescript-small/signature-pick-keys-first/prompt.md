We want `pick` (in `src/structs/utilities.ts`) to take the list of keys first and the struct second, so that it
reads `pick(['id', 'name'], User)`. Change its signature from `pick(struct, keys)` to `pick(keys, struct)` and
update every call of it in the code base, including the tests, so that the type checks and tests pass. Do not keep
an overload or fallback for the old argument order. Updating the documentation is optional.
