# Task and project format

This is the contract every project and task in the study follows. The harness, graders and analysis read these files
and nothing else.

## Projects and tasks

A project (`projects/<lang>-<size>/`) is its pinned upstream repository plus what the harness needs to run it: the
identity, pin, measured size and probe symbols (`project.toml`), how the language server is prepared without a
compiler (`prepare.sh`), and how its build and test dependencies are fetched once (`grade-setup.sh`, with network) and how it is built
and tested at grade time, without network (`check.sh`).

A task (`tasks/<lang>-<size>/<task-id>/`) is the prompt given to the agent, identical in every arm (`prompt.md`), its
type (`task.toml`), an optional starting state (`setup.patch`: a seeded bug, a broken build), and its grading: held-out
tests that the agent never sees (`hidden/`), the ground truth of answer tasks with how it was derived (`oracle.txt`,
`oracle.md`), task-specific checks (`grade.sh`), and a reference solution that proves the task solvable
(`gold.patch`).

`<lang>` is one of `csharp typescript python php cpp kotlin java java-kotlin shell css` (`java-kotlin`: one project
where both languages carry real code and call each other). `<size>` is `small medium large xlarge`.

## Snapshots

- The upstream repository at a pinned full commit SHA, re-committed as a single commit (no history: history could
  reveal fixes for seeded bugs and is not what the study measures).
- Removed before the commit: `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.claude/`, `.cursor/`, `.cursorrules`,
  `.github/copilot-instructions.md`, `.windsurfrules`, `.tereditor/`, `.mcp.json`, `.vscode/`, `.idea/` and any other
  agent or editor instruction file. `project.toml` lists what was removed.
- A task's `setup.patch` is applied and committed as a second commit, so `git log` shows nothing task-specific beyond
  "task setup". The arm overlay (enforced arm only) is a third commit. The graded diff is against the last of these.
- Generated artefacts the language server needs to understand the project (restored packages, a compilation database,
  a Gradle model) are produced by `prepare.sh` in the image, the same for every arm, and are git-ignored.

## Size classes

Code lines in the project's main language, measured identically for every language (`scc`, blank and comment
lines excluded, tests included, vendored code skipped); bands, the measurement script and the chosen projects are in
[PROJECTS.md](PROJECTS.md). Record the count in `project.toml` (`loc`, `loc_by_language`).

| Size | Band (code lines) | Target |
| --- | --- | --- |
| small | 3k to 12k | 6k |
| medium | 25k to 80k | 45k |
| large | 140k to 450k | 250k |
| xlarge | 700k to 3M | 1.2M |

`xlarge` projects exist to measure what happens where text search and whole-file reading stop scaling and where a
language server's indexing cost is highest. They may be too big to build or test as a whole: their edit tasks are
graded by a targeted build and test of the affected modules (`grade.sh`), and answer tasks need no build at grade
time. Two to four tasks per `xlarge` project are enough. Record the language server's memory need and readiness time;
`STUDY_MEMORY` may go to 12g or 16g for them, and they run one at a time.

## Task types

Every task has a deterministic grader for success; no LLM judge decides pass or fail. A separate Haiku review counts quality flaws in an edit's diff (docs/ANALYSIS_PLAN.md, outcome 3). Half the tasks are synthetic, generated from
the pinned snapshot; half are mined from the project's own merged pull requests.

| Id | Kind | Type | Agent output | Grader |
| --- | --- | --- | --- | --- |
| `rename` | synthetic refactoring | Rename a widely used symbol everywhere | the edit | build and tests pass; the old name is gone and the new one exists (hidden check) |
| `rename-file` | synthetic refactoring | Rename a source file or module, updating every import and reference | the edit | build and tests pass; old path gone, new path present |
| `move` | synthetic refactoring | Move a file or class into another package, namespace or module, updating every reference | the edit | build and tests pass; declared in the new place only |
| `signature` | synthetic refactoring | Add, remove or reorder a parameter through overrides and call sites | the edit | build and hidden tests pass |
| `refs` | synthetic navigation | Find all usages of a symbol | `ANSWER.txt` | exact set match (precision, recall and F1 reported) |
| `impls` | synthetic navigation | All transitive implementations or subclasses of a type | `ANSWER.txt` | as `refs` |
| `dispatch` | synthetic navigation | Which definition runs for a call through indirection | `ANSWER.txt` | exact match |
| `callers` | synthetic navigation | Which entry points transitively reach a function | `ANSWER.txt` | as `refs` |
| `inspect` | synthetic navigation | Which of K candidate files contain a defect class (half true, half decoys) | `ANSWER.txt` | as `refs`, oracle from the compiler or a linter |
| `pr` | mined | Resolve the issue a merged pull request resolved, from the issue text | the edit | the pull request's tests: the ones it made pass (fail to pass) now pass, the rest still pass |

Counts per project (provisional; the calibration pilot fixes repetitions under the budget, docs/ANALYSIS_PLAN.md):

- Small, medium and large projects: 6 tasks, 3 synthetic (2 refactorings rotating through `rename`, `rename-file`,
  `move`, `signature`, and 1 navigation question rotating through `refs`, `impls`, `dispatch`, `callers`, `inspect`)
  and 3 `pr`.
- Xlarge projects: 6 tasks, 3 synthetic and 3 `pr`. Resource limits can prevent validating a project's snapshot, but
  they do not reduce its task set; such projects record the limitation and use documented fallback tasks.
- Rotations are fixed across projects so each type appears equally often, and balanced separately within the JVM
  projects (Kotlin, Java, mixed), whose arms differ. A type a language cannot express (Shell and CSS have no
  `impls`, `move` between packages or `signature`) is replaced by the next type in its rotation, and `project.toml`
  says which. A project without enough qualifying pull requests fills its `pr` places with synthetic tasks, recorded
  the same way.

The assignment, fixed before any task is written (the rotations above, applied in the order of docs/PROJECTS.md;
204 task slots over 34 projects: 102 synthetic and 102 mined or documented fallback slots. `kotlin-xlarge` has no slot: no buildable project qualified, `projects/kotlin-xlarge/project.toml` says why, and docs/PROJECTS.md shows none. `java-kotlin-xlarge` has its 3 synthetic tasks, and its mined slots are open, see its `project.toml`):

| Project | Synthetic | Mined (`pr`) |
| --- | --- | --- |
| `python-small` | `rename`, `rename-file`, `refs` | 3 |
| `python-medium` | `move`, `signature`, `impls` | 3 |
| `python-large` | `rename`, `rename-file`, `dispatch` | 3 |
| `python-xlarge` | `dispatch`, `rename-file`, `refs` | 3 |
| `typescript-small` | `move`, `signature`, `callers` | 3 |
| `typescript-medium` | `rename`, `rename-file`, `inspect` | 3 |
| `typescript-large` | `move`, `signature`, `refs` | 3 |
| `typescript-xlarge` | `impls`, `dispatch`, `callers` | 3 |
| `csharp-small` | `rename`, `rename-file`, `impls` | 3 |
| `csharp-medium` | `move`, `signature`, `dispatch` | 3 |
| `csharp-large` | `rename`, `rename-file`, `callers` | 3 |
| `csharp-xlarge` | `refs`, `rename`, `dispatch` | 3 |
| `php-small` | `move`, `signature`, `inspect` | 3 |
| `php-medium` | `rename`, `rename-file`, `refs` | 3 |
| `php-large` | `move`, `signature`, `impls` | 3 |
| `php-xlarge` | `inspect`, `refs`, `callers` | 3 |
| `cpp-small` | `rename`, `rename-file`, `dispatch` | 3 |
| `cpp-medium` | `move`, `signature`, `callers` | 3 |
| `cpp-large` | `rename`, `rename-file`, `inspect` | 3 |
| `cpp-xlarge` | `dispatch`, `inspect`, `refs` | 3 |
| `shell-small` | `move`, `signature`, `refs` | 3 |
| `shell-medium` | `rename`, `rename-file`, `impls` | 3 |
| `css-small` | `move`, `signature`, `dispatch` | 3 |
| `css-medium` | `rename`, `rename-file`, `callers` | 3 |
| `kotlin-small` | `rename`, `rename-file`, `refs` | 3 |
| `kotlin-medium` | `move`, `signature`, `impls` | 3 |
| `kotlin-large` | `rename`, `rename-file`, `dispatch` | 3 |
| `java-small` | `move`, `signature`, `callers` | 3 |
| `java-medium` | `rename`, `rename-file`, `inspect` | 3 |
| `java-large` | `move`, `signature`, `refs` | 3 |
| `java-xlarge` | `rename`, `impls`, `rename` | 3 |
| `java-kotlin-medium` | `rename`, `rename-file`, `impls` | 3 |
| `java-kotlin-large` | `move`, `signature`, `dispatch` | 3 |
| `java-kotlin-xlarge` | `rename`, `dispatch`, `refs` | 3 |

Synthetic tasks are generated by scripts with a fixed seed, sampling candidates by rules fixed in advance (for
example, a symbol with at least N references in M files, whose name also occurs for other symbols); reference
solutions come from a refactoring tool that is not one of the tested language servers, or from a compiler-checked
script.

## Mined pull requests

Selected as SWE-bench selects them, with the study's own cutoff:

- Opened on or after 2026-07-01 and merged into the default branch: after the June 2026 training-data cutoff of every
  model of the study, so the fix cannot be remembered (docs/MEMORIZATION.md, which gives the measured reason). Authors
  that are bots are excluded.
- The prompt is the title and body of the issue the pull request closes (closing keywords) or, when it closes none, of the
  pull request itself; links to the project's issues and pull requests are removed, since the agent has no network.
- Changes non-test source files in the project's language, and adds or changes tests.
- Fail to pass: at least one test fails at the pull request's base commit and passes with the merged change. Pass to
  pass: the other tests of the affected modules pass before and after.
- Builds and runs those tests with the study's current toolchains (`grade-<group>`); pull requests that need an older
  toolchain are skipped (rare for modern pull requests).
- The task's starting point is the pull request's base commit (`base_commit` in `task.toml`), not the project's
  pinned commit; the task records the merge date and the code lines at its base commit.
- Hidden tests are the pull request's test changes; `gold.patch` is its non-test change and is used only by
  `./study validate` (the tests can pass). Nothing grades an agent by comparing its patch with it: modern pull requests
  are partly unreviewed and carry the flaws this study measures.
- Memorization probe: `harness/memprobe/memprobe.py` runs all three models on each accepted task's issue with no tools.
  It is a covariate and a check on the training cutoff, never a filter (docs/MEMORIZATION.md).

## Answers

Answer tasks ask the agent to write `ANSWER.txt` at the workspace root, one item per line, in the exact form the
prompt specifies:

- locations: `relative/path:line` (1-based line of the symbol occurrence), sorted order not required;
- names: a fully qualified name per line when the task asks for types or entry points.

The grader normalises whitespace, a leading `./`, and duplicate lines. Nothing else is forgiven.

## Oracles must not come from the tool under test

Ground truth for `refs`, `impls`, `callers` and `inspect` is derived without the language server tereditor runs:
compiler-driven mutation (rename the declaration, build, collect the errors), a different analyser (mypy for Python,
PHPStan for PHP, `kotlinc` for Kotlin, `clang -fsyntax-only` with the real compilation database for C/C++, `sass`
for SCSS), or an exhaustive text candidate list checked by hand. `oracle.md` records which, with commands, and lists
any item that needed a judgement call. A task whose ground truth is ambiguous is dropped, not argued.

## Validity checks (run before any model is spent)

For every task, in the grading sandbox:

1. The unmodified starting state FAILS the grader (for edit tasks) or an empty `ANSWER.txt` scores 0.
2. `gold.patch` (or `oracle.txt` copied to `ANSWER.txt`) PASSES the grader.
3. The grader is deterministic: two runs of 2. give the same result.

For every project, through the same bridge and server sandbox as a run: the LSP probe (`./study probe`) gets correct cross-file `references` and
`definition` results for the symbols in `project.toml` within the readiness timeout. A project whose language server
cannot do this is reported as such and kept, because that is a finding about the product, but it is analysed
separately (see ANALYSIS_PLAN.md).

## Prompts

- Written as a developer would write a ticket: what to do, the answer format if any, nothing about tools.
- The same file is given in every arm. The fixed preamble that every prompt gets (environment description) is in
  `harness/prompt-preamble.md`.
- Never mention LSP, grep, or any tool name; never say how many results to expect.

## Postponed projects

Rule: a project of any size that cannot be developed normally inside the 30 GB cloud VM of docs/CLOUD_RUN.md (about 40 GB of disk in
total, 14 GB of it the base image; 15 GB of memory) is postponed. Its project and tasks stay in the repository with everything already
done; its `project.toml` says `status = "postponed"` with the measured reason, and `analysis/plan.sh` does not plan it. To turn it on,
set `status = "curated"` and validate it on a larger machine.

Measured in the cloud VM (peak disk used in total, base image included, of about 40 GB):
`python-xlarge` fits, `php-xlarge` fits (36 GB, after the composer fallback), `cpp-xlarge` fits (27 GB), `java-xlarge` fits (27 GB, Gradle
from the Maven Central mirror), `java-kotlin-large` fits (24 GB).
`typescript-xlarge`, `csharp-xlarge`, `java-kotlin-xlarge` (only when handled one commit at a time), `kotlin-large` and `csharp-large` ran out of disk, so these five are postponed. Each project's
`vm_note` or `postponed_reason` is in its `project.toml`.
