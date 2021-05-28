#!/bin/bash

rust_project_name=REPLACE_ME
input_file="input.txt"
output_file="output.txt"

# You can add more input and output files by providing more `--file filename` args
node "../emscripten-module-wrapper/prepare.js" "target/wasm32-unknown-emscripten/release/$rust_project_name.js" --file "$input_file" --file "$output_file" --run --debug --out=truebit_run
