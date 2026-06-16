#!/usr/bin/env bash
# Emits a known_hosts entry for the SFTP server under its Cloud Connector
# virtual host name, ready to upload to Integration Suite as Security Material
# (type "Known Hosts (SSH)"). CPI refuses to connect unless the host key is
# trusted under the exact name it dials — i.e. the virtual host, not localhost.
#
# Usage:  bash scripts/known-hosts.sh [virtual-host]   (default: sftp-lab)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
VHOST="${1:-sftp-lab}"
OUT="$ROOT_DIR/known_hosts.lab"

ED="$ROOT_DIR/ssh/ssh_host_ed25519_key.pub"
RSA="$ROOT_DIR/ssh/ssh_host_rsa_key.pub"

if [ ! -f "$ED" ] && [ ! -f "$RSA" ]; then
  echo "Host keys not found. Run 'bash scripts/setup.sh' first." >&2
  exit 1
fi

# known_hosts line format:  <host> <keytype> <base64-key>
: > "$OUT"
[ -f "$ED"  ] && awk -v h="$VHOST" '{print h, $1, $2}' "$ED"  >> "$OUT"
[ -f "$RSA" ] && awk -v h="$VHOST" '{print h, $1, $2}' "$RSA" >> "$OUT"

echo "Wrote $OUT (virtual host: $VHOST):"
echo "----------------------------------------"
cat "$OUT"
echo "----------------------------------------"
echo "Upload this file in Integration Suite →"
echo "  Monitor → Security Material → Create → Known Hosts (SSH)"
echo "and reference it in the SFTP adapter."
