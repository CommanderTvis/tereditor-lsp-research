# Curating a language: instructions for whoever adds projects and tasks

You add the projects (`<lang>-small`, `<lang>-medium`, `<lang>-large`, and `<lang>-xlarge` where the language has one) of one language and their tasks, and you
prove each one valid. Read [TASKS.md](TASKS.md) first: it is the contract. `projects/python-small` and
`tasks/python-small/*` are the worked example; copy their shape.

## Choosing projects

- Real, well-known open-source projects in the language, pinned to a full commit SHA (a release tag's commit).
- Size classes from TASKS.md. Where a language has no credible project above 100k lines (shell, CSS), take the largest
  credible one and say so in `project.toml` (`size_note`).
- The project must build and its tests (or a meaningful subset) must pass in the grading sandbox, without network,
  within about 10 minutes on 4 CPUs, with its language group's toolchain (`grade-<group>` in `nix/flake.nix`; add a
  tool there if one is missing). `grade-setup.sh` fetches the dependencies once, with network: into the home directory
  (`~/.m2`, `~/.nuget`) or into the tree (`vendor/`, `node_modules/`, kept as an overlay copied into every grading work
  tree). `check.sh` builds and tests without network.
- The language server must be able to understand the project without a compiler in the agent's view: whatever it
  needs (restored packages for C#, `node_modules` type declarations for TypeScript, a `compile_commands.json` with
  paths under `/workspace` for clangd, resolved Gradle or Maven dependencies) comes from `prepare.sh`, which runs once
  in the server's sandbox in the snapshot (`/workspace`), with network and tereditor's managed runtimes under
  `/cache/managed`. What it produces must be git-ignored by the project, so it is not part of the agent's diff.
- Projects with heavy dynamic magic are fine (they are realistic) but write tasks whose ground truth is still
  unambiguous.

## Writing tasks

The counts and kinds per project are in [TASKS.md](TASKS.md): half synthetic (refactorings and a navigation question,
generated with a fixed seed by rules fixed in advance), half mined pull requests (the selection criteria are in
TASKS.md, "Mined pull requests"). Never choose or drop a task after seeing any run of it.

For each project, in this order:

1. Complete the project's files if it is a stub (`prepare.sh`, `grade-setup.sh`, `check.sh`, `probe.json`), then
   `./study setup <group>` (once per group) and `./study project <project>`.
2. Synthetic tasks: exactly the types the assignment table in TASKS.md gives the project. Pick each task's subject by
   a rule fixed before looking at candidates (for example: list every public symbol with at least N references in at
   least M files and a name shared with another symbol, sort them, take the k-th with k from the seeded shuffle
   `awk 'BEGIN{srand(20261110)}...'`); write the rule, the candidate count and the seed in the task's `task.toml`
   (`selection = "..."`). Existing tasks of an assigned type are kept; tasks of types no longer assigned are deleted
   (git history keeps them).
3. Mined tasks (modern pull requests, opened after 2026-07-01; read docs/MEMORIZATION.md first): `sh harness/gen/mine-prs.sh <project>` writes `tasks/<project>/pr-candidates.jsonl` in seeded order. For each candidate you consider, run `python3 harness/memprobe/memprobe.py <task-dir>` before accepting it (drop it under the thresholds of MEMORIZATION.md).
   Take candidates strictly in that order. For each, create `tasks/<project>/pr-<number>/` with `task.toml`
   (`type = "pr"`, `base_commit`, `merged_at`, `pr`, `issue`), `prompt.md` (the issue's title and body, unedited
   except for removing links to the fix), `gold.patch` (the pull request's non-test change, base to merge),
   `hidden/` (the post-merge versions of the test files it changed) and `grade.sh` (its fail-to-pass tests, then the
   pass-to-pass tests of the affected modules). `./study project <project>` sets up the base commit;
   `./study validate <project>` must print VALID. A candidate that does not build or validate with the current
   toolchains is skipped, and the reason goes into `tasks/<project>/pr-log.md`. Stop at the assigned number of valid
   tasks. If candidates run out, fill the remaining places with synthetic tasks of the next types in the rotation and
   record that in `project.toml`.
4. `./study probe <project>` (and `intellij-enforced` for JVM projects), recorded in `project.toml`.
5. `./study prune <project>` to free disk before the next project.

Xlarge projects may be too large to set up or grade on the available machine; then mark them
`status = "skipped"` in `project.toml` with the measured reason (memory, disk, time), rather than shrinking them.

- Make tasks realistic and discriminating: pick symbols whose names collide with other symbols, are overridden,
  re-exported, aliased, shadowed or reached through interfaces, so that text search alone is error-prone; and pick
  edits that ripple across several files. Do not pick tasks that only a language server could possibly solve; a
  careful engineer with grep and an editor must be able to solve every task.
- Medium and large projects should have tasks that touch at least 5 files or 10 locations.
- Prompts read like a ticket a developer would write. Never mention LSP, grep, IDEs, tools, or the expected count.
- Answer tasks: exact output format, scope rules for what counts (definition included or not, comments and strings
  excluded, generated code excluded), as in `tasks/python-small/refs-get/prompt.md`.
- Edit tasks: `setup.patch` (created with `git diff` on a clean checkout at the pinned commit) creates the starting
  state; `gold.patch` is the reference fix on top of it; `hidden/` holds held-out tests copied in at grade time;
  `grade.sh` (optional) adds task-specific checks, then calls `sh /project/check.sh`.
- Oracles never come from the language server under test (see TASKS.md). Write `oracle.md`.

## Proving it

Build and check with the driver (Apple `container` is the runtime on this machine; `STUDY_RUNTIME=container`):

```sh
./study setup <group>              # once per language group (python, typescript, csharp, php, jvm, cpp, shell, css)
./study project <lang>-small
./study probe <lang>-small         # results/probe/<lang>-small-enforced/probe.jsonl
./study validate <lang>-small      # every line must say VALID
```

- `validate` must print `VALID` for every task: the starting state fails, the gold solution passes twice.
- `probe.json` holds 3 to 5 calls with known answers: at least one cross-file `references`, one `definition` and one
  `lsp_diagnostics` on a file. Record the outcome in `project.toml` under `[probe]`: `ok = true|false`, the seconds
  to the first non-`initializing` answer, and what was wrong if it failed. A failed probe is a finding, not a reason
  to drop the project: keep it and describe the failure precisely.
- Do not run any model. Do not spend API money.

## Report back

Projects (repo, commit, LOC and how counted), tasks per project with type and a one-line description, `validate`
output, probe outcome, every judgement call in an oracle, anything you could not make work, and the exact files you
added. Keep everything inside `projects/<lang>-*` and `tasks/<lang>-*`; if the harness itself needs a change, describe
it instead of making it.

## JVM languages (kotlin, java, java-kotlin)

- All three are the `jvm` group (`./study setup jvm`): the Kotlin server, the IntelliJ server with its terms accepted,
  JDK 21 and Maven for the servers' import. Arms: Kotlin and mixed projects run all five
  arms; Java projects run `baseline`, `intellij-optional`, `intellij-enforced` (no tereditor Java server without
  IntelliJ).
- Build-tool import is the main cost: both servers import the Gradle or Maven model. `prepare.sh` (server sandbox,
  `HOME=/cache/home`, JDK and Maven on PATH, network on) must resolve the build once so the
  wrapper distribution and every dependency are in `/cache/home/.gradle` or `/cache/home/.m2`: e.g.
  `./gradlew --no-daemon dependencies` or a compile of the main source sets, `mvn -q dependency:go-offline`. Do not
  pre-build the servers' own indexes: every run starts its language server cold, in every arm and every language.
- Prefer plain JVM builds over Kotlin Multiplatform; a multiplatform project's import pulls every target's toolchain.
  If you choose one anyway, measure its import time with the probe and say so.
- Probe both servers: `./study probe <proj> enforced` (Kotlin server; no Java server) and
  `./study probe <proj> intellij-enforced` (IntelliJ). Record both in `[probe]` / `[probe_intellij]`, including the
  IntelliJ licence verdict from `lsp_status servers` and the time until the project graph is loaded (`./study probe`
  passes the licence).
- Grading: `grade-setup.sh` resolves the build's dependencies into `~/.m2` or `~/.gradle`, so `check.sh` runs
  `--offline`; it compiles (and runs relevant tests of) the affected modules.
- Oracles: `javac`/`kotlinc` via the build (rename the declaration, compile, collect the errors), never either language
  server.
