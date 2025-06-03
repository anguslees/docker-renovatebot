FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/bash@sha256:f02c38693edadb0875d42f72a72046590ec82ed59011a807a031bdf9e00ff3f6 AS fetcher

ARG TARGETOS
ARG TARGETARCH
#ARG TARGETVARIANT

# renovate: datasource=github-releases depName=bazelbuild/bazelisk
ARG BAZELISK_VERSION=1.26.0

RUN mkdir /out
RUN curl -L -o /out/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v$BAZELISK_VERSION/bazelisk-$TARGETOS-$TARGETARCH

RUN chmod a+x /out/*
RUN ln -s bazelisk /out/bazel

FROM ghcr.io/renovatebot/renovate@sha256:aff2bef7e060b10d0507680d45ffbc6b158d544a388cf1a96c395aef92381f58

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
