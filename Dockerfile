FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/bash@sha256:62391cd491beac226e4dae09911481c8139c143a96a33b763a168be68ba3fc01 AS fetcher

ARG TARGETOS
ARG TARGETARCH
#ARG TARGETVARIANT

# renovate: datasource=github-releases depName=bazelbuild/bazelisk
ARG BAZELISK_VERSION=1.25.0

RUN mkdir /out
RUN curl -L -o /out/bazelisk https://github.com/bazelbuild/bazelisk/releases/download/v$BAZELISK_VERSION/bazelisk-$TARGETOS-$TARGETARCH

RUN chmod a+x /out/*
RUN ln -s bazelisk /out/bazel

FROM ghcr.io/renovatebot/renovate@sha256:36cf5db8524809b2df4e313e1af986c23f4bd2e77dae529cb4fc34284723beb6

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
