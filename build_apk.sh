#!/usr/bin/env bash
# Builds ONLY the full (universal) release APK — no debug, no profile, no
# per-ABI splits, no AAB — and copies it out as SuikaMovie-<version>.apk.
set -euo pipefail
cd "$(dirname "$0")"

VERSION="$(grep -m1 '^version:' pubspec.yaml | sed -E 's/^version:[[:space:]]*//; s/\+.*$//' | tr -d '\r')"
OUT="build/app/outputs/flutter-apk/app-release.apk"

flutter pub get
flutter build apk --release

mkdir -p dist
cp "$OUT" "dist/SuikaMovie-${VERSION}.apk"
echo
echo "Done: dist/SuikaMovie-${VERSION}.apk"
