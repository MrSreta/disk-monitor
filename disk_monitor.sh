#!/bin/bash

set -eu

WARNING_THRESHOLD=80
CRITICAL_THRESHOLD=90
LOG_FILE="/tmp/disk_monitor.log"
HOSTNAME=$(hostname)

log() {
        LEVEL=$1
        MESSAGE=$2
        TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[$TIMESTAMP] [$LEVEL] $MESSAGE" | tee -a "$LOG_FILE"
}

check_filesystem() {
        MOUNT_POINT=$1
        USAGE=$(df "$MOUNT_POINT" | tail -1 | awk '{print $5}' | sed 's/%//')
        AVAILABLE=$(df -h "$MOUNT_POINT" | tail -1 | awk '{print $4}')

        if [ "$USAGE" -ge "$CRITICAL_THRESHOLD" ]; then
                log "CRITICAL" "Host: $HOSTNAME | Mount: $MOUNT_POINT | Usage: ${USAGE}% | Available: $AVAILABLE"
        elif [ "$USAGE" -ge "$WARNING_THRESHOLD" ]; then
                log "WARNING" "Host: $HOSTNAME | Mount: $MOUNT_POINT | Usage: ${USAGE}% | Available: $AVAILABLE"
        else
                log "OK" "Host: $HOSTNAME | Mount: $MOUNT_POINT | Usage: ${USAGE}% | Available: $AVAILABLE"
        fi
}

log "INFO" "Starting disk check on $HOSTNAME"

df -h | grep -v "tmpfs\|devtmpfs\|overlay\|Filesystem" | awk '{print $6}' | while read MOUNT; do
        check_filesystem "$MOUNT"
done

log "INFO" "Disk check complete"

