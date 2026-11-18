nvm v0.40.6 does not load the default node version in zsh if the option extendedglob is set

<!-- Thank you for being interested in nvm! Please help us by filling out the following form if you‘re having trouble. If you have a feature request, or some other question, please feel free to clear out the form. Thanks! -->

#### Operating system and version:
Ubuntu 24.04.4 running under Windows 11 WSL and Debian Testing running natively. The following tests have been done on Ubuntu 24.04 WSL but can be replicated under any Linux distro.

#### `nvm debug` output:
<details>
<!-- do not delete the following blank line -->

```sh
nvm debug
nvm --version: v0.40.6
$SHELL: /bin/zsh
$SHLVL: 1
whoami: 'zara'
${HOME}: /home/zara
${NVM_DIR}: '${HOME}/.config/nvm'
${PATH}: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib:/mnt/c/Program Files/Common Files/Oracle/Java/javapath:/mnt/c/Windows/system32:/mnt/c/Windows:/mnt/c/Windows/System32/Wbem:/mnt/c/Windows/System32/WindowsPowerShell/v1.0/:/mnt/c/Windows/System32/OpenSSH/:/mnt/c/Users/beltrame/AppData/Local/Microsoft/WindowsApps, C:/MySql/php-5.6.28:/mnt/c/Users/beltrame/AppData/Local/Microsoft/WindowsApps, C:/php72:/mnt/c/laragon6/bin/php/php-8.2.27-Win32-vs16-x64:/mnt/c/Program Files/PuTTY/:/mnt/c/Program Files/BackupClient/CommandLineTool/:/mnt/c/Program Files (x86)/Common Files/Acronis/FileProtector/:/mnt/c/Program Files (x86)/Common Files/Acronis/FileProtector64/:/mnt/c/Program Files/BackupClient/PyShell/bin/:/mnt/c/Program Files (x86)/Common Files/Acronis/SnapAPI/:/mnt/c/ProgramData/chocolatey/bin:/mnt/c/tools/gsudo/Current:/mnt/c/Program Files/DDEV:/mnt/c/Program Files/NVIDIA Corporation/NVIDIA App/NvDLISR:/mnt/c/Program Files (x86)/NVIDIA Corporation/PhysX/Common:/mnt/c/WINDOWS/system32:/mnt/c/WINDOWS:/mnt/c/WINDOWS/System32/Wbem:/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/:/mnt/c/WINDOWS/System32/OpenSSH/:/mnt/c/Program Files/PowerShell/7/:/mnt/c/Users/zara/AppData/Local/Yarn/config/global/node_modules/.bin:/mnt/c/Users/zara/AppData/Local/Microsoft/WindowsApps:/mnt/c/Users/zara/AppData/Local/Programs/Microsoft VS Code/bin:/mnt/c/tools/dart-sdk/bin:/mnt/c/Users/zara/AppData/Local/Pub/Cache/bin:/mnt/c/Users/zara/AppData/Local/Microsoft/WindowsApps:/mnt/c/Users/zara/.lmstudio/bin:/mnt/c/Users/zara/AppData/Local/PowerToys/DSCModules/
$PREFIX: ''
${NPM_CONFIG_PREFIX}: ''
$NVM_NODEJS_ORG_MIRROR: ''
$NVM_IOJS_ORG_MIRROR: ''
shell version: 'zsh 5.9 (x86_64-ubuntu-linux-gnu)'
uname -a: 'Linux 6.18.33.2-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC Thu Jun 18 21:54:43 UTC 2026 x86_64 x86_64 x86_64 GNU/Linux'
checksum binary: 'sha256sum'
OS version: Ubuntu 24.04.4 LTS
awk: /usr/bin/awk, GNU Awk 5.2.1, API 3.2, PMA Avon 8-g1, (GNU MPFR 4.2.1, GNU MP 6.3.0)
curl: /usr/bin/curl, curl 8.5.0 (x86_64-pc-linux-gnu) libcurl/8.5.0 OpenSSL/3.0.13 zlib/1.3 brotli/1.1.0 zstd/1.5.5 libidn2/2.3.7 libpsl/0.21.2 (+libidn2/2.3.7) libssh/0.10.6/openssl/zlib nghttp2/1.59.0 librtmp/2.3 OpenLDAP/2.6.10
wget: /usr/bin/wget, GNU Wget 1.21.4 built on linux-gnu.
git: /usr/bin/git, git version 2.43.0
grep: /usr/bin/grep, grep (GNU grep) 3.11
sed: /usr/bin/sed, sed (GNU sed) 4.9
cut: /usr/bin/cut, cut (GNU coreutils) 9.4
basename: /usr/bin/basename, basename (GNU coreutils) 9.4
rm: /usr/bin/rm, rm (GNU coreutils) 9.4
mkdir: /usr/bin/mkdir, mkdir (GNU coreutils) 9.4
xargs: /usr/bin/xargs, xargs (GNU findutils) 4.9.0
nvm current: none
which node: node not found
which iojs: iojs not found
which npm: npm not found
npm config get prefix: nvm:276: command not found: npm
npm root -g: nvm:276: command not found: npm
```
</details>

#### `nvm ls` output:
<details>
<!-- do not delete the following blank line -->

```sh
nvm ls
       v24.18.0
iojs -> N/A (default)
unstable -> N/A (default)
node -> stable (-> v24.18.0) (default)
stable -> 24.18 (-> v24.18.0) (default)
```
</details>

#### How did you install `nvm`?
<!-- (e.g. install script in readme, Homebrew) -->
I'm using Debian Testing and WSL and I've installed nvm using the provided script in the README.md file, specifically with the following script, I've updated from version 0.40.5:

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.6/install.sh | bash
```

#### What steps did you perform?
I've tried both in the Debian Testing branch and Ubuntu 24.04.4 (installed through WSL), in my .zshrc config I set the option `extendedglob` very early in the file, if I do so, when I load the shell, nvm does not automatically load the default node version I have specified in the default alias (to check it I've run `npm --version`, if node is loaded npm should also be loaded). This issue only occurs in nvm version 0.40.6 and did not occur in 0.40.5. Here's the .zshrc file I've used for testing the issue:

```sh
export NVM_DIR="$HOME/.config/nvm"

setopt extendedglob       # Extended globbing. Allows using regular expressions with *

# Temporarily turn off extendedglob if it's enabled
# [[ -o extendedglob ]] && local reset_eg=1 && unsetopt extendedglob

# Load NVM safely
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Restore extendedglob
# [[ -n $reset_eg ]] && setopt extendedglob
```

Using the above config, loading a new shell session and running `npm --version` returns the following error:

```sh
npm --version
zsh: command not found: npm
```

On the other hand if I temporarily disable the extendedglob option right before loading nvm using the following config for .zshrc:

```sh
export NVM_DIR="$HOME/.config/nvm"

setopt extendedglob       # Extended globbing. Allows using regular expressions with *

# Temporarily turn off extendedglob if it's enabled
[[ -o extendedglob ]] && local reset_eg=1 && unsetopt extendedglob

# Load NVM safely
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Restore extendedglob
[[ -n $reset_eg ]] && setopt extendedglob
```

nvm correcly loads the default node version I have specified:

```sh
npm --version
12.0.1
```

#### What happened?
In nvm v0.40.6 the zsh option extendedglob makes the nvm load script not load the default node version, this did not happen in v0.40.5 and does not happen if I disable the extendedglob zsh option.

#### What did you expect to happen?
nvm should be able to load the default node version regardless of if the option extendedglob has been enabled in zsh.

#### Is there anything in any of your profile files that modifies the `PATH`?
<!--  (e.g. `.bashrc`, `.bash_profile`, `.zshrc`, etc) -->
No, the testing has been done with a fresh zsh configuration using the files provided above, no .zshenv or .zprofile files have been used for testing, only the .zshrc files I provided above.

</details>

