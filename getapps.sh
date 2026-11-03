#!/bin/sh
set -eu

RAW_BASE="https://raw.githubusercontent.com/chubbyhippo/emacs-android/refs/heads/main"

run_script() {
  name="$1"
  script_dir=""
  if [ -n "${0:-}" ] && [ -f "$(dirname "$0")/$name" ]; then
    script_dir="$(cd "$(dirname "$0")" && pwd)"
  fi

  if [ -n "$script_dir" ] && [ -f "$script_dir/$name" ]; then
    echo "=== Running $name (local) ==="
    sh "$script_dir/$name"
    return 0
  fi

  echo "=== Fetching and running $name ==="
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$RAW_BASE/$name" | sh
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$RAW_BASE/$name" | sh
  else
    echo "Error: need curl or wget installed to fetch $name" >&2
    exit 1
  fi
}

run_script signedtermux.sh
echo
run_script signedemacs.sh

echo
echo "Done. Signed APKs are ready: com.termux_1022.apk, emacs_for_termux.apk"
