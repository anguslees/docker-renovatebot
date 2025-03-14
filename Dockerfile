FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/bash@sha256:dfefb36a312ca72a10def2ed1a30f8f360a0cff868e7aeebabb598a5a68da8e7 AS fetcher

ARG TARGETOS
ARG TARGETARCH
#ARG TARGETVARIANT

# renovate: datasource=github-releases depName=bazelbuild/bazelisk
ARG BAZELISK_VERSION=1.25.0

RUN mkdir /out
RUN curl -L -o /out/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v$BAZELISK_VERSION/bazelisk-$TARGETOS-$TARGETARCH

RUN chmod a+x /out/*
RUN ln -s bazelisk /out/bazel

FROM ghcr.io/renovatebot/renovate@sha256:12e04c3cd445241b1b8829f72ad911a19c4e3a0dfef329a68d8d8ab1d7b2bf31

COPY --from=fetcher /out/* /usr/local/bin/

USER root
RUN apt-get update; apt-get install -y --no-install-recommends gcc g++ build-essential
USER ubuntu

# Remove once nix is removed from tools/bazel
USER root
RUN mkdir -m 0755 /nix && chown ubuntu /nix
USER ubuntu
RUN curl -L https://nixos.org/nix/install | sh
ENV USER=ubuntu HOME=/home/ubuntu
ENTRYPOINT ["bash", "-c", "source /home/ubuntu/.nix-profile/etc/profile.d/nix.sh; exec /usr/local/sbin/renovate-entrypoint.sh"]
