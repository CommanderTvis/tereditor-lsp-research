#!/bin/sh
# Salt's own unit tests: its runtime requirements (base, zeromq, crypto) and the test tools (requirements/pytest.txt),
# installed once into the grading home's virtual environment (CPython 3.12). Salt itself is imported from the work tree.
# timelib has no wheel for this platform and the grading sandbox has no compiler, so it is left out (Salt treats it as
# optional); a requirement that cannot be installed is skipped, the others are kept.
set -e
python -m venv "$HOME/venv"
P="$HOME/venv/bin/python -m pip install -q --disable-pip-version-check --no-input"
$P --upgrade pip setuptools wheel
: > /tmp/salt-req.txt
for r in base zeromq crypto pytest; do [ -f "requirements/$r.txt" ] && cat "requirements/$r.txt" >> /tmp/salt-req.txt; echo >> /tmp/salt-req.txt; done
grep -v '^[[:space:]]*#' /tmp/salt-req.txt | grep -v '^[[:space:]]*-[rc]' | grep -vi '^[[:space:]]*timelib' | grep -v '^[[:space:]]*$' | sort -u > /tmp/salt-flat.txt
$P -r /tmp/salt-flat.txt || { echo "grade-setup: joint install failed, installing line by line" >&2
  while IFS= read -r l; do $P "$l" || echo "skipped: $l" >&2; done < /tmp/salt-flat.txt; }
