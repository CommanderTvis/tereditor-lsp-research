# Curating a language: instructions for whoever adds projects and tasks

You add the projects (`<lang>-small`, `<lang>-medium`, `<lang>-large`, and `<lang>-xlarge` where the language has one) of one language and their tasks, and you
prove each one valid. Read [TASKS.md](TASKS.md) first: it is the contract. `projects/python-small` and
`tasks/python-small/*` are the worked example; copy their shape.

## Choosing projects

- Real, well-known open-source projects in the language, pinned to a full commit SHA (a release tag's commit).
- Size classes from TASKS.md. Where a language has no credible project above 100k lines (shell, CSS), take the largest
  credible one and say so in `project.toml` (`size_note`).
- The project must build and its tests (or a meaningful subset) must pass offline in `Dockerfile.grade` within about
  10 minutes on 4 CPUs. Dependencies are installed when the grade image is built, never at grade time
  (`--network none`).
- The language server must be able to understand it in the run image, which has no compiler: whatever it needs
  (restored packages for C#, `node_modules` type declarations for TypeScript, a `compile_commands.json` with paths
  under `/workspace` and the C/C++ standard headers for clangd, a Gradle-free source layout for Kotlin) must come from
  `prepare.sh` or from files committed under `projects/<lang>-<size>/` and copied in by `prepare.sh`. `prepare.sh`
  runs as uid 1000 with the managed runtimes on PATH-less locations under `/cache/managed`; anything it produces must
  be git-ignored by the project or added to `.git/info/exclude`, so it is not part of the agent's diff.
- Projects with heavy dynamic magic are fine (they are realistic) but write tasks whose ground truth is still
  unambiguous.

## Writing tasks

Five per project unless the language cannot support a type: `refs`, `rename`, `compile`, `bugfix`, and one of
`impls`, `dispatch`, `callers`, `inspect`, `signature`. Spread the fifth type across your three projects.

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
./study images <lang>              # once; the tereditor and agent images may already exist
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

- All three run on `study/warm-jvm:<arch>` (`./study images kotlin` builds it): the Kotlin server, the opt-in IntelliJ
  server with the terms accepted, and a pinned JDK 21 at `/cache/jdk`. Arms: Kotlin and mixed projects run all five
  arms; Java projects run `baseline`, `intellij-optional`, `intellij-enforced` (no tereditor Java server without
  IntelliJ).
- Build-tool import is the main cost: both servers import the Gradle or Maven model. `prepare.sh` (uid 1000,
  `JAVA_HOME=/cache/jdk`, `HOME=/cache/home`, network available at image build) must resolve the build once so the
  wrapper distribution and every dependency are in `/cache/home/.gradle` or `/cache/home/.m2`: e.g.
  `./gradlew --no-daemon dependencies` or a compile of the main source sets, `mvn -q dependency:go-offline`. Do not
  pre-build the servers' own indexes: every run starts its language server cold, in every arm and every language.
- Prefer plain JVM builds over Kotlin Multiplatform; a multiplatform project's import pulls every target's toolchain.
  If you choose one anyway, measure its import time with the probe and say so.
- Probe both servers: `./study probe <proj> enforced` (Kotlin server; no Java server) and
  `./study probe <proj> intellij-enforced` (IntelliJ). Record both in `[probe]` / `[probe_intellij]`, including the
  IntelliJ licence verdict from `lsp_status servers` and the time until the project graph is loaded. The licence is
  `./license.zip`, already present; never print, copy or commit it. `./study probe` must pass it (see `cmd_run` for how
  the driver hands it to a container) — if probing IntelliJ needs a driver change, describe it instead of making it.
- Grade images: a pinned JDK image (eclipse-temurin) with the build's dependencies resolved at image build, so
  `--offline` builds work under `--network none`; check.sh compiles (and runs relevant tests of) the affected modules.
- Oracles: `javac`/`kotlinc` via the build (rename the declaration, compile, collect the errors), never either language
  server.
