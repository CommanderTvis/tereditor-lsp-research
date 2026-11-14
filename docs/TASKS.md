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

Every type has a deterministic grader. No LLM judge is used anywhere.

| Id | Type | Origin | Agent output | Grader |
| --- | --- | --- | --- | --- |
| `refs` | Find all usages of a symbol | devrig find-usages; Barber retrieval | `ANSWER.txt` | set precision, recall, F1 against `oracle.txt`; success = F1 = 1 |
| `impls` | Type hierarchy: all transitive implementations / subclasses | devrig type hierarchy | `ANSWER.txt` | as `refs` |
| `dispatch` | Which definition runs for a call through indirection (factory, interface, override) | Barber dispatch ladder | `ANSWER.txt` | exact match |
| `callers` | Call reachability: which entry points transitively reach a function | devrig call hierarchy | `ANSWER.txt` | as `refs` |
| `inspect` | Which of K candidate files contain a defect class (half true, half decoys) | devrig inspections | `ANSWER.txt` | as `refs`, oracle from the compiler or a linter |
| `rename` | Rename a widely used symbol everywhere | devrig safe rename | the edit | build + project tests + hidden check that the old name is gone from the API |
| `signature` | Add a parameter through overrides and call sites | devrig change signature | the edit | build + hidden tests |
| `compile` | The build is broken in N places by an API change; fix it | checker-detectable defects (Barber) | the edit | build (and tests) pass |
| `bugfix` | A seeded semantic bug, described by symptom; fix it | Barber held-out tests; SWE-bench style | the edit | hidden tests pass, visible tests still pass |

Task counts are balanced in the design rather than reweighted afterwards (docs/research/task-type-weighting.md):

- Small, medium and large projects: 6 tasks each, `refs`, `rename`, `compile`, `bugfix`, plus 2 of `impls`,
  `dispatch`, `callers`, `inspect`, `signature` on a fixed rotation across projects, so each of the five appears
  equally often; the rotation is balanced separately within the JVM projects (Kotlin, Java, mixed), whose arms differ.
- Xlarge projects: 3 tasks each, `refs`, `compile` and one rotating answer type (`impls`, `dispatch`, `callers`,
  `inspect`).
- At most 186 tasks in all. A type the language cannot express (Shell and CSS have no `impls` or `signature`) is
  replaced by the next type in the rotation, and `project.toml` says which.

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
