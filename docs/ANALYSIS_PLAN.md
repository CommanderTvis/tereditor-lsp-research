# Analysis plan

The analysis of the confirmatory run.

## Scale

The study is a pilot-sized comparison: about USD 400, 3 tasks per project (about 100 tasks), one to three repetitions
(see Allocation). Arms are compared on the same tasks, and every result is an observed difference on those tasks with an
interval that shows how much it would move if the tasks were drawn again. The report states the scale next to the
numbers.

## Units

- A *task* is the unit of generalisation. A *run* is one (task, arm, model, repetition).
- Arms are compared on the same tasks (paired). Within a task and model, repetitions of an arm are averaged first, so a
  task counts once per arm and model.
- Arms: baseline, baseline-review, optional, enforced, and on JVM projects intellij-optional and intellij-enforced.

## Outcomes

1. **Success**: the deterministic grader passes (answer tasks: exact set match; edit tasks: build and the PR's or the
   task's tests, including held-out tests, pass). A run that hits the budget, turn or time cap, crashes, or produces no
   answer is a failure.
2. **Cost**: `total_cost_usd` reported by Claude Code for the run (both turns for baseline-review).
3. **Quality flaws** (edit tasks only): the number of defects a post-hoc review finds in the agent's diff, the
   non-functional damage tests cannot see: old names left in comments, docstrings, strings or docs; edits to unrelated
   places; formatting churn; inconsistent naming; dead code or unused imports the edit left behind. The reviewer is
   `claude-haiku-5-5` through `claude -p`, given the task prompt and the agent's diff with read-only access to the edited
   tree (to search for leftovers), never the gold patch and never the arm; it lists concrete flaws (kind, file, line,
   reason), and "none" is valid. One review per diff, prompt fixed before the first run (`harness/judge/`). A human
   labels a random sample of 30 reported flaws as real or not, and that share is reported with the result. The reviewer
   is the same model as one contestant; the review is identical for every arm, so a contrast is not affected by who
   reviews, but Haiku's own absolute counts may be flattered, which the report states. Review cost counts toward the
   budget. The reviewer never decides pass or fail.

Secondary, descriptive only: F1 on answer tasks; wall time; turns; tokens; tool calls; LSP adoption and call count;
share of runs that hit a cap; stop-hook blocks.

## Contrasts

Every arm against baseline, plus the two that answer the question people actually ask: each LSP arm against
baseline-review (does the tool beat asking the agent to double-check?), and intellij against the tereditor arm of the
same mode on Kotlin and mixed projects. For each, on the tasks where both arms ran:

- Success: difference in percentage points, and the number of task-model cells where the first arm did better, the same,
  or worse.
- Cost: the geometric mean of per-cell cost ratios (first over second), and the number of cells where it was cheaper.
  The arithmetic mean cost per arm is shown beside it, because that is what predicts spend. Cost is taken over all runs;
  a second table restricts to cells solved in both arms, labelled as such.
- Quality flaws: difference in the mean flaw count, with the same better/same/worse counts.

Interval: the 2.5 and 97.5 percentiles of 2,000 resamples of tasks (all of a task's cells move together); it describes
the spread of the difference.

Breakdowns of the same contrasts by model, language, project size, task type, and the memorization score (below) are
tables with the number of tasks beside every cell; a stratum under 10 tasks shows the counts and no interval.

## Exclusions (the only ones)

- A run whose `system/init` event does not match the arm's expected configuration (contamination check).
- A run that never reached the model (infrastructure error before the first API call). It is re-run once with the same
  run id; the failed attempt is kept and counted.
- A task found invalid after the fact (its gold solution fails the grader in the final environment); all its runs in all
  arms are excluded and the task is listed.
- A run whose egress log shows a denied connection attempt aimed at a source of the fix (the project's repository, a
  forge, a package index); other denied attempts are reported only.

API errors after the first model call, caps and timeouts are failures, not exclusions. A run that stops on a usage, quota
or rate limit (a plan's 5-hour window) is not a result: it is discarded and started again from the beginning with the
same run id once the limit has reset; the aborted attempt's cost is logged in `limit-attempts.log` and counts toward the
budget.

## Memorization (docs/MEMORIZATION.md)

Pre-2022 pull requests are partly memorized (Opus 5.5 reproduced 35% of gold lines verbatim from the issue alone), so
mined tasks are modern ones, and each is probed (a measurement, never a filter). Success never compares a patch with the
gold patch. Each task's probe score (the highest verbatim share over the three models; for modern tasks it measures how
easy the fix is to derive from the issue) splits the contrasts at the median. The probe tables go into the report.

## Sample size

Budget is about USD 400, an indicative level: a moderate overshoot is acceptable if it buys something. The run spans
several usage windows without anyone attending it: `./study run` waits out a limit (`LIMIT_WAIT_S`, default 30 minutes)
and continues. Tasks are curated at the count of docs/TASKS.md (6 per project, 3 synthetic and 3 mined, fewer where a project has
none to mine), but only 3 per project run (see Allocation). The allocation below was fixed from a calibration pilot of
per-run costs. If the projected
cost does not fit, tasks are dropped by a rule fixed in advance, not by results: whole projects, largest first within each
language, keeping every language and the synthetic/mined split.

## Allocation (filled in after the pilot, before the confirmatory run)

Pilot (2026-11-17, 72 runs, USD 12.82; results/pilot-2026-11-17): four validated projects (python-small, typescript-medium, python-large,
typescript-large), one synthetic and one pull-request task each, all three models, arms baseline, baseline-review and
enforced, one repetition, per-run cap USD 2. Mean cost per run in USD:

| Model | baseline | enforced | baseline-review | small | medium | large |
| --- | --- | --- | --- | --- | --- | --- |
| Haiku 5.5 | 0.008 | 0.012 | 0.021 | 0.009 | 0.009 | 0.018 |
| Sonnet 5.5 | 0.058 | 0.111 | 0.164 | 0.101 | 0.054 | 0.145 |
| Opus 5.5 | 0.264 | 0.353 | 0.611 | 0.290 | 0.262 | 0.543 (max 2.39) |

Enforced costs about 1.3 times the baseline and the self-review arm about 2.3 times. The first design (6 tasks per
project, about 190 tasks) cost about USD 460 for one repetition of every cell, three quarters of it Opus, which does not
fit USD 400. The lever is the number of tasks, not the models or the arms: every project keeps 3 tasks, chosen by the
planner's seeded rule (`./study plan --keep 3`: one refactoring, one navigation question and one mined pull request, a
second refactoring where a project has no mined one; each group ordered by a hash of seed, project and task), 87 tasks
over 29 projects. The allocation:

- Every model on every kept task and every arm: 372 arm-runs per model and repetition (63 non-JVM tasks with 4 arms, 12
  Java tasks with 4, 12 Kotlin and mixed tasks with 6).
- Haiku 5.5: 3 repetitions (about USD 17). Sonnet 5.5: 1 repetition (about USD 49). Opus 5.5: 1 repetition (about
  USD 169). Reviews (Haiku, one per edit diff, about 1,700 of them): about USD 35. Xlarge uplift over the pilot's mix:
  about USD 30. Total about USD 300.
- Reserve, about USD 100: first a second Sonnet repetition, then more Haiku ones, while the projected cost stays under USD
  400 (the figure is an indicative level, a moderate overshoot is acceptable).
- Per-run cap USD 3, 200 turns, 3600 s.

At the final task set the planner (`./study plan --keep 3`) produces 1,860 runs over 87 tasks (29 projects, see "Postponed projects" in docs/TASKS.md): Haiku 1,116 (3 repetitions), Sonnet 372,
Opus 372. Summed with the pilot's per-run means that is about USD 233 of agent cost, about USD 293
with the reviews and the xlarge uplift.

The projected cost is recomputed from these means and the final task counts before launching (every run's
`total_cost_usd` is logged, and no new run starts past 125% of the estimate). Dropped tasks lower the average claim made per
project: with 3 tasks a project contributes at most one task per kind, so by-task-type and by-language breakdowns are
small and are shown with their counts, not read as findings.

## Notes from the cloud run (2026-11-21)

- The quality-flaw reviewer of outcome 3 did not exist in the repository when the cloud run started (`harness/judge/`
  was referenced but absent). The cloud session wrote it before the pilot and before the first confirmatory run, as
  this plan describes it: `harness/judge/prompt.md` (fixed from here on), `harness/env/review-one.sh` and
  `./study review <plan>`. Haiku 5.5 through `claude -p` in the agent sandbox, one review per edit run, given the task
  prompt, the agent's diff and the edited tree; the arm's overlay files and `ANSWER.txt` are excluded from both, so the
  reviewer cannot see the arm. Answer tasks, empty diffs and diffs that do not apply get no review (`flaws` blank).
  The flaw count goes into `runs.csv` (`flaws`, `review_cost_usd`); review cost counts toward the budget.
- The human labelling of 30 reported flaws cannot be done by the cloud session; it delivers the random sample for the
  owner to label.

### Recomputed before the confirmatory run (cloud session, 2026-11-22)

Second pilot on the current pins in the cloud VM, every arm: `pilot` (python-small, typescript-medium, csharp-small,
java-medium; Haiku and Sonnet; `--keep 3`; 96 runs, USD 4.56 agent cost) and `pilot-opus` (java-large, Opus, the four
Java arms; 12 runs, USD 6.51). Mean USD per run:

| Model | baseline | baseline-review | optional | enforced | intellij-optional | intellij-enforced |
| --- | --- | --- | --- | --- | --- | --- |
| Haiku 5.5 (small, medium) | 0.0071 | 0.0160 | 0.0069 | 0.0115 | 0.0054 | 0.0131 |
| Sonnet 5.5 (small, medium) | 0.053 | 0.128 | 0.063 | 0.089 | 0.050 | 0.125 |
| Opus 5.5 (java-large) | 0.351 | 0.938 | (0.416) | (0.585) | 0.377 | 0.504 |

Opus optional and enforced in brackets: Opus baseline times Sonnet's ratio to its baseline. Size factors from the first
pilot: Haiku and Sonnet large x2, xlarge x2.5; Opus small and medium x0.5, xlarge x1.25. Projection for the planned
allocation (3/1/1, 1,860 runs): Haiku USD 16, Sonnet USD 44, Opus USD 146, reviews about USD 4, total about USD 210.
The reserve's first item, a second Sonnet repetition (about USD 44), fits, so it is part of the plan: `./study plan main
--keep 3 --reps-per-model "claude-haiku-5-5=3,claude-sonnet-5-5=2,claude-opus-5-5=1" --budget 3 --turns 200 --timeout
3600`, 2,232 runs (Haiku 1,116, Sonnet 744, Opus 372), projected about USD 255. Further Haiku repetitions (the reserve's
second item, about USD 5 each) are not added: the binding limit in one cloud session is run time, not money. No new
run starts past 125% of USD 400 (USD 500).

Harness fixes made in the cloud session before this plan (all before any confirmatory run; none changes what an agent
sees): `harness/env/probe.sh` tolerates a non-JSON tool answer; the server sandbox gives Maven started by IntelliJ's
import the proxy's trust store (`~/.mavenrc`) and fetches a project's Maven wrapper distribution during preparation
(without both, IntelliJ had no project model on Maven projects behind the cloud proxy: java-small, java-medium).

### Found during the confirmatory run (2026-11-22, cloud session)

- tereditor's own language-server limit: on the 15 GB cloud VM it budgets 4,826 MiB for all language servers of one
  agent run together and kills them all when they exceed it (`stopped by the language server limits: all language
  servers together exceeded the 4826 MiB memory budget`). It hit IntelliJ arms on java-kotlin-large, where IntelliJ
  ran beside the other servers the agent's calls had started. The sandboxes have separate PID namespaces, so a run's
  budget counts only its own servers; the parallel run (`-j 2`) does not enter it. A tereditor finding, not a harness
  defect: nothing was changed, the runs stand as they are (no exclusion rule applies), and the report gives the count
  of runs whose agent saw such a kill.
- `analysis/extract.py` read a task's type with `[a-z]+`, which cut `rename-file` to nothing; fixed to `[a-z-]+`
  before the analysis (it only labels the by-task-type breakdown).

### Usage-limit stops kept as results (found 2026-11-23, repaired from the owner's Mac)

- The 22 remaining projects ran in parallel cloud sessions, one per project, all on the owner's one plan. The 5-hour
  usage window ran out at about 23:30 UTC on 2026-11-22 (reset 01:30). The harness's limit check matched only the
  result text against older wording; Claude Code 2.1.323 writes "You've hit your 5-hour limit · resets 1:30am (UTC)"
  with `api_error` `usage_limit_reached` (status 429), which none of the patterns matched. So 619 agent runs in 12
  projects (median 1 s each, almost all cost USD 0) were kept as finished, failed runs, and 43 quality reviews
  (shell-medium 35, css-small 8) as unparsed reviews, against this plan's rule that such a run is not a result.
- Fix (with the owner's approval, during the run; nothing an agent sees changed): `limit_stop` in
  `harness/env/lib.sh`, used by `run-one.sh` and `review-one.sh`, checks the structured fields first (`api_error`,
  status 429, a rejected `rate_limit_info`) and the text second; `./study run` and the review wait until the
  `resetsAt` the stream reports instead of a fixed 30 minutes, and a review now waits as long as it takes. Checked
  against all 26 archives collected so far: it flags exactly the 619 runs that carry `usage_limit_reached`, nothing else.
- Repair: per affected project, the limit-stopped run directories (and limit-stopped reviews) are deleted, their cost
  is appended to `limit-attempts.log`, and the same run ids are run, graded and reviewed again (`control/repair.sh`).
  The repaired runs therefore ran later than their neighbours in the plan's order, on the same pins.
- Found by the first repair (2026-11-23): `./study grade`, `./study review` and `./study archive` listed a project's
  pending runs in a `while` loop whose last test (`[ … ] && echo`) failed when the project's last planned run was
  already graded (or reviewed, or unfinished for archive); under `set -e` the driver then exited 1 without a message.
  A first full pass never meets this; a repair, with a few pending runs, does. The tests are now `if … fi`. No result
  was affected: the repair of cpp-medium ended `incomplete` (one run ungraded) and is simply repeated.
