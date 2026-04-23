#!/usr/bin/env bash
# Interactive SSH session to the MacinCloud machine.
# Source your .env before running: source scripts/.env && ./scripts/ssh-mac.sh

set -euo pipefail

: "${MAC_IP:?Set MAC_IP}"
: "${MAC_USER:?Set MAC_USER}"
: "${MAC_PASSWORD:?Set MAC_PASSWORD}"
: "${MAC_SSH_PORT:=22}"

sshpass -p "$MAC_PASSWORD" ssh \
  -o StrictHostKeyChecking=no \
  -o PubkeyAuthentication=no \
  -t \
  -p "$MAC_SSH_PORT" \
  "$MAC_USER@$MAC_IP" \
  "export PATH=\"/Users/$MAC_USER/flutter/bin:/usr/local/bin:\$PATH\"; exec zsh -l"
