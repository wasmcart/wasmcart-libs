#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package="${1:?usage: scripts/package-release.sh PACKAGE}"
package_dir="$root/packages/$package"
version="$(sed -n 's/^package_version = "\(.*\)"/\1/p' "$package_dir/package.toml")"

[[ -n "$version" ]] || { echo "Missing package_version in $package_dir/package.toml" >&2; exit 1; }

stage="$root/.build/release/$package-$version"
output="$root/dist/$package-$version.tar.gz"
versioned_archive="$root/dist/lib$package-$version.a"
headers_archive="$root/dist/$package-$version-headers.tar.gz"
source_archive="$root/dist/$package-$version-source.tar.gz"
rm -rf "$stage"
mkdir -p "$stage/include" "$stage/lib" "$stage/source" "$root/dist"

cp -a "$package_dir/vendor/include/." "$stage/include/"
cp "$package_dir/lib/lib$package.a" "$stage/lib/"
cp -a "$package_dir/vendor/src" "$stage/source/"
cp "$package_dir/vendor/LICENSE" "$stage/"
cp "$package_dir/package.toml" "$stage/"
cp "$package_dir/lib/lib$package.a" "$versioned_archive"

tar \
  --sort=name \
  --mtime="@0" \
  --owner=0 \
  --group=0 \
  --numeric-owner \
  -czf "$output" \
  -C "$(dirname "$stage")" \
  "$(basename "$stage")"

tar \
  --sort=name \
  --mtime="@0" \
  --owner=0 \
  --group=0 \
  --numeric-owner \
  -czf "$headers_archive" \
  -C "$stage" \
  include LICENSE package.toml

tar \
  --sort=name \
  --mtime="@0" \
  --owner=0 \
  --group=0 \
  --numeric-owner \
  -czf "$source_archive" \
  -C "$stage" \
  source LICENSE package.toml

sha256sum "$versioned_archive" "$headers_archive" "$source_archive" "$output"
