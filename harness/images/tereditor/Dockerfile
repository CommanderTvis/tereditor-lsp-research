# syntax=docker/dockerfile:1
# Headless tereditor built from a pinned public commit, so the study does not depend on a moving :nightly tag.
# The published :nightly predates the 8-language roster, clangd on arm64 and the IntelliJ consent flow, so the study builds from source.
# Mirrors docker/headless/Dockerfile (target "local") of https://github.com/CommanderTvis/tereditor at TEREDITOR_COMMIT.
ARG TEREDITOR_COMMIT=26a24114919b0abda1a0ae3a2b8bad01a49e3fd2

FROM mcr.microsoft.com/dotnet/sdk:10.0.403@sha256:212fe4cb74627d5adf9817a4088906ae3edff1bd853bb27565d4b46731efe61e AS publish
ARG TEREDITOR_COMMIT
ARG TARGETARCH
WORKDIR /src
RUN git init -q . \
    && git remote add origin https://github.com/CommanderTvis/tereditor.git \
    && git fetch -q --depth 1 origin "$TEREDITOR_COMMIT" \
    && git checkout -q FETCH_HEAD
RUN case "$TARGETARCH" in amd64) rid=linux-x64 ;; arm64) rid=linux-arm64 ;; *) echo "unsupported architecture $TARGETARCH" >&2; exit 1 ;; esac \
    && sh scripts/mise x -- dotnet publish src/Tereditor.Host.Headless -c Release -r "$rid" -o /out

# clangd for linux/arm64, mirrored from upstream docker/headless/Dockerfile: LLVM's pinned arm64 build, only bin/clangd and the
# builtin headers. The host copies it into /cache/managed on first use. Empty on amd64 (the host downloads clangd's own zip).
FROM ubuntu:24.04@sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852 AS clangd
ARG TARGETARCH
ARG CLANGD_ARM64_URL=https://github.com/llvm/llvm-project/releases/download/llvmorg-23.1.5/LLVM-23.1.5-Linux-ARM64.tar.zst
ARG CLANGD_ARM64_SHA256=830ceb70edf63849ce66e97bf85310a3bf2bdd04c860a9f2fa4ef1560e290cef
RUN mkdir -p /out \
    && if [ "$TARGETARCH" = arm64 ]; then \
         apt-get update && apt-get install -y --no-install-recommends ca-certificates curl zstd \
         && curl -fsSL --retry 3 -o /tmp/llvm.tar.zst "$CLANGD_ARM64_URL" \
         && echo "$CLANGD_ARM64_SHA256  /tmp/llvm.tar.zst" | sha256sum -c - \
         && zstd -dc --long=30 /tmp/llvm.tar.zst | tar -x -C /out --strip-components=1 --wildcards '*/bin/clangd' '*/lib/clang/*/include' \
         && test -x /out/bin/clangd && ls /out/lib/clang/*/include/stddef.h \
         && printf '{"sha256":"%s","url":"%s"}' "$CLANGD_ARM64_SHA256" "$CLANGD_ARM64_URL" > /out/.tereditor-artifact.json \
         && rm -f /tmp/llvm.tar.zst; \
       fi

FROM mcr.microsoft.com/dotnet/runtime-deps:10.0-noble@sha256:9cab4d7d886226d47b5489ef9abf0544e2f109fde11a8acc190217610af26c00
ARG TEREDITOR_COMMIT
RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && (userdel --remove ubuntu 2>/dev/null || true) \
    && useradd --uid 1000 --home-dir /cache/home --no-create-home --shell /usr/sbin/nologin tereditor \
    && mkdir -p /cache/home /cache/managed /cache/state /workspace \
    && chown -R tereditor:tereditor /cache /workspace \
    && ln -s /opt/tereditor/tereditor-headless /usr/local/bin/tereditor-headless
COPY --from=publish --chmod=a+rX /out/ /opt/tereditor/
COPY --from=clangd --chmod=a+rX /out/ /opt/tereditor/preinstalled/clangd/
ENV HOME=/cache/home \
    TEREDITOR_TOOLCHAINS=managed \
    TEREDITOR_MANAGED_CACHE=/cache/managed \
    TEREDITOR_STATE_DIR=/cache/state \
    TEREDITOR_ROOT=/workspace \
    DOTNET_NOLOGO=1 \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    GIT_CONFIG_COUNT=1 \
    GIT_CONFIG_KEY_0=safe.directory \
    GIT_CONFIG_VALUE_0=*
LABEL study.tereditor.commit="${TEREDITOR_COMMIT}"
USER tereditor
WORKDIR /workspace
ENTRYPOINT ["tereditor-headless"]
CMD ["mcp"]
