em++ security.cpp -s WASM=1 -I $EMSCRIPTEN/system/include -std=c++11 -o security.js
node ~/emscripten-module-wrapper/c/prepare.js security.js  --run --debug --out dist --file input.data --file output.data --upload-ipfs
cp dist/globals.wasm dist/task.wasm
