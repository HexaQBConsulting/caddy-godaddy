# syntax=docker/dockerfile:1

# =============================================================================
# Caddy + GoDaddy DNS provider — reproducible build
# =============================================================================
# Everything is pinned:
#   - CADDY_VERSION: exact Caddy semver tag (base image + Go module)
#   - CADDY_GODADDY_VERSION: exact caddy-dns/godaddy release tag
#
# To upgrade: edit the ARGs below (or let Renovate open a PR), commit, push.
# The image you build today and the image you build next month from the same
# commit are bit-identical (modulo Go toolchain determinism).
# =============================================================================

ARG CADDY_VERSION=2.11.2
ARG CADDY_GODADDY_VERSION=v1.2.0

FROM caddy:${CADDY_VERSION}-builder-alpine AS builder

ARG CADDY_VERSION
ARG CADDY_GODADDY_VERSION

RUN xcaddy build "v${CADDY_VERSION}" \
    --with "github.com/caddy-dns/godaddy@${CADDY_GODADDY_VERSION}"

FROM caddy:${CADDY_VERSION}-alpine

ARG CADDY_VERSION
ARG CADDY_GODADDY_VERSION

LABEL org.opencontainers.image.title="caddy-godaddy" \
      org.opencontainers.image.description="Caddy with caddy-dns/godaddy plugin baked in" \
      org.opencontainers.image.source="https://github.com/HexaQBConsulting/caddy-godaddy" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.vendor="HexaQB Consulting" \
      com.hexaqb.caddy.version="${CADDY_VERSION}" \
      com.hexaqb.caddy-dns-godaddy.version="${CADDY_GODADDY_VERSION}"

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
