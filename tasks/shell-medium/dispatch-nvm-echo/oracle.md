# Oracle: which `nvm_echo` runs at install.sh:432

Derived by running bash (extdebug reports where a function was defined), not with a language server:

    bash -c 'shopt -s extdebug; NVM_ENV=testing . ./install.sh; declare -F nvm_echo; . ./nvm.sh >/dev/null 2>&1; declare -F nvm_echo'
    # nvm_echo 21 ./install.sh      (before nvm.sh is sourced)
    # nvm_echo 21 ./nvm.sh          (after)

`nvm_do_install` sources nvm.sh at install.sh:559 (`\. "$(nvm_install_dir)/nvm.sh"`) and only then calls
`nvm_check_global_modules` and `nvm_install_node`, so the `nvm_echo` calls inside them (lines 249 to 257 and 426 to 441)
run the definition of nvm.sh, which replaced the installer's own. Calls made earlier in `nvm_do_install` (for example line 525)
run install.sh's. Both definitions start at line 21 of their file, so only the file distinguishes the answers.
No judgement call.
