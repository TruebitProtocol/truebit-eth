FROM ubuntu:20.04

ENV BUILD_DATA_PATH=src/truebit/


RUN \
echo "Installing packages... This may take a while." && \
apt-get -qq update && apt-get -qq install wget tmux python3 python3-pip -y && \
pip install pyzmq && \
mkdir -p /truebit-eth && \
echo "Downloading truebit-os. This may also take a while..." && \
wget -O /truebit-eth/truebit-os https://truebit.io/downloads/truebit-linux -q && \
chmod 755 /truebit-eth/truebit-os && \
apt-get purge wget -y && \
rm -rf /var/lib/apt/lists/*

COPY ${BUILD_DATA_PATH}config/wasm-client /truebit-eth/wasm-client
COPY ${BUILD_DATA_PATH}entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY ${BUILD_DATA_PATH}tasks /truebit-eth/tasks
COPY src/wasm/python/wasm_proxy/wasm.py /truebit-eth/wasm-client/ocaml-offchain/interpreter/wasm
RUN chmod +x /truebit-eth/wasm-client/ocaml-offchain/interpreter/wasm
ENTRYPOINT ["/entrypoint.sh"]
