# AGENTS.md

A controlled, reproducible study of whether language-server (LSP) tools make a Claude Code agent better, faster or
cheaper. The tools come from headless tereditor (formerly SharpRail), the owner's own product. Read this before doing
anything here; the details live in `docs/` (DESIGN, ANALYSIS_PLAN, TASKS, PROJECTS, CURATION) and `README.md`.

## What the owner asked for (the contract)

- "An actual serious research of LSP efficiency", more rigorous than two reference studies: Ian Barber's
  lsps-for-llms REPORT.md (Python, mostly an AST resolver in a custom loop, often 1 seed) and devrig.dev's
  experiment findings (vendor study of IntelliJ APIs on Java, about 1 run per leg, no statistics).
- Languages: every language tereditor ships in its headless image (C#, TypeScript/JavaScript, Python, PHP, C/C++,
  Kotlin, Shell, CSS/SCSS), plus Java, Kotlin and mixed Java+Kotlin projects for the IntelliJ contestant.
- Project sizes small, medium, large, and "actually big" projects (the xlarge tier). Size proxy = code lines in the
  project's language, comparable across languages ("a large Python project is comparable to a large Kotlin one").
  The selection is in `docs/PROJECTS.md`; reproduce sizes with `sh harness/size/measure.sh`.
- Models: Haiku 5.5, Sonnet 5.5, Opus 5.5 (`claude-haiku-5-5`, `claude-sonnet-5-5`, `claude-opus-5-5`), driven by
  `claude -p`.
- Prompt engineering, two regimes: LSP available but not mandatory (`optional`); LSP enforced by hooks and prompt,
  modelled on the owner's rell repository (`~/chromaway/rell/CLAUDE.md` and its `.claude/settings.json` hooks)
  (`enforced`). Baseline: the same Claude Code agent with core utilities only.
- A third contestant: IntelliJ's language server through tereditor (`intellij-optional`, `intellij-enforced`).
- Externally reproducible on macOS and Linux (Docker, Docker on macOS, Apple `container`) with nothing installed but
  Claude Code and a container runtime (plus an Anthropic credential and a JetBrains licence, both required; there is
  no reproduction flow without IntelliJ). Hard requirement:
  Nix (used to define the environments, docs/NIX.md) must never be a requirement for a reproducer; it runs inside a
  builder container, or self-bootstrapped in the native backend.
- The owner's `~/.claude/CLAUDE.md` (and any other user configuration) must not contaminate the study.
- Budget about USD 2,000 for the confirmatory run, which is ON HOLD: the owner asked to wait for the IntelliJ
  contestant. IntelliJ works in the harness, but get an explicit go from the owner
  before launching anything beyond small smoke or calibration runs.

## Decisions already made, and why

- The agent runs inside a container with an empty HOME, `--setting-sources project --strict-mcp-config
  --no-session-persistence`, `--permission-mode bypassPermissions`; WebFetch/WebSearch off. Every run's
  `system/init` event is checked against its arm (`analysis/extract.py`); mismatches are excluded and counted.
- No arm has a compiler, interpreter, package manager, curl or wget. The language servers and their runtimes (.NET
  SDK, Bun, clangd, JDK, Maven, IntelliJ) exist only in the language server's sandbox; the agent's sandbox contains
  only its own closure and reaches the server through a socket (docs/NIX.md).
  Otherwise the LSP arms would get a compiler the baseline lacks.
- `optional` removes tereditor's own "use lsp_navigate instead of grep" advice (sentences only) with
  `harness/server/neutral.jq`; `enforced` keeps the shipped text and adds `harness/arms/enforced/overlay`
  (CLAUDE.md + advisory hooks + a stop hook that blocks once if edited files were not checked with diagnostics).
  The IntelliJ arms reuse these, with `TEREDITOR_PREFETCH=intellij`.
- Arm applicability: IntelliJ arms only on JVM projects; Java runs baseline + IntelliJ arms (tereditor has no
  headless Java server otherwise); Kotlin and mixed run all five arms.
- `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` is OFF: in Claude Code 2.1.322 it forces the default permission mode, a
  bubblewrap+socat sandbox and drops Grep, i.e. changes the agent. Credentials are redacted from outputs instead.
- IntelliJ is part of every JVM image and every plan; the licence is required (`./study run` refuses without it).
  `harness/intellij.env` records the owner's acceptance of the JetBrains
  User Agreement 2.0 (terms hash `cd82e6cd...0c9a25`, region europe, data sharing none). The owner's offline
  activation code is `./license.zip` (git-ignored, never print/copy/commit it); it travels base64 in an env var and
  is decoded into a uid-1000-only directory.
- The JVM image adds a pinned JDK 21 and Apache Maven 3.9.11 under `/cache`: IntelliJ's Maven import runs `mvn` from
  PATH, and without it answers never left the current file.
- Oracles never come from a language server: compiler mutation (rename the declaration, compile, collect errors),
  another analyser, or hand-classified exhaustive candidate lists. Every task must pass `./study validate`.
- The analysis is pre-registered in `docs/ANALYSIS_PLAN.md` (14 primary tests, Holm; mixed models, task-clustered
  bootstrap, sign-flip tests). Changes after the first confirmatory run go in its "Changes after registration".

## Findings so far (smoke only, not evidence)

- Toolz (Python small) and gson (Java medium) tasks: every arm succeeds with Haiku; tasks of this size are at
  ceiling, so success cannot separate arms. Harder tasks on larger projects are needed.
- Offered but not pushed, Haiku used the LSP tools in 0 of 6 runs; enforced, always, at 1.2 to 4.4x the cost.
- For tereditor upstream (report, do not fix from here): headless IntelliJ cannot import Maven projects without
  `mvn` on PATH and may write `mavenPluginInstall-pom*.xml` into the workspace; with IntelliJ, lookup by name
  (`Gson/getAdapter`) returns nothing while lookup at a position works; Gradle import of a Kotlin Multiplatform
  project (kotlin-result) stalled at "2%; Gradle" for minutes; at pin 95f7048 Pyright returned no cross-file
  references on toolz (fixed by later pins).

## Where things are

- `study`: the driver (POSIX sh; images, project, probe, validate, plan, run, grade, analyze).
- `nix/flake.nix`: every environment (docs/NIX.md). `harness/env/`: the scripts every command runs in it.
  `harness/server/`: what runs inside the language server's sandbox. tereditor is built from the commit in
  `harness/tereditor.env`.
- `harness/arms/<arm>/`: `mcp.json` and the workspace overlay. `harness/grade/grade.sh`, `harness/bin/probe-inside.sh`.
- `projects/<lang>-<size>/`, `tasks/<lang>-<size>/<task>/`: see `docs/TASKS.md`. Most projects are stubs
  (`status = "stub"` in `project.toml`); done so far: python-small (4 tasks), java-medium (2), csharp-small
  (2, not validated).
- `analysis/`: planner, extraction, report. `results/<plan>/`: plan, runs.csv, report (raw runs are git-ignored).
- Upstream checkout (read-only from this repo): `~/TereditorProjects/tereditor`, remote
  `github.com/CommanderTvis/tereditor` (formerly `CommanderTvis/sharprail`); image `ghcr.io/commandertvis/tereditor`.
- Credential: `~/.config/tereditor-study/env` (`CLAUDE_CODE_OAUTH_TOKEN=` or `ANTHROPIC_API_KEY=`).

## Running the study (cloud)

The study runs in ONE Claude Code cloud session, unattended, following `docs/CLOUD_RUN.md`: projects one at a time
(build, curate if a stub, validate, probe, run, grade, archive, push, prune Docker), a calibration pilot fixing the
allocation before the confirmatory run, and at the end a pull request with `REPORT.md`, signed with the date. The
cloud environment needs only this GitHub repository (github.com/CommanderTvis/tereditor-lsp-research, private) and
Full network access; the credential is the session's own login, and the owner attaches the JetBrains activation code
(zip or txt) to the first message, saved as git-ignored `license.zip`/`license.txt`. Starting that session with "Run
the study per docs/CLOUD_RUN.md" is the owner's go for the confirmatory run. The cloud run needs the native backend
(docs/NIX.md), which is still being built. Local runs on this Mac are for development only (Apple
`container` is too heavy for RAM and disk here).

## Working here

- This machine: macOS arm64, 24 GB, Apple `container` (`export STUDY_RUNTIME=container`). The builder restarts with
  2 CPUs / 2 GB unless `./study` passes `--cpus/--memory` (it does). Keep `STUDY_MEMORY` at 4 to 8g; xlarge up to
  16g, one at a time. Disk fills fast: prune stale `study/*` images between waves (never images the study did not
  build).
- Use `./study probe` and `./study validate` before spending model money; smoke with Haiku first.
- Curation is done by subagents following `docs/CURATION.md`, one language each, about four at a time; they stop when
  a session ends, so check what is on disk before relaunching.
- Locally: commit only when the owner asks; commits are SSH-signed; never push from here. The cloud session commits
  and pushes its own `run/<date>` branch, as `docs/CLOUD_RUN.md` says.

## Next steps

1. Curate the stub projects (tasks, prepare.sh, grade-setup.sh, check.sh, probe.json), validate and probe them on
   the current tereditor pin, both servers for JVM projects.
2. Re-run the toolz and gson smokes on the renamed images.
3. Calibration pilot (Haiku on small projects, a few Opus runs on large ones) to fix repetitions per model under
   the budget; record the allocation in `docs/ANALYSIS_PLAN.md`.
4. With the owner's go: the confirmatory run, then `./study analyze`.
