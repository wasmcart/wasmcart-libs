#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "$root/toolchain.lock"
sdk="${WASI_SDK_PATH:-$("$root/scripts/bootstrap-wasi-sdk.sh")}"

if [[ "$#" -gt 0 ]]; then
  packages=("$@")
else
  mapfile -t packages < <(find "$root/packages" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | LC_ALL=C sort)
fi

for package in "${packages[@]}"; do
  dir="$root/packages/$package"
  out="$root/.build/$package/smoke.wasm"
  "$sdk/bin/clang" \
    "--target=$TARGET" \
    "--sysroot=$sdk/share/wasi-sysroot" \
    -O2 -pthread -msimd128 \
    -I"$dir/vendor/include" \
    "$dir/examples/smoke.c" \
    "$dir/lib/lib$package.a" \
    -Wl,--no-entry \
    -Wl,--export=smoke \
    -Wl,--import-memory \
    -Wl,--shared-memory \
    -Wl,--max-memory=67108864 \
    -Wl,--gc-sections \
    -o "$out"
  test -s "$out"
  echo "$package $(wc -c < "$out") bytes"
done

