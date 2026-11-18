previously used node version is not removed from the PATH variable

<!-- Thank you for being interested in nvm! Please help us by filling out the following form if you‘re having trouble. If you have a feature request, or some other question, please feel free to clear out the form. Thanks! -->

#### Operating system and version:
macOS

#### `nvm debug` output:

<!-- do not delete the following blank line -->

```sh
nvm --version: v0.40.2
$TERM_PROGRAM: vscode
$SHELL: /bin/zsh
$SHLVL: 1
whoami: 'user'
${HOME}: /Users/user
${NVM_DIR}: '${HOME}/.nvm'
${PATH}: ${NVM_DIR}/versions/node/v20.19.0/bin:${NVM_DIR}/versions/node/v22.14.0/bin:${NVM_DIR}/versions/node/v22.14.0/bin:${NVM_DIR}/versions/node/v20.19.0/bin:${HOME}/.pixi/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/opt/X11/bin:/Library/Apple/usr/bin:/usr/local/share/dotnet:~/.dotnet/tools:${HOME}/.pixi/bin:${HOME}/Library/pnpm:${NVM_DIR}/versions/node/v18.20.6/bin:${HOME}/.cargo/bin:${HOME}/Library/Application Support/JetBrains/Toolbox/scripts:${HOME}/.spicetify:${HOME}/Library/Application Support/JetBrains/Toolbox/scripts:${HOME}/.spicetify
$PREFIX: ''
${NPM_CONFIG_PREFIX}: ''
$NVM_NODEJS_ORG_MIRROR: ''
$NVM_IOJS_ORG_MIRROR: ''
shell version: 'zsh 5.9 (arm64-apple-darwin24.0)'
uname -a: 'Darwin 24.3.0 Darwin Kernel Version 24.3.0: Thu Jan 2 20:24:24 PST 2025; root:xnu-11215.81.4~3/RELEASE_ARM64_T6030 arm64'
checksum binary: 'sha256sum'
OS version: macOS 15.3.2 24D81
awk: /usr/bin/awk, awk version 20200816
curl: /usr/bin/curl, curl 8.7.1 (x86_64-apple-darwin24.0) libcurl/8.7.1 (SecureTransport) LibreSSL/3.3.6 zlib/1.2.12 nghttp2/1.63.0
wget: /opt/homebrew/bin/wget, GNU Wget 1.25.0 built on darwin24.1.0.
sed: /usr/bin/sed
cut: /usr/bin/cut
basename: /usr/bin/basename
rm: /bin/rm
mkdir: /bin/mkdir
xargs: /usr/bin/xargs
git: /usr/bin/git, git version 2.39.5 (Apple Git-154)
grep: /usr/bin/grep, grep (BSD grep, GNU compatible) 2.6.0-FreeBSD
nvm current: v20.19.0
which node: ${NVM_DIR}/versions/node/v20.19.0/bin/node
which iojs: iojs not found
which npm: ${NVM_DIR}/versions/node/v20.19.0/bin/npm
npm config get prefix: ${NVM_DIR}/versions/node/v20.19.0
npm root -g: ${NVM_DIR}/versions/node/v20.19.0/lib/node_modules
```
</details>

#### `nvm ls` output:
<details>
<!-- do not delete the following blank line -->

```sh
->     v20.19.0
       v22.14.0
default -> 20 (-> v20.19.0)
iojs -> N/A (default)
unstable -> N/A (default)
node -> stable (-> v22.14.0) (default)
stable -> 22.14 (-> v22.14.0) (default)
lts/* -> lts/jod (-> v22.14.0)
lts/argon -> v4.9.1 (-> N/A)
lts/boron -> v6.17.1 (-> N/A)
lts/carbon -> v8.17.0 (-> N/A)
lts/dubnium -> v10.24.1 (-> N/A)
lts/erbium -> v12.22.12 (-> N/A)
lts/fermium -> v14.21.3 (-> N/A)
lts/gallium -> v16.20.2 (-> N/A)
lts/hydrogen -> v18.20.8 (-> N/A)
lts/iron -> v20.19.0
lts/jod -> v22.14.0
```
</details>

#### How did you install `nvm`?
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

#### What steps did you perform?
nvm install 20
nvm install 22
nvm use 20

#### What happened?
PATH variable is polluted with bin paths of the previously used node.

#### What did you expect to happen?
PATH to only contain selected node

#### Is there anything in any of your profile files that modifies the `PATH`?
<!--  (e.g. `.bashrc`, `.bash_profile`, `.zshrc`, etc) -->
no


