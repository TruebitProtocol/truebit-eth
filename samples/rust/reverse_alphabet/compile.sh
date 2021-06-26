#!/bin/sh

# This should take the name of the Rust project name
rust_project_name=reverse_alphabet

# Build project
sh build.sh $rust_project_name

node ~/emscripten-module-wrapper/rust/prepare.js \
target/wasm32-unknown-emscripten/release/$rust_project_name.js \
--run \
--debug \
--file alphabet.txt \
--file reverse_alphabet.txt \
--out=dist
