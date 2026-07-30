import { readFile } from 'node:fs/promises';

const [wasmPath, expectedText] = process.argv.slice(2);
if (!wasmPath || expectedText === undefined) {
  throw new Error('usage: node scripts/run-smoke.mjs SMOKE_WASM EXPECTED_RESULT');
}

const module = await WebAssembly.compile(await readFile(wasmPath));
const memory = new WebAssembly.Memory({
  initial: 2,
  maximum: 1024,
  shared: true,
});
const wasi = new Proxy({}, { get: () => () => 0 });
const instance = await WebAssembly.instantiate(module, {
  env: { memory },
  wasi_snapshot_preview1: wasi,
});
const result = instance.exports.smoke();
const expected = Number(expectedText);
if (result !== expected) {
  throw new Error(`${wasmPath}: smoke() returned ${result}, expected ${expected}`);
}
console.log(`${wasmPath}: smoke() returned ${result}`);
