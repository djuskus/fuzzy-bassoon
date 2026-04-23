#!/usr/bin/env bash
# Open an RDP session to the MacinCloud machine.
# Source your .env before running: source scripts/.env && ./scripts/connect-mac.sh

set -euo pipefail

: "${MAC_HOST:?Set MAC_HOST}"
: "${MAC_RDP_PORT:?Set MAC_RDP_PORT}"
: "${MAC_USER:?Set MAC_USER}"
: "${MAC_PASSWORD:?Set MAC_PASSWORD}"

rdesktop \
  -u "$MAC_USER" \
  -p "$MAC_PASSWORD" \
  -g 1280x800 \
  -x l \
  "$MAC_HOST:$MAC_RDP_PORT"
