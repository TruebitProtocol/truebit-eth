### Plain stage to download basic packages ###
FROM ubuntu:22.04 AS stage-base-plain
MAINTAINER Jason Teutsch
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install --no-install-recommends -y curl wget git \
    python3 xz-utils ca-certificates
# && rm -rf /var/lib/apt/lists/*

### Base stage to download common packages ###
FROM stage-base-plain AS stage-base-01

# Get packages list and user utilities
RUN apt-get install --no-install-recommends -y \
    # User utilities
    jq nano tmux vim curl \
    # stage-Emscripten packages
    make cmake g++ \
    # stage-LLVM packages
    ninja-build \
    # stage-ocaml-offchain interpreter
    libffi-dev libzarith-ocaml-dev m4 opam pkg-config zlib1g-dev \
    # Install Toolchain libraries
    autoconf bison flex libtool lzip \
    wabt python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/*

################################################################################
######## The following stages run in sequence from stage-base-01. ##############
################################################################################

# Install WASI-SDK using Wasienv components
FROM stage-base-01 AS stage-base-02

ENV PATH="${PATH}:/root/.local/bin"

RUN curl https://raw.githubusercontent.com/wasienv/wasienv/master/install.sh | sh || echo ":(("

RUN wasienv install-sdk unstable

# Install Node package manager
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash \
    && source ~/.nvm/nvm.sh \
    && nvm install 16.16.0

# Add support for Rust tasks
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && source $HOME/.cargo/env \
    && rustup install 1.63.0 \
    && rustup default 1.63.0 \
    && rustup target add wasm32-unknown-unknown \
    && rustup target add wasm32-wasi

# Installing correct versions of OCaml compilers
RUN opam init -y git+https://github.com/ocaml/opam-repository \
    && opam update \
    && opam switch create 4.05.0

RUN eval `opam config env` \
    &&  opam update \
    && opam install cryptokit yojson ocamlbuild -y

RUN opam switch create 4.14.0

RUN opam switch 4.14.0 \
    && opam install wasm ocamlbuild -y \
    && opam switch 4.05.0

#################################################################################
############### The following stages run in parallel ############################
#################################################################################

# Install Solidity
FROM stage-base-plain AS stage-Solidity
RUN cd bin \
    && wget https://github.com/ethereum/solidity/releases/download/v0.5.17/solc-static-linux \
    && mv solc-static-linux solc \
    && chmod 744 solc

# Install Geth
FROM stage-base-plain AS stage-Geth
RUN wget https://gethstore.blob.core.windows.net/builds/geth-alltools-linux-amd64-1.10.23-d901d853.tar.gz \
    && tar xf geth*tar.gz \
    && rm geth*tar.gz \
    && cd geth*

# Install Consensus
FROM stage-base-plain AS stage-Prysm
RUN mkdir ethereum \
    && cd ethereum \
    && mkdir consensus \
    && cd consensus \
    && mkdir prysm \
    && cd prysm \
    && curl https://raw.githubusercontent.com/prysmaticlabs/prysm/master/prysm.sh --output prysm.sh \
    && chmod 755 prysm.sh \
    && wget https://github.com/eth-clients/eth2-networks/raw/master/shared/prater/genesis.ssz \
    && export PRYSM_ALLOW_UNVERIFIED_BINARIES=1 \
    && ./prysm.sh beacon-chain generate-auth-secret \
    && cp jwt.hex .. \
    && cd .. \
    && chmod 0444 jwt.hex

# Install IPFS
FROM stage-base-plain AS stage-IPFS
RUN wget https://dist.ipfs.io/go-ipfs/v0.7.0/go-ipfs_v0.7.0_linux-amd64.tar.gz \
    && tar xf go-ipfs_v0.7.0_linux-amd64.tar.gz \
    && cd go-ipfs \
    && ./install.sh

###############################################################################
###### Final Image is composed from previous stages + Sample Tasks ############
###############################################################################

# Final Image
FROM stage-base-02 as final-image
COPY --from=stage-Solidity /bin/solc /bin/
COPY --from=stage-Geth /geth-alltools-linux-amd64-1.10.23-d901d853/geth  /bin/
COPY --from=stage-Geth /geth-alltools-linux-amd64-1.10.23-d901d853/clef  /bin/
COPY --from=stage-Prysm /ethereum /ethereum
COPY --from=stage-IPFS /usr/local/bin/ipfs /usr/local/bin/
COPY . truebit-eth/
ARG URL_TRUEBIT_OS=https://downloads.truebit.io/truebit-linux
ADD $URL_TRUEBIT_OS truebit-eth/truebit-os

# Install ocaml-offchain interpreter
RUN eval `opam config env` \
    && cd /truebit-eth/ocaml-offchain/interpreter \
    && make

# Install bulk memory ops handler pass
RUN opam switch 4.14.0 \
    && eval `opam config env` \
    && cd /truebit-eth/memory-ops \
    && rm -f ops.native \
    && ocamlbuild -package wasm ops.native \
    && rm -rf ~/.opam

# Copy the implementation of bulk memory ops
RUN cd /truebit-eth/memory-ops \
    && wat2wasm impl.wat -o bulkmemory.wasm \
    && cp bulkmemory.wasm ../wasm-module-wrapper

# Install Wasm module wrapper and dependencies for deploying sample tasks
RUN source ~/.nvm/nvm.sh \
    && cd /truebit-eth/wasm-module-wrapper \
    && ln -s /truebit-eth/wasm-module-wrapper /root/wasm-module-wrapper \
    && cd /truebit-eth/wasm-client \
    && ln -s /truebit-eth/ocaml-offchain \
    && cd /truebit-eth \
    && npm ci

# Install Toolchain libraries
RUN cd /truebit-eth/wasm-ports \
    && sh openssl.sh

# Move initialization scripts for compiling, network, and authentication.
RUN chmod 755 /truebit-eth/truebit-os \
    && mv /truebit-eth/goerli.sh / \
    && mv /truebit-eth/mainnet.sh /

# Compile  C/C++ sample tasks
RUN ipfs init \
    && source ~/.nvm/nvm.sh \
    && ( ipfs daemon & ) \
    && cd /truebit-eth/wasm-ports/samples/chess \
    && sh compile.sh \
    && cd ../scrypt \
    && sh compile.sh \
    && cd /truebit-eth/data \
    && sh compile.sh \
    && rm -r /root/.ipfs

# Compile Rust sample task
RUN ipfs init \
    ### Initialize
    && cd / \
    && rm -r boot home media mnt opt srv \
    && echo -e '\n# Set up Emscripten\nsource /emsdk/emsdk_env.sh &>/dev/null\n\n# Create Geth keystore directories\nmkdir -p ~/.ethereum/keystore\nmkdir -p ~/.ethereum/goerli/keystore' >> ~/.bashrc

# Open IPFS and blockchain ports
EXPOSE 4001 8080 8545 8546 30303
