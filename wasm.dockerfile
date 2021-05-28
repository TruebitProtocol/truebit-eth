FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow

RUN \
apt-get update && \
apt-get install \
python3 \
python3-pip \
libffi-dev \
libzarith-ocaml-dev \
m4 \
pkg-config \
zlib1g-dev \
curl \
unzip \
-y && \
mkdir -p /truebit-toolchain

# Install opam 1.2.2
RUN curl -sL https://raw.githubusercontent.com/ocaml/opam/1.2/shell/opam_installer.sh | sh -s /usr/local/bin


COPY src/wasm/ocaml-offchain /truebit-toolchain




RUN opam init --comp 4.05.0  -y && \
eval $(opam config env ) && \
opam update && \
opam upgrade && \
opam install cryptokit ctypes ctypes-foreign yojson ocamlbuild -y

RUN \
cd /truebit-toolchain/interpreter && \
eval $(opam config env ) && \
make && \
rm -rf ~/.opam

RUN pip3 install loguru pyzmq
COPY src/wasm/wasm/job_server.py /truebit-toolchain/job_server.py
RUN chmod +x /truebit-toolchain/job_server.py
EXPOSE 5700
ENTRYPOINT ["python3", "/truebit-toolchain/job_server.py"]