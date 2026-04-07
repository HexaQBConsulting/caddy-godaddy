# caddy-godaddy

Custom Caddy image with the [`caddy-dns/godaddy`](https://github.com/caddy-dns/godaddy)
plugin, so Caddy can solve ACME DNS-01 challenges using the GoDaddy API.

**Image:** [`hexaqb/caddy-godaddy`](https://hub.docker.com/r/hexaqb/caddy-godaddy)

## Why

DNS-01 challenges bypass inbound HTTP/HTTPS entirely. Required when the edge
firewall geoblocks the ACME CA's validator IPs (e.g. IPFire country blocking
dropping Let's Encrypt validators).

## Tags

| Tag                | Meaning                                   |
| ------------------ | ----------------------------------------- |
| `latest`           | Latest build from `main`                  |
| `vX.Y.Z`, `vX.Y`   | Semver tag pushed to the repo             |
| `sha-<short>`      | Specific commit                           |

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

## License

Apache License 2.0 — see [LICENSE](LICENSE).

Copyright © 2026 HexaQB Consulting.
