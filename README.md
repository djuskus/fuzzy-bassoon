# Marginalia

A curated literary repository for iOS. Users browse essays and excerpts, filter by subject and author, and submit requests for texts they want added.

Built as an exercise in shipping an iOS app as fast as possible — notably without owning any Apple hardware. The CI/CD pipeline runs entirely on GitHub Actions macOS runners, using Fastlane match to generate and manage code signing certificates via the App Store Connect API. Every push to `master` builds and ships to TestFlight with no local Mac involved.

## Stack

Flutter · FastAPI · SQLite · Cloudflare R2 · Railway · Fastlane · TestFlight

## Getting started

See [docs/getting-started.md](docs/getting-started.md).
