#!/bin/sh
exec >/cache/prepare.log 2>&1
for c in bash curl wget tar gzip python3 git; do command -v $c || echo "no $c"; done
ls /bin | head -80 | tr '\n' ' '
