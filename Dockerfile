FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/bash@sha256:652a220a30fdbff8aad1c0d7b4927301bdfddc355bbc25d2e71b2039b04492a9 AS fetcher

ARG TARGETOS
ARG TARGETARCH
#ARG TARGETVARIANT

# renovate: datasource=github-releases depName=bazelbuild/bazelisk
ARG BAZELISK_VERSION=1.29.0

RUN mkdir /out
RUN curl -L -o /out/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v$BAZELISK_VERSION/bazelisk-$TARGETOS-$TARGETARCH

RUN chmod a+x /out/*
RUN ln -s bazelisk /out/bazel

FROM ghcr.io/renovatebot/renovate@sha256:3e4149122921d530218a4ca809c59636faa668b330e4c9ea7f9ee1e20ea505dd

COPY --from=fetcher /out/* /usr/local/bin/

USER root
RUN apt-get update; apt-get install -y --no-install-recommends gcc g++ build-essential
USER ubuntu

ENV USER=ubuntu HOME=/home/ubuntu
ENTRYPOINT ["/usr/local/sbin/renovate-entrypoint.sh"]
