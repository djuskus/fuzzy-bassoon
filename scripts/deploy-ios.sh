#!/usr/bin/env bash
# Full iOS pipeline: pull latest code, build, sign, upload to TestFlight.
# Source your .env before running: source scripts/.env && ./scripts/deploy-ios.sh

set -euo pipefail

: "${MAC_IP:?Set MAC_IP}"
: "${MAC_USER:?Set MAC_USER}"
: "${MAC_PASSWORD:?Set MAC_PASSWORD}"
: "${MAC_SSH_PORT:=22}"
: "${APP_STORE_CONNECT_KEY_ID:?Set APP_STORE_CONNECT_KEY_ID}"
: "${APP_STORE_CONNECT_ISSUER_ID:?Set APP_STORE_CONNECT_ISSUER_ID}"
: "${APP_STORE_CONNECT_KEY_BASE64:?Set APP_STORE_CONNECT_KEY_BASE64}"
: "${MATCH_PASSWORD:?Set MATCH_PASSWORD}"
: "${MATCH_GIT_BASIC_AUTHORIZATION:?Set MATCH_GIT_BASIC_AUTHORIZATION}"

LANE="${1:-beta}"
echo "==> Deploying lane: $LANE"

# Pass secrets inline — heredoc is unquoted so local vars expand
sshpass -p "$MAC_PASSWORD" ssh \
  -o StrictHostKeyChecking=no \
  -o PubkeyAuthentication=no \
  -p "$MAC_SSH_PORT" \
  "$MAC_USER@$MAC_IP" zsh -l << REMOTE
  set -euo pipefail
  export PATH="/Users/$MAC_USER/flutter/bin:/usr/local/bin:\$HOME/.gem/bin:\$PATH"
  export GEM_HOME="\$HOME/.gem"

  export APP_STORE_CONNECT_KEY_ID="$APP_STORE_CONNECT_KEY_ID"
  export APP_STORE_CONNECT_ISSUER_ID="$APP_STORE_CONNECT_ISSUER_ID"
  export APP_STORE_CONNECT_KEY_BASE64="$APP_STORE_CONNECT_KEY_BASE64"
  export MATCH_PASSWORD="$MATCH_PASSWORD"
  export MATCH_GIT_BASIC_AUTHORIZATION="$MATCH_GIT_BASIC_AUTHORIZATION"

  echo "--- Pulling latest code ---"
  cd ~/fuzzy-bassoon
  git pull origin master

  echo "--- Flutter pub get ---"
  flutter pub get
  flutter precache --ios

  echo "--- Setting up keychain ---"
  security create-keychain -p "ci_temp" ~/Library/Keychains/ci.keychain 2>/dev/null || true
  security default-keychain -s ~/Library/Keychains/ci.keychain
  security unlock-keychain -p "ci_temp" ~/Library/Keychains/ci.keychain
  security set-keychain-settings -t 3600 ~/Library/Keychains/ci.keychain

  echo "--- Running Fastlane $LANE ---"
  bundle exec fastlane $LANE

  echo ""
  echo "==> Deploy complete."
REMOTE
