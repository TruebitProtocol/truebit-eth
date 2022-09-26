#!/bin/sh

wasic++ chess.cpp -fno-exceptions -o chess.wasm

#em++ chess.cpp -s WASM=1 -I $EMSCRIPTEN/system/include -std=c++11 -o chess.js
node ~/emscripten-module-wrapper/prepare.js chess.wasm  --run --debug --out dist --file input.data --file output.data
cp dist/globals.wasm task.wasm
cp dist/info.json .
#solc --overwrite --bin --abi --optimize contract.sol -o build
