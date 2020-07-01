FROM ubuntu:18.04
MAINTAINER Sami Mäkelä

SHELL ["/bin/bash", "-c"]

RUN apt-get update \
 && apt-get install -y git cmake ninja-build g++ python wget ocaml opam libzarith-ocaml-dev m4 pkg-config zlib1g-dev psmisc sudo curl tmux nano npm apache2

RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash \
 && source ~/.nvm/nvm.sh \
 && nvm install node

RUN opam init -y \
 && npm install -g ganache-cli mocha@7.2.0 browserify

RUN cd bin \
 && wget https://github.com/ethereum/solidity/releases/download/v0.5.5/solc-static-linux \
 && mv solc-static-linux solc \
 && chmod 744 solc

RUN wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.9.14-6d74d1e5.tar.gz \
 && tar xf geth*tar.gz \
 && rm geth*tar.gz \
 && cd geth* \
 && cp geth /bin

RUN wget https://dist.ipfs.io/go-ipfs/v0.4.19/go-ipfs_v0.4.19_linux-amd64.tar.gz \
 && tar xf go-ipfs_v0.4.19_linux-amd64.tar.gz \
 && cd go-ipfs \
 && ./install.sh \
 && ipfs init \
 && cd / \
 && rm -rf go-ipfs*

COPY github_key .

RUN chmod 400 github_key \
 && eval $(ssh-agent) \
 && ssh-add github_key \
 && ssh-keyscan -H github.com >> /etc/ssh/ssh_known_hosts \
 && git clone git@github.com:TruebitFoundation/Truebit2020 \
 && cd Truebit2020 \
 && git pull git@github.com:TruebitFoundation/Truebit2020

RUN cd Truebit2020/jit-runner \
 && npm i

RUN cd Truebit2020 \
 && npm i --production \
 && npm run deps \
 #&& npm run compile \
 && rm -rf ~/.opam

RUN cd Truebit2020/wasm-ports/samples \
 && npm i \
 && cd pairing \
 && browserify public/app.js -o public/bundle.js \
 && solc --abi --optimize --overwrite --bin -o build contract.sol \
 && cd ../scrypt \
 && browserify public/app.js -o public/bundle.js \
 && solc --abi --optimize --overwrite --bin -o build contract.sol

RUN cd Truebit2020 \
 && source ~/.nvm/nvm.sh \
 && npm install @openzeppelin/cli \
# && mv contracts/dispute/Common.sol contracts/dispute/Common \
# && mv contracts/filesystem/ChunkManager.sol contracts/filesystem/ChunkManager.sol.old \
 && npx oz compile --optimizer on

#COPY compile.sh

# ipfs and eth ports
EXPOSE 4001 30303 80 8545

# docker build . -t truebit-os:latest
# docker run --rm -it truebit-os:latest /bin/bash
