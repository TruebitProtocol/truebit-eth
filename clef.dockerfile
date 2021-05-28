FROM ethereum/client-go:alltools-stable as runtime
EXPOSE 8550

ENV BUILD_DATA_PATH=src/clef
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
COPY ${BUILD_DATA_PATH}/rules.js /rules/rules.js
COPY ${BUILD_DATA_PATH}/attest $USER_DIR/attest
RUN chown -R $USER:$USER $USER_DIR && chown -R $USER:$USER /rules
COPY ${BUILD_DATA_PATH}/entrypoint.py /entrypoint.py
RUN chmod +x /entrypoint.py
USER $USER

EXPOSE 8550

HEALTHCHECK CMD curl --fail http://localhost:8550/ || exit 1
ENTRYPOINT ["python3", "/entrypoint.py"]
