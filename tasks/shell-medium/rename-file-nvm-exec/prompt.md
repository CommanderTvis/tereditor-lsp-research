Rename the script `nvm-exec` (repository root) to `nvm-runner`, and update everything that refers to the file: what `nvm.sh`
runs, the installer (`install.sh`: the download URL, the file name it downloads, installs and marks executable, the lists
of files it handles), the test suites under `test/` that run, copy or check the file, the CI workflow and the
comments and documentation that name it.

The install method name `script-nvm-exec` is a public setting value and keeps its name, and so do the messages that the
script prints about itself (they start with `nvm-exec:`). Nothing may remain at the old path and no copy or wrapper
under the old name is wanted. The test suites must still pass; a test file may keep its file name.
