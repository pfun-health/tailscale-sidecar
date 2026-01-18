#!/usr/bin/env sh

#-----------------------------------------------------------------------------
# Tailscale Certificate Renewal Scheduler
#
# Purpose:
# - Manages automated certificate renewal via cron
# - Prevents duplicate cron entries
# - Logs renewal attempts for monitoring
#
# Schedule: Every Monday at 12:00 AM (Midnight)
#-----------------------------------------------------------------------------

# Cron Configuration
# Format: Minute Hour Day Month DayOfWeek Command
# 0 0 * * 1 = At 00:00 (12:00 AM) on Monday (0=Sunday, 1=Monday, ..., 6=Saturday)
CRON_JOB="0 0 * * 1 ts-certgen.sh >> /ts-certgen.log 2>&1"

# Cron Job Management
# Check existing crontab for duplicate entries
echo "[INFO] Verifying cron configuration..."
if ! crontab -l | grep -Fxq "${CRON_JOB}"; then
   echo "[INFO] Installing certificate renewal schedule..."
   (crontab -l ; echo "${CRON_JOB}") | crontab -
   echo "[SUCCESS] Scheduled certificate renewal for Monday 12:00 AM"
else
   echo "[INFO] Certificate renewal schedule already exists"
fi
