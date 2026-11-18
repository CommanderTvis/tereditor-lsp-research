#!/bin/sh
# Refactoring check for salt: byte-compile the package, then the hidden structural test. (Salt's own suite needs
# services and takes hours; `python -m pytest tests/pytests/unit/test_payload.py` is not run for the renamed module.)
set -e
export LD_LIBRARY_PATH=$(ls -d /nix/store/*-gcc-*-lib/lib 2>/dev/null | head -n1)
export OPENSSL_LIBDIR=$(ls -d /nix/store/*-openssl-3*/lib 2>/dev/null | grep -v dev | head -n1)
mkdir -p /tmp/sc; cat > /tmp/sc/sitecustomize.py <<'EOF'
import os, ctypes.util as u
_f = u.find_library
def find_library(n):
    if n in ("crypto", "ssl"):
        return os.path.join(os.environ["OPENSSL_LIBDIR"], "lib%s.so.3" % n)
    return _f(n)
u.find_library = find_library
EOF
export PYTHONPATH=/tmp/sc
PY=$HOME/venv/bin/python
$PY -m compileall -q salt > /dev/null
$PY -m pytest -p no:cacheprovider -q tests/pytests/unit/test_study_hidden_payload.py
