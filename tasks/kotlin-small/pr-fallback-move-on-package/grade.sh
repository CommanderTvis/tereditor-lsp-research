#!/bin/sh
# On.kt is moved (old path gone, new path present, new package); onOk and onErr are declared only there (no forwarding
# copies left in the old package); then everything builds and the tests, with the hidden one in the new package, pass.
r=kotlin-result/src/commonMain/kotlin/com/github/michaelbull/result
[ ! -e "$r/On.kt" ] || { echo "grade: On.kt is still in the old directory"; exit 1; }
grep -qx 'package com.github.michaelbull.result.on' "$r/on/On.kt" || { echo "grade: on/On.kt missing or wrong package"; exit 1; }
decl=$(grep -rlE 'fun <V, E> Result<V, E>\.(onOk|onErr)\(' --include=*.kt . | sort -u)
[ "$decl" = "./$r/on/On.kt" ] || { echo "grade: onOk/onErr declared in: $decl"; exit 1; }
sh /project/check.sh
