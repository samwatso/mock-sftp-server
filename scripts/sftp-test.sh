#!/usr/bin/env bash
# Deposits a test file via SFTP and confirms it landed.
# Usage: SFTP_USER=labuser SFTP_PASSWORD=secret bash sftp-test.sh
set -euo pipefail

HOST="${SFTP_HOST:-localhost}"
PORT="${SFTP_PORT:-2222}"
USER="${SFTP_USER:-labuser}"
PASS="${SFTP_PASSWORD:-}"
REMOTE_DIR="upload"
TEST_FILE="lab-test-$(date +%s).xml"
PAYLOAD="<LabTest><ts>$(date -u +"%Y-%m-%dT%H:%M:%SZ")</ts><file>${TEST_FILE}</file></LabTest>"

if [ -z "$PASS" ]; then
  echo "ERROR: SFTP_PASSWORD is not set. Export it before running this script."
  exit 1
fi

command -v sshpass >/dev/null 2>&1 || {
  echo "ERROR: sshpass is required. Install with: brew install sshpass"
  exit 1
}

echo "=== mock-sftp-server test ==="
echo "Host:   $HOST:$PORT"
echo "User:   $USER"
echo "Remote: /$REMOTE_DIR/$TEST_FILE"
echo ""

# Write test payload to local temp file
TMP_FILE="$(mktemp /tmp/lab-sftp-XXXXXX.xml)"
echo "$PAYLOAD" > "$TMP_FILE"

# Upload via sshpass + sftp
sshpass -p "$PASS" sftp -o StrictHostKeyChecking=no -P "$PORT" "$USER@$HOST" <<EOF
put $TMP_FILE /$REMOTE_DIR/$TEST_FILE
ls /$REMOTE_DIR/$TEST_FILE
bye
EOF

rm -f "$TMP_FILE"

echo ""
echo "SFTP test PASSED — $TEST_FILE uploaded to /$REMOTE_DIR/"
echo "Verify in data/upload/ on the host."
