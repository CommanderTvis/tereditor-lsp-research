# Oracle: which `_fingerprint` runs at dnsapi/dns_oci.sh:248

Derived without a language server, by running the shell.

    grep -nE '^_fingerprint\(\)' acme.sh dnsapi/*.sh deploy/*.sh notify/*.sh
    # acme.sh:1071 (certpath hashalg), dnsapi/dns_oci.sh:229 (privkey)
    bash -c '. ./acme.sh >/dev/null 2>&1; . dnsapi/dns_oci.sh; type _fingerprint'
    # prints the body with pkey="$1" and "Usage: _fingerprint privkey": the definition of dns_oci.sh

acme.sh sources the DNS hook inside a subshell (`( . "$d_api"; ... $addcommand ... )`, acme.sh:5863), after all of
acme.sh's own functions are defined, so within that subshell the hook's definition replaces the one from acme.sh, and
`dns_oci_add` -> `_signed_request` -> `_fingerprint` reaches `dnsapi/dns_oci.sh:229`.

No judgement call: the answer is the single definition in effect in the hook's process.
