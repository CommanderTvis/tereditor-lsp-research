# fetch-tereditor.sh <out-dir>: the headless tereditor of the pinned release (harness/tereditor.env) for this machine's
# architecture, checked against its sha256.
set -eu
out=$1
. "$STUDY_ROOT/harness/tereditor.env"
case "$(uname -m)" in
  x86_64) arch=x64 sum=$TEREDITOR_SHA256_X64 ;; aarch64) arch=arm64 sum=$TEREDITOR_SHA256_ARM64 ;;
  *) echo "unsupported $(uname -m)" >&2; exit 1 ;;
esac
url=https://github.com/CommanderTvis/tereditor/releases/download/$TEREDITOR_RELEASE/tereditor-headless-nightly-linux-$arch.tar.gz
t=$(mktemp -d)
curl -fsSL --retry 5 -o "$t/a.tar.gz" "$url"
[ "$(sha256sum "$t/a.tar.gz" | cut -d' ' -f1)" = "$sum" ] || { echo "sha256 mismatch for $url" >&2; exit 1; }
tar -xzf "$t/a.tar.gz" -C "$t"
[ -x "$t/tereditor-headless/tereditor-headless" ] || { echo "no tereditor-headless in $url" >&2; exit 1; }
rm -rf "$out" && mkdir -p "$(dirname "$out")" && mv "$t/tereditor-headless" "$out" && rm -rf "$t"
