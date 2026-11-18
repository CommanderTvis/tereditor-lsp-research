Rename the shell function `nvm_resolve_alias`, defined in `nvm.sh`, to `nvm_follow_alias`, everywhere the repository
uses or mentions it: in `nvm.sh` (calls, comments, the lists of functions that are unset), in `install.sh`,
`bash_completion` and `nvm-exec` if they use it, in the test suites under `test/` and in the documentation.

Do not rename any other function (several other names start with `nvm_resolve_`), do not keep the old name as an alias or
wrapper, and keep nvm working exactly as before: its test suites must still pass. A test file may keep its file name.
