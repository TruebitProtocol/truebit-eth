#!/bin/bash

# Initialize Truebit toolchain for generating C/C++ tasks
#source /emsdk/emsdk_env.sh (run this first)
sed -i "s|EMSCRIPTEN_NATIVE_OPTIMIZER = emsdk_path + '/fastcomp-clang/e1.37.36_64bit/optimizer'|EMSCRIPTEN_NATIVE_OPTIMIZER = ''|" /emsdk/.emscripten
sed -i "s|LLVM_ROOT = emsdk_path + '/fastcomp-clang/e1.37.36_64bit'|LLVM_ROOT = '/usr/bin'|" /emsdk/.emscripten
emcc -v

# Start IPFS
ipfs init
( ipfs daemon & )

# Start clef and geth
CLEF='/root/.clef/clef.ipc'
GETH='geth console --nousb --goerli --syncmode "light" --signer $CLEF'
tmux \
new-session 'clef --advanced --nousb --chainid 5 --keystore ~/.ethereum/goerli/keystore --rules /root/.clef/ruleset.js'\; \
split-window '$GETH until [ -S $CLEF ]; do $GETH; done' \; \
selectp -U \; swap-pane -U

# Improve IPFS connectivity by connecting to other Truebit users
# echo 'Registering IPFS address and connecting with other registered IPFS nodes running Truebit OS (if Geth is synchronized).'
# cd /truebit-eth
# ./truebit-os -c "ipfs register" --batch > /ipfs-connect.log &
# ./truebit-os -c "ipfs connect" --batch >> /ipfs-connect.log &

# For first-time use
clef init
echo ''
clef attest f163a1738b649259bb9b369c593fdc4c6b6f86cc87e343c3ba58faee03c2a178
