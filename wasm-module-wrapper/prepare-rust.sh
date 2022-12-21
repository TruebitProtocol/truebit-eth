#!/bin/bash

export A=${1%.wasm}
export DIR=$A.tmp

mkdir -p $DIR

wasm2wat $1 > $DIR/test.wat

cd $DIR

sed -i 's/[(]export "memory" [(]memory 0[)][)]/\(export "memory" \(memory 0\)\)\n\(export "env_malloc" \(func \$malloc\)\)/g' test.wat
wat2wasm test.wat -o withmalloc.wasm
cp withmalloc.wasm tomerge.wasm

## merge file system
../../ocaml-offchain/interpreter/wasm -u -merge tomerge.wasm ../filesystem.wasm

../../ocaml-offchain/interpreter/wasm -u -underscore merge.wasm

touch input.dta
touch output.dta
touch output2.dta
touch control.dta

## Run with off-chain interpreter
../../ocaml-offchain/interpreter/wasm -u -m -table-size 20 -stack-size 20 -memory-size 25 -wasm underscore.wasm -t -trace-from 0 -file input.dta -file output.dta -file output2.dta -file control.dta |& grep DEBUG

