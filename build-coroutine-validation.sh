#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
IMAGE="${IMAGE:-nickeltc-gcc10}"
OUT_DIR="$SCRIPT_DIR/out"

mkdir -p "$OUT_DIR"

docker build -t "$IMAGE" -f "$SCRIPT_DIR/Dockerfile.gcc10" "$SCRIPT_DIR"
docker run --rm \
  -v "$SCRIPT_DIR":/work \
  "$IMAGE" \
  sh -euxc '
    CXXFLAGS="-std=c++20 -fcoroutines -O2 -Wall -Wextra -march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=hard -mthumb"

    arm-linux-gnueabihf-g++-10 \
      --sysroot="$NICKEL_SYSROOT" \
      $CXXFLAGS \
      -static-libstdc++ -static-libgcc \
      /work/validation/coroutine.cpp \
      -o /work/out/coroutine-validation
    arm-linux-gnueabihf-readelf -l /work/out/coroutine-validation | grep "program interpreter"
    arm-linux-gnueabihf-readelf -d /work/out/coroutine-validation | grep NEEDED

    arm-linux-gnueabihf-g++-10 \
      --sysroot="$NICKEL_SYSROOT" \
      $CXXFLAGS \
      -static \
      /work/validation/coroutine.cpp \
      -o /work/out/coroutine-validation-static
    ! arm-linux-gnueabihf-readelf -l /work/out/coroutine-validation-static | grep "program interpreter"
  '

echo "Built $OUT_DIR/coroutine-validation"
echo "Built $OUT_DIR/coroutine-validation-static"
