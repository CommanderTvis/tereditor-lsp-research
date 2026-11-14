# syntax=docker/dockerfile:1
# The agent image with one language server and its runtime installed into /cache (uid 1000, mode 0700), so runs need
# no network for the language server and the agent (uid 1001) cannot reach the runtimes.
ARG AGENT_IMAGE=study/agent:latest
FROM ${AGENT_IMAGE}
ARG SERVERS
USER tereditor
RUN test -n "$SERVERS" \
    && HOME=/cache/home TEREDITOR_TOOLCHAINS=managed TEREDITOR_MANAGED_CACHE=/cache/managed TEREDITOR_STATE_DIR=/cache/state \
       tereditor-headless warm $SERVERS --workspace /tmp
USER root
RUN chown -R tereditor:tereditor /cache && chmod 0700 /cache
LABEL study.servers="${SERVERS}"
