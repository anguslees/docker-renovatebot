FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/bash@sha256:f1ee7ce3735d95a7c4724f3ceda3a16d3d6f6dcba4d5e6d54b80e2e7e2da9baf AS fetcher

ARG TARGETOS
ARG TARGETARCH
#ARG TARGETVARIANT

# renovate: datasource=github-releases depName=bazelbuild/bazelisk
ARG BAZELISK_VERSION=1.29.0

RUN mkdir /out
RUN curl -L -o /out/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v$BAZELISK_VERSION/bazelisk-$TARGETOS-$TARGETARCH

RUN chmod a+x /out/*
RUN ln -s bazelisk /out/bazel

FROM ghcr.io/renovatebot/renovate@sha256:5159fecda22d7bd50d4ebcdc7896ddb65e649e3a1ad55ec00d8194562a3be8c4

COPY --from=fetcher /out/* /usr/local/bin/

USER root
RUN apt-get update; apt-get install -y --no-install-recommends gcc g++ build-essential
USER ubuntu

ENV USER=ubuntu HOME=/home/ubuntu
ENTRYPOINT ["/usr/local/sbin/renovate-entrypoint.sh"]
