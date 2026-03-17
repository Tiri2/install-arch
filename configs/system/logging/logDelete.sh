#!/bin/zsh

source "/var/system/scripts/logging/lib/log.sh"
source "/var/system/scripts/logging/lib/util.sh"
source "/var/system/scripts/logging/lib/config.sh"

WATCH_DIR="/var/log/tasks"

START_THRESHOLD_BYTES=$(( $(read_config "flexSystem.logging" "tasks_logs.start_value") * 1024 * 1024 * 1024 ))
STOP_THRESHOLD_BYTES=$(( $(read_config "flexSystem.logging" "tasks_logs.stop_value") * 1024 * 1024 * 1024 ))
DISK_USAGE_START_THRESHOLD_PERCENT=$(read_config "flexSystem.logging" "tasks_logs_fallback_percent.start_value")
DISK_USAGE_STOP_THRESHOLD_PERCENT=$(read_config "flexSystem.logging" "tasks_logs_fallback_percent.stop_value")

# Get directory size in bytes (faster than du -BG)
get_dir_size_bytes() {
  du -sb -- "$WATCH_DIR" | awk '{print $1}'
}

get_disk_usage_percent() {
  local btrfs_output device_size free_estimated percent
  btrfs_output="$(btrfs filesystem usage -b "$WATCH_DIR" 2>/dev/null)"
  device_size="$(echo "$btrfs_output" | awk '/[Dd]evice size:/{print $NF}')"
  free_estimated="$(echo "$btrfs_output" | awk '/Free \(estimated\):/{print $3}')"
  percent=$(( (device_size - free_estimated) * 100 / device_size ))
  log_info "Current disk usage: $percent% (device size: $(human_readable "$device_size"), free estimated: $(human_readable "$free_estimated"))" >&2
  echo "$percent"
}


delete_until_within_limit() {
  local current_size disk_usage triggered_by
  current_size="$(get_dir_size_bytes)"
  disk_usage="$(get_disk_usage_percent)"

  log_info "Current directory size: $(human_readable "$current_size")"
  log_info "Current disk usage: ${disk_usage}%"

  if (( disk_usage >= DISK_USAGE_START_THRESHOLD_PERCENT )); then
    log_warn "Disk usage critically high (${disk_usage}%)"
    triggered_by="percentage"
  elif (( current_size >= START_THRESHOLD_BYTES )); then
    log_info "Directory size above threshold $(human_readable "$current_size")"
    triggered_by="size"
  else
    log_info "Directory size and disk usage below thresholds. No deletion needed."
    return 0
  fi

  log_info "Starting cleanup..."

  # Build sorted file list once (oldest first)
  find "$WATCH_DIR" -type f -printf '%T@ %s %p\0' 2>/dev/null \
    | sort -z -n \
    | while IFS= read -r -d '' entry; do

        # Stop if we reached target
        if [[ "$triggered_by" == "percentage" ]]; then
          disk_usage="$(get_disk_usage_percent)"
          if (( disk_usage < DISK_USAGE_STOP_THRESHOLD_PERCENT )); then
            log_info "Disk usage back to safe levels (${disk_usage}%). Stopping cleanup."
            break
          fi
        elif [[ "$triggered_by" == "size" ]]; then
          if (( current_size < STOP_THRESHOLD_BYTES )); then
            log_info "Directory size back below stop threshold. Stopping cleanup."
            break
          fi
        fi

        # Extract size + path
        file_size=$(echo "$entry" | awk '{print $2}')
        file_path=$(echo "$entry" | cut -d' ' -f3-)

        rm -f -- "$file_path" || continue

        current_size=$((current_size - file_size))

        log_info "Deleted: $file_path"
    done

  log_info "Cleanup complete. Final size: $(human_readable "$current_size")"
}

echo "using following values from ${CONFIG_FILE}"
echo " - Start threshold (bytes): $START_THRESHOLD_BYTES"
echo " - Stop threshold (bytes): $STOP_THRESHOLD_BYTES"
echo " - Disk usage start threshold (%): $DISK_USAGE_START_THRESHOLD_PERCENT"
echo " - Disk usage stop threshold (%): $DISK_USAGE_STOP_THRESHOLD_PERCENT"

delete_until_within_limit
echo "Done"