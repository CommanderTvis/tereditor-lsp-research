#!/bin/bash
. "$(dirname "$0")/common.sh"
emit_context SessionStart "REMINDER: for symbol work use the tereditor language tools: lsp_navigate (definition, references, implementation, incomingCalls, symbols, workspaceSymbols) instead of Grep/grep/rg; lsp_rename for renames; lsp_diagnostics on every edited file before you finish (there is no compiler here). Do NOT fall back to text search for symbols. If a call answers initializing, call it again."
