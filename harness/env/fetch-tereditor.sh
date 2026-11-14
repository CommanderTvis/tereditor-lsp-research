# fetch-tereditor.sh <out-dir>: /opt/tereditor of the pinned image (harness/tereditor.env) for this machine's
# architecture, straight from the registry: no Docker, every manifest and layer checked against its sha256 digest.
set -eu
out=$1
. "$STUDY_ROOT/harness/tereditor.env"
case "$(uname -m)" in x86_64) arch=amd64 ;; aarch64) arch=arm64 ;; *) echo "unsupported $(uname -m)" >&2; exit 1 ;; esac
repo=${TEREDITOR_IMAGE#ghcr.io/}
token=$(curl -fsS "https://ghcr.io/token?scope=repository:$repo:pull" | jq -r .token)
get() { curl -fsSL -H "Authorization: Bearer $token" -H "Accept: $2" "https://ghcr.io/v2/$repo/$1"; }
check() { [ "sha256:$(sha256sum "$1" | cut -d' ' -f1)" = "$2" ] || { echo "digest mismatch for $2" >&2; exit 1; }; }
t=$(mktemp -d)
get "manifests/$TEREDITOR_DIGEST" 'application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.list.v2+json' > "$t/index"
check "$t/index" "$TEREDITOR_DIGEST"
m=$(jq -r --arg a "$arch" '.manifests[] | select(.platform.os == "linux" and .platform.architecture == $a) | .digest' "$t/index")
get "manifests/$m" 'application/vnd.oci.image.manifest.v1+json, application/vnd.docker.distribution.manifest.v2+json' > "$t/manifest"
check "$t/manifest" "$m"
mkdir -p "$t/root"
for l in $(jq -r '.layers[].digest' "$t/manifest"); do
  get "blobs/$l" '*/*' > "$t/layer"; check "$t/layer" "$l"
  if tar -tzf "$t/layer" 2>/dev/null | grep -q '^opt/tereditor/'; then tar -xzf "$t/layer" -C "$t/root" opt/tereditor; fi
done
[ -x "$t/root/opt/tereditor/tereditor-headless" ] || { echo "no tereditor-headless in $TEREDITOR_IMAGE@$TEREDITOR_DIGEST" >&2; exit 1; }
rm -rf "$out" && mkdir -p "$(dirname "$out")" && mv "$t/root/opt/tereditor" "$out" && rm -rf "$t"
