#!/usr/bin/env bash
set -euo pipefail

# Match the SDK used to verify this project. Change deliberately when upgrading.
readonly FLUTTER_VERSION='3.41.4'
readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly SDK_TEMP="$(mktemp -d "${TMPDIR:-/tmp}/merimemory-flutter.XXXXXX")"
trap 'rm -rf -- "$SDK_TEMP"' EXIT

cd "$PROJECT_ROOT"
git clone --depth 1 --branch "$FLUTTER_VERSION" \
  https://github.com/flutter/flutter.git "$SDK_TEMP/flutter"
readonly FLUTTER_BIN="$SDK_TEMP/flutter/bin/flutter"
export CI=true
export FLUTTER_SUPPRESS_ANALYTICS=true
export DART_SUPPRESS_ANALYTICS=true

"$FLUTTER_BIN" --version
"$FLUTTER_BIN" pub get --enforce-lockfile
# Bundle CanvasKit locally and keep the existing custom PWA service worker.
"$FLUTTER_BIN" build web --release --base-href / \
  --no-web-resources-cdn --pwa-strategy=none

test -s build/web/index.html
test -s build/web/main.dart.js
test -s build/web/sw.js
