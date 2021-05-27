FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow

RUN \
apt-get update && \
apt-get install python3 python3-pip libffi-dev libzarith-ocaml-dev m4 opam pkg-config zlib1g-dev -y && \
mkdir -p /truebit-toolchain

# Install ocaml-offchain interpreter
RUN apt-get update && apt-get install -y libffi-dev libzarith-ocaml-dev m4 opam pkg-config zlib1g-dev


# 20.04 - --disable-sandboxing   18.04 USES OCAML < 2.0
COPY ocaml-offchain /truebit-toolchain
RUN opam init  -y && \
eval $(opam config env ) && \
opam update && \
opam upgrade && \
opam install cryptokit ctypes ctypes-foreign yojson ocamlbuild -y && \
cd /truebit-toolchain/interpreter && eval $(opam config env ) && make && \
rm -rf ~/.opam

RUN ls -la /truebit-toolchain/interpreter
RUN pip3 install loguru pyzmq
COPY job_server.py /truebit-toolchain/job_server.py
RUN chmod +x /truebit-toolchain/job_server.py
EXPOSE 5700
ENTRYPOINT ["python3", "/truebit-toolchain/job_server.py"]