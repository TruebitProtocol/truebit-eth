# Truebit WASM Proxy
This is a temporary solution on separating the truebit-os from the wasm-toolchain.
There are two files, `job_server.py` and `wasm.py`. The `wasm.py` file is a drop-in replacement to the wasm interpreter, but it requires a job server.
The objective here is the following:
1. Truebit OS sends a command to the wasm script. All arguments are passed in and recorded. The request is forwarded through TCP to the toolchain container which runs the `job_server.py`daemon.
2. The `job_server.py` deamon calls the `wasm` interpreter with the original input arguments. Note that we also sent over all files and have stored these in `/tmp`. We now run wasm and collect all files that have changed during the run (including the output)
3. We send back the resulting file structure to `wasm.py` and Truebit-os takes it from there.
4. TLDR: simple proxy for having the wasm interpreter "somewhere else".