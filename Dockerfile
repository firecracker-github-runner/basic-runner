FROM oven/bun:distroless@sha256:6cf857056b03a4eecd8cf62d67296e1da50bbb205c824d7b888202f66fd690ce as bun
FROM denoland/deno:bin@sha256:7da859b3e0bca7229bd5baef44c11ec6ba32caa4af2aba5dd3945d9297009cd2 AS deno
FROM chainguard/apko:latest@sha256:931b89968e4182649c4de2ac5bae07184b0327462641db997c0df22f87077740 as apko

FROM ghcr.io/actions/actions-runner:latest@sha256:45f609ab5bd691735dbb25e3636db2f5142fcd8f17de635424f2e7cbd3e16bc9

ENV BIN_DIR=/usr/bin

USER root

# Add binaries
COPY --from=deno --chown=root:0 /deno ${BIN_DIR}/deno
COPY --from=bun --chown=root:0 /usr/local/bin/bun ${BIN_DIR}/bun
COPY --from=apko --chown=root:0 /usr/bin/apko ${BIN_DIR}/apko

RUN apt update && apt install -y \
  git \
  curl \
  jq \
  unzip \
  wget \
  && apt clean \
  && rm -rf /var/lib/apt/lists/*

USER runner