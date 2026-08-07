#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
DIST_DIR="$SCRIPT_DIR/dist-coroutine-validation"
BIN="$SCRIPT_DIR/out/coroutine-validation"

if [ ! -x "$BIN" ]; then
  echo "Missing validation binary: $BIN" >&2
  echo "Run ./build-coroutine-validation.sh first." >&2
  exit 1
fi

mkdir -p "$DIST_DIR"
cp "$BIN" "$DIST_DIR/coroutine-validation"
cp "$SCRIPT_DIR/validation/run.sh" "$DIST_DIR/run.sh"
chmod +x "$DIST_DIR/coroutine-validation" "$DIST_DIR/run.sh"

echo "Packaged $DIST_DIR"
echo "Copy its contents to /mnt/onboard/.adds/coroutine-validation on the Kobo."
