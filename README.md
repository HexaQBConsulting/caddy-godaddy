# caddy-godaddy

Custom Caddy image with the [`caddy-dns/godaddy`](https://github.com/caddy-dns/godaddy)
plugin, so Caddy can solve ACME DNS-01 challenges using the GoDaddy API.

**Image:** [`hexaqb/caddy-godaddy`](https://hub.docker.com/r/hexaqb/caddy-godaddy)

## Why

DNS-01 challenges bypass inbound HTTP/HTTPS entirely. Required when the edge
firewall geoblocks the ACME CA's validator IPs (e.g. IPFire country blocking
dropping Let's Encrypt validators).

## Reproducible build

Both Caddy and the plugin are pinned to exact versions via Dockerfile `ARG`s:

```dockerfile
ARG CADDY_VERSION=2.11.2
ARG CADDY_GODADDY_VERSION=v1.2.0
```

No floating tags, no "whatever upstream shipped today". The image built from
any given commit uses exactly those versions. Upgrades happen through
[Renovate](https://docs.renovatebot.com/) PRs (see `renovate.json`) that
bump the ARGs — review, merge, new image published.

## Tags

| Tag                                | Meaning                                                  |
| ---------------------------------- | -------------------------------------------------------- |
| `latest`                           | Latest build from `main`                                 |
| `<caddy_version>`                  | E.g. `2.11.2` — the Caddy version baked into the image   |
| `<caddy_version>-godaddy-<plugin>` | E.g. `2.11.2-godaddy-v1.2.0` — full version bundle       |
| `vX.Y.Z`, `vX.Y`                   | Repo semver tag                                          |
| `sha-<short>`                      | Specific commit                                          |

## Usage

### Caddyfile

```
your.domain.tld {
    tls {
        dns godaddy {env.GODADDY_API_TOKEN}
        propagation_timeout 5m
        resolvers 8.8.8.8 1.1.1.1
    }
    reverse_proxy upstream:80
}
```

### docker-compose / Swarm stack

```yaml
services:
  caddy:
    image: hexaqb/caddy-godaddy:latest
    environment:
      - GODADDY_API_TOKEN=${GODADDY_API_TOKEN}
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - caddy-data:/data
      - caddy-config:/config
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
```

`GODADDY_API_TOKEN` must be in the format `KEY:SECRET`, which is what the
[libdns/godaddy](https://github.com/libdns/godaddy) provider expects.

Generate a **Production** key at <https://developer.godaddy.com/keys>. Note:
GoDaddy's DNS API currently requires an account with 10+ domains or a Discount
Domain Club plan.

## Build locally

```bash
docker build -t caddy-godaddy:local .
```

## Release

Push a tag:

```bash
git tag v0.1.0
git push origin v0.1.0
```

The GitHub Actions workflow builds multi-arch (`linux/amd64`, `linux/arm64`)
and pushes to Docker Hub.

## Upgrading Caddy or the plugin

1. Renovate opens a PR bumping `ARG CADDY_VERSION` or
   `ARG CADDY_GODADDY_VERSION` in the Dockerfile.
2. Review the upstream changelog linked in the PR.
3. Merge. The build workflow publishes a new `:latest` plus a new
   `:<caddy_version>` and `:<caddy_version>-godaddy-<plugin_version>` tag.

To bump manually without waiting for Renovate:

```bash
# edit Dockerfile ARGs, then
git commit -am "Bump Caddy to 2.12.0"
git push
```

## License

Apache License 2.0 — see [LICENSE](LICENSE).

Copyright © 2026 HexaQB Consulting.
