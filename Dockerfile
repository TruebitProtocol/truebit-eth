### Plain stage to download basic packages ###
FROM ubuntu:22.04 AS stage-base-plain
MAINTAINER Jason Teutsch
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install --no-install-recommends -y curl wget git \
# Plain image packages
 python xz-utils ca-certificates
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

# Install LLVM components
FROM stage-base-01 AS stage-base-02

ENV PATH="${PATH}:/root/.local/bin"

RUN curl https://raw.githubusercontent.com/wasienv/wasienv/master/install.sh | sh || echo ":(("

RUN wasienv install-sdk unstable

# Install Node package manager
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash \
 && source ~/.nvm/nvm.sh \
 && nvm install 14.10.0

# Add support for Rust tasks
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
 && source $HOME/.cargo/env \
 && rustup install 1.63.0 \
 && rustup default 1.63.0 \
 && rustup target add wasm32-unknown-unknown \
 && rustup target add wasm32-wasi

#################################################################################
############### The following stages run in parallel ############################
#################################################################################

# Set up Emscripten
FROM stage-base-01 AS stage-Emscripten
RUN git clone https://github.com/emscripten-core/emsdk.git emsdk \
 && cd emsdk \
 && ./emsdk install 3.1.20 \
 && ./emsdk activate 3.1.20 \
 && rm -r zips

# Install Solidity
FROM stage-base-plain AS stage-Solidity
RUN cd bin \
 && wget https://github.com/ethereum/solidity/releases/download/v0.5.17/solc-static-linux \
 && mv solc-static-linux solc \
 && chmod 744 solc

# Install Geth
FROM stage-base-plain AS stage-Geth
RUN wget https://gethstore.blob.core.windows.net/builds/geth-alltools-linux-amd64-1.10.21-67109427.tar.gz \
 && tar xf geth*tar.gz \
 && rm geth*tar.gz \
 && cd geth*

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
COPY --from=stage-Emscripten /emsdk /emsdk
COPY --from=stage-Solidity /bin/solc /bin/
COPY --from=stage-Geth /geth-alltools-linux-amd64-1.10.21-67109427/geth  /bin/
COPY --from=stage-Geth /geth-alltools-linux-amd64-1.10.21-67109427/clef  /bin/
COPY --from=stage-IPFS /usr/local/bin/ipfs /usr/local/bin/
COPY . truebit-eth/
ARG URL_TRUEBIT_OS=https://truebit.io/downloads/truebit-linux
ADD $URL_TRUEBIT_OS truebit-eth/truebit-os

RUN opam init -y git+https://github.com/ocaml/opam-repository \
 && opam update \
 && opam switch create 4.05.0

# Install ocaml-offchain interpreter
RUN eval `opam config env` \
 && opam update \
 && opam install cryptokit yojson -y \
 && cd /truebit-eth/ocaml-offchain/interpreter \
 && make \
 && rm -rf ~/.opam

# Install Emscripten module wrapper and dependencies for deploying sample tasks
RUN source ~/.nvm/nvm.sh \
 && cd /truebit-eth/emscripten-module-wrapper \
 && ln -s /truebit-eth/emscripten-module-wrapper /root/emscripten-module-wrapper \
 && cd /truebit-eth/wasm-client \
 && ln -s /truebit-eth/ocaml-offchain \
 && cd /truebit-eth \
 && npm ci

# Install Toolchain libraries
RUN source /emsdk/emsdk_env.sh \
 && cd /truebit-eth/wasm-ports \
 && sh gmp.sh \
 && sh openssl.sh \
 && sh secp256k1.sh \
 && sh libff.sh \
 && sh boost.sh \
 && sh libpbc.sh

# Move initialization scripts for compiling, network, and authentication.
RUN chmod 755 /truebit-eth/truebit-os \
 && mv /truebit-eth/goerli.sh / \
 && mv /truebit-eth/mainnet.sh / \
 && cd emsdk \
 && ./emsdk activate sdk-fastcomp-1.37.36-64bit \
 && ./emsdk activate binaryen-tag-1.37.36-64bit

# Compile  C/C++ sample tasks
RUN ipfs init \
 && ( ipfs daemon & ) \
 && source /emsdk/emsdk_env.sh \
 && sed -i "s|LLVM_ROOT = emsdk_path + '/fastcomp-clang/e1.37.36_64bit'|LLVM_ROOT = '/usr/bin'|" /emsdk/.emscripten \
 && sed -i "s|EMSCRIPTEN_NATIVE_OPTIMIZER = emsdk_path + '/fastcomp-clang/e1.37.36_64bit/optimizer'|EMSCRIPTEN_NATIVE_OPTIMIZER = ''|" /emsdk/.emscripten \
 && cd /truebit-eth/wasm-ports/samples/chess \
 && sh compile.sh \
 && cd ../scrypt \
 && sh compile.sh \
 && cd ../pairing \
 && sh compile.sh \
 && cd ../ffmpeg \
 && sh compile.sh \
 && rm -r /root/.ipfs

# Compile Rust sample task
RUN ipfs init \
 && ( ipfs daemon & ) \
 && source ~/.nvm/nvm.sh \
 && mv /truebit-eth/wasm-ports/samples/wasm / \
 && cd / \
 && git clone https://github.com/georgeroman/emscripten-module-wrapper.git \
 && cd /emscripten-module-wrapper \
 && npm install \
 && /emsdk/emsdk activate 1.39.8 \
 && source /emsdk/emsdk_env.sh \
 && source $HOME/.cargo/env \
 && cd /wasm \
 && npm i \
 && sh compile.sh \
 && rm -r /emscripten-module-wrapper \
 && mv /wasm /truebit-eth/wasm-ports/samples \
 && rm -r /root/.ipfs \

### Initialize
 && cd / \
 && rm -r boot home media mnt opt srv \
 && echo -e '\n# Set up Emscripten\nsource /emsdk/emsdk_env.sh &>/dev/null\n\n# Create Geth keystore directories\nmkdir -p ~/.ethereum/keystore\nmkdir -p ~/.ethereum/goerli/keystore' >> ~/.bashrc

# Open IPFS and blockchain ports
EXPOSE 4001 8080 8545 8546 30303
