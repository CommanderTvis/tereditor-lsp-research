# Environments

Every environment of the study is defined by `nix/flake.nix` with a locked nixpkgs: the agent's sandbox, the language
server's runtime, one grading toolchain per language group, and the planner and analysis. A reproducer never installs
Nix: with Docker or Apple `container`, every command runs in the pinned `nixos/nix` image; on a Linux host without a
container runtime (the native backend, used in a Claude Code cloud session), `./study` unpacks the pinned Nix release
into `/nix` itself.

## Closures

| Output | Contents | Used by |
| --- | --- | --- |
| `agent` | bash, coreutils, findutils, grep, sed, awk, diff, patch, less, file, tree, procps, ripgrep, jq, gitMinimal (no perl), socat, CA certificates, Claude Code 2.1.322 (the static release binary, by its published sha256) | the agent's sandbox: nothing else exists in it |
| `server-fhs` | an FHS-shaped root: the glibc loader and the shared libraries (libstdc++, zlib, ICU, OpenSSL, Kerberos) of the prebuilt binaries tereditor downloads, and the tools its scripts call | the language server's sandbox |
| `jvm-tools` | JDK 21 and Maven | the JVM language servers (Gradle and Maven import) |
| `grade-<group>` | the toolchain that builds and tests a group's projects: python, typescript, csharp, php, jvm, cpp (gcc), shell, css | the grader's sandbox |
| `analysis` | Python with numpy, pandas, scipy, statsmodels, matplotlib, tabulate | the planner and the analysis |
| `host-tools` | bubblewrap, socat, util-linux, jq, git, curl | the harness outside the sandboxes |
| `env-<group>` | a file naming the closures of a group, sourced by `harness/env/entry.sh` | every command |

The agent closure contains claude, git, rg and jq and none of python3, perl, node, gcc, cc, javac, java, dotnet, php,
bun, curl, wget. Closure sizes (aarch64): agent 528 MB, server-fhs about 300 MB, jvm-tools 636 MB, grading from
206 MB (shell) to 2.2 GB (jvm); closures share store paths, so a group needs a few GB.

tereditor is taken from its published headless image, pinned by digest in `harness/tereditor.env`:
`harness/env/fetch-tereditor.sh` downloads the image's layers from the registry, checks each against its digest and
keeps `/opt/tereditor`; no Docker is involved.

## Sandboxes

Each run is three bubblewrap sandboxes, each without capabilities in its own PID, IPC and UTS namespaces, with a
private `/tmp` and an empty environment; what a sandbox can reach is what is mounted into it:

- Agent: the agent closure's store paths, its `bin` at `/bin`, `/workspace`, a fresh home, the prompt and
  MCP configuration at `/in`, the bridge socket at `/run/study`. Network on (the Anthropic API). In a Claude Code cloud
  session the session's token file is bound read-only at its own path, so Claude Code authenticates with it.
- Server, started per MCP connection by the bridge (`socat` on the run's socket): `server-fhs` at `/bin`,
  `/lib`, `/lib64` and `/usr/lib`, tereditor at `/opt/tereditor`, the runtime cache at `/cache`, the same
  `/workspace`, the call log and the licence. The agent's sandbox contains none of these.
- Grader (no network): `grade-<group>` at `/bin`, the snapshot, the dependency cache and overlay of the project, the
  task, the patch and the output directory.

## State

The container backends keep two volumes: `study-nix` (the Nix store) and `study-state` (the tereditor build, the
language servers' runtime cache, each project's snapshot, dependency cache and overlay). The native backend keeps
the same state in `/var/lib/study`. `./study prune <project>` drops a project's part.
