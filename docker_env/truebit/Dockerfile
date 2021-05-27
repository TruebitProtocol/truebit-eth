FROM ubuntu:20.04

RUN \
apt-get update && apt-get install wget tmux python3 python3-pip -y && \
pip install pyzmq && \
mkdir -p /truebit-eth && \
wget -O /truebit-eth/truebit-os https://truebit.io/downloads/truebit-linux && \
chmod 755 /truebit-eth/truebit-os && \
apt-get purge wget -y && \
rm -rf /var/lib/apt/lists/*

COPY config/wasm-client /truebit-eth/wasm-client
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY tasks /truebit-eth/tasks
COPY wasm.py /truebit-eth/wasm-client/ocaml-offchain/interpreter/wasm
RUN chmod +x /truebit-eth/wasm-client/ocaml-offchain/interpreter/wasm
ENTRYPOINT ["/entrypoint.sh"]
