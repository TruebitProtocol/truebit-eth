#!/bin/sh

ocamlbuild -package wasm ops.native

wat2wasm filltest.wat -o test.wasm
wat2wasm impl.wat -o impl.wasm
./ops.native test.wasm impl.wasm replaced.wasm
wasm-interp -t --run replaced.wasm
