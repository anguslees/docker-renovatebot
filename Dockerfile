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

FROM ghcr.io/renovatebot/renovate@sha256:33153a313777d4640e37dccdac5ec67263c00edd5d470748599eba25790dea93

COPY --from=fetcher /out/* /usr/local/bin/
