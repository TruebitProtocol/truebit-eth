#!/bin/sh

sh build.sh
touch output.wasm
node /wasm-module-wrapper/prepare.js target/wasm32-unknown-emscripten/release/wasm_sample.js --run --debug --file input.wasm --file output.wasm --out=dist --upload-ipfs

## OLD COMPILE SCRIPT ##
# cargo build --target wasm32-unknown-emscripten
# cp input.wasm target/wasm32-unknown-emscripten/debug
# cd target/wasm32-unknown-emscripten/debug
# touch output.wasm
# node ~/wasm-module-wrapper/prepare.js wasm_sample.js --run --file input.wasm --file output.wasm --asmjs --debug --analyze --out=stuff --upload-ipfs

# cp stuff/globals.wasm ../../../task.wasm
# cp stuff/info.json ../../../
#
# cd ../../..

solc --overwrite --bin --abi --optimize contract.sol -o build
