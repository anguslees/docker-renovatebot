FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/bash@sha256:6c2a805343f7202cbe5c66b4f8cdfd7b034c44c57b034be85a254dee92fd1939 AS fetcher

ARG TARGETOS
ARG TARGETARCH
#ARG TARGETVARIANT

# renovate: datasource=github-releases depName=bazelbuild/bazelisk
ARG BAZELISK_VERSION=1.25.0

RUN mkdir /out
RUN curl -L -o /out/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v$BAZELISK_VERSION/bazelisk-$TARGETOS-$TARGETARCH

RUN chmod a+x /out/*
RUN ln -s bazelisk /out/bazel

FROM ghcr.io/renovatebot/renovate@sha256:2d8fa8319ec3cde693771a2b8b8c6dc11862000e22de2981e3ecf11a31eb1d53

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
