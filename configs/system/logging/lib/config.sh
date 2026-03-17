#!/usr/bin/env bash

CONFIG_FILE="/var/system/config.json"

function load_config() {
  local json_path="${1:-.}" # Arg 1 => JSON path, default to root
  local config_file="${2:-$CONFIG_FILE}" # Arg 2 => config file, default to CONFIG_FILE

  echo "Loading config from: $config_file (path: $json_path)"

  if [[ ! -f "$config_file" ]]; then
    echo "Error: Config file not found: $config_file" >&2
    return 1
  fi

  local section_json
  section_json=$(jq ".${json_path}" "$config_file")

  if [[ -z "$section_json" || "$section_json" == "null" ]]; then
    echo "Error: '${json_path}' not found in config" >&2
    return 1
  fi

  # Prefix aus dem Pfad ableiten: "flexSystem.logging" -> "FLEX_SYSTEM_LOGGING"
  local prefix
  prefix=$(echo "$json_path" | tr '[:lower:]' '[:upper:]' | tr '.' '_')
  echo "Using prefix: $prefix for environment variables"

  while IFS="=" read -r key value; do
    local var_name="${prefix}_${key//-/_}"
    export "${var_name}=${value}"
  done < <(jq -r ".${json_path} | to_entries[] | \"\(.key)=\(.value)\"" "$config_file")
}