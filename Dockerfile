FROM ubuntu:18.04
MAINTAINER Jason Teutsch

SHELL ["/bin/bash", "-c"]

# Get basic packages
RUN apt-get update && apt-get install -y tmux

# Set up Emscripten
RUN apt-get install -y cmake g++ git python \
 && git clone https://github.com/emscripten-core/emsdk.git emsdk \
 && cd emsdk \
 && ./emsdk install sdk-fastcomp-1.38.15-64bit \
 && ./emsdk activate sdk-fastcomp-1.38.15-64bit \
 && ./emsdk install binaryen-tag-1.38.15-64bit \
 && ./emsdk activate binaryen-tag-1.38.15-64bit

# Add support for Rust tasks
RUN apt-get install curl \
 && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
 && source $HOME/.cargo/env \
 && rustup install 1.40.0 \
 && rustup default 1.40.0 \
 && rustup target add wasm32-unknown-emscripten \
 && cd emsdk \
 && ./emsdk install 1.38.33 \
 && ./emsdk install 1.39.8
 # One may activate version 1.39.8 and substitute emscripten-module-wrapper as described in rust_workaround/README.md:
 # ./emsdk activate 1.39.8
 # source /emsdk/emsdk_env.sh
 # cd truebit-eth
 # rm -r emscripten-module-wrapper
 # git clone https://github.com/georgeroman/emscripten-module-wrapper.git
 # cd emscripten-module-wrapper
 # npm i

# Install Node package manager
RUN apt-get install wget \
 && wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash \
 && source ~/.nvm/nvm.sh \
 && nvm install 14.10.0

# Install Solidity
RUN cd bin \
 && wget https://github.com/ethereum/solidity/releases/download/v0.5.17/solc-static-linux \
 && mv solc-static-linux solc \
 && chmod 744 solc

# Install Geth
RUN wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.9.14-6d74d1e5.tar.gz \
 && tar xf geth*tar.gz \
 && rm geth*tar.gz \
 && cd geth* \
 && cp geth /bin \
 && rm -rf /geth-linux-amd64-1.9.14-6d74d1e5

# Install IPFS
RUN wget https://dist.ipfs.io/go-ipfs/v0.4.19/go-ipfs_v0.4.19_linux-amd64.tar.gz \
 && tar xf go-ipfs_v0.4.19_linux-amd64.tar.gz \
 && cd go-ipfs \
 && ./install.sh \
 && ipfs init \
 && cd / \
 && rm -rf go-ipfs*

# Download Truebit
COPY truebit-eth truebit-eth

# Install ocaml-offchain interpreter
RUN apt-get install -y libffi-dev libzarith-ocaml-dev m4 opam pkg-config zlib1g-dev \
 && opam init -y \
 && eval `opam config env` \
 && opam update \
 && opam install cryptokit ctypes ctypes-foreign yojson -y \
 && cd /truebit-eth/ocaml-offchain/interpreter \
 && make \
 && rm -rf ~/.opam

# Install Emscripten module wrapper and dependencies for sample tasks
RUN source ~/.nvm/nvm.sh \
 && ln -s /truebit-eth/emscripten-module-wrapper /root/emscripten-module-wrapper \
 && cd truebit-eth \
 && npm i

# Install Toolchain libraries
RUN apt-get install -y autoconf bison flex libtool lzip \
 && source /emsdk/emsdk_env.sh \
 && mkdir -p /emsdk/fastcomp-clang/lib/clang/6.0.1 \
 && cp -rf /emsdk/emscripten/1.38.15/system/include/libc/ /emsdk/fastcomp-clang/lib/clang/6.0.1 \
 && mv /emsdk/fastcomp-clang/lib/clang/6.0.1/libc /emsdk/fastcomp-clang/lib/clang/6.0.1/include \
 && rm -rf /emsdk/fastcomp-clang/lib/clang/6.0.1/include/bits && mkdir /emsdk/fastcomp-clang/lib/clang/6.0.1/include/bits \
 && cp -rf /emsdk/emscripten/1.38.15/system/include/libc/bits/* /emsdk/fastcomp-clang/lib/clang/6.0.1/include/bits \
 && cd /truebit-eth/wasm-ports \
 && sh gmp.sh \
 && sh openssl.sh \
 && sh secp256k1.sh \
 && sh libff.sh \
 && sh boost.sh \
 && sh libpbc.sh

# DUBUGGING NOTES
# RUN sed -i 's|/binaryen/tag-1.38.3_64bit_binaryen|/fastcomp-clang/e1.38.3_64bit/binaryen/|' /emsdk/.emscripten
# mkdir -p /emsdk/binaryen/tag-1.38.3_64bit_binaryen/share
# Then one of these:
# Fist one is much smaller!
# cp -r /emsdk/binaryen/tag-1.38.3/bin /emsdk/binaryen/tag-1.38.3_64bit_binaryen/share/binaryen
# cp -r /emsdk/fastcomp-clang/e1.38.3_64bit/binaryen/bin /emsdk/binaryen/tag-1.38.3_64bit_binaryen/share/binaryen
# cp /emsdk/fastcomp-clang/e1.38.3_64bit/binaryen/bin/binaryen.js /emsdk/binaryen/tag-1.38.3_64bit_binaryen/share/
# cp /emsdk/fastcomp-clang/e1.38.3_64bit/binaryen/bin/wasm.js /emsdk/binaryen/tag-1.38.3_64bit_binaryen/share/

# Compile sample tasks
RUN source /emsdk/emsdk_env.sh \
 && ( ipfs daemon & ) \
 && cd /truebit-eth/wasm-ports/samples/chess \
 && sh compile.sh \
 && cd ../scrypt \
 && sh compile.sh \
 && cd ../pairing \
 && sh compile.sh \
 && cd ../wasm \
 && source $HOME/.cargo/env \
 && sh compile.sh \
 && cd ../ffmpeg \
 && sh compile.sh

# Optional: set up Ganache, Mocha, and Browserify example
# RUN npm install -g ganache-cli mocha@7.2.0 browserify \
#  && cd /truebit-eth/wasm-ports/samples/pairing \
#  && browserify public/app.js -o public/bundle.js \
#  && cd ../scrypt \
#  && browserify public/app.js -o public/bundle.js

# Set up IPFS and blockchain ports
EXPOSE 4001 30303 80 8545

# Container incantations
# BUILD: docker build . -t truebit:latest
# START CONTAINER: docker run --rm -it truebit:latest /bin/bash
# OPEN NEW TERMINAL WINDOW: docker exec -it _yourContainerName_ /bin/bash
