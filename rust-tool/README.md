## Compilation workflow for new Emscripten versions

As Emscripten is trying to move in the direction of WASI, WASM files resulted from transpiling via recent Emscripten versions will use both WASI and Emscripten APIs.  At the moment, Truebit lacks support for WASI APIs, so code transpiled with recent Emscripten versions will fail to run on Truebit.  The following presents some workarounds to this issue for Rust code.  You may wish to refer to this [example](https://github.com/TruebitProtocol/truebit-eth#building-your-own-tasks) as a template when compiling your own Rust tasks.

## How does it work?

When transpiling from Rust to WASM via Emscripten, the resulting WASM file has two types of imports:
`env` imports, provided via Emscripten APIs, and `wasi` imports, provided via WASI APIs
(since WASI is not stable yet, several different names might appear: `wasi_unstable`, `wasi_snapsot_preview1`, ...).

Truebit doesn't support the WASI APIs out of the box, so there is a need to manually implement and make available the required WASI APIs in Truebit's WASM runtime.
To make this happen, using the `wasm2wat` and `wat2wasm` utilities, the WASI imports should be changed to regular `env` imports in the WAT representation of the WASM file
and then implementations for those APIs should be provided in `filesystem.c` of `wasm-module-wrapper` so that the APIs will be available at runtime.

At the moment, `fd_environ_get`, `fd_environ_sizes_get`, `fd_fdstat_get`, `fd_write` and `fd_close` are the WASI APIs provided in this workaround,
although additional APIs can be easily supported via similar changes.

## Dependencies

Although fixed Emscripten and Rust versions are used here, it should be possible to use any other versions as long as all WASI APIs are made available at runtime.

The directory structure needs to be as follows:
```
| rust_project_dir
    | ...
    | data
      | input.txt
      | output.txt
    | build.sh
    | run.sh
| emsdk
| ocaml-offchain
|`wasm-module-wrapper
```
Note that the [Docker container](https://hub.docker.com/r/truebitprotocol/truebit-eth) already contains the required `emsdk` installation as well as a symlink to `ocaml-offchain` in its top-level directory.  You may clone and run a modified version of `wasm-module-wrapper` as follows:
```
git clone https://github.com/georgeroman`wasm-module-wrapper.git
cd`wasm-module-wrapper
npm install
# Optional - only needed if additional WASI APIs are to be supported
# Make sure Emsscripten 1.38.33 is activated before running this
./fs-script.sh
```

Make sure your project compiles with Rust version `1.40.0`:
```
rustup install 1.40.0
rustup default 1.40.0
rustup target add wasm32-unknown-emscripten
```

If you working outside the Docker container, you will need to install Emscripten (versions `1.38.33` (needed in `wasm-module-wrapper`) and `1.39.8` (needed for transpiling the Rust code to WebAssembly)):
```
git clone https://github.com/emscripten-core/emsdk
cd emsdk
./emsdk install 1.38.33
./emsdk install 1.39.8
```

To activate and make available any of these Emscripten versions, run the following:
```
./emsdk activate $VERSION
source ./emsdk_env.sh
```

## Building and testing

You should place the files `rust_workaround/build.sh` and `rust_workaround/run.sh` at the root of your Rust project and modify them to fit your needs.
Run `build.sh` (make sure Emscripten `1.39.8` is activated when doing this) to get your code compiled and have the resulting WASM modified so that it is compatible with Truebit.
Run `run.sh` to get your task running in Truebit's interpreter.
