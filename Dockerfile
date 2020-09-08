FROM ubuntu:18.04
MAINTAINER Jason Teutsch

SHELL ["/bin/bash", "-c"]

# Basic packages
RUN apt-get update \
 && apt-get install -y apache2 cmake curl g++ git libzarith-ocaml-dev m4 mongodb nano ninja-build npm ocaml opam pkg-config psmisc python sudo tmux wget zlib1g-dev

# Set up Emscripten
RUN git clone https://github.com/emscripten-core/emsdk.git emsdk \
 && cd emsdk \
 && ./emsdk install sdk-fastcomp-1.37.36-64bit \
 && ./emsdk activate sdk-fastcomp-1.37.36-64bit \
 && ./emsdk install binaryen-tag-1.37.36-64bit \
 && ./emsdk activate binaryen-tag-1.37.36-64bit

# Install LLMV and Clang
RUN git clone https://github.com/llvm-mirror/llvm \
 && cd llvm/tools \
 && git clone https://github.com/llvm-mirror/clang \
 && git clone https://github.com/llvm-mirror/lld \
 && cd /llvm \
 && git checkout release_60 \
 && cd tools/clang \
 && git checkout release_60 \
 && cd ../lld \
 && git checkout release_60 \
 && mkdir /build \
 && cd /build \
 && cmake -G Ninja -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=/usr/ /llvm \
 && ninja \
 && ninja install \
 && cd / \
 && rm -rf build llvm

# Configure Emscripten
RUN sed -i 's|/emsdk/clang/e1.37.36_64bit|/usr/bin|' /root/.emscripten

# Add support for Rust and WASI.
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh \
 && rustup install 1.40.0 \
 && rustup default 1.40.0 \
 && rustup target add wasm32-unknown-emscripten \
 && cd emsdk \
 && ./emsdk install 1.39.8
 # Additionall,y one may substitute emscripten-module-wrapper as follows as per rust_workaround/README.md:
 # ./emsdk activate 1.39.8
 # source ./emsdk_env.sh
 # cd truebit-eth
 # rm -r emscripten-module-wrapper
 # git clone https://github.com/georgeroman/emscripten-module-wrapper.git
 # cd emscripten-module-wrapper
 # npm i

# Install Node package manager
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash \
 && source ~/.nvm/nvm.sh \
 && nvm install node

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
 && cp geth /bin

# Install IPFS
RUN wget https://dist.ipfs.io/go-ipfs/v0.4.19/go-ipfs_v0.4.19_linux-amd64.tar.gz \
 && tar xf go-ipfs_v0.4.19_linux-amd64.tar.gz \
 && cd go-ipfs \
 && ./install.sh \
 && ipfs init \
 && cd / \
 && rm -rf go-ipfs*

# Configure OCaml
RUN opam init -y \
 && eval `opam config env` \
 && apt-get install libffi-dev \
 && opam update \
 && opam install cryptokit yojson ctypes ctypes-foreign -y \
 && rm -rf ~/.opam

# Install Emscripten module wrapper and off-chain interpreter
RUN git clone https://github.com/teutsch/truebit-eth \
 && ln -s /truebit-eth/emscripten-module-wrapper /root/emscripten-module-wrapper \
 && cd truebit-eth \
 && npm i \
 && cd ocaml-offchain/interpreter \
 && make

# Install Toolchain libraries
RUN source /emsdk/emsdk_env.sh \
 && cd /Truebit2020/wasm-ports \
 && export EMCC_WASM_BACKEND=1 \
 && apt-get install -y lzip autoconf libtool flex bison \
 && sh gmp.sh \
 && sh openssl.sh \
 && sh secp256k1.sh \
 && sh libff.sh \
 && sh boost.sh \
 && sh libpbc.sh

# Install Truebit-OS client
COPY truebit-os truebit-eth

# Compile sample tasks
RUN source /emsdk/emsdk_env.sh \
 && ( ipfs daemon & ) \
 && export EMCC_WASM_BACKEND=1 \
 && cd /truebit-eth/wasm-ports/samples/pairing \
 && sh compile.sh \
 && cd ../scrypt \
 && sh compile.sh \
 && cd ../chess \
 && sh compile.sh \
 && cd ../wasm \
 && sh compile.sh \
 && cd ../ffmpeg \
 && sh compile.sh

# Optional: set up Ganache, Mocha, and Browserify example
RUN npm install -g ganache-cli mocha@7.2.0 browserify \
 && cd truebit-eth/wasm-ports/samples/pairing \
 && browserify public/app.js -o public/bundle.js \
 && cd ../scrypt \
 && browserify public/app.js -o public/bundle.js \

# Set up IPFS and blockchain ports
EXPOSE 4001 30303 80 8545

# Open IPFS session on startup
CMD ( ipfs daemon & )

# CONTAINER COMMAND CHEAT SHEET
# BUILD
# docker build . -t truebit:latest
# START CONTAINER: From the directory where you plan to usually run the container, type the following, substituting `YYY` for the *full path* to a directory where you wish to cache files.  tT get the full path to your current working directory, type `pwd`.
# docker run --network host -v YYY/geth-docker-cache:/root/.ethereum --rm -it truebit-os:latest /bin/bash
# OPEN TERMINAL WINDOW: When it is time to open a new container window, find the name of your container running `truja/truebit` by using `docker ps`, open a new local terminal window and enter the following at the command line; _yourcontainerNAME_ might look like `xenodochial_fermat`.
# docker exec -it yourcontainerNAME /bin/bash

# && ./emsdk list --old \
