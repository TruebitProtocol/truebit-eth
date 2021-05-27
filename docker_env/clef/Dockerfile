#FROM golang:1.16-alpine as build

#ARG TAG="v1.10.3"

#RUN \
#apk add --no-cache make gcc musl-dev linux-headers git && \
#git clone https://github.com/ethereum/go-ethereum.git && \
#cd /go/go-ethereum && \
#git checkout $TAG && \
#env GO111MODULE=on go run build/ci.go install ./cmd/clef

FROM ethereum/client-go:alltools-stable as runtime
EXPOSE 8550

ENV USER=truebit
ENV UID=1000
ENV GID=1000
ENV USER_DIR=/home/truebit

RUN \
addgroup -S $USER

RUN adduser \
    --disabled-password \
    --gecos "" \
    --shell "/bin/bash" \
    --home "$USER_DIR" \
    --ingroup "$USER" \
    --no-create-home \
    --uid "$UID" \
    "$USER"

RUN apk add --no-cache ca-certificates python3 curl
#COPY --from=build /go/go-ethereum/build/bin/clef /usr/local/bin/clef

RUN mkdir -p $USER_DIR
COPY rules.js /rules/rules.js
COPY attest $USER_DIR/attest
RUN chown -R $USER:$USER $USER_DIR && chown -R $USER:$USER /rules
COPY entrypoint.py /entrypoint.py
RUN chmod +x /entrypoint.py
USER $USER

EXPOSE 8550

HEALTHCHECK CMD curl --fail http://localhost:8550/ || exit 1
ENTRYPOINT ["python3", "/entrypoint.py"]
