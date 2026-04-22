# Developer Getting Started

This doc covers everything you need to work on, build, and ship Marginalia (Blessed Readings) as a new developer on the project.

---

## What the app is

Marginalia is a literary repository app. Users browse a curated collection of essays and excerpts, filter by subject or author, and submit requests for texts they want added. The community upvotes requests to signal demand.

Bundle ID: `com.ultaire.blessedreadings`

---

## Repos

| Repo | Purpose |
|---|---|
| `djuskus/fuzzy-bassoon` | The Flutter app (this repo) |
| `djuskus/refactored-telegram-secretive` | Encrypted iOS certificates storage (managed by Fastlane match — do not touch manually) |

---

## Tech stack

| Layer | Technology |
|---|---|
| Mobile | Flutter (Dart) |
| Fonts | Google Fonts — Playfair Display (serif), Inter (sans) |
| Backend | FastAPI + SQLite (planned) |
| Content storage | Cloudflare R2 (planned) |
| Deployment | Railway (planned) |
| iOS CI/CD | GitHub Actions → Fastlane → TestFlight |

---

## Local development

### Prerequisites

- Flutter SDK (stable channel)
- An editor (VS Code or Android Studio)

### Run locally

```bash
flutter pub get
flutter run
```

To run on a specific platform:

```bash
flutter run -d chrome     # web
flutter run -d macos      # macOS desktop
flutter run -d <device>   # connected iOS/Android device
```

To analyze and test:

```bash
flutter analyze
flutter test
```

---

## Project structure

```
lib/
  main.dart          # Entire app — single file for now
fastlane/
  Fastfile           # CI lanes: certs and beta
  Matchfile          # Points match at the secretive repo
  Appfile            # Bundle ID and team ID
docs/                # You are here — not bundled into the app
.github/
  workflows/
    ios.yml          # GitHub Actions CI/CD pipeline
```

---

## iOS deployment pipeline

The app ships to TestFlight via GitHub Actions with no Mac hardware required. Here is how it works end to end.

### How code signing works

Fastlane `match` manages certificates and provisioning profiles. They are generated via the App Store Connect API, encrypted with `MATCH_PASSWORD`, and stored in `refactored-telegram-secretive`. The CI runner clones that repo, decrypts the certs, and uses them to sign the build.

### The two Fastlane lanes

**`certs`** — one-time setup. Creates the distribution certificate and provisioning profile via the App Store Connect API and stores them encrypted in the secretive repo. Re-run only if certs expire (once a year).

**`beta`** — the build lane. Pulls certs from secretive, builds the Flutter app, signs the IPA, uploads to TestFlight. Runs automatically on every push to `master`.

### Triggering a build

- **Automatic** — push any commit to `master`
- **Manual** — Actions → iOS Build & Deploy → Run workflow → choose `beta` or `certs`

### First time setup for a new project

If starting from scratch, run the `certs` lane once before pushing any code. This initialises the secretive repo with encrypted certs. After that, every push to `master` handles everything.

---

## GitHub secrets

All secrets live in `fuzzy-bassoon` under Settings → Secrets and variables → Actions → Repository secrets.

| Secret | How to get it |
|---|---|
| `MATCH_PASSWORD` | Any strong password you choose — used to encrypt/decrypt certs in the secretive repo |
| `MATCH_GIT_BASIC_AUTHORIZATION` | `echo -n "djuskus:YOUR_GITHUB_PAT" \| base64 \| tr -d '\n'` — PAT needs Contents read/write on the secretive repo |
| `APP_STORE_CONNECT_KEY_ID` | App Store Connect → Users and Access → Integrations → Keys — the 10-char ID |
| `APP_STORE_CONNECT_ISSUER_ID` | Same page — the UUID shown above the keys table |
| `APP_STORE_CONNECT_KEY_BASE64` | `base64 -i AuthKey_XXXXXXXXXX.p8` — download the .p8 once when creating the key |

App Store Connect API key role: **Admin** (required to create distribution certificates).

---

## Testing on device

1. Install TestFlight on your iPhone
2. In App Store Connect → your app → TestFlight → add yourself as an internal tester
3. Accept the email invite on your iPhone
4. The build appears in TestFlight

---

## Planned backend

The backend does not exist yet. When built it will be:

- **FastAPI** (Python) running on **Railway**
- **SQLite** for structured data (texts, authors, requests, votes)
- **Cloudflare R2** for content file storage (zero egress fees)

The Flutter app currently uses hardcoded sample data. When the backend is ready, that data layer gets swapped out for API calls.
