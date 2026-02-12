#!/usr/bin/env bash

BASE_DIR="/tmp/log"
READY_DIR="$BASE_DIR/ready"
SERVICE="debug"
FILE_COUNT=250
HOSTNAME="$(hostnamectl hostname)"

mkdir -p "$BASE_DIR" "$READY_DIR"

generate_block() {
  local lines=$1
  local ts host="$HOSTNAME"
  ts=$(date '+%b %d %H:%M:%S')

  awk -v ts="$ts" -v host="$host" -v svc="$SERVICE" -v lines="$lines" '
  BEGIN {
    levels[0]="INFO"; levels[1]="WARN"; levels[2]="ERROR"; levels[3]="DEBUG";
    events[0]="PLC connection established";
    events[1]="PLC read request completed";
    events[2]="PLC write request completed";
    events[3]="S7 packet timeout";
    events[4]="Reconnecting to PLC";
    events[5]="Invalid S7 frame received";
    events[6]="Heartbeat OK";
    events[7]="Connection lost, retrying";
    events[8]="Protocol negotiation complete";
    events[9]="Job queue processed";
    events[10]="Memory buffer flushed";
    events[11]="Worker thread restarted";
    events[12]="Authentication failed";
    events[13]="Authentication succeeded";
    events[14]="Packet retransmission";

    srand();

    for (i=0; i<lines; i++) {
      printf "%s %s %s[%d]: %s src=%d.%d.%d.%d dst=%d.%d.%d.%d msg=\"%s\" latency=%dms\n",
        ts, host, svc, rand()*10000,
        levels[int(rand()*4)],
        rand()*256, rand()*256, rand()*256, rand()*256,
        rand()*256, rand()*256, rand()*256, rand()*256,
        events[int(rand()*15)],
        rand()*200;
    }
  }'
}

echo "Generating $FILE_COUNT files..."

for ((i=1; i<=FILE_COUNT; i++)); do
  ts=$(date '+%Y-%m-%d-%H%M%S')
  final_file="$READY_DIR/${SERVICE}-${ts}-${RANDOM}.log"
  tmp_file="$BASE_DIR/.${SERVICE}-${ts}-${RANDOM}.tmp"

  if (( RANDOM % 100 < 98 )); then
    target_bytes=$(( (RANDOM % 800 + 100) * 1024 ))  # 100KB–900KB
    size_label="$((target_bytes/1024))KB"
  else
    target_mb=$((RANDOM % 41 + 10))
    target_bytes=$((target_mb * 1024 * 1024))
    size_label="${target_mb}MB"
  fi

  # durchschnittliche Zeile ≈ 140 Bytes
  lines_needed=$(( target_bytes / 140 ))

  echo "[$i/$FILE_COUNT] $size_label (~$lines_needed lines)"

  generate_block "$lines_needed" > "$tmp_file"

  mv "$tmp_file" "$final_file"
done

echo "Done."
