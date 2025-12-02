#!/usr/bin/env bash

PIDFILE=".socat-pids"

if [[ "$EUID" -ne 0 ]]; then
  echo "Permission denied, try running as root (sudo):"
  echo "    sudo $0"
  exit 1
fi

if [[ ! -f "$PIDFILE" ]]; then
    echo "!! No PID file ($PIDFILE) found. Are proxies running? !!"
    exit 1
fi

echo "--- Stopping socat proxies ---"

while read -r PID; do
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "  - Killing PID $PID"
        kill "$PID"
    else
        echo "  - PID $PID not running"
    fi
done < "$PIDFILE"

rm -f "$PIDFILE"
nixos-firewall-tool reset
echo "--- All proxies stopped & firewall reset ---"
