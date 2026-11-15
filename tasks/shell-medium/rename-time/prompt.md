Rename the helper function `_time` in `acme.sh` (it prints the current Unix time) to `_unix_time`, everywhere it is
defined or called: in `acme.sh` itself and in the hook scripts under `dnsapi/`, `deploy/` and `notify/` that acme.sh
sources. Do not keep `_time` as an alias, and do not rename anything else (for example `_time2str`, or variables whose
names merely contain `_time`).
