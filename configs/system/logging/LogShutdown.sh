#!/bin/bash

source "/var/system/scripts/logging/lib/log.sh"
source "/var/system/scripts/logging/lib/util.sh"

files=(/tmp/log/*.log(N))
date=$(date +"%Y-%m-%d-%H%M%S")

log_info "Starting log shutdown process. Found ${#files} log files to process."

for file in $files; do
    [[ -f $file ]] || continue

    nfile="/tmp/log/$(basename ${file} .log)-${date}-halt.log"
    mv "$file" "$nfile"

    size=$(stat -c %s "$nfile")
    log_info "Compressing $(human_readable "$size"): $nfile"

    if /usr/bin/zstdmt -f --rm --no-progress --output-dir-flat=/var/flex/log "$nfile"; then
        log_info "Compressed: $nfile"
    else
        log_error "Compression failed: $nfile"
    fi
done