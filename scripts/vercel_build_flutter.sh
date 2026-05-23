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

git config --global --add safe.directory "${FLUTTER_HOME}" || true
git config --global --add safe.directory "$(pwd)" || true
flutter --disable-analytics
flutter --version
flutter config --enable-web
flutter pub get

DART_DEFINES=()

add_dart_define() {
  local name="$1"
  local value="$2"
  DART_DEFINES+=("--dart-define=${name}=${value}")
}

add_dart_define_from_env() {
  local name="$1"
  add_dart_define "${name}" "${!name:-}"
}

for name in \
  FIREBASE_PROJECT_ID \
  FIREBASE_DEV_API_KEY \
  FIREBASE_DEV_APP_ID \
  FIREBASE_DEV_MESSAGING_SENDER_ID \
  FIREBASE_DEV_AUTH_DOMAIN \
  FIREBASE_DEV_STORAGE_BUCKET \
  FIREBASE_WEB_CLIENT_ID \
  SUPABASE_URL \
  SUPABASE_PUBLISHABLE_KEY \
  SUPABASE_ANON_KEY \
  SUITE_IDENTITY_BRIDGE_URL \
  SENTRY_DSN; do
  add_dart_define_from_env "${name}"
done

add_dart_define \
  SENTRY_ENVIRONMENT \
  "${SENTRY_ENVIRONMENT:-${VERCEL_ENV:-}}"
add_dart_define \
  WINFLOWZ_APP_BUILD_SHA \
  "${WINFLOWZ_APP_BUILD_SHA:-${VERCEL_GIT_COMMIT_SHA:-local}}"
add_dart_define \
  WINFLOWZ_APP_BUILD_RUN_ID \
  "${WINFLOWZ_APP_BUILD_RUN_ID:-${VERCEL_DEPLOYMENT_ID:-${VERCEL_GIT_COMMIT_SHA:-local}}}"
add_dart_define \
  WINFLOWZ_APP_BUILD_REF \
  "${WINFLOWZ_APP_BUILD_REF:-${VERCEL_GIT_COMMIT_REF:-local}}"

flutter build web --release --no-wasm-dry-run "${DART_DEFINES[@]}"
