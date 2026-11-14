# project.sh <project>: the project's snapshot (pinned commit, agent instruction files removed, one commit), the
# server-side preparation (prepare.sh), and the grading dependencies (grade-setup.sh), each once.
set -eu
. "$STUDY_ROOT/harness/env/lib.sh"
proj=$1; pd=$STUDY_ROOT/projects/$proj; st=$STUDY_STATE/projects/$proj
toml() { sed -n "s/^$1[[:space:]]*=[[:space:]]*\"\{0,1\}\([^\"]*\)\"\{0,1\}[[:space:]]*\$/\1/p" "$pd/project.toml" | head -n1; }
repo=$(toml repo); commit=$(toml commit)
[ -n "$repo" ] && [ -n "$commit" ] || die "$pd/project.toml needs repo and commit"
mkdir -p "$st"
g() { git -c user.name=study -c user.email=study@localhost "$@"; }
if [ ! -f "$st/.snapshot" ]; then
  log "snapshot $repo@$commit"
  rm -rf "$st/snapshot" && mkdir -p "$st/snapshot" && cd "$st/snapshot"
  g init -q . && g remote add origin "$repo" && g fetch -q --depth 1 origin "$commit" && g checkout -q FETCH_HEAD
  rm -rf .git
  for p in CLAUDE.md AGENTS.md GEMINI.md .claude .cursor .cursorrules copilot-instructions.md .windsurfrules .tereditor \
           .mcp.json .vscode .idea .junie .continue .clinerules; do
    find . -name node_modules -prune -o -name "$p" -prune -exec rm -rf {} +
  done
  find . -name '.aider*' -prune -exec rm -rf {} +
  g init -q -b main . && g add -A && g commit -qm snapshot
  touch "$st/.snapshot"
fi
if [ ! -f "$st/.prepared" ]; then
  tmp=$(mktemp -d); mkdir -p "$tmp/log" "$tmp/lic"
  if [ -s "$pd/prepare.sh" ]; then
    log "prepare $proj (server side)"; cp "$pd/prepare.sh" "$tmp/log/prepare.sh"
    ( server_exec enforced "$st/snapshot" "$tmp/log" "$tmp/lic" /bin/sh /study/harness/prepare.sh )
  fi
  rm -rf "$tmp"; touch "$st/.prepared"
fi
if [ ! -f "$st/.grade-ready" ]; then
  mkdir -p "$st/grade-home"
  if [ -s "$pd/grade-setup.sh" ]; then
    log "grading dependencies of $proj"
    scratch=$STUDY_STATE/scratch/$proj-setup; rm -rf "$scratch"; mkdir -p "$scratch"; cp -a "$st/snapshot" "$scratch/work"
    GRADE_BINDS=(--ro-bind "$pd" /project --bind "$scratch" /scratch --chdir /scratch/work)
    ( grade_exec net "$st/snapshot" "$st/grade-home" /bin/sh /project/grade-setup.sh )
    # Dependencies installed into the tree (vendor/, node_modules/, obj/) are what git ignores there: kept as the overlay
    # that grading copies into its work tree.
    rm -rf "$st/grade-overlay"; mkdir -p "$st/grade-overlay"
    git -C "$scratch/work" status --ignored --porcelain=v1 | sed -n 's/^!! //p' | while IFS= read -r f; do
      mkdir -p "$st/grade-overlay/$(dirname "$f")" && cp -a "$scratch/work/$f" "$st/grade-overlay/$f"
    done
    rm -rf "$scratch"
  fi
  touch "$st/.grade-ready"
fi
log "project $proj ready"
