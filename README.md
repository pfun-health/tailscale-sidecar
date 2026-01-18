# Tailscale Sidecar with Certificate Sharing

This is a fork of [hhftechnology/tailscale-sidecar](https://github.com/hhftechnology/tailscale-sidecar). Thanks for the assist @[hhftechnology](https://github.com/hhftechnology)!

---

A specialized Docker container that extends the official Tailscale image to enable secure networking and certificate management within Docker Compose environments. This container acts as a sidecar, automatically managing Tailscale certificates and sharing them across your containerized services.

[![Docker Hub](https://img.shields.io/docker/v/pfun/tailscale-sidecar?sort=semver)](https://hub.docker.com/r/pfun/tailscale-sidecar)

## Features

- Built on the official Tailscale base image
- Automated certificate generation and renewal
- Weekly certificate regeneration (Monday at 12 AM)
- Multi-architecture support via Docker buildx
- Simplified certificate sharing between containers
- Persistent state management

## Container build steps

### Environment

Define the required environment variables in `.env`. You can start by copying the example:

```bash
cp .env.example ./.env
```

### Container Scripts

The image includes three critical scripts:

#### ts-entrypoint.sh

- Primary container entrypoint that:
  - Initializes Tailscale daemon
  - Generates initial certificates
  - Configures automated renewal cron jobs

#### ts-certgen.sh

- Certificate generation script that:
  - Creates new Tailscale certificates
  - Uses domain name from environment variables
  - Runs on a scheduled basis

#### ts-manage-cron.sh

- Cron management script that:
  - Establishes weekly certificate renewal schedule
  - Runs every Monday at 12 AM
  - Ensures certificate freshness

## Building and Deployment

### Building the Image

```bash
docker build -t pfun/tailscale-sidecar .
```

### Deploying to Docker Hub

```bash
docker push pfun/tailscale-sidecar
```

## Usage with Docker Compose

### Example Configuration

```yaml
services:
  tailscale:
    image: pfun/tailscale-sidecar:latest
    container_name: ts-${TS_HOSTNAME}
    restart: unless-stopped
    hostname: ${TS_HOSTNAME}
    environment:
      - TS_AUTHKEY=${TS_AUTHKEY}
      - TS_STATE_DIR=/var/lib/tailscale
      - TS_DOMAIN_NAME=${TS_HOST_FQDN}
    volumes:
      - ts-state:/var/lib/tailscale
      - ts-certs:/certs
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - net_admin
      - sys_module

  service:
    image: your-service:latest
    network_mode: service:tailscale
    depends_on:
      - tailscale
    volumes:
      - ts-certs:/certs
    # Additional service configuration...

volumes:
  ts-state:
  ts-certs:
```

### Key Configuration Points

#### Environment Variables

- `TS_AUTHKEY`: Your Tailscale authentication key
- `TS_HOSTNAME`: Container hostname
- `TS_HOST_FQDN`: Fully qualified domain name

#### Volume Sharing

- `/certs`: Certificate sharing directory
- `/var/lib/tailscale`: Tailscale state persistence

#### Networking

- Uses `network_mode: service:tailscale` for service networking
- Requires `net_admin` and `sys_module` capabilities
- Mounts `/dev/net/tun` for VPN functionality

## Examples

- [Tailscaled Nginx](https://github.com/hhftechnology/tailscaled-nginx): Demonstrates Nginx integration

## Development

### Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

### Requirements

- Docker with buildx support
- Docker Compose
- Tailscale account and authkey

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
