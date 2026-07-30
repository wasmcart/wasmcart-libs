#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "$#" -gt 0 ]]; then
  packages=("$@")
else
  mapfile -t packages < <(find "$root/packages" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | LC_ALL=C sort)
fi

for package in "${packages[@]}"; do
  committed="$root/packages/$package/lib/lib$package.a"
  [[ -f "$committed" ]] || { echo "Missing committed archive: $committed" >&2; exit 1; }

  before="$(sha256sum "$committed" | awk '{print $1}')"
  "$root/scripts/build-package.sh" "$package" >/dev/null
  after="$(sha256sum "$committed" | awk '{print $1}')"

  if [[ "$before" != "$after" ]]; then
    echo "$package is not reproducible" >&2
    echo "before: $before" >&2
    echo "after:  $after" >&2
    exit 1
  fi

  echo "$package $after"
done

