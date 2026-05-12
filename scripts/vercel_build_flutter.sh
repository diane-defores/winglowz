#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.41.7}"
FLUTTER_HOME="${FLUTTER_HOME:-/tmp/flutter-${FLUTTER_VERSION}}"
FLUTTER_ARCHIVE="/tmp/flutter-${FLUTTER_VERSION}.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

if ! command -v flutter >/dev/null 2>&1; then
  if [[ ! -x "${FLUTTER_HOME}/bin/flutter" ]]; then
    rm -rf "${FLUTTER_HOME}"
    mkdir -p "${FLUTTER_HOME}"
    curl --fail --location --show-error --silent "${FLUTTER_URL}" --output "${FLUTTER_ARCHIVE}"
    tar -xf "${FLUTTER_ARCHIVE}" -C "${FLUTTER_HOME}" --strip-components=1
  fi
  export PATH="${FLUTTER_HOME}/bin:${PATH}"
fi

flutter --disable-analytics
flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release --no-wasm-dry-run
