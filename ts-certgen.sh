#!/usr/bin/env sh

#-----------------------------------------------------------------------------
# Tailscale Certificate Generation Script
#
# Purpose:
# - Generates and renews Tailscale SSL/TLS certificates
# - Designed for automated execution via cron
# - Ensures continuous certificate validity
#
# Usage:
# - Requires TS_DOMAIN_NAME environment variable
# - Certificates are stored in /certs directory
# - Exit codes: 0 (success), 1 (error)
#-----------------------------------------------------------------------------

# Environment Validation
# Check if domain name is configured
if [ -z "${TS_DOMAIN_NAME}" ]; then
   echo "[ERROR] Missing TS_DOMAIN_NAME environment variable"
   echo "[INFO] Please set TS_DOMAIN_NAME to your Tailscale domain"
   exit 1
fi

# Certificate Generation
# Navigate to certificate directory and generate new cert
echo "[INFO] Starting certificate generation for ${TS_DOMAIN_NAME}"
if ! cd /certs/; then
   echo "[ERROR] Failed to access certificate directory"
   exit 1
fi

echo "[INFO] Requesting certificate from Tailscale..."
if ! tailscale cert "${TS_DOMAIN_NAME}"; then
   echo "[ERROR] Certificate generation failed"
   exit 1
fi

echo "[SUCCESS] Certificate generated successfully"