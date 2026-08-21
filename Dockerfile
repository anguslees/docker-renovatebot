FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/bash@sha256:2e7c7e0e7e4bdd5f9f76e0e8a2b158010878e0bf20ad5ab9bc484df2c68d1a8d AS fetcher

ARG TARGETOS
ARG TARGETARCH
#ARG TARGETVARIANT

# renovate: datasource=github-releases depName=bazelbuild/bazelisk
ARG BAZELISK_VERSION=1.29.0

RUN mkdir /out
RUN curl -L -o /out/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v$BAZELISK_VERSION/bazelisk-$TARGETOS-$TARGETARCH

RUN chmod a+x /out/*
RUN ln -s bazelisk /out/bazel

FROM ghcr.io/renovatebot/renovate@sha256:00699dedb6d44bf645e3f0a98729bcdb660a660f1952a53d9592d3a127088b11

COPY --from=fetcher /out/* /usr/local/bin/

USER root
RUN apt-get update; apt-get install -y --no-install-recommends gcc g++ build-essential
USER ubuntu

ENV USER=ubuntu HOME=/home/ubuntu
ENTRYPOINT ["/usr/local/sbin/renovate-entrypoint.sh"]
