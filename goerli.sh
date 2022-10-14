#!/bin/bash

# Initialize Truebit toolchain for generating C/C++ tasks
#source /emsdk/emsdk_env.sh #(run this first)
# sed -i "s|EMSCRIPTEN_NATIVE_OPTIMIZER = emsdk_path + '/fastcomp-clang/e1.37.36_64bit/optimizer'|EMSCRIPTEN_NATIVE_OPTIMIZER = ''|" /emsdk/.emscripten
# sed -i "s|LLVM_ROOT = emsdk_path + '/fastcomp-clang/e1.37.36_64bit'|LLVM_ROOT = '/usr/bin'|" /emsdk/.emscripten
#emcc -v

# Refresh Clef and Geth IPC sockets
rm ~/.clef/clef.ipc &>/dev/null
rm ~/.ethereum/goerli/geth.ipc &>/dev/null

export PRYSM_ALLOW_UNVERIFIED_BINARIES=1

# Start IPFS
ipfs init &>/dev/null
tmux new -d 'ipfs daemon'

# Start Clef and Geth
CLEF='/root/.clef/clef.ipc'
GETHIPC='./root/.ethereum/geth.ipc'

GETH=$(echo 'geth  console --goerli --http --http.api web3,eth,net,engine,admin --datadir ~/.ethereum/ --authrpc.jwtsecret /ethereum/consensus/jwt.hex --authrpc.vhosts localhost  --signer' $CLEF)
PRYSM=$(echo '/ethereum/consensus/prysm/prysm.sh beacon-chain --execution-endpoint=http://localhost:8551 --prater --jwt-secret=/ethereum/consensus/jwt.hex --genesis-state=/ethereum/consensus/prysm/genesis.ssz --suggested-fee-recipient=0x1Da28542742614B3CA2941F9DFcD23FFc3CB0071')                         
cat <<< $(jq '.geth.providerURL="/root/.ethereum/goerli/geth.ipc"' /truebit-eth/wasm-client/config.json) > /truebit-eth/wasm-client/config.json
tmux \
new-session 'clef --advanced --nousb --chainid 5 --keystore ~/.ethereum/goerli/keystore --rules /truebit-eth/wasm-client/ruleset.js' \; \
split-window -v  "echo 'Geth is waiting for Clef IPC socket...'; until [ -S $CLEF ]; do sleep 0.1; done; $GETH " \; \
split-window -hf  "echo 'Prysm Geth is waiting for Clef IPC socket...'; until [ -S $CLEF ]; do sleep 0.1; done; $PRYSM " \; \
selectp -L \; swap-pane -U


# Improve IPFS connectivity by connecting to other Truebit users
# echo 'Registering IPFS address and connecting with other registered IPFS nodes running Truebit OS (if Geth is synchronized).'
# cd /truebit-eth
# ./truebit-os -c "ipfs register" --batch > /ipfs-connect.log &
# ./truebit-os -c "ipfs connect" --batch >> /ipfs-connect.log &

