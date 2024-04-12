FROM ghcr.io/actions/actions-runner:latest@sha256:45f609ab5bd691735dbb25e3636db2f5142fcd8f17de635424f2e7cbd3e16bc9

ENV BIN_DIR=/usr/bin
ENV USER=runner

USER root

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

# Move /nix/store (as it will be mounted as a volume)
RUN mv /nix/store /nix/store_base

# cleanup
RUN rm /etc/sudoers.d/runner && rm -rf /tmp/*

# Inject sudo shim
COPY --chown=root:root ./sudoShim.sh /usr/bin/sudo

USER runner
