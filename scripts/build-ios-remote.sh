#!/usr/bin/env bash
# SSH into the MacinCloud machine and run the iOS build.
# Source your .env before running: source scripts/.env && ./scripts/build-ios-remote.sh

set -euo pipefail

: "${MAC_IP:?Set MAC_IP}"
: "${MAC_USER:?Set MAC_USER}"
: "${MAC_PASSWORD:?Set MAC_PASSWORD}"
: "${MAC_SSH_PORT:=22}"

sshpass -p "$MAC_PASSWORD" ssh \
  -o StrictHostKeyChecking=no \
  -o PubkeyAuthentication=no \
  -p "$MAC_SSH_PORT" \
  "$MAC_USER@$MAC_IP" zsh -l << 'REMOTE'
  set -euo pipefail

  cd ~/fuzzy-bassoon 2>/dev/null || {
    git clone https://github.com/djuskus/fuzzy-bassoon.git ~/fuzzy-bassoon
    cd ~/fuzzy-bassoon
  }

  git pull origin master

  export PATH="/Users/user944308/flutter/bin:/usr/local/bin:$PATH"
  command -v flutter || { echo "ERROR: flutter not found"; exit 1; }

  flutter pub get
  flutter precache --ios
  flutter build ios --release --no-codesign --verbose
  echo "Flutter build complete"
REMOTE
