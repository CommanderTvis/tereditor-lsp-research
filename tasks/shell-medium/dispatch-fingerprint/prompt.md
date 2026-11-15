`dnsapi/dns_oci.sh` calls `_fingerprint "$OCI_CLI_KEY"` inside `_signed_request` (line 248). More than one function
named `_fingerprint` exists in this repository. When acme.sh issues a certificate with `--dns dns_oci` and that call
is reached, which definition runs?

Write the answer to `ANSWER.txt` in the repository root: one line, the location of the definition's first line (the
line with `_fingerprint() {`) as `relative/path:LINE` (1-based), for example `deploy/foo.sh:12`.
