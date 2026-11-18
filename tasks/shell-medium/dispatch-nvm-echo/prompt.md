`install.sh` calls the helper `nvm_echo` at line 432, inside `nvm_check_global_modules`. More than one function named `nvm_echo`
exists in this repository (`install.sh` and `nvm.sh` each define one). When the installer is run as
`bash install.sh` (for example by `curl ... | bash`), `nvm_do_install` reaches that line. Which definition of `nvm_echo`
is the one that runs there?

Write the answer to `ANSWER.txt` in the repository root: one line, the location of the first line of that definition
(the line with `nvm_echo() {`) as `relative/path:LINE` (1-based), for example `foo.sh:12`.
