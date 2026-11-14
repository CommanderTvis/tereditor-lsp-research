# Environments on Nix (in progress: milestone 1 done)

Hard requirement (owner, 2026-11-14): a reproducer needs only a container runtime. Nix is never a requirement:
with Docker or Apple `container`, Nix runs inside a pinned `nixos/nix` builder container, which builds the images as
tarballs (`dockerTools`) that `./study` loads into the runtime. The native backend, meant for hosts without a usable
container runtime (the owner's cloud session), downloads a pinned, checksummed static Nix binary into the study's own
cache directory and uses it from there; nothing is installed system-wide.

Decided 2026-11-14: every environment of the study (the agent's sandbox, the language server's runtime, the grading
toolchains, and the Docker images) is defined by one `flake.nix` with a locked nixpkgs. Two backends use it:

- `native`: a Linux host with Nix (a Claude Code cloud session, any VM). Each run is a bubblewrap sandbox; no daemon.
- `docker` / `container`: images built from the same closures with `dockerTools.buildLayeredImage`, so both backends
  see byte-identical toolchains.

tereditor itself is not built by Nix: its NativeAOT build needs network and its own pinned toolchain, so it is built
with its `scripts/mise` at `TEREDITOR_COMMIT` and imported as a tarball. Its language servers keep downloading their
pinned runtimes into `/cache` (`TEREDITOR_TOOLCHAINS=managed`).

## Closures (flake outputs, per linux system)

| Output | Contents | Visible to |
| --- | --- | --- |
| `claude-code` | the static musl release binary of Claude Code 2.1.322, fetched with its published sha256 | agent |
| `agent` | bash, coreutils, findutils, grep, sed, awk, diff, patch, less, file, tree, procps, ripgrep, jq, gitMinimal (no perl), socat, CA certificates, `claude-code` | agent (the sandbox allow-list) |
| `server-fhs` | a minimal FHS root (glibc loader, libstdc++, libgcc, zlib, ICU, OpenSSL, Kerberos, CA certificates, bash, coreutils, git, util-linux) for the downloaded server binaries | language server only |
| `jvm-tools` | JDK 21 and Maven, copied into `/cache` at warm time (mode 0700) | language servers only |
| `grade-<lang>` | the toolchain that builds and tests that language's projects (python, typescript, csharp, php, jvm, cpp, shell, css) | grader only, no network |

Measured 2026-11-14 (aarch64-linux, nixpkgs d4f25a3e, closure sizes with all dependencies): claude-code 310 MB,
agent 528 MB, server-fhs 297 MB, jvm-tools 636 MB, grade-python 351 MB, grade-typescript 426 MB, grade-csharp
1,036 MB, grade-php 371 MB, grade-jvm 2,186 MB, grade-cpp 557 MB, grade-shell 206 MB, grade-css 333 MB, host-tools
249 MB. Closures share store paths (glibc, bash, coreutils), so the sum overstates disk use. The agent closure
contains claude, git, rg and jq and none of python3, perl, node, gcc, cc, javac, java, dotnet, php, bun, curl, wget
(checked). C/C++ grading uses gcc only (gcc and clang collide on `cc` in one environment).

## Sandboxes (native backend)

- Agent: bubblewrap with only the `agent` closure's store paths, `/workspace`, `/in`, `/out`, a fresh HOME and the MCP
  socket; network on (the Anthropic API). No compiler or interpreter exists in this view, by construction: the
  baseline check (`python3`, `node`, `gcc`, `javac`, `dotnet`, `php` absent) tests the declaration.
- Server: started per connection by the socket bridge outside the agent sandbox, in its own bubblewrap view
  (`server-fhs` at `/usr`, `/lib`, `/lib64`; `/opt/tereditor`, `/cache`, the same `/workspace`), as the `tereditor`
  user. sudo is gone: it cannot run under bubblewrap's no-new-privileges.
- Grader: bubblewrap with `grade-<lang>`, `/study/snapshot`, `/task`, `/project`, `/grade`, `/run`, `/out` at the
  paths `harness/grade/grade.sh` already uses, `--unshare-net`.

## Images (docker backend)

- `study/agent`: `agent` + `server-fhs` + tereditor + the entrypoint; the agent user cannot read `/cache` or
  `/opt/tereditor` (as before); the bridge replaces sudo here too, so both backends start the server the same way.
- `study/grade-<lang>`: `grade-<lang>` only.
- Layers per store path: images share glibc, bash and coreutils layers.

## Milestones

1. flake.nix with the closures; build them and record closure sizes (in a nixos/nix container on the Mac).
2. Native backend in `./study` (`STUDY_RUNTIME=native`): host setup, sandboxes, bridge, grading.
3. Docker images from the flake replacing the Dockerfiles.
4. Re-validate python-small and java-medium on both backends; the toolz smoke on both; then the cloud preflight.
