For consistency with how we build schema objects, `QueryRunner.createCheckConstraint` should take the check
constraint first and the table second: `createCheckConstraint(checkConstraint, tableOrName)` instead of
`createCheckConstraint(tableOrName, checkConstraint)`.

Change the declaration in the `QueryRunner` interface (`packages/typeorm/src/query-runner/QueryRunner.ts`), every
query runner that implements it, and every call of it in the code base, including the tests and the test
migrations, so that the package compiles and the tests pass. Do not keep an overload or fallback for the old
argument order. Updating the documentation is optional.
