#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package="${1:?usage: scripts/package-release.sh PACKAGE}"
package_dir="$root/packages/$package"
version="$(sed -n 's/^package_version = "\(.*\)"/\1/p' "$package_dir/package.toml")"

[[ -n "$version" ]] || { echo "Missing package_version in $package_dir/package.toml" >&2; exit 1; }

stage="$root/.build/release/$package-$version"
output="$root/dist/$package-$version.tar.gz"
rm -rf "$stage"
mkdir -p "$stage/include" "$stage/lib" "$stage/source" "$root/dist"

cp -a "$package_dir/vendor/include/." "$stage/include/"
cp "$package_dir/lib/lib$package.a" "$stage/lib/"
cp -a "$package_dir/vendor/src" "$stage/source/"
cp "$package_dir/vendor/LICENSE" "$stage/"
cp "$package_dir/package.toml" "$stage/"

tar \
  --sort=name \
  --mtime="@0" \
  --owner=0 \
  --group=0 \
  --numeric-owner \
  -czf "$output" \
  -C "$(dirname "$stage")" \
  "$(basename "$stage")"

sha256sum "$output"

