#!/bin/sh
# Runs one harness script in the study's environment, as root, on a Linux host with Nix: the pinned nixos/nix container
# of the container backends, or the native host. Usage: entry.sh <group> <script> [args...]
#   <group>   the language group whose closures the script needs (python typescript csharp php jvm cpp shell css)
#   <script>  a script in harness/env (setup, project, run-one, grade-one, probe, plan, analyze, ...)
# STUDY_ROOT is this repository, STUDY_STATE the persistent state (snapshots, caches, the tereditor build).
set -eu
export STUDY_ROOT=${STUDY_ROOT:-/study-root} STUDY_STATE=${STUDY_STATE:-/state}
mkdir -p "$HOME/.config/nix" /var/tmp "$STUDY_STATE"
printf 'experimental-features = nix-command flakes\nsandbox = false\nwarn-dirty = false\naccept-flake-config = false\n' \
  > "$HOME/.config/nix/nix.conf"
group=$1 script=$2; shift 2
mkdir -p "$STUDY_STATE/gcroots"
envfile=$(nix build --out-link "$STUDY_STATE/gcroots/env-$group" --print-out-paths "path:$STUDY_ROOT/nix#env-$group")
set -a; . "$envfile"; set +a
export PATH="$STUDY_HOST/bin:$PATH" SSL_CERT_FILE="$STUDY_HOST/etc/ssl/certs/ca-bundle.crt"
exec bash "$STUDY_ROOT/harness/env/$script.sh" "$@"
