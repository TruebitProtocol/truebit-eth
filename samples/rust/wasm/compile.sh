#!/bin/sh

# This should take the name of the Rust project name
rust_project_name=wasm

# Build project
sh build.sh $rust_project_name

node ~/emscripten-module-wrapper/rust/prepare.js \
target/wasm32-unknown-emscripten/release/$rust_project_name.js \
--run \
--debug \
--file input.wasm \
--file output.wasm \
--out=dist \
--upload-ipfs

solc --overwrite --bin --abi --optimize contract.sol -o dist/build
