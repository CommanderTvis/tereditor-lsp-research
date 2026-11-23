# Does LSP help Claude Code?

Two language-server stacks compete against the same agent without them: [headless tereditor](https://github.com/CommanderTvis/tereditor/blob/main/docs/headless.md)'s
servers and IntelliJ's, across every language tereditor serves headless plus Java, four project sizes, three models
and two prompting regimes.

- [docs/DESIGN.md](docs/DESIGN.md), [docs/ANALYSIS_PLAN.md](docs/ANALYSIS_PLAN.md),
  [docs/PROJECTS.md](docs/PROJECTS.md), [docs/TASKS.md](docs/TASKS.md).

## Requirements

- Docker, or Apple `container` 1.7+ on macOS: 8 CPUs, 16 GB of memory, about 150 GB of disk; on Apple `container`,
  `container builder start --cpus 8 --memory 12g`.
- `ANTHROPIC_API_KEY`, or `CLAUDE_CODE_OAUTH_TOKEN` from `claude setup-token`.
- A JetBrains licence including IntelliJ IDEA Ultimate.

## Reproduce

1. On <https://account.jetbrains.com/licenses>, **Download a code for offline activation** and save the zip as
   `./license.zip` (or the bare code as `./license.txt`).
2. Put your own answers to JetBrains' terms in `harness/intellij.env` (the committed ones are the study owner's).
3. Put the credential in `./study.env` as `ANTHROPIC_API_KEY=...`, or export it.
4. Run:

   ```sh
   ./study setup
   ./study project $(ls projects)
   for p in $(ls projects); do ./study probe "$p"; ./study validate "$p"; done
   ./study plan mine --models "claude-haiku-5-5 claude-sonnet-5-5 claude-opus-5-5" --reps 3 --budget 5
   ./study run mine -j 3        # resumable
   ./study grade mine -j 3
   ./study analyze mine         # results/mine/report/report.md
   ```

`STUDY_RUNTIME=docker|container` picks the runtime when both exist. Docker (OrbStack on macOS) and Apple `container` are tested.
The author's run uses one Claude Code cloud session: [docs/CLOUD_PROMPT.md](docs/CLOUD_PROMPT.md) (the runbook it follows is [docs/CLOUD_RUN.md](docs/CLOUD_RUN.md)).
A committed plan can also run in parallel cloud sessions, one per project, with results returned through your own S3 bucket: [docs/CLOUD_PARALLEL.md](docs/CLOUD_PARALLEL.md).
