#!/bin/sh
set -eu

KEYSTORE_URL="https://github.com/emacs-mirror/emacs/raw/refs/heads/master/java/emacs.keystore"
EMACS_URL="https://ftp.gnu.org/gnu/emacs/android/termux/emacs-31.1-35-arm64-v8a.apk"
KEYSTORE_FILE="emacs.keystore"
EMACS_APK_FILE="emacs.apk"
DECODED_DIR="emacs_for_termux"
OUTPUT_APK="emacs_for_termux.apk"
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
download "$EMACS_URL" "$EMACS_APK_FILE"

if ! command -v apktool >/dev/null 2>&1; then
  echo "Error: apktool not found. Install apktool and make sure it is on PATH." >&2
  exit 1
fi

if ! APKSIGNER="$(find_apksigner)"; then
  echo "Error: apksigner not found." >&2
  echo "Install the Android SDK build-tools (e.g. via Android Studio or sdkmanager)" >&2
  echo "and make sure 'apksigner' is on PATH, or set ANDROID_HOME / ANDROID_SDK_ROOT." >&2
  exit 1
fi

echo "Unpacking $EMACS_APK_FILE into $DECODED_DIR ..."
apktool d -f -o "$DECODED_DIR" "$EMACS_APK_FILE"

MANIFEST="$DECODED_DIR/AndroidManifest.xml"
if grep -q 'android:sharedUserId="com.termux"' "$MANIFEST"; then
  echo "AndroidManifest.xml already has sharedUserId, skipping."
elif grep -q 'android:requestLegacyExternalStorage="true"' "$MANIFEST"; then
  sed -i 's|android:requestLegacyExternalStorage="true"|android:requestLegacyExternalStorage="true" android:sharedUserId="com.termux" android:sharedUserLabel="@string/shared_user_name"|' "$MANIFEST"
else
  sed -i 's|<manifest |<manifest android:sharedUserId="com.termux" android:sharedUserLabel="@string/shared_user_name" |' "$MANIFEST"
fi

if ! grep -q 'android:name="android.permission.ACCESS_LOCAL_NETWORK"' "$MANIFEST"; then
  sed -i 's|<application |    <uses-permission android:name="android.permission.ACCESS_LOCAL_NETWORK"/>\n    <application |' "$MANIFEST"
fi

sed -i 's|android:debuggable="false"|android:debuggable="true"|' "$MANIFEST"

STRINGS="$DECODED_DIR/res/values/strings.xml"
if grep -q 'name="shared_user_name"' "$STRINGS"; then
  sed -i 's|<string name="shared_user_name">[^<]*</string>|<string name="shared_user_name">Emacs shared user</string>|' "$STRINGS"
else
  sed -i 's|</resources>|    <string name="shared_user_name">Emacs shared user</string>\n</resources>|' "$STRINGS"
fi

echo "Building $OUTPUT_APK ..."
apktool b "$DECODED_DIR" -o "$OUTPUT_APK"

ZIPALIGN="$(dirname "$APKSIGNER")/zipalign"
if [ ! -f "$ZIPALIGN" ] && [ ! -f "$ZIPALIGN.exe" ]; then
  ZIPALIGN="$(command -v zipalign || true)"
fi
if [ -z "$ZIPALIGN" ]; then
  echo "Error: zipalign not found. It ships with the Android SDK build-tools." >&2
  exit 1
fi

echo "Aligning $OUTPUT_APK (resources.arsc must be 4-byte aligned for R+) ..."
ALIGNED_APK="${OUTPUT_APK%.apk}-aligned.apk"
"$ZIPALIGN" -f -p 4 "$OUTPUT_APK" "$ALIGNED_APK"
mv "$ALIGNED_APK" "$OUTPUT_APK"

echo "Using apksigner: $APKSIGNER"
"$APKSIGNER" sign --v2-signing-enabled --ks "$KEYSTORE_FILE" -debuggable-apk-permitted --ks-pass "$KS_PASS" "$OUTPUT_APK"

echo "Signed $OUTPUT_APK successfully."
