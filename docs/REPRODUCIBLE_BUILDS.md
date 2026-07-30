# Reproducible builds

The checked-in archives are conveniences, not trust anchors. The committed
source and locked toolchain must reproduce the same bytes.

## Locked inputs

- Exact upstream commit in `package.toml`
- Vendored source and public headers
- WASI SDK release and SHA-256 in `toolchain.lock`
- Complete compiler flags in `scripts/build-package.sh`
- Deterministic archive construction with `llvm-ar rcD`
- Vendored SSE-to-WASM compatibility headers used by the physics solvers

## Normalized build

The build uses a sorted source list and creates one object per C translation
unit. Source paths are rewritten to `/usr/src/wasmcart-libs`. Archive member
timestamps, owners, and modes are normalized by LLVM's deterministic archive
mode.

Release tarballs sort their entries and normalize timestamps and ownership.

## User verification

```sh
git clone https://github.com/wasmcart/wasmcart-libs
cd wasmcart-libs
scripts/verify-reproducible.sh
```

A successful verification prints one SHA-256 digest per archive. Any difference
is a release-blocking failure.

## Toolchain changes

A WASI SDK update is a repository-wide change. It requires rebuilding every
archive, linking every smoke program, and publishing new `wc` package revisions.
Upstream versions do not need to change when only wasmcart packaging changes.
