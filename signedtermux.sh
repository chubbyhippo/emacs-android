#!/bin/sh
set -eu

KEYSTORE_URL="https://github.com/emacs-mirror/emacs/raw/refs/heads/master/java/emacs.keystore"
TERMUX_URL="https://f-droid.org/repo/com.termux_1022.apk"
KEYSTORE_FILE="emacs.keystore"
APK_FILE="com.termux_1022.apk"
KS_PASS="pass:emacs1"

download() {
  url="$1"
  out="$2"
  if [ -f "$out" ]; then
    echo "Found existing $out, skipping download."
    return 0
  fi
  echo "Downloading $out ..."
  if command -v curl >/dev/null 2>&1; then
    curl -fL -o "$out" "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$out" "$url"
  else
    echo "Error: need curl or wget installed to download $out" >&2
    exit 1
  fi
}

winpath() {
  # Convert a Windows-style path to a POSIX one when running under
  # Git Bash/MSYS2/Cygwin, where cygpath is available.
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -u "$1" 2>/dev/null || echo "$1"
  else
    echo "$1"
  fi
}

find_apksigner() {
  for name in apksigner apksigner.bat; do
    if command -v "$name" >/dev/null 2>&1; then
      command -v "$name"
      return 0
    fi
  done

  roots="${ANDROID_HOME:-} ${ANDROID_SDK_ROOT:-}"
  roots="$roots $HOME/Library/Android/sdk"
  roots="$roots $HOME/Android/Sdk"
  roots="$roots /opt/android-sdk"
  roots="$roots /usr/lib/android-sdk"
  if [ -n "${LOCALAPPDATA:-}" ]; then
    roots="$roots $(winpath "$LOCALAPPDATA")/Android/Sdk"
  fi

  for root in $roots; do
    [ -n "$root" ] || continue
    [ -d "$root/build-tools" ] || continue
    for f in "$root"/build-tools/*/apksigner "$root"/build-tools/*/apksigner.bat; do
      if [ -f "$f" ]; then
        echo "$f"
        return 0
      fi
    done
  done

  return 1
}

download "$KEYSTORE_URL" "$KEYSTORE_FILE"
download "$TERMUX_URL" "$APK_FILE"

if ! APKSIGNER="$(find_apksigner)"; then
  echo "Error: apksigner not found." >&2
  echo "Install the Android SDK build-tools (e.g. via Android Studio or sdkmanager)" >&2
  echo "and make sure 'apksigner' is on PATH, or set ANDROID_HOME / ANDROID_SDK_ROOT." >&2
  exit 1
fi

echo "Using apksigner: $APKSIGNER"
"$APKSIGNER" sign --v2-signing-enabled --ks "$KEYSTORE_FILE" -debuggable-apk-permitted --ks-pass "$KS_PASS" "$APK_FILE"

echo "Signed $APK_FILE successfully."
