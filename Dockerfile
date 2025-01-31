FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/bash@sha256:155bb115668e5ff1a831f59aa4f09a7fcebd827080815e2b04f5fc03fca8ed07 AS fetcher

ARG TARGETOS
ARG TARGETARCH
#ARG TARGETVARIANT

# renovate: datasource=github-releases depName=bazelbuild/bazelisk
ARG BAZELISK_VERSION=1.25.0

RUN mkdir /out
RUN curl -L -o /out/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v$BAZELISK_VERSION/bazelisk-$TARGETOS-$TARGETARCH

RUN chmod a+x /out/*
RUN ln -s bazelisk /out/bazel

FROM ghcr.io/renovatebot/renovate

COPY --from=fetcher /out/* /usr/local/bin/
