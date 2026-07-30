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
  smoke="$dir/examples/smoke.c"
  compiler="$sdk/bin/clang"
  if [[ -f "$dir/examples/smoke.cpp" ]]; then
    smoke="$dir/examples/smoke.cpp"
    compiler="$sdk/bin/clang++"
  fi
  archives=("$dir/lib/lib$package.a")
  package_flags=()
  if [[ -f "$dir/build-flags.txt" ]]; then
    mapfile -t package_flags < "$dir/build-flags.txt"
  fi
  dependency_line="$(sed -n 's/^dependencies = \[\(.*\)\]/\1/p' "$dir/package.toml")"
  include_flags=()
  if [[ -n "$dependency_line" ]]; then
    dependency_line="${dependency_line//\"/}"
    dependency_line="${dependency_line// /}"
    IFS=',' read -r -a dependencies <<< "$dependency_line"
    for dependency in "${dependencies[@]}"; do
      include_flags+=("-I$root/packages/$dependency/vendor/include")
      archives+=("$root/packages/$dependency/lib/lib$dependency.a")
    done
  fi
  "$compiler" \
    "--target=$TARGET" \
    "--sysroot=$sdk/share/wasi-sysroot" \
    -O2 -pthread -msimd128 \
    "${package_flags[@]}" \
    -I"$dir/vendor/include" \
    -I"$root/third_party/emscripten-simd-compat/include" \
    "${include_flags[@]}" \
    "$smoke" \
    "${archives[@]}" \
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
