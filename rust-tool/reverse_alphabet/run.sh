#!/bin/bash

rust_project_name=reverse_alphabet
input_file="alphabet.txt"
output_file="reverse_alphabet.txt"

# You can add more input and output files by providing more `--file filename` args
node "../wasm-module-wrapper/prepare.js" "target/wasm32-unknown-emscripten/release/$rust_project_name.js" --file "$input_file" --file "$output_file" --run --debug --out=truebit_run
