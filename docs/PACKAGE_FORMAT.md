# Package format

Each release is a gzip-compressed tar archive with one top-level directory:

```text
box2d-3.1.1-dev.19-wc1/
  include/
  lib/
    libbox2d.a
  source/
  LICENSE
  package.toml
```

`package.toml` identifies the upstream repository and commit, wasmcart package
revision, target triple, required WebAssembly features, and archive path.

## Versioning

Package versions combine the upstream version with a wasmcart packaging
revision:

```text
3.1.0-wc1
3.1.0-wc2
```

The `wc` revision changes when build flags, wasmcart patches, packaging, or the
toolchain change without an upstream version change.

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
url = "https://github.com/wasmcart/wasmcart-libs/releases/download/box2d-3.1.0-wc1/box2d-3.1.0-wc1.tar.gz"
sha256 = "..."
```

The lockfile is committed. Extracted dependencies are cached and ignored.

