#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "$root/toolchain.lock"

case "$(uname -s):$(uname -m)" in
  Linux:x86_64)
    platform="x86_64-linux"
    expected="$WASI_SDK_LINUX_X86_64_SHA256"
    ;;
  *)
    echo "No locked WASI SDK artifact for $(uname -s) $(uname -m)." >&2
    echo "Set WASI_SDK_PATH to an existing WASI SDK $WASI_SDK_VERSION installation." >&2
    exit 1
    ;;
esac

cache="${WASMCART_LIBS_CACHE:-$root/.cache}"
archive="$cache/wasi-sdk-$WASI_SDK_VERSION-$platform.tar.gz"
sdk="$cache/wasi-sdk-$WASI_SDK_VERSION-$platform"
url="https://github.com/WebAssembly/wasi-sdk/releases/download/$WASI_SDK_TAG/$(basename "$archive")"

mkdir -p "$cache"

if [[ ! -x "$sdk/bin/clang" ]]; then
  if [[ ! -f "$archive" ]]; then
    curl -fL "$url" -o "$archive"
  fi

  actual="$(sha256sum "$archive" | awk '{print $1}')"
  if [[ "$actual" != "$expected" ]]; then
    echo "WASI SDK checksum mismatch" >&2
    echo "expected: $expected" >&2
    echo "actual:   $actual" >&2
    exit 1
  fi

  tar -xzf "$archive" -C "$cache"
fi

printf '%s\n' "$sdk"

