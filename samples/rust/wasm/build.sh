#!/bin/bash

rust_project_name=$1
# Make sure a recent version of Emscripten (e.g. 1.39.8) is activated and available before running this

# Transpile to WASM - only release builds work for this particular target
cargo build --release --target=wasm32-unknown-emscripten

cd target/wasm32-unknown-emscripten/release

# Transform to WAT
npx wasm2wat "$rust_project_name.wasm" -o "$rust_project_name.wat"

# The WASI functions are exported from `env` in the filesystem from `emscripten-module-wrapper`
sed -i 's/wasi_snapshot_preview1/env/g' "$rust_project_name.wat"
sed -i 's/wasi_unstable/env/g' "$rust_project_name.wat"
sed -i 's/wasi/env/g' "$rust_project_name.wat"

# Transform back to WASM
npx wat2wasm "$rust_project_name.wat" -o "$rust_project_name.wasm"

