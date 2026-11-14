# syntax=docker/dockerfile:1
# The JVM warm image (Kotlin, Java, mixed): the Kotlin server, the opt-in IntelliJ server with the owner's recorded
# acceptance of its terms (harness/intellij.env), and a pinned JDK at /cache/jdk for project import. Everything lives
# under /cache (uid 1000, 0700): the agent can reach none of it. The IntelliJ server is used only by the intellij-* arms
# (TEREDITOR_PREFETCH=intellij in harness/images/agent/tereditor-mcp); the other arms keep the Kotlin server.
ARG AGENT_IMAGE=study/agent:latest

FROM ubuntu:24.04@sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852 AS jdk
ARG TARGETARCH
ARG JDK_AARCH64_URL=https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.13%2B9/OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.13_9.tar.gz
ARG JDK_AARCH64_SHA256=e3522e707fc7dbe2a72c30746b1e7068301a0213ecd213d4491f35a14eb55578
ARG JDK_X64_URL=https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.13%2B9/OpenJDK21U-jdk_x64_linux_hotspot_21.0.13_9.tar.gz
ARG JDK_X64_SHA256=d7f5d5cf865a2902b70ff549b97586a7d3f234e016f041ab447ea740c7d66d1c
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl \
    && case "$TARGETARCH" in arm64) url=$JDK_AARCH64_URL sha=$JDK_AARCH64_SHA256 ;; amd64) url=$JDK_X64_URL sha=$JDK_X64_SHA256 ;; *) exit 1 ;; esac \
    && curl -fsSL --retry 3 -o /tmp/jdk.tgz "$url" && echo "$sha  /tmp/jdk.tgz" | sha256sum -c - \
    && mkdir -p /jdk && tar -xzf /tmp/jdk.tgz -C /jdk --strip-components=1 && /jdk/bin/java -version

# Apache Maven: IntelliJ's native Maven import runs `mvn` from PATH (without it the import fails and answers stay
# within one file). Pinned and checked like the JDK; on the servers' PATH only (harness/images/agent/tereditor-mcp).
FROM ubuntu:24.04@sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852 AS maven
ARG MAVEN_URL=https://archive.apache.org/dist/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz
ARG MAVEN_SHA512=bcfe4fe305c962ace56ac7b5fc7a08b87d5abd8b7e89027ab251069faebee516b0ded8961445d6d91ec1985dfe30f8153268843c89aa392733d1a3ec956c9978
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl \
    && curl -fsSL --retry 3 -o /tmp/maven.tgz "$MAVEN_URL" && echo "$MAVEN_SHA512  /tmp/maven.tgz" | sha512sum -c - \
    && mkdir -p /maven && tar -xzf /tmp/maven.tgz -C /maven --strip-components=1

FROM ${AGENT_IMAGE}
ARG INTELLIJ_TERMS_HASH
ARG INTELLIJ_REGION
ARG INTELLIJ_DATA_SHARING
COPY --from=jdk --chown=tereditor:tereditor /jdk /cache/jdk
COPY --from=maven --chown=tereditor:tereditor /maven /cache/maven
USER tereditor
ENV STUDY_WARM_ENV="HOME=/cache/home TEREDITOR_TOOLCHAINS=managed TEREDITOR_MANAGED_CACHE=/cache/managed TEREDITOR_STATE_DIR=/cache/state JAVA_HOME=/cache/jdk"
# Without the three INTELLIJ_* build args the image has no IntelliJ server and no acceptance (./study images without
# STUDY_INTELLIJ=1); the intellij-* arms then refuse to start and the other arms are unaffected.
RUN env $STUDY_WARM_ENV tereditor-headless warm kotlin --workspace /tmp \
    && if [ -z "$INTELLIJ_TERMS_HASH" ]; then exit 0; fi \
    && test -n "$INTELLIJ_REGION" && test -n "$INTELLIJ_DATA_SHARING" \
    && env $STUDY_WARM_ENV TEREDITOR_PREFETCH=intellij TEREDITOR_ACCEPT_TERMS="intellij:$INTELLIJ_TERMS_HASH" \
         INTELLIJ_REGION="$INTELLIJ_REGION" INTELLIJ_DATA_SHARING="$INTELLIJ_DATA_SHARING" \
         tereditor-headless warm intellij --workspace /tmp \
    && printf 'INTELLIJ_TERMS_HASH=%s\nINTELLIJ_REGION=%s\nINTELLIJ_DATA_SHARING=%s\n' \
         "$INTELLIJ_TERMS_HASH" "$INTELLIJ_REGION" "$INTELLIJ_DATA_SHARING" > /cache/study-intellij.env
USER root
RUN chown -R tereditor:tereditor /cache && chmod 0700 /cache
LABEL study.servers="kotlin intellij" study.intellij.terms="${INTELLIJ_TERMS_HASH}"
