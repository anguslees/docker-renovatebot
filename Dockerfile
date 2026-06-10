FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/bash@sha256:cee1d5ed7a17b502aee077b8c24a029abdcc1e6027c6bff2d1e0f26ddb4e1a2a AS fetcher

ARG TARGETOS
ARG TARGETARCH
#ARG TARGETVARIANT

# renovate: datasource=github-releases depName=bazelbuild/bazelisk
ARG BAZELISK_VERSION=1.28.1

RUN mkdir /out
RUN curl -L -o /out/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v$BAZELISK_VERSION/bazelisk-$TARGETOS-$TARGETARCH

RUN chmod a+x /out/*
RUN ln -s bazelisk /out/bazel

FROM ghcr.io/renovatebot/renovate@sha256:1d2ef5146c66adbf3221f0e5b361665ae636f4261349d3119fd6c3d3331b5a50

COPY --from=fetcher /out/* /usr/local/bin/

USER root
RUN apt-get update; apt-get install -y --no-install-recommends gcc g++ build-essential
USER ubuntu

ENV USER=ubuntu HOME=/home/ubuntu
ENTRYPOINT ["/usr/local/sbin/renovate-entrypoint.sh"]
