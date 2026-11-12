# syntax=docker/dockerfile:1
# One project's run image: the warm agent image plus the project snapshot at /study/snapshot.
# Build context: projects/<lang>-<size>/ (for prepare.sh). The snapshot is fetched inside the build, so the host needs
# no git. Agent and editor instruction files are removed and the tree is re-committed without history.
ARG WARM_IMAGE
FROM alpine/git:v2.49.1 AS snapshot
ARG REPO
ARG COMMIT
ARG STRIP="CLAUDE.md AGENTS.md GEMINI.md .claude .cursor .cursorrules .github/copilot-instructions.md .windsurfrules .sharprail .mcp.json .vscode .idea .junie .aider* .continue .clinerules"
WORKDIR /snapshot
RUN git init -q . && git remote add origin "$REPO" && git fetch -q --depth 1 origin "$COMMIT" && git checkout -q FETCH_HEAD \
    && rm -rf .git \
    && for p in $STRIP; do find . -path ./node_modules -prune -o -name "$p" -prune -exec rm -rf {} + ; done \
    && find . -name 'CLAUDE.md' -o -name 'AGENTS.md' | (! grep .) \
    && git init -q -b main . && git add -A \
    && git -c user.name=study -c user.email=study@localhost commit -qm "snapshot $COMMIT"

FROM ${WARM_IMAGE}
COPY --from=snapshot --chown=sharprail:sharprail /snapshot /study/snapshot
COPY --chmod=0755 prepare.sh /study/prepare.sh
USER sharprail
RUN cd /study/snapshot && HOME=/cache/home SHARPRAIL_TOOLCHAINS=managed \
      SHARPRAIL_MANAGED_CACHE=/cache/managed SHARPRAIL_STATE_DIR=/cache/state sh /study/prepare.sh \
    && git add -A && git -c user.name=study -c user.email=study@localhost commit -qm "prepare" --allow-empty
USER root
RUN chmod 0700 /cache
ARG REPO
ARG COMMIT
LABEL study.repo="${REPO}" study.commit="${COMMIT}"
