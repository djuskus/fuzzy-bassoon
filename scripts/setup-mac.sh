#!/usr/bin/env bash
# First-time setup of the MacinCloud machine.
# Run once on a fresh Mac before deploying.
# Source your .env before running: source scripts/.env && ./scripts/setup-mac.sh

set -euo pipefail

: "${MAC_IP:?Set MAC_IP}"
: "${MAC_USER:?Set MAC_USER}"
: "${MAC_PASSWORD:?Set MAC_PASSWORD}"
: "${MAC_SSH_PORT:=22}"

echo "==> Setting up MacinCloud Mac..."

sshpass -p "$MAC_PASSWORD" ssh \
  -o StrictHostKeyChecking=no \
  -o PubkeyAuthentication=no \
  -p "$MAC_SSH_PORT" \
  "$MAC_USER@$MAC_IP" zsh -l << 'REMOTE'
  set -euo pipefail
  export PATH="/Users/$USER/flutter/bin:/usr/local/bin:$PATH"

  echo "--- Checking Homebrew ---"
  if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "Homebrew already installed: $(brew --version)"
  fi

  echo "--- Checking Ruby ---"
  echo "Ruby: $(ruby --version)"

  echo "--- Checking Flutter ---"
  if ! command -v flutter &>/dev/null; then
    echo "ERROR: Flutter not found. Install it first via:"
    echo "  cd ~ && curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.32.0-stable.zip"
    echo "  unzip flutter_macos_arm64_3.32.0-stable.zip"
    echo "  echo 'export PATH=\"\$PATH:\$HOME/flutter/bin\"' >> ~/.zshrc"
    exit 1
  fi
  echo "Flutter: $(flutter --version | head -1)"

  echo "--- Installing gems (user install, no sudo) ---"
  export GEM_HOME="$HOME/.gem"
  export PATH="$HOME/.gem/bin:$PATH"
  gem install --user-install bundler cocoapods

  echo "--- Cloning / updating repo ---"
  if [ ! -d ~/fuzzy-bassoon ]; then
    git clone https://github.com/djuskus/fuzzy-bassoon.git ~/fuzzy-bassoon
  fi
  cd ~/fuzzy-bassoon
  git pull origin master

  echo "--- Installing bundle gems ---"
  bundle config set --local path "$HOME/.gem"
  bundle install

  echo ""
  echo "==> Setup complete. Run deploy-ios.sh to build and ship."
REMOTE
