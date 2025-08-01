FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/bash@sha256:bead13d6e4fd0e862b77ab8bb8871e44774a74c344fb11d85977c1db0567e305 AS fetcher

ARG TARGETOS
ARG TARGETARCH
#ARG TARGETVARIANT

# renovate: datasource=github-releases depName=bazelbuild/bazelisk
ARG BAZELISK_VERSION=1.26.0

RUN mkdir /out
RUN curl -L -o /out/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v$BAZELISK_VERSION/bazelisk-$TARGETOS-$TARGETARCH

RUN chmod a+x /out/*
RUN ln -s bazelisk /out/bazel

FROM ghcr.io/renovatebot/renovate@sha256:1019a86c4e18c798addb30584c43de6860036f9b0afee4f82efefa56b09fb00e

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
