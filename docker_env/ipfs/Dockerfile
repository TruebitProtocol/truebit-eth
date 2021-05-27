
FROM ipfs/go-ipfs:v0.8.0
HEALTHCHECK CMD netstat -an | grep 5001 > /dev/null; if [ 0 != $? ]; then exit 1; fi;