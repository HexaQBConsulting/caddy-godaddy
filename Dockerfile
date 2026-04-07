# syntax=docker/dockerfile:1

# =============================================================================
# Caddy + GoDaddy DNS provider
# =============================================================================
# Custom Caddy build with the caddy-dns/godaddy plugin baked in, so we can use
# the ACME DNS-01 challenge against the GoDaddy API.
#
# Why: DNS-01 bypasses inbound HTTP/HTTPS entirely, which is necessary when the
# edge firewall geoblocks the ACME CA's validator IPs.
# =============================================================================

ARG CADDY_VERSION=2

FROM caddy:${CADDY_VERSION}-builder-alpine AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/godaddy

FROM caddy:${CADDY_VERSION}-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
