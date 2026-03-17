#!/usr/bin/env bash

CONFIG_FILE="/var/system/config.json"

function read_config() {
  local json_path="$1"  # z.B. "flexSystem.logging"
  local key="$2"        # z.B. "task_logs_xxxx"
  local config_file="${3:-$CONFIG_FILE}"

  if [[ ! -f "$config_file" ]]; then
    echo "Error: Config file not found: $config_file" >&2
    return 1
  fi

  local value
  value=$(jq -r ".${json_path}.${key}" "$config_file")

  if [[ -z "$value" || "$value" == "null" ]]; then
    echo "Error: '${json_path}.${key}' not found in config" >&2
    return 1
  fi

  echo "$value"
}