#!/bin/sh
# Fail to pass and pass to pass: the test files the pull request changed (mocha runs every case in them, on sql.js).
set -e
sh /project/check.sh test/functional/entity-metadata-validator/basic/entity-metadata-validator \
  test/functional/entity-metadata-validator/initialized-relations/validator-intialized-relations \
  test/functional/persistence/persistence-order/persistence-order \
  test/functional/relations/eager-relations/circular-eager-relations/circular-eager-relations \
  test/functional/util/ImportUtils test/github-issues/6284/issue-6284
