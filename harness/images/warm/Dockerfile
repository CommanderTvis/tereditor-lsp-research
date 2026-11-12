# syntax=docker/dockerfile:1
# The agent image with one language server and its runtime installed into /cache (uid 1000, mode 0700), so runs need
# no network for the language server and the agent (uid 1001) cannot reach the runtimes.
ARG AGENT_IMAGE=study/agent:latest
FROM ${AGENT_IMAGE}
ARG SERVERS
USER sharprail
RUN test -n "$SERVERS" \
    && HOME=/cache/home SHARPRAIL_TOOLCHAINS=managed SHARPRAIL_MANAGED_CACHE=/cache/managed SHARPRAIL_STATE_DIR=/cache/state \
       sharprail-headless warm $SERVERS --workspace /tmp
USER root
RUN chown -R sharprail:sharprail /cache && chmod 0700 /cache
LABEL study.servers="${SERVERS}"
