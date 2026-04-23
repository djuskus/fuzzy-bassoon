#!/usr/bin/env bash
# SSH into the MacinCloud machine and run the iOS build.
# Source your .env before running: source scripts/.env && ./scripts/build-ios-remote.sh

set -euo pipefail

: "${MAC_IP:?Set MAC_IP}"
: "${MAC_USER:?Set MAC_USER}"
: "${MAC_PASSWORD:?Set MAC_PASSWORD}"
: "${MAC_SSH_PORT:=22}"

ssh -p "$MAC_SSH_PORT" "$MAC_USER@$MAC_IP" bash << 'REMOTE'
  set -euo pipefail

  cd ~/fuzzy-bassoon 2>/dev/null || {
    git clone https://github.com/djuskus/fuzzy-bassoon.git ~/fuzzy-bassoon
    cd ~/fuzzy-bassoon
  }

  git pull origin master

  export PATH="$PATH:/usr/local/bin:$HOME/flutter/bin"

  flutter pub get
  flutter precache --ios
  flutter build ios --release --no-codesign
  echo "Flutter build complete"
REMOTE
