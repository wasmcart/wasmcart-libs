# Package format

Every release publishes one ready-to-link SDK ZIP:

```text
box2d-3.1.1-dev.19-wc1.zip
```

The ZIP has one top-level directory:

```text
box2d-3.1.1-dev.19-wc1/
  include/
  lib/
    libbox2d.a
  LICENSE
  package.toml
```

`package.toml` identifies the upstream repository and commit, wasmcart package
revision, target triple, required WebAssembly features, and archive path.
Source is not duplicated in release assets. It remains available in the
corresponding `packages/` directory and from the upstream repository.

## Versioning

Package versions combine the upstream version with a wasmcart packaging
revision:

```text
3.1.0-wc1
3.1.0-wc2
```

The `wc` revision changes when build flags, wasmcart patches, packaging, or the
toolchain change without an upstream version change.

The `features` array records required execution and link capabilities.
`wasm-eh` means the archive uses standardized WebAssembly exception handling;
with wasi-sdk 33, consumers compile participating code with
`-mllvm -wasm-enable-sjlj` and include `-lsetjmp` in the final link.

Release tags begin with the package name:

```text
box2d-3.1.0-wc1
box3d-0.1.0-wc1
```

## Consumer lock

Consumers record immutable release URLs and SHA-256 digests:

```toml
[[library]]
name = "box2d"
version = "3.1.0-wc1"
url = "https://github.com/wasmcart/wasmcart-libs/releases/download/box2d-3.1.0-wc1/box2d-3.1.0-wc1.zip"
sha256 = "..."
```

The lockfile is committed. Extracted dependencies are cached and ignored.
