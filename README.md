# wasmcart-libs

[![CI](https://github.com/wasmcart/wasmcart-libs/actions/workflows/ci.yml/badge.svg)](https://github.com/wasmcart/wasmcart-libs/actions/workflows/ci.yml)

Reproducible, ready-to-link static libraries for wasmcart games.

Every archive targets one platform:

```text
wasm32-wasip1-threads + simd128
```

Conforming wasmcart hosts provide WASI threads, shared memory, atomics, and
WebAssembly SIMD. There are no slower compatibility builds.

## Packages

| Package | Upstream | Archive | Status |
|---|---|---|---|
| Box2D | 3.1.1 development snapshot | `libbox2d.a` | ready |
| Box3D | 0.1.0 development snapshot | `libbox3d.a` | ready |
| cgltf | 1.15 development snapshot | `libcgltf.a` | ready |
| Flecs | 4.1.6 core | `libflecs.a` | ready |
| Dear ImGui | 1.92.9 core | `libimgui.a` | ready |
| Jolt Physics | 5.6.1 development snapshot | `libjolt.a` | ready |
| libpng | 1.8.0 development snapshot | `liblibpng.a` | ready |
| libxmp | 4.7.2 lite formats | `liblibxmp.a` | ready |
| meshoptimizer | 1.2 development snapshot | `libmeshoptimizer.a` | ready |
| miniaudio | 0.11.25 decoding and mixing | `libminiaudio.a` | ready |
| Nuklear | 4.13 development snapshot | `libnuklear.a` | ready |
| Ogg | 1.3.6 development snapshot | `libogg.a` | ready |
| Vorbis | 1.3.8 development snapshot | `libvorbis.a` | ready |
| zlib | 1.3.2 development snapshot | `libzlib.a` | ready |

Raylib, SDL2, SDL3, and Skia need wasmcart platform backends, not merely
cross-compilation. They land here only after their examples run in the browser,
Node.js, native, and libretro hosts.

The libpng build omits its simplified API because that API requires
`setjmp`/`longjmp`. Those operations depend on WebAssembly exception handling,
which is not part of the wasmcart host contract. The regular row-based read and
write APIs are included.

## Why static archives

Game builds compile only game code. The linker pulls required objects from the
prebuilt archive and discards unused sections. Users can also rebuild every byte
from the committed source without trusting the checked-in binary.

The archives are WebAssembly object archives. They are not native Linux,
Windows, or macOS libraries.

## Build

Set `WASI_SDK_PATH` to WASI SDK 33.0:

```sh
WASI_SDK_PATH=/opt/wasi-sdk-33.0 scripts/build.sh
scripts/link-smoke.sh
scripts/verify-reproducible.sh
```

On Linux x86_64, omitting `WASI_SDK_PATH` downloads the official WASI SDK 33.0
release into `.cache/` and verifies its SHA-256 digest first:

```sh
scripts/build.sh
```

No upstream library source is downloaded during a normal build. All source and
headers used to create an archive are committed under that package's `vendor/`
directory.

## Consume a release

Each package release publishes separate files:

```text
libbox2d-3.1.0-wc1.a
box2d-3.1.0-wc1-headers.tar.gz
box2d-3.1.0-wc1-source.tar.gz
box2d-3.1.0-wc1.tar.gz
SHA256SUMS
```

Download only the versioned `.a` if headers are already available. A new
project usually downloads the `.a` and small headers archive. Source remains a
separate artifact for auditing and reproducible builds.

After verifying the downloads, add their include and library paths:

```sh
clang --target=wasm32-wasip1-threads \
  -pthread -msimd128 \
  -I deps/box2d/include \
  game.c deps/box2d/lib/libbox2d.a \
  -o game.wasm
```

Projects pin the release URL and SHA-256 in `wasmcart-libs.lock`. They do not
need this repository as a submodule.

## Reproducibility

The repository commits source, public headers, licenses, build recipes, and
generated archives together. CI performs three independent checks:

1. Rebuild every archive from committed source with the pinned toolchain.
2. Compare the rebuilt archive byte-for-byte with the committed archive.
3. Link a smoke program against each committed archive.

Build paths are normalized, object order is sorted, and `llvm-ar` deterministic
mode removes archive timestamps and host identity.

Box2D and Box3D use SSE2 intrinsics as their portable four-wide SIMD API.
WASI Clang lowers the vendored Emscripten SSE compatibility headers to native
WebAssembly `simd128` instructions. The compatibility headers and their license
are committed under `third_party/emscripten-simd-compat/`.

See [docs/REPRODUCIBLE_BUILDS.md](docs/REPRODUCIBLE_BUILDS.md).
The release archive layout and version rules are documented in
[docs/PACKAGE_FORMAT.md](docs/PACKAGE_FORMAT.md).

## Updating a library

Library updates are explicit:

1. Replace the package's vendored source with an exact upstream revision.
2. Update `package.toml`.
3. Run `scripts/build.sh <package>`.
4. Run `scripts/link-smoke.sh <package>`.
5. Run `scripts/verify-reproducible.sh <package>`.
6. Commit source, metadata, headers, and archive together.

Changing a package only rebuilds that package and its integration examples.
Changing the toolchain or shared build scripts rebuilds everything.

## License

Repository tooling is MIT licensed. Each packaged library keeps its upstream
license in its package and release archive.
