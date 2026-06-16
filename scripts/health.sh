#!/usr/bin/env bash
# Quick health check: is the SFTP container running and is port 2222 reachable?
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PORT="${SFTP_PORT:-2222}"

echo "=== mock-sftp-server health ==="

# Container status
if docker compose -f "$ROOT_DIR/docker-compose.yml" ps --quiet 2>/dev/null | grep -q .; then
  echo "Container:  RUNNING"
else
  echo "Container:  STOPPED  (run: npm run lab:sftp)"
  exit 1
fi

# Port reachable
if nc -z -w 2 localhost "$PORT" 2>/dev/null; then
  echo "Port $PORT:  OPEN"
else
  echo "Port $PORT:  NOT REACHABLE"
  exit 1
fi

echo "Status:     OK"
