#!/usr/bin/env bash
# First-time setup: creates users.conf from the example and makes data directories.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== mock-sftp-server setup ==="

if [ ! -f "$ROOT_DIR/users.conf" ]; then
  cp "$ROOT_DIR/users.conf.example" "$ROOT_DIR/users.conf"
  echo "Created users.conf from example."
  echo "  → Edit $ROOT_DIR/users.conf and replace CHANGEME with a real password."
else
  echo "users.conf already exists — skipping."
fi

mkdir -p "$ROOT_DIR/data/upload" \
         "$ROOT_DIR/data/inbox" \
         "$ROOT_DIR/data/outbox" \
         "$ROOT_DIR/data/archive"
echo "Created data directories."

# Persistent SSH host keys so the server presents a stable identity across
# container recreates (otherwise CPI's known_hosts entry breaks). Gitignored.
mkdir -p "$ROOT_DIR/ssh"
if [ ! -f "$ROOT_DIR/ssh/ssh_host_ed25519_key" ]; then
  ssh-keygen -t ed25519 -f "$ROOT_DIR/ssh/ssh_host_ed25519_key" -N "" -C "mock-sftp-lab" >/dev/null </dev/null
  echo "Generated ed25519 host key."
fi
if [ ! -f "$ROOT_DIR/ssh/ssh_host_rsa_key" ]; then
  ssh-keygen -t rsa -b 4096 -f "$ROOT_DIR/ssh/ssh_host_rsa_key" -N "" -C "mock-sftp-lab" >/dev/null </dev/null
  echo "Generated RSA host key."
fi

if [ ! -f "$ROOT_DIR/.env" ]; then
  cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
  echo "Created .env from example."
fi

echo ""
echo "Next steps:"
echo "  1. Edit users.conf — set a password for labuser"
echo "  2. npm run lab:sftp           — start the container"
echo "  3. npm run lab:sftp:test      — verify SFTP connectivity"
echo "  4. bash scripts/known-hosts.sh — emit the known_hosts entry for CPI"
echo "  5. See CLOUD-CONNECTOR.md     — expose via SAP Cloud Connector"
