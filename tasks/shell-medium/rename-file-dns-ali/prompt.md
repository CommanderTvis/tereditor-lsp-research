Rename the Alibaba Cloud DNS hook `dnsapi/dns_ali.sh` to `dnsapi/dns_aliyun.sh`, so that it is selected with
`--dns dns_aliyun`. acme.sh derives the names it calls from the hook's file name, so the hook's entry points and its
info variable have to follow the new name (`dns_aliyun_add`, `dns_aliyun_rm`, `dns_aliyun_info`), and every other
script in the repository that loads this hook must load it under the new name. The private helpers inside the file
keep their names. Nothing may remain at the old path, and no `dns_ali_*` alias is wanted.
