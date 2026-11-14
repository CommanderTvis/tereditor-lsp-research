# Running the study in one Claude Code cloud session

The runbook for the session that carries out the whole study unattended, one project at a time, and ends by handing
the owner the dated report and every result as downloads. Read `AGENTS.md` first; it is the contract. Everything here
uses `./study` with the native backend (docs/NIX.md): no Docker daemon is needed in the cloud VM.

## Why one cloud session, and what it implies

- A cloud session is a free Ubuntu 24.04 x86_64 VM (about 4 vCPUs, 16 GB of memory, 30 GB of disk), isolated from the
  owner's machine. Model usage counts against the owner's plan.
- The session needs no GitHub account: it clones this public repository, commits on a local branch, and sends its work
  to the owner as downloadable files (the session's file-sharing). It never pushes.
- 30 GB of disk holds one project at a time: build, use, then `./study prune`.
- The VM can pause or be reclaimed. After every project the session sends a git bundle of its branch, so nothing
  finished is lost; a new session resumes from the latest bundle.
- All projects run on linux/amd64 here. Do not mix in runs from another architecture for the same project.

## Before the first command (the owner's part)

A cloud environment with network access **Full**: no repository, no environment variables, no setup script.

1. The credential is the session's own login: the native backend binds the session's token file
   (`/home/claude/.claude/remote/.oauth_token`) into each agent sandbox and redacts it from every output.
2. Attach JetBrains' offline activation code to the first message: the zip from "Download a code for offline
   activation", or the `... - for 2018.2 or later.txt` file inside it. It is required.
3. To resume a lost run, also attach the latest `study-<date>.bundle` the previous session sent.
4. The prompt "Run the study per docs/CLOUD_RUN.md in https://github.com/CommanderTvis/tereditor-lsp-research" is
   the owner's go for the confirmatory run, within the budget below.

Status: the environments and sandboxes run end to end on Apple `container`, and a cloud smoke on the native backend
passed; the full runbook has not run yet.

## Rules for the session

- Never end your turn while work remains: the VM pauses when the session is idle and running commands die with it.
  Run long commands in the background and poll them every few minutes until the final files are sent.
- Work in `/root/study` on the branch `run/<YYYY-MM-DD>` (the date the run starts). Commit after every project and
  every phase. Commit only study files: never the licence, never tokens, never raw `results/*/runs/` (archives only).
- Checkpoint after every project and every phase: `git bundle create /root/study-<date>.bundle main..HEAD` (the whole
  branch, so the latest bundle supersedes earlier ones) and send it to the owner as a download, with one line saying
  what it now contains.
- While curating tasks, never read run results; while running, never change tasks, prompts, oracles, arms or the
  harness. A defect found mid-run is recorded in `docs/ANALYSIS_PLAN.md` under "Changes after registration" with the
  date, and the affected runs are handled by the plan's exclusion rules, not by editing data.
- Disk: check `df -h /` before each project; if a project cannot fit, record it as skipped (`project.toml`
  `status = "skipped"`, with the reason) and continue.
- Budget: USD 2,000 as reported by Claude Code (`total_cost_usd`), across all model runs of the study. Stop starting
  runs at 95% and say so in the report.

## Phase 0: preflight

```sh
git clone https://github.com/CommanderTvis/tereditor-lsp-research /root/study && cd /root/study
git config user.name "Claude Code cloud session" && git config user.email noreply@anthropic.com
git switch -c run/$(date -u +%F)
# resuming: git pull /path/to/attached/study-<date>.bundle run/<date>   (then ./study restore main)
cp /path/to/attachment license.zip            # or license.txt for the bare code
git check-ignore -q license.zip && git check-ignore -q license.txt && echo "licence files ignored"
export STUDY_RUNTIME=native STUDY_CPUS=3 STUDY_MEMORY=10g
./study setup python
```

Then the toolz smoke (`./study plan smoke-cloud --projects python-small --tasks refs-get --models claude-haiku-5-5`,
`run`, `grade`, `analyze`): 3 runs, all graded, 0 contamination failures. If anything fails here, stop and report;
do not work around harness failures. Send a first bundle to confirm that downloads reach the owner.

## Phase A: curate every project, one at a time

For each `projects/<lang>-<size>` in `docs/PROJECTS.md`, smallest first within each language:

1. `./study setup <group>` (once per language group), `./study project <lang>-<size>`.
2. If the project is a stub, curate it per `docs/CURATION.md` (tasks, prepare.sh, grade-setup.sh, check.sh,
   probe.json; oracles never from a language server). Subagents may do it, one project each, briefed with
   `docs/CURATION.md` and `docs/TASKS.md`.
3. `./study validate <lang>-<size>`: every task VALID. Drop a task that cannot be made valid (say why in its
   directory as `DROPPED.md` and remove it from `tasks/`).
4. `./study probe <lang>-<size>` (and `intellij-enforced` for JVM projects, with `POLL_S=900`): record the outcome in
   `project.toml` `[probe]` / `[probe_intellij]`.
5. Commit, send the bundle, `./study prune <lang>-<size>`.

## Phase B: calibration pilot and allocation

1. Two pilot plans, run, graded and analysed project by project as in Phase C (`--project`):

   ```sh
   ./study plan pilot --projects "python-small java-medium csharp-small typescript-medium" \
     --models "claude-haiku-5-5 claude-sonnet-5-5" --reps 1 \
     --arms "baseline optional enforced intellij-optional intellij-enforced"
   ./study plan pilot-opus --projects "<one large project curated in Phase A>" --models claude-opus-5-5 --reps 1 \
     --arms "baseline optional enforced intellij-optional intellij-enforced"
   ```

   Pilot runs measure cost and variance only; they are not part of the confirmatory analysis.
2. From the pilot's cost per run (by model and size) and the number of valid tasks, fix repetitions per model with
   the rule in `docs/ANALYSIS_PLAN.md` (every cell at least once; add repetitions Haiku, then Sonnet, then Opus while
   the projected cost stays under the budget, equally across arms). Write the allocation into its "Allocation"
   section, commit and send the bundle BEFORE Phase C.

## Phase C: the confirmatory run, one project at a time

```sh
./study plan main --models "claude-haiku-5-5 claude-sonnet-5-5 claude-opus-5-5" \
  --arms "baseline optional enforced intellij-optional intellij-enforced" \
  --reps-per-model "<from the allocation>" --budget 10 --turns 200 --timeout 3600
git add results/main/plan.tsv && git commit -m "Confirmatory plan"      # and send the bundle
```

Then for each project (the planner already randomised the run order; run projects in the order of their first run in
`plan.tsv`):

```sh
./study restore main                    # after a new session or machine
./study status main                     # skip projects already finished and graded
./study setup <group>; ./study project <p>
./study run main --project <p> -j 2
./study grade main --project <p> -j 2
./study archive main <p>
git add results/main/archive/<p>.tar.gz && git commit -m "Runs: <p>"     # and send the bundle
./study prune <p>
```

`-j 2` keeps two runs (two language servers) inside 16 GB; use `-j 1` and `STUDY_MEMORY=14g` for xlarge projects.

## Phase D: report and delivery

1. `./study restore main && ./study analyze main` (results/main/report/).
2. Write `REPORT.md` at the repository root: question, design summary (link docs/), what ran (projects, tasks, runs,
   exclusions with reasons, budget used), primary results exactly as the pre-registered analysis produced them, the
   secondary and exploratory results labelled as such, tereditor and IntelliJ findings, deviations from the plan, and
   threats to validity. No claim without a number from `results/main/report/`.
3. Sign it at the end with the date: `Report generated on <YYYY-MM-DD> (UTC) by a Claude Code cloud session from
   plan results/main/plan.tsv, tereditor <TEREDITOR_COMMIT>, Claude Code <version>.`
4. Commit `REPORT.md` and `results/main/` (plan, runs.csv, report, archives) and send three downloads: the final
   bundle, `REPORT.md` itself, and `study-results-<date>.tar.gz` (REPORT.md plus `results/main/`). Print the report's
   summary in the chat. The owner applies the bundle (`git pull study-<date>.bundle run/<date>`) and opens the pull
   request.
