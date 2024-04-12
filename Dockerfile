# Use docker images as sources for binaries as possible, to keep versioning simpler
FROM chainguard/apko:latest@sha256:931b89968e4182649c4de2ac5bae07184b0327462641db997c0df22f87077740 as apko
FROM oven/bun:distroless@sha256:3cc457ea32e90b9c87b1d134e89c072a986ee3adaed7063d35fef2fce90cc4a7 as bun
FROM denoland/deno:bin@sha256:18d72c43e4b91c81e824e368e8eb15c67b481e669c5151dc3902cf113c87c4b7 AS deno

FROM registry.access.redhat.com/ubi9/ubi@sha256:66233eebd72bb5baa25190d4f55e1dc3fff3a9b77186c1f91a0abdb274452072 as builder
# Grab anything we can't get via other means

RUN dnf install -y \
  jq \
  && dnf clean all

ENV WORKDIR=/work

RUN mkdir -p ${WORKDIR}
WORKDIR ${WORKDIR}

COPY --chown=root:0 fetch-externals.sh ${WORKDIR}/
RUN cd ${WORKDIR} && \
  ./fetch-externals.sh

FROM ghcr.io/actions/actions-runner:latest@sha256:45f609ab5bd691735dbb25e3636db2f5142fcd8f17de635424f2e7cbd3e16bc9

ENV BIN_DIR=/usr/bin
ENV USER=runner

USER root

# Add binaries
COPY --from=bun --chown=root:0 /usr/local/bin/bun ${BIN_DIR}/bun
COPY --from=apko --chown=root:0 /usr/bin/apko ${BIN_DIR}/apko
COPY --from=deno --chown=root:0 /deno ${BIN_DIR}/deno
COPY --from=builder --chown=root:0 /work/ko/ko ${BIN_DIR}/ko

RUN apt update && apt install -y \
  git \
  curl \
  jq \
  unzip \
  wget \
  xz-utils \
  && apt clean \
  && rm -rf /var/lib/apt/lists/*

# Add runner to sudoers
RUN echo "runner ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/runner
COPY --chown=runner:0 ./install /tmp/install/

# Install nix
USER runner
RUN /tmp/install/nix.sh
ENV PATH /nix/var/nix/profiles/default/bin:/home/runner/.nix-profile/bin:$PATH
USER root

# cleanup
RUN rm /etc/sudoers.d/runner && rm -rf /tmp/*

USER runner
