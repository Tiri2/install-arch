#!/usr/bin/env bash

LOG_FILE="/var/log/system/logger.log"

log() {
    local level="$1"
    shift
    local msg="$*"
    printf "[%s] [%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$msg" >> "$LOG_FILE"
}

log_info()  { log INFO  "$@"; }
log_warn()  { log WARN  "$@"; }
log_error() { log ERROR "$@"; }
