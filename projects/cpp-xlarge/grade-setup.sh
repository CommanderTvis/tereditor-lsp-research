#!/bin/sh
# Measurement only (the project is skipped, see project.toml): can the grading toolchain configure and build
# PostgreSQL from its git tree? Reports the outcome on stderr and always exits 0, so ./study project does not retry.
{
  echo "== tools: $(for t in perl bison flex tclsh python3 meson ninja; do command -v $t >/dev/null 2>&1 && printf '%s ' $t; done)(present)"
  start=$(date +%s)
  if ./configure --without-icu --without-readline --without-zlib > /tmp/configure.log 2>&1; then
    echo "== configure: ok ($(( $(date +%s) - start )) s)"; grep -i -E 'warning|bison|flex|perl' /tmp/configure.log | head -20
    start=$(date +%s)
    if make -j 4 > /tmp/make.log 2>&1; then echo "== make: ok ($(( $(date +%s) - start )) s)"
    else echo "== make: FAILED after $(( $(date +%s) - start )) s"; grep -E -B3 -A3 'Error|error|missing|not found' /tmp/make.log | head -40; fi
  else
    echo "== configure: FAILED after $(( $(date +%s) - start )) s"; tail -25 /tmp/configure.log
  fi
} >&2
exit 0
