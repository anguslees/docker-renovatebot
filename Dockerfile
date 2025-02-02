FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/bash@sha256:ea45bf4807e36fce0d752aa6ad143da9f92ef2a66a35902fff90ebfff23a830f AS fetcher

ARG TARGETOS
ARG TARGETARCH
#ARG TARGETVARIANT

# renovate: datasource=github-releases depName=bazelbuild/bazelisk
ARG BAZELISK_VERSION=1.25.0

RUN mkdir /out
RUN curl -L -o /out/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v$BAZELISK_VERSION/bazelisk-$TARGETOS-$TARGETARCH

RUN chmod a+x /out/*
RUN ln -s bazelisk /out/bazel

FROM ghcr.io/renovatebot/renovate@sha256:d55235796d54faf25ad429400e05dea351c8b6e35211677ee2b27ffd005ae849

COPY --from=fetcher /out/* /usr/local/bin/
