#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "$root/toolchain.lock"

package="${1:?usage: scripts/build-package.sh PACKAGE}"
package_dir="$root/packages/$package"
vendor="$package_dir/vendor"

if [[ ! -d "$vendor/src" || ! -d "$vendor/include" ]]; then
  echo "Package $package has no vendored src/include tree" >&2
  exit 1
fi

sdk="${WASI_SDK_PATH:-}"
if [[ -z "$sdk" ]]; then
  sdk="$("$root/scripts/bootstrap-wasi-sdk.sh")"
fi

cc="$sdk/bin/clang"
ar="$sdk/bin/llvm-ar"
ranlib="$sdk/bin/llvm-ranlib"

for tool in "$cc" "$ar" "$ranlib"; do
  [[ -x "$tool" ]] || { echo "Missing tool: $tool" >&2; exit 1; }
done

build="$root/.build/$package"
objects="$build/objects"
archive="$build/lib$package.a"

rm -rf "$build"
mkdir -p "$objects"

mapfile -t sources < <(find "$vendor/src" -maxdepth 1 -type f -name '*.c' -print | LC_ALL=C sort)
[[ "${#sources[@]}" -gt 0 ]] || { echo "No C sources for $package" >&2; exit 1; }

common_flags=(
  "--target=$TARGET"
  "--sysroot=$sdk/share/wasi-sysroot"
  -std=gnu17
  -O3
  -DNDEBUG
  -pthread
  -msimd128
  -msse2
  -ffunction-sections
  -fdata-sections
  -fvisibility=hidden
  "-ffile-prefix-map=$root=/usr/src/wasmcart-libs"
  "-fdebug-prefix-map=$root=/usr/src/wasmcart-libs"
  -I"$vendor/include"
  -I"$vendor/src"
)

for source in "${sources[@]}"; do
  name="$(basename "${source%.c}")"
  "$cc" "${common_flags[@]}" -c "$source" -o "$objects/$name.o"
done

mapfile -t object_files < <(find "$objects" -type f -name '*.o' -print | LC_ALL=C sort)
ZERO_AR_DATE=1 "$ar" rcD "$archive" "${object_files[@]}"
"$ranlib" -D "$archive"

mkdir -p "$package_dir/lib"
cp "$archive" "$package_dir/lib/lib$package.a"
sha256sum "$package_dir/lib/lib$package.a"

