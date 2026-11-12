# syntax=docker/dockerfile:1
# The agent image: one Claude Code agent plus headless SharpRail, used by every arm of the study.
# Every arm runs this same image; arms differ only in the MCP config, the workspace's .claude/ and CLAUDE.md
# (see harness/arms/). The agent has core utilities only: no compiler, interpreter, package manager or downloader.
ARG SHARPRAIL_IMAGE=study/sharprail:95f7048
ARG CLAUDE_CODE_VERSION=2.1.322

FROM ubuntu:24.04 AS claude
ARG CLAUDE_CODE_VERSION
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates bash \
    && curl -fsSL https://claude.ai/install.sh -o /tmp/install.sh \
    && bash /tmp/install.sh "$CLAUDE_CODE_VERSION" \
    && install -m 0755 "$(readlink -f /root/.local/bin/claude)" /claude \
    && /claude --version | grep -q "^$CLAUDE_CODE_VERSION "

FROM ${SHARPRAIL_IMAGE}
ARG CLAUDE_CODE_VERSION
USER root
# Core utilities the agent may use. jq is here for the hooks; every arm gets the same set.
# No curl/wget/python/node: the agent cannot fetch or run toolchains in any arm. /opt/sharprail (the headless binary,
# which can download runtimes, and the preinstalled clangd, which can type-check C/C++) is closed to the agent too.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ripgrep jq sudo less file findutils diffutils patch procps tree \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --uid 1001 --create-home --home-dir /home/agent --shell /bin/bash agent \
    && chmod 0700 /cache \
    && chown -R root:sharprail /opt/sharprail && chmod -R o-rwx /opt/sharprail && chmod 0750 /opt/sharprail \
    && mkdir -p /study \
    && echo 'agent ALL=(sharprail) NOPASSWD: /usr/local/bin/sharprail-mcp' > /etc/sudoers.d/sharprail-mcp \
    && echo 'Defaults:agent !requiretty, !lecture, !syslog' >> /etc/sudoers.d/sharprail-mcp \
    && chmod 0440 /etc/sudoers.d/sharprail-mcp
COPY --from=claude /claude /usr/local/bin/claude
COPY --chmod=0755 sharprail-mcp /usr/local/bin/sharprail-mcp
COPY --chmod=0644 neutral.jq /usr/local/share/study/neutral.jq
COPY --chmod=0755 entrypoint.sh /usr/local/bin/study-entrypoint
# Some builders apply --chmod to the directories COPY creates, too.
RUN chmod 0755 /usr/local/share/study
ENV HOME=/home/agent \
    DISABLE_AUTOUPDATER=1 \
    DISABLE_TELEMETRY=1 \
    DISABLE_ERROR_REPORTING=1 \
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
    IS_SANDBOX=1 \
    USE_BUILTIN_RIPGREP=0
LABEL study.claude-code.version="${CLAUDE_CODE_VERSION}"
# The entrypoint starts as root only to hand the workspace to the agent, then drops to uid 1001.
USER root
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/study-entrypoint"]
