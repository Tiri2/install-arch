#!/bin/zsh

source "/var/system/scripts/logging/lib/log.sh"
source "/var/system/scripts/logging/lib/util.sh"

files=(/tmp/log/ready/*.log(N))
sleep 2

for file in $files; do
    [[ -f $file ]] || continue

    size=$(stat -c %s "$file")
    log_info "Compressing $(human_readable "$size"): $file"

    if /usr/bin/zstdmt -f --rm --no-progress \
            --output-dir-flat=/var/flex/log "$file"; then
        log_info "Success: $file"
    else
        log_error "FAILED: $file"
    fi
done
