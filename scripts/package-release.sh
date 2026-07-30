#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package="${1:?usage: scripts/package-release.sh PACKAGE}"
package_dir="$root/packages/$package"
version="$(sed -n 's/^package_version = "\(.*\)"/\1/p' "$package_dir/package.toml")"

[[ -n "$version" ]] || { echo "Missing package_version in $package_dir/package.toml" >&2; exit 1; }

stage="$root/.build/release/$package-$version"
output="$root/dist/$package-$version.zip"
rm -rf "$stage"
mkdir -p "$stage/include" "$stage/lib" "$root/dist"

cp -a "$package_dir/vendor/include/." "$stage/include/"
cp "$package_dir/lib/lib$package.a" "$stage/lib/"
cp "$package_dir/vendor/LICENSE" "$stage/"
cp "$package_dir/package.toml" "$stage/"

rm -f \
  "$root/dist/lib$package-$version.a" \
  "$root/dist/$package-$version-headers.tar.gz" \
  "$root/dist/$package-$version-source.tar.gz" \
  "$root/dist/$package-$version.tar.gz" \
  "$output"

find "$stage" -exec touch -h -t 198001010000 {} +

(
  cd "$(dirname "$stage")"
  find "$(basename "$stage")" -print \
    | LC_ALL=C sort \
    | zip -X -q "$output" -@
)

sha256sum "$output"
