FROM ubuntu:18.04
MAINTAINER Sami Mäkelä

SHELL ["/bin/bash", "-c"]

RUN apt-get update \
 && apt-get install -y git cmake ninja-build g++ python wget ocaml opam libzarith-ocaml-dev m4 pkg-config zlib1g-dev apache2 psmisc sudo mongodb curl tmux nano \
 && opam init -y

RUN git clone https://github.com/urho3d/emscripten-sdk emsdk \
 && cd emsdk \
 && ./emsdk install sdk-1.37.36-64bit \
 && ./emsdk activate sdk-1.37.36-64bit \
 && ./emsdk install  binaryen-tag-1.37.36-64bit \
 && ./emsdk activate binaryen-tag-1.37.36-64bit

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

RUN sed -i 's|/emsdk/clang/e1.37.36_64bit|/usr/bin|' /root/.emscripten

COPY github_key .

RUN chmod 400 github_key \
 && eval $(ssh-agent) \
 && ssh-add github_key \
 && ssh-keyscan -H github.com >> /etc/ssh/ssh_known_hosts \
 && git clone git@github.com:TruebitFoundation/Truebit2020 \
 && cd Truebit2020 \
 && git pull git@github.com:TruebitFoundation/Truebit2020

RUN eval `opam config env` \
 && apt-get install libffi-dev \
 && opam update \
 && opam install cryptokit yojson ctypes ctypes-foreign -y \
 && cd Truebit2020/ocaml-offchain/interpreter \
 && make

RUN wget https://dist.ipfs.io/go-ipfs/v0.4.17/go-ipfs_v0.4.17_linux-amd64.tar.gz \
 && tar xf go-ipfs_v0.4.17_linux-amd64.tar.gz \
 && cd go-ipfs \
 && ./install.sh \
 && ipfs init \
 && cd / \
 && rm -rf go-ipfs*

RUN apt-get update \
 && apt-get install -y git cmake ninja-build g++ python wget ocaml opam libzarith-ocaml-dev m4 pkg-config zlib1g-dev psmisc sudo curl tmux nano npm apache2 \
 && opam init -y \
 && npm install -g ganache-cli mocha browserify

RUN cd bin \
 && wget https://github.com/ethereum/solidity/releases/download/v0.5.2/solc-static-linux \
 && mv solc-static-linux solc \
 && chmod 744 solc

RUN cd Truebit2020/jit-runner \
 && npm i

RUN source /emsdk/emsdk_env.sh \
 && cd /Truebit2020/emscripten-module-wrapper \
 && npm install \
 && ln -s /Truebit2020/emscripten-module-wrapper /root/emscripten-module-wrapper

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

RUN cd Truebit2020 \
 && npm i --production \
 && npm run deps \
 && npm run compile \
 && rm -rf ~/.opam

RUN source /emsdk/emsdk_env.sh \
 && cd /Truebit2020/wasm-ports/samples/pairing \
 && ( ipfs daemon & ) \
 && export EMCC_WASM_BACKEND=1 \
 && sh compile.sh \
 && cd ../wasm \
 && sh compile.sh \
 && cd ../scrypt \
 && sh compile.sh \
 && cd ../chess \
 && sh compile.sh

RUN source /emsdk/emsdk_env.sh \
 && cd /Truebit2020/wasm-ports/samples/ffmpeg \
 && ( ipfs daemon & ) \
 && sh compile.sh

RUN cd Truebit2020/wasm-ports/samples \
 && npm i


EXPOSE 4001 30303 80 8545
#docker build . -t truebit-toolchain:latest
