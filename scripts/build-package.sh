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
cxx="$sdk/bin/clang++"
ar="$sdk/bin/llvm-ar"
ranlib="$sdk/bin/llvm-ranlib"

for tool in "$cc" "$cxx" "$ar" "$ranlib"; do
  [[ -x "$tool" ]] || { echo "Missing tool: $tool" >&2; exit 1; }
done

build="$root/.build/$package"
objects="$build/objects"
archive="$build/lib$package.a"

rm -rf "$build"
mkdir -p "$objects"

if [[ -f "$package_dir/sources.txt" ]]; then
  mapfile -t source_names < "$package_dir/sources.txt"
  sources=()
  for source_name in "${source_names[@]}"; do
    [[ -z "$source_name" || "$source_name" == \#* ]] && continue
    sources+=("$vendor/src/$source_name")
  done
else
  mapfile -t sources < <(find "$vendor/src" -type f \( -name '*.c' -o -name '*.cc' -o -name '*.cpp' \) -print | LC_ALL=C sort)
fi
[[ "${#sources[@]}" -gt 0 ]] || { echo "No C or C++ sources for $package" >&2; exit 1; }

common_flags=(
  "--target=$TARGET"
  "--sysroot=$sdk/share/wasi-sysroot"
  -O3
  -DNDEBUG
  -pthread
  -msimd128
  -ffunction-sections
  -fdata-sections
  -fvisibility=hidden
  "-ffile-prefix-map=$root=/usr/src/wasmcart-libs"
  "-fdebug-prefix-map=$root=/usr/src/wasmcart-libs"
  -I"$vendor/include"
  -I"$vendor/src"
  -I"$root/third_party/emscripten-simd-compat/include"
)

if [[ -f "$package_dir/build-flags.txt" ]]; then
  mapfile -t package_flags < "$package_dir/build-flags.txt"
  common_flags+=("${package_flags[@]}")
fi

dependency_line="$(sed -n 's/^dependencies = \[\(.*\)\]/\1/p' "$package_dir/package.toml")"
if [[ -n "$dependency_line" ]]; then
  dependency_line="${dependency_line//\"/}"
  dependency_line="${dependency_line// /}"
  IFS=',' read -r -a dependencies <<< "$dependency_line"
  for dependency in "${dependencies[@]}"; do
    common_flags+=("-I$root/packages/$dependency/vendor/include")
  done
fi

for source in "${sources[@]}"; do
  relative="${source#"$vendor/src/"}"
  name="${relative//\//_}"
  name="${name%.*}"
  compiler="$cc"
  language_flags=(-std=gnu17)
  case "$source" in
    *.cc|*.cpp)
      compiler="$cxx"
      language_flags=(-std=gnu++17 -fno-exceptions -fno-rtti)
      ;;
  esac
  "$compiler" "${common_flags[@]}" "${language_flags[@]}" -c "$source" -o "$objects/$name.o"
done

mapfile -t object_files < <(find "$objects" -type f -name '*.o' -print | LC_ALL=C sort)
ZERO_AR_DATE=1 "$ar" rcD "$archive" "${object_files[@]}"
"$ranlib" -D "$archive"

mkdir -p "$package_dir/lib"
cp "$archive" "$package_dir/lib/lib$package.a"
sha256sum "$package_dir/lib/lib$package.a"
