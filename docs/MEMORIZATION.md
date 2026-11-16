# Memorization: the contamination this study must design around

Read this before touching task selection, grading or the analysis. It records a measured threat to the validity of the
whole experiment and how the design answers it.

## The problem

The question is whether language-server tools help an agent work on code. Every task is solved by a model that was
trained on public code, and for a public project the model may have seen not only the code but the very change the task
asks for. A model that remembers the fix does not need to search the repository to find what to edit, and a language
server's value is precisely in searching and checking. Memory therefore competes with the treatment:

- It inflates success and deflates cost for the models that remember, without any tool.
- It differs between models, so it is entangled with the model factor: Opus remembers more than Haiku. An arm effect
  that looks smaller for Opus may be memory, not capability.
- It compresses the measured benefit of the tools on exactly the tasks (real, public, well-known pull requests) that
  look most like real work.
- It is invisible in the outcome: a remembered fix passes the tests like any other.

The study's headline contrasts compare arms within a model, so memory is not a bias in the contrast by itself. It is a
modifier of it, and it makes the absolute levels and the model comparisons unreliable. That is enough to need a design
answer.

## What was measured (2026-11-16)

A probe (`harness/memprobe/memprobe.py`, results in `results/memprobe-pre2022/rows.json`) gives a model only the
repository name and the issue text of a mined pull request, no tools and no repository, and asks it to reproduce the
upstream fix as a unified diff from memory. The score is the share of the gold patch's added lines (at least 25
characters, whitespace-normalised) that appear verbatim in the answer, and how many of the changed files it names. As a
control, each answer is also scored against another task's gold patch.

The tasks were the 34 real, pre-2022 mined pull requests then in the repository, over small and medium projects in
Python, TypeScript, C#, Java, PHP and C++, with all three models (102 calls, USD 1.52; the 27 calls that returned
nothing, 9 tasks for each model, count as no answer, leaving 24 tasks per model).

| Model | Gold lines reproduced verbatim (mean) | Changed files named (mean) | Tasks with at least half the lines |
| --- | --- | --- | --- |
| Haiku 5.5 | 6% | 50% | 2 of 24 |
| Sonnet 5.5 | 17% | 65% | 4 of 24 |
| Opus 5.5 | 35% | 77% | 9 of 24 |

The control overlap was 0.0% for every model. The gold patch's added lines are practically never in the issue text, yet
Opus reproduced 182 of the 525 such lines across the tasks, among them 65 of the 95 added lines of
`java-small/pr-734`, 32 of 50 for `python-medium/pr-144`, 4 of 4 for `typescript-small/pr-1068` and 7 of 8 for
`csharp-small/pr-655`.

How to read this: it is an upper bound on memory, not a measurement of it. A small fix can be derived from the issue by
reasoning alone and still match line for line (renames, obvious guards). The sample is small, the 25-character filter
favours long lines, and the 9 unanswered tasks are unexplained. What the control rules out is chance. What it cannot
separate is derivation from recall, which is why the new design does not try: it removes the possibility.

## Why the first design was wrong

The first design took pull requests merged before 2022-11-30 (the release of ChatGPT), on the reasoning that the
reference solution was then written by humans. That rule protects the reference and exposes the experiment: those
exact commits are what the models were trained on. The probe above is the evidence. It was chosen without measuring.

The opposite choice has its own flaw, and it is why the reference solution is not used for grading at all. Pull
requests written after AI assistants became common are merged, in part, unreviewed; their implementations carry
precisely the flaws this study investigates (stale comments, sed-style renames, churn, dead code). A gold patch with
those flaws is a poor standard, and comparing an agent's patch to it would reward copying them. So nothing in the
grading compares the agent's work to a gold patch, for any task, in any form.

## The design

1. Mined tasks come from modern issues and pull requests: opened on or after 2026-07-01 and merged. Anthropic's model
   documentation gives a June 2026 training-data cutoff and a June 2026 reliable-knowledge cutoff for Opus 5.5 and Sonnet
   5.5, and a third-party summary gives it for Haiku 5.5; the models were released between 2026-09-22 and 2026-10-07.
   Requiring the pull request to be opened after the cutoff, not only merged, excludes drafts that were public before it.
   The date is a registered constant (`harness/gen/mine-prs.sh`).
2. The prompt is the issue text. Success is only the pull request's own tests (fail to pass, pass to pass), copied in at
   grade time. The gold patch is used in exactly one place, `./study validate`, to prove that the tests can pass; it is
   never compared with an agent's patch.
3. Non-functional quality is a separate outcome (docs/ANALYSIS_PLAN.md, outcome 3): a Haiku review of the agent's diff
   with read-only access to the edited tree, never shown the gold patch or the arm. The deterministic residue checks
   (old name left in comments, strings and docs; edits outside the intended places) stand beside it.
4. Every candidate task is memorization-probed with all three models before it is accepted, and a task is dropped if any
   model reproduces 25% or more of the gold patch's added lines verbatim, or names every changed file while reproducing
   10% or more. The thresholds are fixed here, before the new tasks exist. The probe reads the gold patch only to score
   itself. The distribution over the accepted tasks goes into the report next to the pre-2022 distribution above.
5. Synthetic tasks (refactorings and navigation questions) are not exposed in the same way: no fix exists to remember, and
   the answers (reference lists, call sets) are not something a model can recite for a large project. The same probe runs
   on the navigation tasks (repository, symbol, "list every use") and its result is reported.
6. The agent cannot look the fix up: its sandbox has no network except the Anthropic API (docs/DESIGN.md, Egress), and
   `./study redteam` checks it.

## Residual risks, stated

- Familiarity with the project: the models know the repositories as they were before July 2026. This is legitimate
  background, the same for every arm, and unavoidable.
- A pull request may have a pre-cutoff discussion, a duplicate issue or an upstream backport; the probe catches the
  consequence, not the cause.
- Some projects have no modern pull requests that can be mined (Drupal's GitHub repository is a mirror with no merged
  pull requests; Angular's changes land through an internal sync). Their slots stay empty and are reported, not filled
  with substitutes.
- Test quality: a modern pull request's tests may be weak or tied to its implementation, a risk that grows with
  unreviewed AI-written changes. A task whose fail-to-pass tests do not exercise public behaviour is dropped, and the
  reason is recorded in the project's `pr-log.md`.
- The cutoff of Haiku 5.5 rests on a third-party source. The probe on the new tasks is the check.
- Models trained after 2026-06 on later data would need the date moved; a later study must rerun the probe.

## What goes into the report

The pre-2022 probe table above, the same table for the accepted tasks, the number of candidates dropped by the probe,
and the model-by-arm contrasts split by each task's memorization score as a covariate. If the new tasks still show
memory, that is reported as a limitation, not hidden.
