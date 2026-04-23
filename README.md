# Marginalia

A curated literary iOS app. This repo is primarily a deployment project — the goal is a fully repeatable iOS build and ship pipeline that requires no local Apple hardware.

## Deployment

There are two ways to build and ship:

### 1. MacinCloud (primary)

A remote Mac is provisioned on [MacinCloud](https://www.macincloud.com). All scripts live in `scripts/` and are driven from your local machine via SSH.

**First-time setup** (run once on a fresh Mac):
```bash
source scripts/.env && ./scripts/setup-mac.sh
```

**Deploy to TestFlight:**
```bash
source scripts/.env && ./scripts/deploy-ios.sh
```

**Interactive SSH session:**
```bash
source scripts/.env && ./scripts/ssh-mac.sh
```

**RDP (GUI) session:**
```bash
source scripts/.env && ./scripts/connect-mac.sh
```

### 2. GitHub Actions (alternative)

A workflow at `.github/workflows/ios.yml` runs on `macos-latest` and does the same thing — Flutter build + Fastlane match + TestFlight upload. Trigger it manually from the Actions tab or it fires on every push to `master`.

This path is slower due to cold runners and no persistent DerivedData cache.

## Environment

Copy `scripts/.env.example` to `scripts/.env` and fill in all values. This file is gitignored.

```
MAC_HOST          MacinCloud hostname
MAC_IP            MacinCloud IP address
MAC_USER          MacinCloud username
MAC_PASSWORD      MacinCloud password
MAC_RDP_PORT      RDP port (default 6000)
MAC_SSH_PORT      SSH port (default 22)

APP_STORE_CONNECT_KEY_ID      App Store Connect API key ID
APP_STORE_CONNECT_ISSUER_ID   App Store Connect issuer UUID
APP_STORE_CONNECT_KEY_BASE64  .p8 key file, base64 encoded
MATCH_PASSWORD                Passphrase for match cert encryption
MATCH_GIT_BASIC_AUTHORIZATION base64("username:github_pat")
```

**App Store Connect API keys** — [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → Users and Access → Integrations → App Store Connect API.

To base64 encode your `.p8` key:
```bash
base64 -w 0 ~/Downloads/AuthKey_XXXXXX.p8
```

To generate `MATCH_GIT_BASIC_AUTHORIZATION`:
```bash
echo -n "githubusername:github_pat_xxx" | base64
```

## Fastlane lanes

| Lane | What it does |
|------|-------------|
| `beta` | Sync certs (readonly), build, upload to TestFlight |
| `certs` | Create and store certs/profiles in match repo (run once) |

Cert storage repo: `github.com/djuskus/refactored-telegram-secretive` (private)

## App

Flutter · Bundle ID `com.ultaire.blessedreadings` · Team `VH5B36Z9UD`

Backend (not yet built): FastAPI · SQLite · Cloudflare R2 · Railway
