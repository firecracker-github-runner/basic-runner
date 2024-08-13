FROM ghcr.io/actions/actions-runner:latest@sha256:30a523019a27c97da3f2145252dad9478b7427a8b484a0c775f3a8605d84d35d

ENV BIN_DIR=/usr/bin
ENV USER=runner

USER root

# Ensure runner is in group 0
RUN usermod -aG 0 runner

RUN apt update && apt install -y \
  git \
  curl \
  jq \
  unzip \
  wget \
  zstd \
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

RUN \
  # Move /nix/store (as it will be mounted as a volume)
  mkdir -p /nix_base && \
  mv /nix/store /nix_base/store && \
  chown -R runner:0 /nix_base && \
  chown -R runner:0 /home/runner && \
  # Cleanup
  rm /etc/sudoers.d/runner && \
  rm -rf /tmp/*

# Inject sudo shim
COPY --chown=root:root ./sudoShim.sh /usr/bin/sudo

USER runner
