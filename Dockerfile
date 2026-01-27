FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/bash@sha256:ff6a8a6f73835c1c3b04604543e3e1d6e6a130efd076c8f069e7ef2bdc040786 AS fetcher

ARG TARGETOS
ARG TARGETARCH
#ARG TARGETVARIANT

# renovate: datasource=github-releases depName=bazelbuild/bazelisk
ARG BAZELISK_VERSION=1.27.0

RUN mkdir /out
RUN curl -L -o /out/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v$BAZELISK_VERSION/bazelisk-$TARGETOS-$TARGETARCH

RUN chmod a+x /out/*
RUN ln -s bazelisk /out/bazel

FROM ghcr.io/renovatebot/renovate@sha256:1c6d7458b8cf195926ba82fd2b3b3c07c0c580d2fa0edf54a19db9ff0c43c362

COPY --from=fetcher /out/* /usr/local/bin/

USER root
RUN apt-get update; apt-get install -y --no-install-recommends gcc g++ build-essential
USER ubuntu

ENV USER=ubuntu HOME=/home/ubuntu
ENTRYPOINT ["/usr/local/sbin/renovate-entrypoint.sh"]
