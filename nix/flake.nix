{
  description = "LSP efficiency study: pinned environments for the agent, the language server and grading (docs/NIX.md)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f system nixpkgs.legacyPackages.${system});

      # Claude Code 2.1.322, the static musl release binaries, with the checksums of its release manifest
      # (https://downloads.claude.ai/claude-code-releases/2.1.322/manifest.json).
      claudeVersion = "2.1.322";
      claudeRelease = {
        x86_64-linux = { platform = "linux-x64-musl"; sha256 = "9bed6cfc5d2420b673a0b9fe41c71533a02904935cbc3b4cd110302d475fee6f"; };
        aarch64-linux = { platform = "linux-arm64-musl"; sha256 = "b8a07ebb71cd612bd1ed80eabd2084ded98cadbae298d068a4a1307f0448c40c"; };
      };

      # Language groups: one grading toolchain each; the JVM group also gets the JDK and Maven for its language servers.
      groups = [ "python" "typescript" "csharp" "php" "jvm" "cpp" "shell" "css" ];
    in {
      packages = forAll (system: pkgs:
        let
          lib = pkgs.lib;
          env = name: paths: pkgs.buildEnv { inherit name paths; pathsToLink = [ "/bin" "/lib" "/share" "/etc" ]; };
          common = with pkgs; [ bash coreutils findutils gnugrep gnused gawk diffutils gnupatch gitMinimal cacert ];

          claude-code = pkgs.stdenvNoCC.mkDerivation {
            pname = "claude-code";
            version = claudeVersion;
            src = pkgs.fetchurl {
              url = "https://downloads.claude.ai/claude-code-releases/${claudeVersion}/${claudeRelease.${system}.platform}/claude";
              sha256 = claudeRelease.${system}.sha256;
            };
            dontUnpack = true;
            dontStrip = true;
            installPhase = "install -Dm755 $src $out/bin/claude";
          };

          # Claude Code's musl build asks for /lib/ld-musl-<arch>.so.1 and libc.musl-<arch>.so.1 (Alpine's names); both are
          # musl's libc. Part of the agent closure, whose lib/ is bound at /lib in the agent's sandbox.
          musl-loader = let arch = pkgs.stdenv.hostPlatform.parsed.cpu.name; in pkgs.runCommand "study-musl-loader" { } ''
            mkdir -p $out/lib
            ln -s ${pkgs.musl}/lib/libc.so $out/lib/ld-musl-${arch}.so.1
            ln -s ${pkgs.musl}/lib/libc.so $out/lib/libc.musl-${arch}.so.1
          '';

          # The agent's whole world: core utilities, search, git (without perl), jq, socat (its end of the MCP bridge)
          # and Claude Code. No compiler, interpreter, package manager or downloader, in any arm.
          agent = env "study-agent" (common ++ (with pkgs; [ less file tree procps ripgrep jq socat claude-code ]) ++ [ musl-loader ]);

          # The language server's runtime: an FHS-shaped root (lib/ with the glibc loader and every shared library the
          # prebuilt binaries tereditor downloads need; bin/ with the tools its scripts call), bound at /lib, /lib64,
          # /usr/lib, /bin and /usr/bin inside the server's sandbox.
          server-fhs = pkgs.runCommand "study-server-fhs" { } ''
            mkdir -p $out/lib $out/bin $out/etc
            for p in ${lib.concatMapStringsSep " " (x: "${lib.getLib x}") (with pkgs; [ glibc stdenv.cc.cc zlib icu openssl krb5 ])}; do
              for f in $p/lib/*; do [ -e "$out/lib/$(basename "$f")" ] || ln -s "$f" "$out/lib/"; done
            done
            for p in ${lib.concatMapStringsSep " " (x: "${x}") (common ++ (with pkgs; [ util-linux socat jq gnutar gzip xz zstd unzip which ]))}; do
              [ -d $p/bin ] && for f in $p/bin/*; do [ -e "$out/bin/$(basename "$f")" ] || ln -s "$f" "$out/bin/"; done
            done
            ln -s ${pkgs.cacert}/etc/ssl $out/etc/ssl
          '';

          # JDK and Maven for the JVM language servers' Gradle and Maven import.
          jvm-tools = env "study-jvm-tools" (with pkgs; [ jdk21_headless maven ]);

          grade = {
            python = env "study-grade-python" (common ++ [ (pkgs.python312.withPackages (p: [ p.pytest ])) ]);
            typescript = env "study-grade-typescript" (common ++ (with pkgs; [ nodejs_22 bun pnpm ]));
            csharp = env "study-grade-csharp" (common ++ (with pkgs; [
              (dotnetCorePackages.combinePackages [ dotnetCorePackages.sdk_10_0 dotnetCorePackages.runtime_8_0 ]) icu openssl ]));
            php = env "study-grade-php" (common ++ (with pkgs; [ php84 php84Packages.composer unzip ]));
            jvm = env "study-grade-jvm" (common ++ (with pkgs; [ jdk21_headless maven gradle ]));
            cpp = env "study-grade-cpp" (common ++ (with pkgs; [ gcc14 cmake gnumake pkg-config ]));
            shell = env "study-grade-shell" (common ++ (with pkgs; [ bats shellcheck ]));
            css = env "study-grade-css" (common ++ (with pkgs; [ dart-sass nodejs_22 ]));
          };

          # The planner and the analysis (analysis/plan.sh, extract.py, report.py).
          analysis = env "study-analysis" (common ++ [ (pkgs.python312.withPackages (p: with p; [
            numpy pandas scipy statsmodels matplotlib tabulate ])) ]);

          # The tools the harness itself runs (outside every sandbox).
          host-tools = env "study-host-tools" (common ++ (with pkgs; [ bubblewrap socat util-linux jq gnutar gzip curl ]));

          closure = root: "${pkgs.closureInfo { rootPaths = [ root ]; }}/store-paths";

          # One file per group naming every closure the harness uses, sourced by the scripts in harness/env.
          envfile = g: pkgs.writeText "study-env-${g}.sh" ''
            STUDY_GROUP=${g}
            STUDY_HOST=${host-tools}
            STUDY_AGENT=${agent}
            STUDY_AGENT_CLOSURE=${closure agent}
            STUDY_SERVER_FHS=${server-fhs}
            STUDY_SERVER_CLOSURE=${closure server-fhs}
            STUDY_GRADE=${grade.${g}}
            STUDY_GRADE_CLOSURE=${closure grade.${g}}
            STUDY_JVM=${if g == "jvm" then jvm-tools else ""}
            STUDY_JVM_CLOSURE=${if g == "jvm" then closure jvm-tools else ""}
            STUDY_ANALYSIS=${analysis}
          '';

        in
          { inherit claude-code agent server-fhs jvm-tools host-tools analysis; }
          // lib.mapAttrs' (g: v: lib.nameValuePair "grade-${g}" v) grade
          // lib.genAttrs' groups (g: lib.nameValuePair "env-${g}" (envfile g)));
    };
}
