#!/bin/sh

#-----------------------------------------------------------------------------
# Tailscale Container Entrypoint Script
#
# Purpose:
# - Initializes Tailscale environment
# - Starts Tailscale daemon
# - Manages initial certificate generation
# - Sets up automated certificate renewal
#-----------------------------------------------------------------------------

# Environment Setup
# Configure required Tailscale directories and authentication
export TS_STATE_DIR=/var/lib/tailscale
export TS_AUTHKEY=$TS_AUTHKEY

# Daemon Initialization
# Start Tailscale in background with containerboot
echo "[INFO] Initializing Tailscale daemon..."
env TS_STATE_DIR="$TS_STATE_DIR" TS_AUTHKEY="$TS_AUTHKEY" /usr/local/bin/containerboot &

# Startup Delay
# Ensure daemon is fully operational before proceeding
echo "[INFO] Awaiting daemon initialization..."
sleep 5  # Critical delay for daemon stability

# Initial Certificate Setup
# Generate first certificate before starting services
echo "[INFO] Performing initial certificate generation..."
/usr/local/bin/ts-certgen.sh

# Automated Renewal Configuration
# Configure periodic certificate updates via cron
echo "[INFO] Setting up automated certificate renewal..."
/usr/local/bin/ts-manage-cron.sh

# Process Management
# Keep container running by waiting for background processes
echo "[INFO] Tailscale initialization complete, monitoring daemon..."
wait -n