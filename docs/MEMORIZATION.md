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

## What was measured

Given only the repository name and the issue text of a merged pre-2022 pull request, with no tools, the models
reproduce the upstream fix from memory (`harness/memprobe/memprobe.py`, rows in `results/memprobe-pre2022/rows.json`).
Share of the gold patch's added lines that appear verbatim in the answer (lines of at least 25 characters), and of its
changed files that the answer names:

| Model | Gold lines reproduced verbatim | Changed files named | Tasks with at least half the lines |
| --- | --- | --- | --- |
| Haiku 5.5 | 6% | 50% | 2 of 24 |
| Sonnet 5.5 | 17% | 65% | 4 of 24 |
| Opus 5.5 | 35% | 77% | 9 of 24 |

The control (the same answers scored against another task's gold patch) is 0% for every model, and the gold lines are
practically never in the issue text. Opus reproduced, among others, 65 of the 95 added lines of `java-small/pr-734` (square/javapoet) and 32 of 50 for `python-medium/pr-144` (Textualize/rich); recall was also strong on pytoolz/toolz, ianstormtaylor/superstruct, MediatR and guzzle/guzzle, all fixes merged before November 2022. This is an upper bound, since small fixes
can be derived by reasoning alone, but it cannot be chance: models remember the patches of well-known repositories
made before their cutoff, Opus most.

### The accepted modern tasks

All 79 accepted mined tasks were probed the same way (scores in `results/memprobe-accepted.json`, per task in
each task's `memprobe.txt`). The median of the worst score over the three models is 0. 10 tasks reach 25%, all of them
with gold patches under 15 added lines, where a fix derived from the issue can match line for line. Of the 38 tasks
with 15 or more added lines, none reaches 25%: after the cutoff the models do not reproduce the change.

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
   5.5. For Haiku 5.5 the documentation was not found, but asked directly through `claude -p` (the path the study uses,
   2026-11-16) all three models answered "June 2026", as did a claude.ai chat shown to the owner; the models were
   released between 2026-09-22 and 2026-10-07.
   Requiring the pull request to be opened after the cutoff, not only merged, excludes drafts that were public before it.
   The date is a constant (`harness/gen/mine-prs.sh`).
2. The prompt is the issue text. Success is only the pull request's own tests (fail to pass, pass to pass), copied in at
   grade time. The gold patch is used in exactly one place, `./study validate`, to prove that the tests can pass; it is
   never compared with an agent's patch.
3. Non-functional quality is a separate outcome (docs/ANALYSIS_PLAN.md, outcome 3): a Haiku review of the agent's diff
   with read-only access to the edited tree, never shown the gold patch or the arm. The deterministic residue checks
   (old name left in comments, strings and docs; edits outside the intended places) stand beside it.
4. Every candidate task is memorization-probed with all three models, but the probe is a measurement, not a filter. For
   modern pull requests no model can remember the change, so a high score means the fix is easy to derive from the issue.
   Such tasks are kept: for them the difference in token cost between arms is exactly what the study wants to see, and
   dropping them would select tasks by model behaviour. Each task's score is a covariate (docs/ANALYSIS_PLAN.md). The
   probe has one more job, a check on the cutoff itself: modern tasks whose gold patch has 15 or more added lines should
   score near zero, since derivation alone rarely reproduces that much verbatim. If they do not, the cutoff claim is
   false and the date must move; `memprobe.py` flags such tasks. The probe reads the gold patch only to score itself.
5. Synthetic tasks (refactorings and navigation questions) are not exposed in the same way: no fix exists to remember, and
   the answers (reference lists, call sets) are not something a model can recite for a large project. The same probe runs
   on the navigation tasks (repository, symbol, "list every use") and its result is reported.
6. The agent cannot look the fix up: its sandbox has no network except the Anthropic API (docs/DESIGN.md, Egress), and
   `./study redteam` checks it.

## Residual risks, stated

- Familiarity with the project: the models know the repositories as they were before July 2026. This is legitimate
  background and the same for every arm, but it is not unavoidable: see "Possible direction: new projects" below.
- Some projects have no modern pull requests that can be mined (Drupal's GitHub repository is a mirror with no merged
  pull requests; Angular's changes land through an internal sync). Such a project is replaced by a live one of the same
  language and size tier (a project's liveness, the number of merged pull requests opened since 2026-07-01, is checked
  when it is chosen, docs/PROJECTS.md); a slot is left empty and reported only when a live project still yields too few.
- Test quality is not judged. The tests of a merged pull request are what the maintainers accepted, in a world where
  part of that code and those tests are AI-written; the study measures what an agent does against that standard, as a
  developer joining the project would face it. A task is dropped for being unbuildable or unvalidatable, never for weak tests
  or for a high probe score.

## Possible direction: new projects (not adopted)

Modern pull requests remove the memory of the change, not of the project. The only way to remove the second is to give
the models a project they have never seen, which means vibe-coding one: an agent writes it from a specification after the
cutoff, the result is frozen as an archive with a hash, and the tasks are set on it.

The obvious objection is that such a project starts messy: duplicated code, inconsistent naming, stale comments, dead
code. It may matter less than it looks, because the study judges diffs, not whole projects. The flaw review counts what
an agent's edit introduces or leaves behind. For that to hold, three things must be done:

- Flaws are counted as a difference: review the tree before and after the edit and count only the flaws that are new.
  A stale mention that was already in the project is not the agent's. The same applies to the deterministic residue
  checks.
- The starting mess is a covariate. A messier project makes some tasks harder (more places to update) and some easier
  (more to find by search alone). Report the arm contrasts by a simple messiness measure (duplicate blocks, comment
  and name inconsistencies counted by a fixed script).
- The oracles stay independent of a language server: compiler mutation, another analyser, and hidden tests written
  together with the project.

What it would cost or change:

- No real history: there are no issues, pull requests or reviews, so the mined-task analogue disappears. Feature and bug
  tasks would be written by the same generator, with tests that an AI wrote, which is the weakness this document warns
  about for modern pull requests, concentrated.
- Self-familiarity: code written by a Claude model is predictable to Claude models in its style and structure. It could
  flatter every arm, or one model family more than another. The generator's identity would have to be fixed and
  reported, and ideally varied.
- Realism and size: a generated project is not a project that lived through years of maintenance. Reaching the large and
  xlarge tiers (hundreds of thousands of lines) by generation is expensive, and a language server's value is largest
  on exactly such code.
- Reproducibility gains: a frozen archive removes the dependence on a repository staying available and on its toolchain
  history.

A cheap measurement should come before any such work: does project familiarity matter at all? Ask each model, with
no tools, to list the references of a named symbol in a real pre-cutoff repository from memory, over a spread of
sizes, and compare with the same question about a symbol of a generated project. If the models recall nothing about
large repositories, the residual risk is small and generation is not worth its cost. If they do, the first step is a
generated stratum run beside the real projects (not instead of them) and the report compares the two.

This direction is recorded, not adopted. The design above stands.

## What goes into the report

The pre-2022 probe table above, the same table for the accepted tasks (with the cutoff check on the large gold patches),
and the model-by-arm contrasts split by each task's probe score as a covariate. If large modern patches still score
high, that is reported as a limitation, not hidden.
