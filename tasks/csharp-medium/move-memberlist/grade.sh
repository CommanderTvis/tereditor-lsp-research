#!/bin/sh
# move: the enum is declared in its new file and namespace only; build and tests (with the hidden check that the
# compiled enum lives in AutoMapper.Core only).
set -e
f=src/AutoMapper/Core/MemberList.cs
[ -f "$f" ] || { echo "missing $f"; exit 1; }
grep -q 'namespace AutoMapper\.Core' "$f" && grep -q 'enum MemberList' "$f" || { echo "$f does not declare MemberList in AutoMapper.Core"; exit 1; }
! grep -q 'enum MemberList' src/AutoMapper/Configuration/IProfileExpression.cs || { echo "still declared in IProfileExpression.cs"; exit 1; }
sh /project/check.sh
