# CLAUDE.md

## Code intelligence: use the language tools, not grep

This codebase is too large for grep-based symbol work. Symbol search, references, implementations, call hierarchy,
diagnostics and renames go through the language server, which the `tereditor` MCP server exposes:

1. `lsp_navigate` for every question about a symbol: `definition`, `references`, `implementation`, `hover`,
   `incomingCalls`/`outgoingCalls`, `symbols` (outline of a file), `workspaceSymbols`. Name the symbol in `query`;
   no position is needed.
2. `lsp_diagnostics` with `paths` listing every file you edited, before you declare the work done. There is no
   compiler here: diagnostics are the only type check you have.
3. `lsp_rename` for renames and `lsp_code_actions` for quick fixes, instead of hand-editing every occurrence.
4. Do not degrade to `grep`/`rg`/Grep for symbol work: text search misses implementations, overrides and
   indirection, and matches comments and unrelated names. Plain text search remains fine for string literals,
   comments, configuration, documentation and file types without a language server.
5. A call that answers `initializing` means the server is still starting: call again; it is never "no results".

Hooks in `.claude/settings.json` reinforce this: a session-start reminder, advisory nudges when text search looks like
symbol work or when a source file is edited, and a stop check that edited source files were checked with
`lsp_diagnostics`.
