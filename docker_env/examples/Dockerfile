FROM ubuntu:20.04
SHELL ["/bin/bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow

ENV TRUEBIT_DIR=truebit-eth
ENV EMSDK_VERSION=1.37.36
ENV LLVM_VERSION=release_60
ENV RUST_VERSION=1.40.0
ENV NVM_VERSION=v0.38.0
ENV NODE_VERSION=14.17.0
# v0.5.17
ENV SOLIDITY_VERSION=v0.8.4
# Set up Emscripten
RUN apt-get update && apt-get install -y cmake g++ git python

# Set up Emscripten
RUN git clone https://github.com/emscripten-core/emsdk.git emsdk \
 && cd emsdk \
 && ./emsdk install sdk-fastcomp-${EMSDK_VERSION}-64bit \
 && ./emsdk install binaryen-tag-${EMSDK_VERSION}-64bit \
 && ./emsdk activate sdk-fastcomp-${EMSDK_VERSION}-64bit \
 && ./emsdk activate binaryen-tag-${EMSDK_VERSION}-64bit


# Install LLVM components
RUN apt-get install -y ninja-build \
  && git clone https://github.com/llvm-mirror/llvm \
  && cd llvm/tools \
  && git clone https://github.com/llvm-mirror/clang \
  && git clone https://github.com/llvm-mirror/lld \
  && cd /llvm \
  && git checkout ${LLVM_VERSION} \
  && cd tools/clang \
  && git checkout ${LLVM_VERSION} \
  && cd ../lld \
  && git checkout ${LLVM_VERSION} \
  && mkdir /build \
  && cd /build \
  && cmake -G Ninja -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=/usr/ /llvm \
  && ninja \
  && ninja install \
  && cd / \
  && rm -rf build llvm


# Add support for Rust tasks
RUN apt-get install curl \
 && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
 && source $HOME/.cargo/env \
 && rustup install ${RUST_VERSION} \
 && rustup default ${RUST_VERSION} \
 && rustup target add wasm32-unknown-emscripten
 #&& cd emsdk \
 #&& ./emsdk install 1.38.33 \
 #&& ./emsdk install 1.39.8 \
 #&& rm -r zips


# Install Node package manager
RUN apt-get install wget \
 && wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash \
 && source ~/.nvm/nvm.sh \
 && nvm install ${NODE_VERSION}

# Install Solidity
RUN cd bin \
 && wget https://github.com/ethereum/solidity/releases/download/${SOLIDITY_VERSION}/solc-static-linux \
 && mv solc-static-linux solc \
 && chmod 744 solc


COPY wasm-ports /${TRUEBIT_DIR}/wasm-ports

# Install Toolchain libraries
RUN apt-get install -y autoconf bison flex libtool lzip \
 && source /emsdk/emsdk_env.sh \
 #&& sed -i "s|LLVM_ROOT = emsdk_path + '/fastcomp-clang/e1.37.36_64bit'|LLVM_ROOT = '/usr/bin'|" /emsdk/.emscripten \
 #&& sed -i "s|EMSCRIPTEN_NATIVE_OPTIMIZER = emsdk_path + '/fastcomp-clang/e1.37.36_64bit/optimizer'|EMSCRIPTEN_NATIVE_OPTIMIZER = ''|" /emsdk/.emscripten \
 && cd /${TRUEBIT_DIR}/wasm-ports \
 && sh gmp.sh \
 && sh openssl.sh \
 && sh secp256k1.sh \
 && sh libff.sh \
 && sh boost.sh \
 && sh libpbc.sh
