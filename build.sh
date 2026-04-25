#!/usr/bin/env bash
# Build a release APK for 山海 (Shānhǎi) without polluting the host system.
# Everything lives under ./.tools/. Re-running is idempotent and fast.
#
# Requirements: Linux or macOS, ~3 GB free disk, ~10 min on first run, Java 17+.
#   Linux:  sudo apt-get install -y openjdk-17-jdk curl unzip xz-utils
#   macOS:  brew install openjdk@17 && export PATH="$(brew --prefix openjdk@17)/bin:$PATH"
#   WSL:    same as Linux.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS="$ROOT/.tools"
mkdir -p "$TOOLS"

FLUTTER_VERSION="3.41.7"
ANDROID_CMDLINE_TOOLS="11076708"     # cmdline-tools 11.0
ANDROID_PLATFORM="android-34"
ANDROID_BUILDTOOLS="34.0.0"

case "$(uname -s)" in
  Linux)  HOST_OS=linux;  FLUTTER_ARCHIVE_EXT=tar.xz; ANDROID_OS=linux ;;
  Darwin) HOST_OS=macos;  FLUTTER_ARCHIVE_EXT=zip;    ANDROID_OS=mac ;;
  *) echo "Unsupported OS: $(uname -s)"; exit 1 ;;
esac

# ----------------------------------------------------------------------------
# 1. Java
# ----------------------------------------------------------------------------
if ! command -v java >/dev/null; then
  echo "Java not found. Install JDK 17+ and re-run. See header of this script."
  exit 1
fi
JAVA_MAJOR=$(java -version 2>&1 | sed -nE 's/.*version "([0-9]+).*/\1/p' | head -1)
if [ "${JAVA_MAJOR:-0}" -lt 17 ]; then
  echo "Java 17+ required (found $JAVA_MAJOR)."
  exit 1
fi

# ----------------------------------------------------------------------------
# 2. Flutter
# ----------------------------------------------------------------------------
FLUTTER_HOME="$TOOLS/flutter"
if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  echo "==> Downloading Flutter $FLUTTER_VERSION ($HOST_OS)..."
  url="https://storage.googleapis.com/flutter_infra_release/releases/stable/$HOST_OS/flutter_${HOST_OS}_${FLUTTER_VERSION}-stable.${FLUTTER_ARCHIVE_EXT}"
  cd "$TOOLS"
  curl -L -o "flutter.${FLUTTER_ARCHIVE_EXT}" "$url"
  if [ "$FLUTTER_ARCHIVE_EXT" = "tar.xz" ]; then
    tar -xJf "flutter.${FLUTTER_ARCHIVE_EXT}"
  else
    unzip -q "flutter.${FLUTTER_ARCHIVE_EXT}"
  fi
  rm "flutter.${FLUTTER_ARCHIVE_EXT}"
  cd "$ROOT"
fi
export PATH="$FLUTTER_HOME/bin:$PATH"
export PUB_CACHE="$TOOLS/.pub-cache"

# ----------------------------------------------------------------------------
# 3. Android SDK (just cmdline-tools + the bits Flutter needs)
# ----------------------------------------------------------------------------
export ANDROID_HOME="$TOOLS/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
mkdir -p "$ANDROID_HOME/cmdline-tools"
if [ ! -d "$ANDROID_HOME/cmdline-tools/latest" ]; then
  echo "==> Downloading Android command-line tools..."
  cd "$ANDROID_HOME/cmdline-tools"
  curl -L -o tools.zip \
    "https://dl.google.com/android/repository/commandlinetools-${ANDROID_OS}-${ANDROID_CMDLINE_TOOLS}_latest.zip"
  unzip -q tools.zip
  rm tools.zip
  mv cmdline-tools latest
  cd "$ROOT"
fi
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

if [ ! -d "$ANDROID_HOME/platforms/$ANDROID_PLATFORM" ] \
  || [ ! -d "$ANDROID_HOME/build-tools/$ANDROID_BUILDTOOLS" ]; then
  echo "==> Installing Android platform-tools, $ANDROID_PLATFORM, build-tools $ANDROID_BUILDTOOLS..."
  yes | sdkmanager --licenses >/dev/null
  sdkmanager \
    "platform-tools" \
    "platforms;$ANDROID_PLATFORM" \
    "build-tools;$ANDROID_BUILDTOOLS" >/dev/null
fi

# Point Flutter at the local SDK
flutter config --android-sdk "$ANDROID_HOME" --no-analytics >/dev/null

# ----------------------------------------------------------------------------
# 4. Build
# ----------------------------------------------------------------------------
echo "==> flutter pub get"
flutter pub get

echo "==> flutter build apk --release --split-per-abi"
flutter build apk --release --split-per-abi

echo
echo "==> Done. APKs:"
ls -lh build/app/outputs/flutter-apk/*.apk
echo
echo "Install on a connected phone with:"
echo "  $ANDROID_HOME/platform-tools/adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
