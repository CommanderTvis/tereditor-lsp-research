# Does a language server make a Claude Code agent better, faster or cheaper?

Study design. The analysis is fixed in advance in [ANALYSIS_PLAN.md](ANALYSIS_PLAN.md); task and project rules are in
[TASKS.md](TASKS.md).

## Question

Given the same Claude Code agent, the same model, the same task and the same environment, what changes when the
agent also has tereditor's language-server tools (`lsp_navigate`, `lsp_diagnostics`, `lsp_status`,
`lsp_code_actions`, `lsp_rename`, `lsp_format`, served by headless tereditor over MCP)? And does it matter whether the
agent is merely offered them or pushed to use them?

## Factors

| Factor | Levels |
| --- | --- |
| Arm | `baseline`, `baseline-review`, `optional`, `enforced`, `intellij-optional`, `intellij-enforced` (below) |
| Model | `claude-haiku-5-5`, `claude-sonnet-5-5`, `claude-opus-5-5`, through `claude -p`, each at Claude Code's default effort (`medium` for all three) |
| Language | every language headless tereditor serves: C#, TypeScript/JavaScript, Python, PHP, C/C++, Kotlin, Shell, CSS/SCSS; plus Java and mixed Java+Kotlin for the IntelliJ arms |
| Project size | small, medium, large (lines of code, see TASKS.md) |
| Task | half synthetic (refactorings: `rename`, `rename-file`, `move`, `signature`; navigation: `refs`, `impls`, `dispatch`, `callers`, `inspect`), half mined pull requests opened after 2026-07-01 (docs/TASKS.md, docs/MEMORIZATION.md) |
| Repetition | independent runs of the same cell |

Tasks are nested in projects, projects in language x size. Arm and model are crossed with every task.

## Arms

All three arms run the same image, the same Claude Code version, the same flags, the same prompt and the same
starting workspace. They differ only in what is listed here.

| | baseline | optional | enforced |
| --- | --- | --- | --- |
| tereditor MCP server | none | yes | yes |
| MCP `initialize` text and tool descriptions | n/a | neutralised: what the tools do, no advice to prefer them | as shipped: "Use lsp_navigate instead of grep ..., and lsp_diagnostics to check edited files" |
| `CLAUDE.md` in the workspace | none | none | code-intelligence rules modelled on a production repo's (use the language tools for symbol work, never grep for symbols, check edited files with diagnostics) |
| Hooks in `.claude/settings.json` | none | none | SessionStart reminder; PreToolUse advisory on Grep/Glob and on `grep`/`rg` in Bash when the pattern looks like a symbol; PreToolUse advisory on edits of source files; Stop hook that blocks once if edited source files were never checked with `lsp_diagnostics` |

The two IntelliJ arms are `optional` and `enforced` with one change: headless tereditor is started with its opt-in
IntelliJ server (`TEREDITOR_PREFETCH=intellij`), which then serves `.kt` instead of the Kotlin server and is the only
server for `.java`. The same six tools, the same text handling and (for `intellij-enforced`) the same CLAUDE.md and
hooks. They run on JVM projects only (Kotlin, Java, mixed); elsewhere they would equal the tereditor arms.

`baseline-review` is `baseline` followed by a second prompt in the same session (`harness/review-prompt.md`, fixed
text): check that you did not break anything and left no mess, fix what you find. It is the habit people use today to buy
quality with tokens, and the comparison the LSP arms must beat: the same tools as baseline (no compiler, so the review
is by reading), the cost of both turns counted, runs on every project. The edit is taken after the second turn; an
answer task is answered after it. Only the baseline has a review variant.

Egress. The agent's sandbox has a private network namespace: no route, no DNS. Its `HTTPS_PROXY` reaches, through a loopback forwarder and a unix socket, a proxy on the host (`harness/env/egress-conn.sh`) that lets through `CONNECT api.anthropic.com:443` and nothing else (`harness/egress-allow.txt`), logging every attempt to the run's `egress.log`. `./study redteam` attacks this from inside the sandbox with no model (direct connections, DNS, proxy bypass tricks, searching the filesystem for a planted gold-patch canary, host paths, sockets, capabilities, writes to read-only mounts, git history) and must print `all attacks blocked` before any run. What it does not cover: a kernel or container escape, the Anthropic API itself as a channel, and the models' training data.

Arm applicability: Java has no tereditor server without IntelliJ (Eclipse JDT is not headless), so Java projects run
`baseline`, `intellij-optional` and `intellij-enforced` only. Kotlin and mixed projects run all five arms.

The JetBrains side: the IntelliJ server's terms (JetBrains User Agreement 2.0) were accepted by the study's owner for
the exact terms text named by its hash (`harness/intellij.env`), with region `europe` and usage statistics `none`;
the acceptance is recorded when the JVM group is set up (`./study setup jvm`). It runs on the owner's licence (offline activation code,
README). The JVM image also holds a pinned JDK under `/cache`, given to the Kotlin and IntelliJ servers alike
(Gradle and Maven import); like every other runtime it is closed to the agent.

The enforced arm copies the pattern of a real repository's setup (a session-start reminder, advisory nudges on
edits, a stop hook) rather than inventing one: hooks advise, and only the stop hook blocks, once. The exact files are
in `harness/arms/enforced/`.

"Optional" is LSP that is available but not mandatory: the server's own text tells the agent to prefer it over grep,
so the harness rewrites that text in this arm (a `jq` filter on the server's stdout, `harness/server/neutral.jq`)
to keep the tool on the menu without advice.

## Baseline: the same agent with core utilities

The agent's sandbox contains exactly the `agent` closure (docs/ENVIRONMENT.md): Claude Code, bash, coreutils, findutils, grep,
sed, awk, diff, patch, less, file, tree, procps, git (without perl), ripgrep, jq. No compiler, interpreter, test
runner, package manager, `curl` or `wget` exists in it, in any arm. Claude Code gets the built-in tools Bash, Read,
Edit, Write, Task (subagents) and ToolSearch (`--tools`; MCP tools are deferred behind ToolSearch); web tools are off.

Consequences, deliberate and the same in every arm:

- No arm can build or run the code. The language server is the only semantic checker the LSP arms have, and nothing
  replaces it in the baseline. This isolates static code intelligence. It is not how most people run agents (they also
  run builds and tests); a follow-up with toolchains in every arm would measure the marginal value of LSP on top of a
  compiler.
- The language server's runtimes (.NET SDK, Bun, clangd, the JDK, IntelliJ) and tereditor itself exist only in the
  server's sandbox; the agent reaches the server through a socket and cannot run any of them. Otherwise the LSP arms
  would get a compiler (`dotnet build`, `clangd --check`, Bun) that the baseline does not.

## Contamination control

- Claude Code runs in its sandbox with an empty `HOME`. No user `CLAUDE.md`, settings, plugins, skills, hooks, MCP
  servers, memory or keychain exist. `--setting-sources project`, `--strict-mcp-config`, `--no-session-persistence`.
- The workspace starts as one fresh commit (the snapshot with the task's setup and the arm's files): no history shows
  where a bug was seeded.
- Snapshots strip every agent or editor instruction file from the upstream repository (TASKS.md).
- Every run's `system/init` event is checked against the arm's expected tool list, MCP servers, slash commands,
  plugins and memory files (`analysis/contamination.py`). A run that does not match is excluded and counted.
- Claude Code's own LSP tool (plugin-provided) is absent in all arms; the check above asserts it.
- The credential is passed as an environment variable and redacted from every output file. It is visible to the
  agent's shell: Claude Code's `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1` would hide it, but in 2.1.322 it also forces the
  default permission mode, a bubblewrap/socat sandbox around Bash and the removal of the Grep tool, which would change
  the agent under test.
- Version facts that hold in every arm: MCP tools are deferred behind `ToolSearch` (the agent must look them up
  before the first call), and three builtin plugins load (`cc-plugin-agents-md`, `cc-plugin-privacy`,
  `cc-plugin-plugin-authoring`).
- No network at the language server: runtimes, servers and project dependencies are installed when the image is
  set up (`./study setup`, `prepare.sh`). The agent's sandbox does need the Anthropic API.

## Fairness and confounders

- Cold start is part of the treatment: every run starts a fresh server, which indexes the project. Its cost is
  measured separately (server readiness time per project, from the call log and a scripted probe) so it can be
  reported apart from agent behaviour.
- Run order is randomised and arms are interleaved, so API latency drift or model-serving changes do not line up
  with an arm. Because the cloud VM's disk holds one project at a time (docs/CLOUD_RUN.md), runs execute project by
  project, in the order of each project's first run in the randomised plan, and in plan order within a project; arm
  contrasts are within project, so the interleaving that matters is kept.
- Same `--max-budget-usd` and `--max-turns` caps and the same wall-clock timeout in every arm; hitting a cap is a
  failure, never an exclusion.
- Hidden tests and oracles are never in the agent's sandbox. Grading happens afterwards in the grading sandbox,
  without network.
- One architecture for every project and arm: the host's native one. Wall-time comparisons are within project.

## Effort

No arm sets an effort level: no `--effort`, no `CLAUDE_CODE_EFFORT_LEVEL` (the sandbox environment starts empty), and no
effort setting in any settings file. Claude Code therefore uses each model's default, which its documentation gives
as `medium` for Haiku 5.5, Sonnet 5.5 and Opus 5.5 (code.claude.com/docs/en/model-config, "Adjust effort level").
The run's own output does not report the level, so it is recorded from these inputs; the documentation describes
the current Claude Code, the study pins 2.1.322.

## Measures

Per run, from Claude Code's `stream-json`, tereditor's call log and the grader:

- success (graded), and for answer tasks precision, recall and F1;
- cost in USD (`total_cost_usd`), input, output, cache-read and cache-write tokens;
- turns, wall time, API time;
- tool calls by tool (Read, Grep, Glob, Bash by command, Edit, Write, each `lsp_*` operation), LSP errors and
  `initializing` answers, bytes returned by LSP;
- LSP adoption: share of runs using any `lsp_*` tool, first-use turn, and the stop-hook blocks in the enforced arm;
- whether the run hit the budget, turn or time cap.

## Reproducibility

Pinned: tereditor (a dated release archive, by sha256), nixpkgs (`nix/flake.lock`, so every toolchain and library), the
Claude Code version, the `nixos/nix` image (by digest), the model IDs and every project's commit. Host requirements
are in the README.