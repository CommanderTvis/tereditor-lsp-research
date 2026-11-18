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

Pilot (2026-11-17, 72 runs, USD 12.82): four validated projects (python-small, typescript-medium, python-large,
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
second refactoring where a project has no mined one; each group ordered by a hash of seed, project and task), 102 tasks
over 34 projects. The allocation:

- Every model on every kept task and every arm: 444 arm-runs per model and repetition (72 non-JVM tasks with 4 arms, 12
  Java tasks with 4, 18 Kotlin and mixed tasks with 6).
- Haiku 5.5: 3 repetitions (about USD 17). Sonnet 5.5: 1 repetition (about USD 49). Opus 5.5: 1 repetition (about
  USD 169). Reviews (Haiku, one per edit diff, about 1,700 of them): about USD 35. Xlarge uplift over the pilot's mix:
  about USD 30. Total about USD 300.
- Reserve, about USD 100: first a second Sonnet repetition, then more Haiku ones, while the projected cost stays under USD
  400 (the figure is an indicative level, a moderate overshoot is acceptable).
- Per-run cap USD 3, 200 turns, 3600 s.

At the final task set the planner (`./study plan --keep 3`) produces 2,220 runs over 102 tasks: Haiku 1,332 (3 repetitions), Sonnet 444,
Opus 444. Summed with the pilot's per-run means that is about USD 233 of agent cost, about USD 293
with the reviews and the xlarge uplift. While the tereditor Kotlin server is expired, `--skip-arms` leaves the
`optional` and `enforced` arms of the 18 Kotlin and mixed tasks out.

The projected cost is recomputed from these means and the final task counts before launching (every run's
`total_cost_usd` is logged, and no new run starts past 125% of the estimate). Dropped tasks lower the average claim made per
project: with 3 tasks a project contributes at most one task per kind, so by-task-type and by-language breakdowns are
small and are shown with their counts, not read as findings.
