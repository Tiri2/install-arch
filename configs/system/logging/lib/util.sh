#!/usr/bin/env bash

human_readable() {
    local size=$1
    if (( size >= 1073741824 )); then
        awk "BEGIN {printf \"%.2f GiB\", $size/1073741824}"
    elif (( size >= 1048576 )); then
        awk "BEGIN {printf \"%.2f MiB\", $size/1048576}"
    elif (( size >= 1024 )); then
        awk "BEGIN {printf \"%.2f KiB\", $size/1024}"
    else
        echo "${size} B"
    fi
}