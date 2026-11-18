nvm_err fails when stderr is closed

<!-- Thank you for being interested in nvm! Please help us by filling out the following form if you‘re having trouble. If you have a feature request, or some other question, please feel free to clear out the form. Thanks! -->

#### Operating system and version:

#### `nvm debug` output:
<details>
<!-- do not delete the following blank line -->

```sh
nvm --version: v0.40.6
$SHELL: /bin/bash
$SHLVL: 1
whoami: 'bas'
${HOME}: /home/bas
${NVM_DIR}: '${HOME}/.nvm'
${PATH}: ${HOME}/.local/share/mise/shims:/usr/x86_64-pc-linux-gnu/libexec/rbenv/shims:${NVM_DIR}/versions/node/v24.19.0/bin:${HOME}/.local/bin:${HOME}/.cargo/bin:/usr/local/bin:/usr/host/bin:/opt/bin:/usr/x86_64-pc-linux-gnu/lib/jdk/bin:/usr/x86_64-pc-linux-gnu/lib/jre/bin
$PREFIX: ''
${NPM_CONFIG_PREFIX}: ''
$NVM_NODEJS_ORG_MIRROR: ''
$NVM_IOJS_ORG_MIRROR: ''
shell version: 'GNU bash, version 5.3.15(1)-release (x86_64-pc-linux-gnu)'
uname -a: 'Linux 7.1.8 #1 SMP PREEMPT Mon Aug 10 08:02:27 UTC 2026 x86_64 GNU/Linux'
checksum binary: 'sha256sum'
OS version: {ANSI_COLOR}{PRETTY_NAME} - .,  ,
awk: /usr/host/bin/awk, GNU Awk 5.4.1, API 4.1, PMA Avon 8-g1, (GNU MPFR 4.2.2, GNU MP 6.3.0)
curl: /usr/host/bin/curl, curl 8.21.0 (x86_64-pc-linux-gnu) libcurl/8.21.0 OpenSSL/3.5.7 zlib/1.3.2 zstd/1.5.7 libidn2/2.3.8 libssh2/1.11.1 nghttp2/1.70.0
wget: /usr/host/bin/wget, GNU Wget 1.25.0 built on linux-gnu.
git: /usr/host/bin/git, git version 2.55.0
grep: /usr/host/bin/grep (grep --color=auto), grep (GNU grep) 3.12
sed: /usr/host/bin/sed, sed (GNU sed) 4.10
cut: /usr/host/bin/cut, cut (GNU coreutils) 9.11
basename: /usr/host/bin/basename, basename (GNU coreutils) 9.11
rm: /usr/host/bin/rm, rm (GNU coreutils) 9.11
mkdir: /usr/host/bin/mkdir, mkdir (GNU coreutils) 9.11
xargs: /usr/host/bin/xargs, xargs (GNU findutils) 4.11.0
nvm current: v24.19.0
which node: ${NVM_DIR}/versions/node/v24.19.0/bin/node
which iojs: which: no iojs in (${HOME}/.local/share/mise/shims:/usr/x86_64-pc-linux-gnu/libexec/rbenv/shims:${NVM_DIR}/versions/node/v24.19.0/bin:${HOME}/.local/bin:${HOME}/.cargo/bin:/usr/local/bin:/usr/host/bin:/opt/bin:/usr/x86_64-pc-linux-gnu/lib/jdk/bin:/usr/x86_64-pc-linux-gnu/lib/jre/bin)
which npm: ${NVM_DIR}/versions/node/v24.19.0/bin/npm
npm config get prefix: ${NVM_DIR}/versions/node/v24.19.0
npm root -g: ${NVM_DIR}/versions/node/v24.19.0/lib/node_modules
```
</details>

#### `nvm ls` output:
<details>
<!-- do not delete the following blank line -->

```sh
         v4.9.1
        v6.17.1
        v8.17.0
       v10.24.1
      v12.22.12
       v14.21.3
       v16.20.2
       v18.20.8
       v20.20.2
       v22.23.2
->     v24.19.0
        v26.7.0
         system (-> v24.19.0)
default -> 24 (-> v24.19.0)
iojs -> N/A (default)
unstable -> N/A (default)
node -> stable (-> v26.7.0) (default)
stable -> 26.7 (-> v26.7.0) (default)
lts/* -> lts/krypton (-> v24.19.0)
lts/argon -> v4.9.1
lts/boron -> v6.17.1
lts/carbon -> v8.17.0
lts/dubnium -> v10.24.1
lts/erbium -> v12.22.12
lts/fermium -> v14.21.3
lts/gallium -> v16.20.2
lts/hydrogen -> v18.20.8
lts/iron -> v20.20.2
lts/jod -> v22.23.2
lts/krypton -> v24.19.0
```
</details>

#### How did you install `nvm`?
<!-- (e.g. install script in readme, Homebrew) -->
Internal distribution package

#### What steps did you perform?

In a much larger Ruby script:
```ruby
IO.popen(["bash", "-l", "-c", "nvm install v21.7.0"], err: :close, &:read)
```

#### What happened?

The 21.7.0 version was not installed

#### What did you expect to happen?

The 21.7.0 version to be installed

#### Is there anything in any of your profile files that modifies the `PATH`?
<!--  (e.g. `.bashrc`, `.bash_profile`, `.zshrc`, etc) -->

Yes, but it is not related


### My findings

The previous version we used (0.40.4) worked fine, and I bisected the issue to bda39c7c04ee0c34cad272fea3fc54e71f6ad710.
But it is *not* the actual culprit. It only activated the code path where the issue happening was reported.

My next debugging step was to check `stderr`, and it actually “fixed” the issue so I checked each patch chunk from the commit and without much surprise, the checksum step was the one that “failed”.

Since the issue appeared only when closing `stderr`, I checked any part of `nvm.sh` that would try to write to it.  
Commenting the `nvm_err 'Computing checksum with sha256sum'` and `nvm_err 'Checksums matched!'` lines from `nvm_compute_checksum` and `nvm_compare_checksum` indeed fixed my issue.

It is quite common in Ruby and other non-Shell scripting languages to actually close `stderr` (not redirecting to `/dev/null`) so I would consider a fix in `nvm_err` not to fail the entire operation when `stderr` is closed.

We will workaround with a `/dev/null` redirection for now.
