#!/bin/sh
# Builds headless tereditor at TEREDITOR_COMMIT with tereditor's own pinned toolchain (scripts/mise: the .NET SDK,
# Zig) into $1, plus the clangd that tereditor preinstalls on linux/arm64. Runs on an Ubuntu 24.04 root with network:
# the cloud VM itself, or the pinned ubuntu container of the container backends (./study does that).
set -eu
out=$1 commit=$2
[ -x "$out/tereditor-headless" ] && exit 0
export DEBIAN_FRONTEND=noninteractive
command -v git >/dev/null && command -v curl >/dev/null && command -v zstd >/dev/null \
  || { apt-get update -q && apt-get install -y -q --no-install-recommends git curl ca-certificates zstd libicu74 >/dev/null; }
src=$(mktemp -d)
git -C "$src" init -q && git -C "$src" remote add origin https://github.com/CommanderTvis/tereditor.git
git -C "$src" fetch -q --depth 1 origin "$commit" && git -C "$src" checkout -q FETCH_HEAD
case "$(uname -m)" in x86_64) rid=linux-x64 ;; aarch64) rid=linux-arm64 ;; *) echo "unsupported $(uname -m)" >&2; exit 1 ;; esac
mkdir -p "$out.tmp"
(cd "$src" && sh scripts/mise x -- dotnet publish src/Tereditor.Host.Headless -c Release -r "$rid" -o "$out.tmp")
if [ "$rid" = linux-arm64 ]; then
  # Mirrors the clangd stage of tereditor's docker/headless/Dockerfile: LLVM's pinned arm64 build, clangd and headers.
  url=https://github.com/llvm/llvm-project/releases/download/llvmorg-23.1.5/LLVM-23.1.5-Linux-ARM64.tar.zst
  sha=830ceb70edf63849ce66e97bf85310a3bf2bdd04c860a9f2fa4ef1560e290cef
  curl -fsSL --retry 3 -o "$src/llvm.tar.zst" "$url" && echo "$sha  $src/llvm.tar.zst" | sha256sum -c - >/dev/null
  mkdir -p "$out.tmp/preinstalled/clangd"
  zstd -dc --long=30 "$src/llvm.tar.zst" | tar -x -C "$out.tmp/preinstalled/clangd" --strip-components=1 --wildcards '*/bin/clangd' '*/lib/clang/*/include'
  printf '{"sha256":"%s","url":"%s"}' "$sha" "$url" > "$out.tmp/preinstalled/clangd/.tereditor-artifact.json"
fi
rm -rf "$src" "$out" && mv "$out.tmp" "$out"
