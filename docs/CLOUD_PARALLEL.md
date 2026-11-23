# Running a plan in parallel cloud sessions, one per project

An alternative to the single session of `docs/CLOUD_RUN.md`: the operator's machine starts one unattended Claude Code
cloud session per project of a committed plan, a few at a time, and every session returns its project's archive
through an S3-compatible bucket the operator brings. `./study cloud` does the launching, watching and collecting;
`harness/cloud/child.sh` is the worker each session runs.

## When to use it

Use `docs/CLOUD_RUN.md` when one session should do everything (curation, validation, the pilot, the plan, the runs and
the report) and wall-clock time does not matter: it runs one project at a time and needs nothing but a Claude
subscription. Use this document when a plan is already fixed and committed (`results/<plan>/plan.tsv`) and its
projects should run side by side: each project gets its own VM, its own 30 GB disk and its own worker, so a plan that
takes days in one session takes hours. Curation, validation, the pilot and the report stay with the single-session
runbook or the operator.

The parallel sessions all use the same cloud VM type (linux/amd64), so their runs are comparable with each other.
Do not mix the runs of one plan from these VMs with runs from another architecture (an arm64 Mac, say) for the same
project.

## What the operator needs

- Claude Code on the operator's machine (macOS or Linux), logged in with a Claude subscription. Every helper session
  and every run inside it counts against that subscription.
- A cloud environment with network access Full, selected as the default for `claude --cloud` with `/remote-env` in an
  interactive `claude`. `--environment` accepts only self-hosted environment ids, so the selection is the only way to
  choose it. The JetBrains variable of `docs/CLOUD_RUN.md` is not needed here: the licence travels through the bucket.
- An S3-compatible bucket of the operator's own (AWS, Scaleway, Cloudflare R2, MinIO, ...), private, and an access key
  limited to that bucket. The key is written into every helper's prompt (see "The key in the prompt"), so make it a
  dedicated key with read and write on this bucket only, and revoke it when the plan is collected.
- The JetBrains offline activation code as `./license.zip` in the repository root, as for every run of the study.
- `curl` 7.75 or later (for `--aws-sigv4`), `script` (BSD or util-linux), `git`; `jq` and `bash` for `collect`'s scan
  (without `jq` the scan only looks for the `usage_limit_reached` text and says so). No container runtime is needed on
  the operator's machine for `./study cloud`.

## Usage

1. Put the bucket in `cloud.env` in the repository root (git-ignored):

   ```sh
   S3_ENDPOINT=https://<bucket>.s3.<region>.<provider>    # the bucket's own URL, virtual-hosted style
   S3_REGION=<region>
   S3_ACCESS=<access key id>
   S3_SECRET=<secret access key>
   ```

2. Commit the plan (`./study plan <plan> ...`, then `git add results/<plan>/plan.tsv && git commit`). The helpers
   clone a git bundle of the current branch, so whatever they should run must be committed on it; `launch` refuses an
   uncommitted or modified plan and warns about uncommitted harness changes.
3. Check the launch without starting anything: `STUDY_CLOUD_DRY_RUN=1 ./study cloud launch <plan>` prints the uploads,
   the `script ... claude ... --cloud` command and the prompt with the key masked, and makes no network call.
4. Launch, from the repository root:

   ```sh
   ./study cloud launch <plan> [--projects "p1 p2 ..."] [--max-running N] [--model M] [--permission-mode M]
   ```

   Defaults: every project of the plan that is not postponed, skipped or dropped and has neither a status in the bucket
   nor a session in `results/<plan>/cloud/sessions.tsv`; N = 4; model `sonnet` (the helper session's own model, which
   only starts and watches the worker; the runs use the plan's models); permission mode `auto`. It uploads
   `control/study.bundle`, `control/branch.txt`, `control/plan.sha256`, `control/license.zip`, `control/child.sh` and
   `control/s3.sh`, then stays in the foreground and launches helpers as slots free up (see "Pacing"). Each launch
   appends `<project>`, the session id and the time to `results/<plan>/cloud/sessions.tsv` and prints the session's
   URL. Leave it running until it says everything is launched; if it stops, run it again: it rebuilds its state from
   the bucket and `sessions.tsv`. The control keys are shared by all plans in a bucket, so launch one plan at a time.
5. Watch: `./study cloud status <plan>` prints one line per project from the bucket: state, step, host, time of the
   last step, and the last heartbeat (every 5 minutes, with the runs finished and graded and the free disk). A project
   that is running or waiting with a heartbeat older than 25 minutes is flagged `stalled: open <session URL>`.
6. Collect: `./study cloud collect <plan>` downloads `<plan>/<project>/<project>.tar.gz` of every project whose state is
   done or incomplete into `results/<plan>/archive/` (with its `limit-attempts.log` as `<project>.limit-attempts.log`),
   checks that each tarball unpacks, and scans it for runs and reviews that stopped on a usage limit. It prints the
   counts per project and calls a project "collected clean" only when its state is done and nothing stopped on a limit;
   it exits non-zero otherwise. `./study cloud scan <archive.tar.gz>...` runs the same scan on archives already on disk.
   Collect commits nothing: review the output, then `git add results/<plan>/archive results/<plan>/cloud/sessions.tsv`
   and commit (`./study restore <plan>` and `./study analyze <plan>` as usual afterwards).

## What a helper does

The prompt (`harness/cloud/prompt.tmpl`) tells the session to download `control/child.sh` and `control/s3.sh`, start
`child.sh <project> <plan>` detached, and keep its own turn alive by polling every 9 minutes until the worker ends,
restarting the worker after a restart of the session. The worker clones the bundle at the branch in
`control/branch.txt`, checks `results/<plan>/plan.tsv` against `control/plan.sha256` (it never regenerates a plan),
then sets up, runs, grades (and reviews, where the branch's driver has `./study review`), archives and uploads, with
`-j 2` and `STUDY_MEMORY=10g`, or `-j 1` and `14g` for xlarge projects. Everything it writes goes under
`<plan>/<project>/` in the bucket: `status.json` at every step, `heartbeat.txt`, `log-tail.txt`, the archive and
`limit-attempts.log`. A project whose `status.json` names another host is skipped, so two sessions never work on one
project. The project ends `done` only when every planned run is finished and graded and none of them, and no review,
stopped on a usage limit; otherwise `incomplete`.

## Pacing

All helper sessions share the operator's Claude plan, and so do the runs inside them. When the plan's 5-hour usage
window runs out, the runs wait for the reset (the harness retries them), but the helper sessions' own turns die too:
their VMs pause and the workers stop until someone types into each session. About 20 sessions started at once
exhausted the window in about an hour. So `launch` keeps at most N projects in a model-heavy step, anything before
grading (checkout, setup, plan, project, waiting for the licence, run, and a launched session that has not reported
yet), and launches the next one when a project moves to grading, review or the end, or fails. Raise N for a larger
plan or a subscription with more headroom; lower it if sessions stall on the limit.

## Launch pitfalls (found the hard way)

- `claude --cloud` refuses to start without a terminal, so `launch` wraps it in `script`: on macOS and BSD
  `script -q <log> claude ...`, with util-linux `script -qec "<command>" <log>`.
- It must run from the repository root: in an untrusted directory it stops at the folder-trust dialog, which nobody
  answers. Open `claude` once interactively in the checkout to trust it.
- The prompt must directly follow `--cloud`: `claude --model M --permission-mode auto -n "<name>" --cloud "<prompt>"`.
- With stdin at end of file the client detaches after printing `Created cloud session: ... session_...`; `launch` takes
  the session id from the pty log, then deletes the log (it can echo the prompt) and the filled prompt; only when no session id appears does it keep
  the log, and says where.
- The cloud environment is the one selected with `/remote-env`; it must have network access Full.
- Attaching to an existing cloud session from the CLI may be unavailable ("not enabled for your account"), so a paused
  session is revived in the browser at its URL (`https://claude.ai/code/<session id>`, printed by `launch` and
  `status`).

## Reviving a stalled session

When `status` flags a project as stalled (usually after the usage window ran out), open its URL and send:

```text
Continue. Check /root/child-<project>.status.json and `pgrep -f child.sh`: if the state is "running" or "waiting" and no worker runs, start it again exactly as in your first message (it continues where it stopped). Then keep polling every 9 minutes as before until the state is done, incomplete or failed.
```

If the session itself is gone, delete `<plan>/<project>/status.json` in the bucket (the claim names the old VM) and
launch the project again with `--projects <project>`; the new VM starts from the bundle and re-runs the project's runs.

## The key in the prompt

The S3 key pair is part of each helper's prompt, so it sits in every session transcript and in the session list of
the operator's account. That is the operator's accepted trade-off for helpers that need nothing configured in the
cloud environment. Hence: a dedicated key, scoped to this one bucket, short-lived, revoked after `collect`. On the
operator's machine the key stays in `cloud.env` (git-ignored); the filled prompt and pty logs live in a private
temporary directory and are deleted, and `sessions.tsv` holds no secret. The S3 helper passes the key to `curl`
through its standard input, not its command line.
