# Analysis plan (pre-registered)

Written and committed before any model run of the confirmatory study. Changes after that point are listed at the end
with their date and reason; the original text stays.

## Units

- A *task* is the unit of generalisation. A *run* is one (task, arm, model, repetition).
- Every task runs in all three arms with every model it is assigned to, the same number of repetitions per arm, so
  arm contrasts are paired within task x model.

## Primary outcomes

1. **Success**: the deterministic grader passes (answer tasks: exact set match, F1 = 1; edit tasks: build and tests,
   including held-out tests, pass). A run that hits the budget, turn or time cap, crashes, or produces no answer is a
   failure.
2. **Cost**: `total_cost_usd` reported by Claude Code for the run.

## Secondary outcomes

F1 on answer tasks; wall time; turns; input+output tokens; number of tool calls; Read bytes; LSP adoption (any
`lsp_*` call) and LSP call count; share of runs that hit a cap; stop-hook blocks (enforced arm).

## Primary hypotheses

For each of these pairs of arms, pooled over everything else in the tasks where both arms run:

- SharpRail: optional vs baseline, enforced vs baseline, enforced vs optional (all projects);
- IntelliJ: intellij-optional vs baseline, intellij-enforced vs baseline (JVM projects), and intellij-optional vs
  optional, intellij-enforced vs enforced (Kotlin and mixed projects, where both servers exist);

- H1: success differs.
- H2: cost differs.

Fourteen primary tests (seven pairs, two outcomes). Holm correction over the fourteen. alpha = 0.05.

## Models

- Success: logistic mixed model, `success ~ arm * model + (1 | task)`, with `project` as a further random intercept
  if it converges; estimated with `statsmodels` BinomialBayesMixedGLM, and as a robustness check a GEE with
  exchangeable correlation clustered on task. Reported as success-rate differences (percentage points) with 95%
  intervals from a task-clustered bootstrap (10,000 resamples of tasks, keeping all runs of a resampled task).
- Cost: linear mixed model on log(cost), `log_cost ~ arm * model + (1 | task)`, reported as cost ratios with 95%
  task-clustered bootstrap intervals. Cost is analysed on all runs, not only successful ones; a second table restricts
  to tasks solved at least once in every arm (survivor-matched, as Barber did), labelled as such.
- Pairwise arm tests: the arm contrasts of these models. As a model-free check, a paired permutation test on task-level
  means (sign-flip of per-task arm differences, 10,000 permutations).

## Secondary analyses (exploratory, Benjamini-Hochberg at 5% within each family)

- Arm effect by model, by language, by project size, by task type (interaction terms; per-stratum bootstrap intervals).
- Navigation versus edit tasks.
- LSP adoption in the optional arm, and whether adoption predicts success within that arm (observational, labelled).
- Cold start: language-server readiness time per project from the probe and the call log; the share of runs whose
  first LSP call answered `initializing`.
- Projects where the LSP probe failed are reported separately and also excluded in a sensitivity analysis.

## Exclusions (the only ones)

- A run whose `system/init` event does not match the arm's expected configuration (contamination check).
- A run that never reached the model (infrastructure error before the first API call: container failed to start,
  API 5xx on the first request). It is re-run once with the same run id; the failed attempt is kept and counted.
- A task found invalid after the fact (its gold solution fails the grader in the final environment); all its runs in
  all arms are excluded and the task is listed.

API errors after the first model call, caps and timeouts are failures, not exclusions.

## Sample size

Budget is about USD 2,000. A calibration pilot measures cost per run per model x size and the between-task variance
of success; the run allocation (repetitions per model) is fixed from it before the confirmatory runs and recorded
below. Allocation rule: every task x arm x model cell gets at least one run; repetitions are added in the order
Haiku, Sonnet, Opus while the projected cost stays under budget, and equally across arms.

## Allocation (filled in after the pilot, before the confirmatory run)

_pending_

## Changes after registration

_none_
