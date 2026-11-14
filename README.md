# LSP efficiency study: does a language server help a Claude Code agent?

A controlled, reproducible experiment on whether giving Claude Code the language-server tools of
[headless tereditor](https://github.com/CommanderTvis/tereditor/blob/main/docs/headless.md) changes success, cost and
time on real code tasks, across every language tereditor serves headless, three project sizes, three models and three
prompting regimes.

- [docs/DESIGN.md](docs/DESIGN.md): question, factors, arms, contamination control, measures.
- [docs/ANALYSIS_PLAN.md](docs/ANALYSIS_PLAN.md): the pre-registered analysis.
- [docs/TASKS.md](docs/TASKS.md): project and task format, oracle rules, validity checks.
- `results/<plan>/report/report.md`: results of a plan, once run.

## Requirements

- A container runtime: Docker (Linux, or Docker Desktop / Colima / OrbStack on macOS) or Apple `container` 1.7+ on
  macOS. Give it at least 8 CPUs and 16 GB; the image builder needs 12 GB for the NativeAOT build
  (`container builder start --cpus 8 --memory 12g` on Apple `container`).
- An Anthropic credential: `ANTHROPIC_API_KEY`, or `CLAUDE_CODE_OAUTH_TOKEN` from `claude setup-token`.

### The IntelliJ arms need your own JetBrains licence

The arms that use the IntelliJ language server (Java and Kotlin) run only with a licence you own that includes
IntelliJ IDEA Ultimate (an IntelliJ IDEA Ultimate or All Products Pack subscription). Headless tereditor has no trial
and no sign-in, so it uses JetBrains' offline activation code:

1. Sign in at <https://account.jetbrains.com/licenses>, choose the licence and click **Download a code for offline
   activation**. You get a zip named `<LICENSE ID> - <your account email>.zip`.
2. Move it, unopened, to the root of this repository as `license.zip`:

   ```sh
   mv ~/Downloads/"<LICENSE ID> - <your account email>.zip" ./license.zip
   chmod 600 license.zip
   ```

   Or keep it elsewhere and set `STUDY_INTELLIJ_LICENSE=/path/to/the.zip`.

`license.zip` is git-ignored: never commit it. At run time `./study run` hands it to each run's container in an
environment variable (base64), the container writes it to a directory only the language server's user can read, and the
agent's environment is rebuilt without it, so the agent under test cannot see it. tereditor reads the zip itself
(`INTELLIJ_SERVER_LICENSE_FILE`, see its `docs/headless.md`). Without the file, the other arms run as usual; leave the
IntelliJ arms out of your plan (`--arms`). Results from the IntelliJ arms can only be reproduced by someone with such a licence.

## Reproduce with only an Anthropic API key

This is the whole study except the two IntelliJ arms (which need a JetBrains licence, above). You need a container
runtime and an API key; nothing else is installed on your machine.

1. Get the repository and give the runtime enough room: at least 8 CPUs, 16 GB of memory and about 150 GB of disk
   (images for every language and the very large projects). On Apple `container`, the image builder also needs
   `container builder start --cpus 8 --memory 12g` once; on Docker, raise the limits in Docker Desktop, Colima or
   OrbStack if you use one.
2. Provide the key, either in your shell or in a private file that `./study run` reads:

   ```sh
   export ANTHROPIC_API_KEY=sk-ant-...
   # or, so it is not in your shell history:
   mkdir -p ~/.config/tereditor-study
   printf 'ANTHROPIC_API_KEY=%s\n' 'sk-ant-...' > ~/.config/tereditor-study/env && chmod 600 ~/.config/tereditor-study/env
   ```

   The key reaches each run's container by variable name only, is redacted from every output file, and is billed per
   token. `--budget` caps the spend of a single run.
3. Build and check everything, without spending money (`STUDY_INTELLIJ` stays unset, so no JetBrains terms are
   accepted and the JVM image has no IntelliJ server):

   ```sh
   ./study images
   ./study project $(ls projects)
   for p in $(ls projects); do ./study probe "$p"; ./study validate "$p"; done
   ```

4. Run a plan without the IntelliJ arms (the default arms are `baseline optional enforced`), then grade and analyse:

   ```sh
   ./study plan mine --models "claude-haiku-5-5 claude-sonnet-5-5" --reps 3 --budget 5
   ./study run mine -j 3        # resumable; rerun the same command after an interruption
   ./study grade mine -j 3
   ./study analyze mine         # results/mine/report/report.md
   ```

   Start small to see the cost before a large plan, for example `--projects python-small --models claude-haiku-5-5
   --reps 1` (12 runs; the authors' run of exactly that cost $0.08).

With a JetBrains licence as well, build with `STUDY_INTELLIJ=1 ./study images` after reviewing the terms answers in
`harness/intellij.env` (they record the study owner's acceptance; accepting is your own decision), put `license.zip`
in place and add `--arms "baseline optional enforced intellij-optional intellij-enforced"`.

On Linux with Docker, files the containers write into `results/` are handed back to your user. Docker on Linux and
Docker Desktop on macOS have not been run by the authors yet; Apple `container` on macOS has.

## Reproduce

```sh
./study images                      # tereditor from the pinned commit, the agent image, one warm image per language
./study project python-small ...    # run + grade images per project (or: ./study project $(ls projects))
./study probe python-small          # language server works on this project, no model involved
./study validate python-small       # every task: start state fails, gold solution passes, twice
./study plan pilot --projects "python-small" --models claude-haiku-5-5 --reps 2
export ANTHROPIC_API_KEY=...
./study run pilot -j 3              # resumable: finished runs are skipped
./study grade pilot -j 3
./study analyze pilot               # results/pilot/report/report.md
```

`STUDY_RUNTIME=docker|container` picks the runtime when both exist.

## What stays out of the experiment

Your own Claude Code configuration cannot reach a run. Claude Code runs inside the container with an empty home
directory, so no `~/.claude/CLAUDE.md`, settings, plugins, skills, hooks, MCP servers or memory exist; the flags
`--setting-sources project --strict-mcp-config --no-session-persistence` close the remaining doors, and every run's
initial configuration event is checked and the run excluded if it differs from what its arm should see.
