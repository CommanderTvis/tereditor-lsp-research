Rename Redis's own `sdsnewlen` (declared in `src/sds.h`, defined in `src/sds.c`) to `sdsnewbuf`, at every call site
and every mention in comments of the server, the tools in `src/` and the modules in `modules/` and `tests/modules/`.
Do not keep the old name as an alias or macro. The vendored libraries under `deps/` have their own SDS implementation,
which keeps its names; do not modify anything under `deps/`.
