#!/bin/bash

# Initialize Truebit toolchain for generating C/C++ tasks
#source /emsdk/emsdk_env.sh #(run this first)
sed -i "s|EMSCRIPTEN_NATIVE_OPTIMIZER = emsdk_path + '/fastcomp-clang/e1.37.36_64bit/optimizer'|EMSCRIPTEN_NATIVE_OPTIMIZER = ''|" /emsdk/.emscripten
sed -i "s|LLVM_ROOT = emsdk_path + '/fastcomp-clang/e1.37.36_64bit'|LLVM_ROOT = '/usr/bin'|" /emsdk/.emscripten
emcc -v


# Start IPFS
if [ ! -f ~/.ipfs/api ]; then
  ipfs init
  ( ipfs daemon & );
fi
until [ -f ~/.ipfs/api ]; do sleep 0.1; done

# Start clef and geth
CLEF='/root/.clef/clef.ipc'
GETH=$(echo 'geth console --nousb --syncmode light --signer' $CLEF)
sed -i "s|http://localhost:8545|/root/.ethereum/geth.ipc|" /truebit-eth/wasm-client/config.json
tmux \
new-session 'clef --advanced --nousb --chainid 1 --keystore ~/.ethereum/keystore --rules /root/.clef/ruleset.js' \; \
split-window "echo 'Geth is waiting for Clef IPC socket...'; until [ -S $CLEF ]; do sleep 0.1; done; $GETH" \; \
selectp -U \; swap-pane -U

# Improve IPFS connectivity by connecting to other Truebit users
# echo 'Registering IPFS address and connecting with other registered IPFS nodes running Truebit OS (if Geth is synchronized).'
# cd /truebit-eth
# ./truebit-os -c "ipfs register" --batch > /ipfs-connect.log &
# ./truebit-os -c "ipfs connect" --batch >> /ipfs-connect.log &
