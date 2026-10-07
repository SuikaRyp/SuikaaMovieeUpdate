#!/usr/bin/env bash
# Builds a full (universal) APK — release by default, debug with `./build_apk.sh debug`.
# No profile, no per-ABI splits, no AAB. Output: dist/SuikaMovie-<version>[-debug].apk
set -euo pipefail
cd "$(dirname "$0")"

MODE="${1:-release}"
case "$MODE" in
  release) SUFFIX="" ;;
  debug)   SUFFIX="-debug" ;;
  *) echo "Usage: $0 [release|debug]"; exit 1 ;;
esac

VERSION="$(grep -m1 '^version:' pubspec.yaml | sed -E 's/^version:[[:space:]]*//; s/\+.*$//' | tr -d '\r')"

flutter pub get
flutter build apk "--$MODE"

mkdir -p dist
cp "build/app/outputs/flutter-apk/app-$MODE.apk" "dist/SuikaMovie-${VERSION}${SUFFIX}.apk"
echo
echo "Done: dist/SuikaMovie-${VERSION}${SUFFIX}.apk"
