docker build -t truebit/os:latest -f truebit-os.dockerfile .
docker build -t truebit/wasm:latest -f wasm.dockerfile .
docker build -t truebit/ipfs:latest -f clef.dockerfile .
docker build -t truebit/clef:latest -f ipfs.dockerfile .
docker build -t truebit/examples:latest -f samples-legacy.dockerfile .