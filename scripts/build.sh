#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "$#" -gt 0 ]]; then
  packages=("$@")
else
  mapfile -t packages < <(find "$root/packages" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | LC_ALL=C sort)
fi

for package in "${packages[@]}"; do
  echo "==> $package"
  "$root/scripts/build-package.sh" "$package"
done

