#!/bin/bash

./prepare-rust.sh test.wasm

for i in ../demo-wasi/*.dir; do
  cp -r $i $(basename $i)
done

for i in *.dir; do
  cd $i
  cp input.dta.in input.dta
  cp output.dta.in output.dta
  cp output2.dta.in output2.dta
  echo; echo
  echo "Running test $i ********************************"
  ../../ocaml-offchain/interpreter/wasm -u -m -table-size 20 -stack-size 20 -memory-size 25 -wasm ../test.tmp/underscore.wasm -t -trace-from 0 -file input.dta -file output.dta -file output2.dta -file control.dta |& grep DEBUG
  cd ..
done

for i in *.dir; do
  cd $i
  echo; echo
  echo "Test $i results ********************************"
  diff input.dta.out input.dta.ref
  diff output.dta.out output.dta.ref
  diff output2.dta.out output2.dta.ref
  cd ..
done

