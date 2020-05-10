FROM ubuntu:18.04
MAINTAINER Sami Mäkelä

SHELL ["/bin/bash", "-c"]

RUN apt-get  update \
 && apt-get install -y git cmake ninja-build g++ python wget ocaml opam libzarith-ocaml-dev m4 pkg-config zlib1g-dev psmisc sudo curl tmux nano npm apache2 \
 && opam init -y \
 && npm install -g ganache-cli mocha browserify

RUN cd bin \
 && wget https://github.com/ethereum/solidity/releases/download/v0.5.5/solc-static-linux \
 && mv solc-static-linux solc \
 && chmod 744 solc

RUN wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.8.23-c9427004.tar.gz \
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

RUN eval $(ssh-agent) && \
    ssh-add github_key && \
    ssh-keyscan -H github.com >> /etc/ssh/ssh_known_hosts

RUN git clone teutsch@github.com:TruebitFoundation/2020 \
 && cd 2020 \
 && npm i --production \
 && npm run deps \
 && npm run  compile \
 && rm -rf ~/.opam \
 && ln -s truebit-os . \
 && cd samples \
 && npm i \
 && ln -s /wasm-ports/samples /var/www/html \
 && cd pairing \
 && browserify public/app.js -o public/bundle.js \
 && solc --abi --optimize --overwrite --bin -o build contract.sol \
 && cd ../scrypt \
 && browserify public/app.js -o public/bundle.js \
 && solc --abi --optimize --overwrite --bin -o build contract.sol

RUN cd truebit-os \
 && git pull


# ipfs and eth ports
EXPOSE 4001 30303 80 8545

# docker build . -t truebit-os:latest
# docker run -it -p 3000:80 -p 8545:8548 -p 4001:4001 -p 30303:30303 -v ~/goerli:/root/.local/share/io.parity.ethereum truebit-os:latest /bin/bash
