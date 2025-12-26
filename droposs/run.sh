#!/bin/sh
set -e

echo "[Drop Addon] Mounting local disks..."

# Get comma-separated list and split
LOCALDISKS=$(jq -r '.localdisks // ""' /data/options.json | tr ',' ' ')

for disk in $LOCALDISKS; do
  if [ -e "/dev/$disk" ]; then
    DEV="/dev/$disk"
  elif [ -e "/dev/disk/by-label/$disk" ]; then
    DEV=$(readlink -f "/dev/disk/by-label/$disk")
  elif [ -e "/dev/disk/by-uuid/$disk" ]; then
    DEV=$(readlink -f "/dev/disk/by-uuid/$disk")
  else
    echo "WARNING: Disk '$disk' not found. Skipping."
    continue
  fi

  mkdir -p "/mnt/$disk"
  if mount "$DEV" "/mnt/$disk"; then
    echo "Mounted $disk -> /mnt/$disk"
    chown -R node:node "/mnt/$disk" 2>/dev/null || true
  else
    echo "ERROR: Failed to mount $disk"
  fi
done

echo "[Drop Addon] Ready! Use /mnt/<disk>, /share, or subfolders as libraries in Drop."

exec "$@"