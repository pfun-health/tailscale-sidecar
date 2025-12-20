# Base Image
FROM tailscale/tailscale:latest AS builder

#-----------------------------------------------------------------------------
# Environment Configuration
#-----------------------------------------------------------------------------
ENV TS_STATE_DIR=/var/lib/tailscale

#-----------------------------------------------------------------------------
# System Setup
#-----------------------------------------------------------------------------
# First copy the scripts
COPY ts-entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ts-manage-cron.sh /usr/local/bin/ts-manage-cron.sh
COPY ts-certgen.sh /usr/local/bin/ts-certgen.sh

# Then set permissions in a separate RUN command
RUN chmod 755 /usr/local/bin/entrypoint.sh \
    /usr/local/bin/ts-manage-cron.sh \
    /usr/local/bin/ts-certgen.sh \
    && mkdir -p /var/lib/tailscale \
    && ls -la /usr/local/bin/ts-*.sh

#-----------------------------------------------------------------------------
# Runtime Configuration
#-----------------------------------------------------------------------------
# Health check to verify Tailscale service
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD tailscale status || exit 1

# Use exec form for proper signal handling
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Optional: Add labels for better container management
LABEL maintainer="HHF Technology <discourse@hhf.technology>" \
      org.opencontainers.image.title="Tailscale Sidecar with Certificate Sharing" \
      org.opencontainers.image.description="Tailscale container with automated certificate management" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.source="https://github.com/hhftechnology/tailscale-sidecar"