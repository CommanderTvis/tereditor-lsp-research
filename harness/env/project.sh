# project.sh <project> [commit...]: for the project's pinned commit and every base commit its tasks name (or the given
# commits): the snapshot (agent instruction files removed, one commit), the server-side preparation (prepare.sh), and
# the grading dependencies (grade-setup.sh), each once per commit.
set -eu
. "$STUDY_ROOT/harness/env/lib.sh"
proj=$1; shift; pd=$STUDY_ROOT/projects/$proj
repo=$(toml_val "$pd/project.toml" repo); pinned=$(project_commit "$proj")
[ -n "$repo" ] && [ -n "$pinned" ] || die "$pd/project.toml needs repo and commit"
if [ $# -eq 0 ]; then
  set -- $( { echo "$pinned"; for t in "$STUDY_ROOT/tasks/$proj"/*/; do [ -f "$t/task.toml" ] && task_commit "$proj" "${t%/}"; done; } | sort -u)
fi
for commit in "$@"; do
st=$(state_dir "$proj" "$commit")
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
    # Package registries behind shared egress IPs rate-limit by answering 404 with retry-after, and Maven then records the
    # artifact as absent: retry with -U (ignore cached failures); what was downloaded stays in the grade home.
    GRADE_BINDS+=(--setenv MAVEN_ARGS -U)
    for try in 1 2 3 4 5 6; do
      if ( grade_exec net "$st/snapshot" "$st/grade-home" /bin/sh /project/grade-setup.sh ); then break; fi
      [ "$try" -lt 6 ] || die "grade-setup.sh of $proj failed $try times"
      log "grade-setup.sh of $proj failed (attempt $try); retrying in 120 s"; sleep 120
    done
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
log "project $proj ready at $commit"
done
