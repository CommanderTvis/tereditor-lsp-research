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
  Nix (used to define the environments, docs/ENVIRONMENT.md) must never be a requirement for a reproducer; it runs inside a
  builder container, or self-bootstrapped in the native backend.
- The owner's `~/.claude/CLAUDE.md` (and any other user configuration) must not contaminate the study.
- Budget about USD 400 (API-equivalent, as Claude Code reports it; the Max 5x plan allows about USD 100 per 5-hour window) for the confirmatory run. It is an indicative price level, not a hard spending cap: the owner's subscription covers roughly USD 1,000 to 2,000 a month, so a moderate overshoot to buy power is acceptable, but ask before going far past it. The confirmatory run waited for the IntelliJ
  contestant. That run is DONE (see "Results" below); get an explicit go from the owner before launching any new
  run beyond small smoke or calibration runs.

## Decisions already made, and why

- The agent runs inside a container with an empty HOME, `--setting-sources project --strict-mcp-config
  --no-session-persistence`, `--permission-mode bypassPermissions`; WebFetch/WebSearch off. Every run's
  `system/init` event is checked against its arm (`analysis/extract.py`); mismatches are excluded and counted.
- No arm has a compiler, interpreter, package manager, curl or wget. The language servers and their runtimes (.NET
  SDK, Bun, clangd, JDK, Maven, IntelliJ) exist only in the language server's sandbox; the agent's sandbox contains
  only its own closure and reaches the server through a socket (docs/ENVIRONMENT.md).
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
- Tasks: half synthetic (refactorings: rename, rename file, move to another package or module, change signature;
  plus navigation questions), half mined pull requests selected as SWE-bench selects them, opened after 2026-07-01 (after
  every model's training cutoff; old PRs may be memorized, not only the pre-2022 ones (measured in docs/MEMORIZATION.md), and never compared with a
  gold patch), runnable with the current toolchains. Curated count: 6 per project (3 + 3); the confirmatory run uses 3 per project (`./study plan --keep 3`, seeded,
  docs/ANALYSIS_PLAN.md); the calibration pilot fixed the repetitions to fit USD 400 (docs/TASKS.md, docs/ANALYSIS_PLAN.md).
- Effort: every model at Claude Code's default, `medium` for Haiku, Sonnet and Opus 5.5; nothing in the harness sets
  an effort level (docs/DESIGN.md). Success is averaged arithmetically, cost and time geometrically (ratios).
- Oracles never come from a language server: compiler mutation (rename the declaration, compile, collect errors),
  another analyser, or hand-classified exhaustive candidate lists. Every task must pass `./study validate`.
- The analysis is described in `docs/ANALYSIS_PLAN.md` (a descriptive paired comparison on the tasks with a task-resampling interval for spread; includes a
  Haiku-reviewed quality-flaw count).

## Results (the confirmatory run is complete)

The confirmatory run is finished and analysed: 2,232 runs, 87 tasks, 29 projects, three models, every arm. Nothing of
it is on main: the results live on the `gh-pages` branch, published at https://commandertvis.github.io/tereditor-lsp-research/
(`index.html`, built by `build_site.py` from `data/`; `llms.txt` for agents). `data/results/<plan>/` holds every plan's
plan, run archives, `runs.csv` and analysis report (`main` is the confirmatory run; also the pilots and smokes);
`./study data pull [plan]` fetches them into `results/`, `./study restore <plan>` unpacks the archives. Read the page or
`llms.txt` before claiming anything about the results. In short (paired on tasks, 95% task-resampling intervals):

- Success: no measurable change. Optional vs baseline +0.3 pp (-2.2 to +3.0), enforced vs baseline -2.0 pp (-5.2 to +1.0).
- Cost: optional about equal (1.02x), enforced 1.57x the baseline (1.45 to 1.70).
- Adoption: offered but not pushed, Haiku and Sonnet called the LS tools in 0% of runs, Opus in 16%; enforced, 86 to 93%.
- Flaws (Haiku-reviewed, re-checked: a defect repeated per file counts once, flaws about what a task declared optional
  are dropped; not yet checked by a human): optional -0.01 per run (-0.10 to +0.09), enforced +0.13 (+0.02 to +0.24).

For tereditor upstream (report, do not fix from here): with IntelliJ, lookup by name (`Gson/getAdapter`) returns
nothing while lookup at a position works; Gradle import of a Kotlin Multiplatform project (kotlin-result) stalled at
"2%; Gradle"; on the cloud VM tereditor's 4,826 MiB memory budget for all servers of a run killed IntelliJ arms on
java-kotlin-large; php-large definition by name was not found.

## Where things are

- `study`: the driver (POSIX sh; images, project, probe, validate, plan, run, grade, analyze).
- `nix/flake.nix`: every environment (docs/ENVIRONMENT.md). `harness/env/`: the scripts every command runs in it.
  `harness/server/`: what runs inside the language server's sandbox. tereditor comes from a dated release
  archive, pinned by sha256 in `harness/tereditor.env`.
- `harness/arms/<arm>/`: `mcp.json` and the workspace overlay. `harness/grade/grade.sh`, `harness/bin/probe-inside.sh`.
- `projects/<lang>-<size>/`, `tasks/<lang>-<size>/<task>/`: see `docs/TASKS.md`. 29 projects are curated and
  validated (6 tasks each, 3 used by the confirmatory plan); 5 are postponed (below).
- `analysis/`: planner, extraction, report. `results/<plan>/`: plan, runs.csv, report, archives. Never in this branch
  (git-ignored): published on gh-pages under `data/results/`; `./study data pull [plan]` / `./study data push <plan>`.
- Upstream checkout (read-only from this repo): `~/TereditorProjects/tereditor`, remote
  `github.com/CommanderTvis/tereditor` (formerly `CommanderTvis/sharprail`); headless archives on its nightly releases.
- Local secrets live git-ignored in the repository root: `study.env` (`CLAUDE_CODE_OAUTH_TOKEN=` or
  `ANTHROPIC_API_KEY=`), `license.zip`/`license.txt`. Nothing goes into `~`.

## Running the study (cloud)

The study runs in ONE Claude Code cloud session, unattended, following `docs/CLOUD_RUN.md`: projects one at a time
(set up, curate if a stub, validate, probe, run, grade, archive, prune), a calibration pilot fixing the allocation
before the confirmatory run, and at the end `REPORT.md`, signed with the date. The session works on this public repository with its own login and sends
its work to the owner as downloads (a git bundle of its branch after every project, then the report and a results
tarball). The owner sets up one cloud environment (Full network access, the JetBrains activation code as the variable
`STUDY_LICENSE_B64`) and starts it with the `claude --cloud` command of `docs/CLOUD_PROMPT.md`, which is the owner's go
for the confirmatory run; an outside reproducer with a Claude subscription does the same. Local runs on this Mac are for
development. Alternatively, `./study cloud` runs a plan in parallel cloud sessions, one per project, paced
and returning results through the operator's S3 bucket (`docs/CLOUD_PARALLEL.md`).

## Working here

- This machine: macOS arm64, 24 GB, Apple `container` (`export STUDY_RUNTIME=container`). The builder restarts with
  2 CPUs / 2 GB unless `./study` passes `--cpus/--memory` (it does). Keep `STUDY_MEMORY` at 4 to 8g; xlarge up to
  16g, one at a time. Disk fills fast: prune stale `study/*` images between waves (never images the study did not
  build).
- Use `./study probe` and `./study validate` before spending model money; smoke with Haiku first.
- Curation is done by subagents following `docs/CURATION.md`, one language each, about four at a time; they stop when
  a session ends, so check what is on disk before relaunching.
- Locally: commit and push only when the owner asks; commits are SSH-signed. The cloud session commits on its own
  `run/<date>` branch and sends it as a git bundle; the owner applies it and opens the pull request.

## Postponed projects

Rule: a project of any size that cannot be developed inside the 30 GB cloud VM is postponed (`status = "postponed"` in its `project.toml`, skipped by `analysis/plan.sh`, everything else kept); see docs/TASKS.md. Postponed so far (measured, ran out of the VM's disk): `typescript-xlarge`, `csharp-xlarge`, `java-kotlin-xlarge`, `kotlin-large`, `csharp-large`.

## Next steps

1. The owner labels the random sample of 30 reported flaws (outcome 3's human check, docs/ANALYSIS_PLAN.md); its
   share of real flaws goes onto the results page.
2. Any new run (more repetitions, the postponed projects, newer pins) needs the owner's explicit go.
