#!/bin/sh
# The package and its tests compile (every implementation and call site uses the new order), then the check
# constraint tests on sql.js: the hidden test (new argument order) and the existing ones that call it.
set -e
sh /project/check.sh test/functional/query-runner/study-hidden-check-constraint-order.test \
  test/functional/query-runner/create-check-constraint.test \
  test/functional/schema-builder/foreign-key/constraint-names-sqlite test/unit
