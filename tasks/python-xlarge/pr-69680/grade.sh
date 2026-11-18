#!/bin/sh
# Mined pull request: its fail-to-pass tests, then the pass-to-pass tests of the test files it changed. Test ids are
# listed one per line. The sandbox has no ldconfig, so libstdc++ (pyzmq) and OpenSSL's libcrypto (salt.utils.rsax931) are
# found by hand.
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
PY=python; [ -x "$HOME/venv/bin/python" ] && PY=$HOME/venv/bin/python
run() { [ -s "$1" ] || return 0; tr '\n' '\0' < "$1" | xargs -0 "$PY" -m pytest -p no:cacheprovider -q; }
run "$TASK_DIR/fail_to_pass.txt"
run "$TASK_DIR/pass_to_pass.txt"
