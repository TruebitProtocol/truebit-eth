#!/bin/sh

wasicc -fno-exceptions -c scrypthash.cpp
wasicc -fno-exceptions -c scrypt.cpp

wasic++ scrypt.o scrypthash.o -o scrypt.wasm -lssl -lcrypto

#em++ -O2 -I $EMSCRIPTEN/system/include -c -std=c++11 scrypthash.cpp
#em++ -O2 -I $EMSCRIPTEN/system/include -c -std=c++11 scrypt.cpp
#em++ -o scrypt.js scrypthash.o scrypt.o -lcrypto -lssl

node ~/wasm-module-wrapper/prepare.js scrypt.wasm --file input.dta --file output.dta --run --debug --out=dist --memory-size=20 --metering=5000 --limit-stack
cp dist/stacklimit.wasm task.wasm
cp dist/info.json .
#solc --overwrite --bin --abi --optimize contract.sol -o build
