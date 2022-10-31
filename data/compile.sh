wasicc -fno-exceptions -c reverse_alphabet.c
wasic++ reverse_alphabet.o -o reverse_alphabet.wasm

node ~/emscripten-module-wrapper/prepare.js reverse_alphabet.wasm --file alphabet.txt --file reverse_alphabet.txt --run --debug --out=dist --memory-size=20 --metering=5000 --limit-stack
cp dist/stacklimit.wasm task.wasm