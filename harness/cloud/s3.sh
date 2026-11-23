# Sourced (POSIX sh) by `./study cloud` and harness/cloud/child.sh: a curl-only client for an S3-compatible bucket
# (curl 7.75 or later, for --aws-sigv4). Needs S3_ENDPOINT (the bucket's own URL, virtual-hosted style, e.g.
# https://<bucket>.s3.<region>.<provider>), S3_REGION, S3_ACCESS and S3_SECRET. The key pair reaches curl through a
# config on its stdin, never on its command line, so it does not show in the process list.

s3_check() {
  for v in S3_ENDPOINT S3_REGION S3_ACCESS S3_SECRET; do
    eval "[ -n \"\${$v:-}\" ]" || { echo "s3: $v is not set" >&2; return 2; }
  done
  command -v curl >/dev/null 2>&1 || { echo "s3: curl is missing" >&2; return 2; }
}

# s3_curl <curl arguments...>: one signed request. Transient failures (timeouts, 429, 5xx) are retried.
s3_curl() {
  printf 'user = "%s:%s"\n' "$S3_ACCESS" "$S3_SECRET" \
    | curl -sS --fail -K - --aws-sigv4 "aws:amz:$S3_REGION:s3" --retry 5 --retry-connrefused --retry-max-time 600 "$@"
}
# s3_put <file> <key>: upload, retrying every error (a missing bucket or a wrong key fails after the retries).
s3_put() { s3_curl --retry-all-errors -T "$1" "${S3_ENDPOINT%/}/$2" >/dev/null; }
# s3_get <key> <file>: download a key that must exist, retrying every error; the file appears only when complete.
s3_get() { s3_curl --retry-all-errors -o "$2.part" "${S3_ENDPOINT%/}/$1" && mv "$2.part" "$2" || { rm -f "$2.part"; return 1; }; }
# s3_try <key>: print a key that may not exist (fails at once on 404, still retries transient errors).
s3_try() { s3_curl "${S3_ENDPOINT%/}/$1" 2>/dev/null; }

# json_field <name>: a string field of the one-line status.json files of harness/cloud/child.sh (no jq needed).
json_field() { sed -n "s/.*\"$1\":\"\([^\"]*\)\".*/\1/p" | head -n1; }
# sha256_of <file>: the hex digest, with GNU coreutils or macOS.
sha256_of() { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1"; else shasum -a 256 "$1"; fi | cut -d' ' -f1; }
