# Tailscale Sidecar with Certificate Sharing

A specialized Docker container that extends the official Tailscale image to enable secure networking and certificate management within Docker Compose environments. This container acts as a sidecar, automatically managing Tailscale certificates and sharing them across your containerized services.

[![Docker Hub](https://img.shields.io/docker/v/hhftechnology/tailscale-sidecar?sort=semver)](https://hub.docker.com/r/hhftechnology/tailscale-sidecar)

## Features

- Built on the official Tailscale base image
- Automated certificate generation and renewal
- Weekly certificate regeneration (Saturday at 12 AM)
- Multi-architecture support via Docker buildx
- Simplified certificate sharing between containers
- Persistent state management

## Container Scripts

The image includes three critical scripts:

### ts-entrypoint.sh
- Primary container entrypoint that:
  - Initializes Tailscale daemon
  - Generates initial certificates
  - Configures automated renewal cron jobs

### ts-certgen.sh
- Certificate generation script that:
  - Creates new Tailscale certificates
  - Uses domain name from environment variables
  - Runs on a scheduled basis

### ts-manage-cron.sh
- Cron management script that:
  - Establishes weekly certificate renewal schedule
  - Runs every Saturday at 12 AM
  - Ensures certificate freshness

## Building and Deployment

### Building the Image

Use the provided `x_build.sh` script:

```bash
./x_build.sh
```

- Supports multi-architecture builds via buildx
- Version controlled through `build-manifest.env`
- Configurable image naming

### Deploying to Docker Hub

Use the provided `x_deploy.sh` script:

```bash
./x_deploy.sh
```

- Handles multi-architecture pushing
- Automatically tags latest version
- Uses repository settings from `build-manifest.env`

## Usage with Docker Compose

### Example Configuration

```yaml
services:
  tailscale:
    image: hhftechnology/tailscale-sidecar:latest
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

Detailed examples are available in the `/list` directory:
- [Tailscaled Nginx](https://github.com/hhftechnology/tailscaled-nginx): Demonstrates Nginx integration
- More to follow

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
