#!/bin/sh
set -eu

APPDIR="/mnt/onboard/.adds/coroutine-validation"
LOGDIR="$APPDIR/logs"

mkdir -p "$LOGDIR"

cd "$APPDIR"
{
  echo "==== start $(date) ===="
  ./coroutine-validation
  echo "==== exit $? $(date) ===="
} >> "$LOGDIR/coroutine-validation.log" 2>&1
