#!/bin/bash


#cp -R /truebit-eth/wasm-ports /samples

cp -R /input /compile


if [ "$RUNTIME" == "c" ]
then
  echo "Running C-Compiler environment"
  # TODO eventually, this section should be removed.
  ipfs init
  ( ipfs daemon & )
  source /emsdk/emsdk_env.sh
  sed -i "s|LLVM_ROOT = emsdk_path + '/fastcomp-clang/e1.37.36_64bit'|LLVM_ROOT = '/usr/bin'|" /emsdk/.emscripten
  sed -i "s|EMSCRIPTEN_NATIVE_OPTIMIZER = emsdk_path + '/fastcomp-clang/e1.37.36_64bit/optimizer'|EMSCRIPTEN_NATIVE_OPTIMIZER = ''|" /emsdk/.emscripten
  # TODO end of section that should be removed.

  cd /compile

  # Install Dependencies
  if [ -d "libs" ]; then
      # Install Dependencies
      for f in libs/*.sh; do
        echo "Installing dependency '$f'..."
        sh $f
        done
  fi

  /bin/bash compile.sh
  cp -R dist/* /output
  chown -R nobody:nogroup /output
  chmod -R 777 /output

fi

if [ "$RUNTIME" == "rust" ]
then
  echo "Running Rust-Compiler environment"

  # TODO - This section should be removed eventually...
  ipfs init
  ( ipfs daemon & )
  source ~/.nvm/nvm.sh
  /emsdk/emsdk activate 1.39.8
  source /emsdk/emsdk_env.sh
  source $HOME/.cargo/env
  # TODO end of section that should be removed.

  cd /compile

  # Install dependencies
  npm i

  /bin/bash compile.sh
  cd /compile
  cp -R dist/* /output
  chown -R nobody:nogroup /output
  chmod -R 777 /output

fi

if [ "$RUNTIME" == "" ]
then
  echo "No Runtime is set. You must set environment variable RUNTIME to either 'c' or 'rust' Currently RUNTIME=$RUNTIME"
fi