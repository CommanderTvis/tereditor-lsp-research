{
  description = "Does LSP help Claude Code? Pinned environments for the agent, the language server and grading (docs/NIX.md)";

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

          # A second JDK for the projects whose builds refuse to start below it (Lucene main, gradle/gradle toolchain): kept off
          # PATH so JDK 21 stays the default; a project's scripts ask for its home with `study-jdk25` (the closure holds it).
          jdk25-home = pkgs.writeShellScriptBin "study-jdk25" "echo ${pkgs.jdk25_headless}/lib/openjdk";
          jdk17-home = pkgs.writeShellScriptBin "study-jdk17" "echo ${pkgs.jdk17_headless}/lib/openjdk";
          jdk11-home = pkgs.writeShellScriptBin "study-jdk11" "echo ${pkgs.jdk11_headless}/lib/openjdk";
          jdk8-home = pkgs.writeShellScriptBin "study-jdk8" "echo ${pkgs.jdk8_headless}/lib/openjdk";

          # .NET 11 for the projects that need it (efcore), off PATH so SDK 10 stays the default (the newest SDK's apphost does not
          # start in the grading sandbox): `study-dotnet11` prints its home, whose bin/ holds dotnet.
          dotnet11-home = pkgs.writeShellScriptBin "study-dotnet11" "echo ${pkgs.dotnetCorePackages.sdk_11_0}";

          # A second Node for projects that need it (payload: node 24), off PATH so Node 22 stays the default: `study-node24` prints its home.
          node24-home = pkgs.writeShellScriptBin "study-node24" "echo ${pkgs.nodejs_24}";

          # JDKs that nixpkgs no longer ships, from Azul's Zulu builds (JDK 9 exists for x86_64 Linux only), pinned by sha256;
          # kept off PATH like study-jdk25: `study-jdk9` and `study-jdk16` print their homes (JetBrains/kotlin builds against both).
          zulu = { v, file, sha256 }: pkgs.stdenvNoCC.mkDerivation {
            pname = "zulu-jdk"; version = v; dontStrip = true;
            src = pkgs.fetchurl { url = "https://cdn.azul.com/zulu/bin/${file}"; inherit sha256; };
            nativeBuildInputs = [ pkgs.autoPatchelfHook ];
            buildInputs = [ pkgs.stdenv.cc.cc.lib pkgs.zlib pkgs.alsa-lib pkgs.freetype pkgs.xorg.libX11 pkgs.xorg.libXext pkgs.xorg.libXi pkgs.xorg.libXrender pkgs.xorg.libXtst ];
            autoPatchelfIgnoreMissingDeps = true;
            installPhase = "mkdir -p $out && cp -r . $out/";
          };
          zuluJdks = {
            x86_64-linux = {
              jdk9 = zulu { v = "9.0.7"; file = "zulu9.0.7.1-ca-jdk9.0.7-linux_x64.tar.gz"; sha256 = "45f2dfbee93b91b1468cf81d843fc6d9a47fef1f831c0b7ceff4f1eb6e6851c8"; };
              jdk16 = zulu { v = "16.0.2"; file = "zulu16.32.15-ca-jdk16.0.2-linux_x64.tar.gz"; sha256 = "8eb9764ed708d6953bf77e8f04c03260801e87a1fe7b85b41648dab2e99ff31b"; };
            };
            aarch64-linux = {
              jdk16 = zulu { v = "16.0.2"; file = "zulu16.32.15-ca-jdk16.0.2-linux_aarch64.tar.gz"; sha256 = "601ead5a1e50cdca6da4ece8971ea9ede9b9c33e921a1a8352637abd546e75c8"; };
            };
          }.${system};
          jdk9-home = pkgs.writeShellScriptBin "study-jdk9" (if zuluJdks ? jdk9 then "echo ${zuluJdks.jdk9}" else "echo 'no JDK 9 build exists for this architecture (x86_64 only)' >&2; exit 1");
          jdk16-home = pkgs.writeShellScriptBin "study-jdk16" "echo ${zuluJdks.jdk16}";

          # JDK and Maven for the JVM language servers' Gradle and Maven import.
          jvm-tools = env "study-jvm-tools" ((with pkgs; [ jdk21_headless maven ]) ++ [ jdk25-home jdk17-home jdk11-home jdk8-home jdk9-home jdk16-home ]);

          grade = {
            python = env "study-grade-python" (common ++ [ (pkgs.python312.withPackages (p: [ p.pytest ])) ]);
            typescript = env "study-grade-typescript" (common ++ (with pkgs; [ nodejs_22 bun pnpm ]) ++ [ node24-home ]);
            csharp = env "study-grade-csharp" (common ++ [ dotnet11-home ] ++ (with pkgs; [
              (dotnetCorePackages.combinePackages [ dotnetCorePackages.sdk_10_0 dotnetCorePackages.runtime_8_0 ]) icu openssl ]));
            php = env "study-grade-php" (common ++ (with pkgs; [ php84 php84Packages.composer unzip ]));
            jvm = env "study-grade-jvm" (common ++ (with pkgs; [ jdk21_headless maven gradle ]) ++ [ jdk25-home jdk17-home jdk11-home jdk8-home jdk9-home jdk16-home ]);
            cpp = env "study-grade-cpp" (common ++ (with pkgs; [ gcc14 cmake gnumake pkg-config python312 tcl ]));
            shell = env "study-grade-shell" (common ++ (with pkgs; [ bats shellcheck util-linux procps ]));
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
