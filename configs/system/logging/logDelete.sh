#!/bin/zsh

source "/var/system/scripts/logging/lib/log.sh"
source "/var/system/scripts/logging/lib/util.sh"

CONFIG_DIR="/var/system/scripts/logging/config" # TODO: threshold in conf setzen
WATCH_DIR="/var/log/tasks"

START_THRESHOLD_BYTES=$((15 * 1024 * 1024 * 1024))
STOP_THRESHOLD_BYTES=$((13 * 1024 * 1024 * 1024))

# Get directory size in bytes (faster than du -BG)
get_dir_size_bytes() {
  du -sb -- "$WATCH_DIR" | awk '{print $1}'
}

delete_until_within_limit() {
  local current_size
  current_size="$(get_dir_size_bytes)"

  log_info "Current directory size: $(human_readable "$current_size")"

  # Nothing to do
  if (( current_size < START_THRESHOLD_BYTES )); then
    log_info "Directory size below threshold. No deletion needed."
    return 0
  fi

  log_info "Starting cleanup..."

  # Build sorted file list once (oldest first)
  find "$WATCH_DIR" -type f -printf '%T@ %s %p\0' 2>/dev/null \
    | sort -z -n \
    | while IFS= read -r -d '' entry; do

        # Extract size + path
        file_size=$(echo "$entry" | awk '{print $2}')
        file_path=$(echo "$entry" | cut -d' ' -f3-)

        # Stop if we reached target
        if (( current_size <= STOP_THRESHOLD_BYTES )); then
          break
        fi

        rm -f -- "$file_path" || continue

        current_size=$((current_size - file_size))

        log_info "Deleted: $file_path"
    done

  log_info "Cleanup complete. Final size: $(human_readable "$current_size")"
}

delete_until_within_limit
echo "Done"