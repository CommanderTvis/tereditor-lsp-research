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
    in {
      packages = forAll (system: pkgs:
        let
          env = name: paths: pkgs.buildEnv { inherit name paths; pathsToLink = [ "/bin" "/lib" "/share" "/etc" ]; };
          common = with pkgs; [ bash coreutils findutils gnugrep gnused gawk diffutils gnupatch gitMinimal cacert ];
        in rec {
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

          # The agent's whole world: core utilities, search, git (without perl), jq, and Claude Code. No compiler,
          # interpreter, package manager or downloader, in any arm.
          agent = env "study-agent" (common ++ (with pkgs; [ less file tree procps ripgrep jq socat claude-code ]));

          # The language server's runtime libraries, laid out for the prebuilt binaries tereditor downloads.
          server-fhs = env "study-server-fhs" (common ++ (with pkgs; [
            glibc stdenv.cc.cc.lib zlib icu openssl krb5 util-linux socat jq
          ]));

          # Copied into /cache at warm time for the JVM servers (Kotlin, IntelliJ): Gradle and Maven import.
          jvm-tools = env "study-jvm-tools" (with pkgs; [ jdk21_headless maven ]);

          # Grading toolchains, one per language class. Never visible to the agent.
          grade-python = env "study-grade-python" (common ++ [ (pkgs.python312.withPackages (p: [ p.pytest ])) ]);
          grade-typescript = env "study-grade-typescript" (common ++ (with pkgs; [ nodejs_22 bun ]));
          grade-csharp = env "study-grade-csharp" (common ++ (with pkgs; [ dotnet-sdk_10 icu openssl ]));
          grade-php = env "study-grade-php" (common ++ (with pkgs; [ php84 php84Packages.composer unzip ]));
          grade-jvm = env "study-grade-jvm" (common ++ (with pkgs; [ jdk21_headless maven gradle ]));
          grade-cpp = env "study-grade-cpp" (common ++ (with pkgs; [ gcc14 cmake gnumake pkg-config ]));
          grade-shell = env "study-grade-shell" (common ++ (with pkgs; [ bats shellcheck ]));
          grade-css = env "study-grade-css" (common ++ (with pkgs; [ dart-sass nodejs_22 ]));

          # Host tools of the native backend.
          host-tools = env "study-host-tools" (common ++ (with pkgs; [ bubblewrap socat util-linux jq ]));
        });
    };
}
