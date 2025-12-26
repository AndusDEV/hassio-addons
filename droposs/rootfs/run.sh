#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

echo "[Drop Addon] Reading configuration..."

# Read from Home Assistant config
if [ -f "$CONFIG_PATH" ]; then
    DATABASE_URL=$(jq -r '.database_url // empty' $CONFIG_PATH)
    EXTERNAL_URL=$(jq -r '.external_url // empty' $CONFIG_PATH)
    LOCALDISKS=$(jq -r '.localdisks // empty' $CONFIG_PATH)
    
    export DATABASE_URL
    export EXTERNAL_URL
    
    [ -n "$DATABASE_URL" ] && echo "[Drop Addon] DATABASE_URL configured"
    [ -n "$EXTERNAL_URL" ] && echo "[Drop Addon] EXTERNAL_URL: $EXTERNAL_URL"
fi

# Mount disks
if [ -n "$LOCALDISKS" ]; then
    echo "[Drop Addon] Disk config: '$LOCALDISKS'"
    echo "[Drop Addon] Available labels:"
    ls -1 /dev/disk/by-label/ 2>/dev/null || echo "  (none)"
    
    echo "[Drop Addon] Block devices:"
    lsblk -o NAME,SIZE,LABEL,MOUNTPOINT 2>/dev/null || true
    
    # Process each disk (avoid subshell)
    IFS=',' read -ra DISKS <<< "$LOCALDISKS"
    for disk_raw in "${DISKS[@]}"; do
        disk=$(echo "$disk_raw" | xargs)
        
        [ -z "$disk" ] && continue
        
        echo "[Drop Addon] === Processing: '$disk' ==="
        
        DEVICE=""
        LABEL=""
        
        if [[ "$disk" == /dev/* ]]; then
            DEVICE="$disk"
            echo "[Drop Addon]   Type: device path"
        else
            LABEL="$disk"
            LABEL_PATH="/dev/disk/by-label/$disk"
            echo "[Drop Addon]   Type: label"
            echo "[Drop Addon]   Looking for: $LABEL_PATH"
            
            if [ -e "$LABEL_PATH" ]; then
                DEVICE=$(readlink -f "$LABEL_PATH")
                echo "[Drop Addon]   Found: $DEVICE"
            else
                echo "[Drop Addon]   ERROR: Label not found!"
                continue
            fi
        fi
        
        if [ ! -b "$DEVICE" ]; then
            echo "[Drop Addon]   ERROR: Not a block device"
            continue
        fi
        
        MOUNT_POINT="/mnt/${LABEL:-$(basename "$DEVICE")}"
        echo "[Drop Addon]   Mount point: $MOUNT_POINT"
        
        mkdir -p "$MOUNT_POINT"
        
        if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
            echo "[Drop Addon]   Status: Already mounted"
        else
            echo "[Drop Addon]   Mounting..."
            if mount "$DEVICE" "$MOUNT_POINT" 2>&1; then
                echo "[Drop Addon]   SUCCESS: Mounted to $MOUNT_POINT"
                chmod 755 "$MOUNT_POINT"
            else
                echo "[Drop Addon]   FAILED to mount"
            fi
        fi
    done
    
    echo "[Drop Addon] === Mount summary ==="
    mount | grep "^/dev" | grep "/mnt" || echo "  No /mnt mounts"
fi

# Start Drop
echo "[Drop Addon] Starting Drop..."
exec sh /app/startup/launch.sh