#!/usr/bin/env bash

PIDFILE=".socat-pids"

if [[ "$EUID" -ne 0 ]]; then
  echo "Permission denied, try running as root (sudo):"
  echo "    sudo $0"
  exit 1
fi

echo "--- Starting socat proxies ---"
echo -n > "$PIDFILE"

for port in {8081..8088}; do
    VM_PORT=$((10000 + port)) 
    echo "  - $port -> 127.0.0.1:$VM_PORT"

    socat TCP-LISTEN:${port},fork,bind=0.0.0.0 TCP:127.0.0.1:${VM_PORT} &
    nixos-firewall-tool open tcp ${port}
    echo $! >> "$PIDFILE"
done

echo "--- Done. All proxies running & firewall open ---"
echo "--- PIDs stored in $PIDFILE ---"
