<p align="center">
  <img src="./data/images/truebit-logo.png" width="650">
</p>

[![Docker Image](https://img.shields.io/docker/cloud/build/truebitprotocol/truebit-eth)](https://hub.docker.com/r/truebitprotocol/truebit-eth)
[![Docker size](https://img.shields.io/docker/image-size/truebitprotocol/truebit-eth/latest)](https://hub.docker.com/r/truebitprotocol/truebit-eth)
[![Truebit OS version](https://img.shields.io/github/package-json/v/TruebitProtocol/package-tracker?label=truebit-os)](https://downloads.truebit.io/)
[![Gitter](https://img.shields.io/gitter/room/TruebitProtocol/community?color=yellow)](https://gitter.im/TruebitProtocol/community)
[![Discord](https://img.shields.io/discord/681631420674080993?color=yellow&label=discord)](https://discord.gg/CpjSeGK4Px)

# What is Truebit?

## Documentation Update in Progress

For the latest documentation, please visit our documentation site:
[https://docs.truebit.io/v1docs](https://docs.truebit.io/v1docs)

_This README will be updated soon. Thank you for your patience._


<br><br>
[Truebit](https://truebit.io/) is a blockchain enhancement which enables smart contracts to securely perform complex computations in standard programming languages at reduced gas costs. As described in the [whitepaper](https://people.cs.uchicago.edu/~teutsch/papers/truebit.pdf) and this graphical, developer-oriented [overview](https://medium.com/truebit/truebit-the-marketplace-for-verifiable-computation-f51d1726798f), Task Givers can issue computational tasks while Solvers and Verifiers receive remuneration for correctly solving them.  You may wish to familiarize yourself with the installation instructions [user guide](https://docs.truebit.io/v1docs/getting-started/master) before proceeding.

Feel free to browse the [legacy wiki](https://github.com/TruebitProtocol/wiki), contribute to this repo's wiki, or check out these classic development blog posts:
* [Developing with Truebit: An Overview](https://medium.com/truebit/developing-with-truebit-an-overview-86a2e3565e22)
* [Using the Truebit Filesystem](https://medium.com/truebit/using-the-truebit-filesystem-f6a5d4ac9604)
* [Truebit Toolchain & Transmute](https://medium.com/truebit/truebit-toolchain-transmute-4984928364a7)
* [Writing a Truebit Task in Rust](https://medium.com/truebit/writing-a-truebit-task-in-rust-6d96f2ee0a4b)
* [JIT for Truebit](https://medium.com/truebit/jit-for-truebit-e5299afc72d8)

In addition, Truebit's [Reddit](https://www.reddit.com/r/truebit/) channel features links to some excellent introductions and mainstream media articles about Truebit.  If you'd like to speak with developers working on this project, come say hello on Truebit's [Gitter](https://gitter.im/TruebitProtocol/Lobby) and [Discord](https://discord.gg/CzpsQ66) channels.


## Quickstart guide: computational playground

This tutorial demonstrates how to get started with Truebit using Ethereum mainnet or hardhat (testnet) to solve, verify, issue, and build tasks. Please refer to this guide for step by step installation instructions.

## GETTING STARTED

Follow the [getting started] (https://docs.truebit.io/v1docs) guide to learn about:<br>
-Install Truebit on Ethereum<br>
-Truebit on Ethereum Structure<br>
-Start Docker container<br>
-Create a Wallet<br>
-Synchronize the Ethereum Node<br>
-Start a Truebit on Ethereum Terminal for Each Role<br>
-Start Truebit on Ethereum<br>
-Purchase TRU tokens<br>
-Check Balances<br>
-Purchase Solver License<br>
-Start Solve and Verify<br>
-IPFS connection for distributed file sharing<br>


## Sample tasks via smart contracts

In general, Dapps will issue tasks from smart contracts rather than the Truebit OS command line.  This allows Truebit to call back to the smart contract with a Truebit-verified solution.  Typically the Task Owner smart contract fixes the task function code during deployment while the Task Submitter puts forth the function inputs at runtime.  To demonstrate this method, we deploy and issue some tasks that are preinstalled in your container.  One can deploy each of the samples onto the blockchain as follows.
```bash
cd /truebit-eth/wasm-ports/samples
sh deploy.sh
```
To run a sample task, `cd` into that directory and run `node send.js` as explained below.  You may wish to edit `../deploy.js` or `send.js` by replacing the '`0`' in `accounts[0]` with the index of your desired Geth account.  

### Scrypt (C++)
```bash
cd /truebit-eth/wasm-ports/samples/scrypt
node send.js <text>
```
Computes scrypt.  The string is extended to 80 bytes. See the source code [here](https://github.com/TruebitProtocol/truebit-eth/blob/master/wasm-ports/samples/scrypt/scrypthash.cpp).  Originally by @chriseth.

### Bilinear pairing (C++)
```bash
cd /truebit-eth/wasm-ports/samples/pairing
node send.js <text>
```
For `<text>`, enter a string with more than 32 characters.  This example uses the `libff` library to compute bilinear pairings for a bn128 curve. It reads two 32 byte data pieces `a` and `b` which are used like private keys to get `a*O` and `b*O`. Then a bilinear pairing is computed. The result has several components, and one of them is posted as output. (To be clear, the code just shows that `libff` can be used to implement bilinear pairings with Truebit).
See the source code [here](https://github.com/TruebitProtocol/truebit-eth/blob/master/wasm-ports/samples/pairing/pairing.cpp).

### Chess (C++)
```bash
cd /truebit-eth/wasm-ports/samples/chess
node send.js <text>
```
This example checks moves in a game of chess. Players could use a state channel to play a chess match, and if there is a disagreement, then the game sequence can be posted to Truebit. This method will always work for state channels because both parties have the data available. See the source code [here](https://github.com/TruebitProtocol/truebit-eth/blob/master/wasm-ports/samples/chess/chess.cpp).
The source code doesn't implement all the rules of chess, and is not much tested.

### Validate WASM file (Rust)
```bash
cd /truebit-eth/wasm-ports/samples/wasm
node send.js <wasm file>
```
Uses `parity-wasm` to read and write a WASM file.  See the source code [here](https://github.com/TruebitProtocol/truebit-eth/blob/master/wasm-ports/samples/wasm/src/main.rs).

### Size of video packets in a file (C)
```bash
cd /truebit-eth/wasm-ports/samples/ffmpeg
node send.js input.ts
```
See the source code [here](https://github.com/mrsmkl/FFmpeg/blob/truebit_check/fftools/ffcheck.c).


# Building your own tasks
We now explore the Truebit Toolchain.  Each of the samples below produces a task code file called `task.wasm`, and each such file is produced by running a script called `compile.sh`.  You can use the `compile.sh` files as templates for generating your own tasks. Inspect sample source codes and their respective compile scripts [here](https://github.com/TruebitProtocol/truebit-eth/tree/master/wasm-ports/samples).  Each compile script first compiles C, C++, or Rust source code, along with included library dependencies, to a pair of WebAssembly JavaScript runtime files using [WASI-SDK](https://github.com/WebAssembly/wasi-sdk).  Truebit's [Wasm module wrapper](https://github.com/TruebitProtocol/truebit-eth/tree/master/wasm-module-wrapper) then converts these files into a WebAssemebly format executable in Truebit.  Here are is a helpful, legacy [tutorial](https://github.com/TruebitProtocol/truebit-eth/tree/master/wasm-ports/samples/scrypt/README.md) for creating and deploying Truebit tasks as well as a [demo video](https://www.youtube.com/watch?v=dDzPCMBlZN4) illustrating this process.

## Compiling from C/C++
You should now be able to re-compile the sample tasks yourself in C++ (chess, scrypt, pairing), and C (ffmpeg) below.
```bash
cd /truebit-eth/wasm-ports/samples/chess
sh compile.sh
cd /truebit-eth/wasm-ports/samples/scrypt
sh compile.sh
cd /truebit-eth/wasm-ports/samples/pairing
sh compile.sh
cd /truebit-eth/wasm-ports/samples/ffmpeg
sh compile.sh
```
Note that `sh compile.sh` will rebuild both the `build` and `dist` directories.

## Compiling from Rust
For Rust tasks, take a look @georgeroman's [walk-through](
https://github.com/TruebitProtocol/truebit-eth/tree/master/rust-tool).  You can use this guide to compile the `/truebit-eth/wasm-ports/samples/wasm` task via the steps below.  First, set up the Rust compiler.
```bash
ipfs init
```

Then you can recompile the Rust sample task as follows.
```bash
mv /truebit-eth/wasm-ports/samples/wasm /
cp /truebit-eth/rust-tool/build.sh /wasm
sed -i "s|rust_project_name=REPLACE_ME|rust_project_name=wasm_sample|" /wasm/build.sh
cd /wasm
rm -r build dist target task.wasm
sh compile.sh
```

## Runtime
Once you have compiled your task to Truebit-flavored WebAssmebly, try using the files `contract.sol`, and `send.js`, and `../deploy.js` as templates for issuing your own tasks directly from smart contracts.  The API reference [below](#Contract-API-reference) will help you navigate through these templates.  

When building and executing your own tasks, you may have to adjust some of the interpreter execution parameters (within range 5 to 30 exclusive), including:

`memory-size`: depth of the Merkle tree for memory

`table-size`: depth of Merkle tree for the call table

`globals-size`: depth of Merkle tree for the globals table

`stack-size`: depth of Merkle tree for the stack

`call-stack-size`: depth of Merkle tree for the call stack

Try adjusting `memory-size` first.  Greater parameters make the task more likely to execute.  See this [file](https://github.com/TruebitProtocol/truebit-eth/blob/master/ocaml-offchain/interpreter/main/main.ml#L138) for a complete list of interpreter options.


# Native installation
You may wish to experiment with this tutorial on your native command line rather than running it inside the Docker container.  To set up natively, first install [git](https://github.com/git-guides/install-git) and clone the Truebit repo.
```bash
git clone https://github.com/TruebitProtocol/truebit-eth
```
## Running samples natively
A Node.js [installation](https://nodejs.org/en/download/package-manager/) is a prerequisite for running the smart contract samples. Once you have [confirmed](https://www.npmjs.com/get-npm) that your Node.js installation includes npm, install Truebit's node packages from the Truebit repository's top-level directory:
```bash
cd truebit-eth
npm i
```
You can then deploy the sample task according to the instructions [above](#Sample-tasks-via-smart-contracts).  Truebit toolchain task compilations should be done inside the Docker container as native setup is relatively [complex](https://github.com/TruebitProtocol/truebit-eth/blob/master/Dockerfile).

## Running Truebit OS natively

You will need Clef, Geth, IPFS, and Truebit OS.

### Installation
To get started, install both [Geth](https://geth.ethereum.org/docs/install-and-build/installing-geth) & [IPFS](https://docs.ipfs.io/install/command-line/) natively (not in the Docker container).  Be sure to install a version of Geth that includes Clef.  Then download a pre-built Truebit OS executable here:

<https://downloads.truebit.io>

Choose from Linux, MacOS, or Windows flavors, and paste your chosen executable into the top level of the `truebit-eth` directory.  This downloads page contains the latest Truebit OS version, and you should keep your local copy updated to avoid client errors.  Truebit OS displays your local version at startup, and you can compare this against the latest one listed in the badge at the top of this README file.  For consistency with the Docker container, the steps [below](#Starting-up) assume that you rename your executable file to `truebit-os`, however you may choose any name for your downloaded file.

You may need to give your system permission to execute the `truebit-os` download.  In MacOS, for example, this can be done via the following commands.
```bash
mv truebit-macos truebit-os
chmod 755 truebit-os
```
If running `./truebit-os` in MacOS returns a pop-up error like: “truebit-os” cannot be opened because the developer cannot be verified, go to System Preferences -> Security & Privacy and where it says: "truebit-os" was blocked from use because it is not from an identified developer, choose "Allow Anyway."

Next, build the Truebit WebAssmebly interpreter from source as described below.

#### macOS interpreter install
In macOS, once [Brew](https://brew.sh/) is installed, one can install the interpreter as follows, starting from the `truebit-eth` directory:
```bash
brew install libffi ocaml ocamlbuild opam pkg-config
opam init -y
eval $(opam config env)
opam install cryptokit ctypes ctypes-foreign yojson -y
cd ocaml-offchain/interpreter
make
```
If you previously installed an older version of OCaml, you may need to run `ocaml update`, `ocaml upgrade`, and/or `brew upgrade`.  You can also get a fresh install by removing `~/.opam`.

#### Linux interpreter install
From the `truebit-eth` directory, use the following Ubuntu install (or modify it to suit your Linux flavor).
```bash
apt-get update
apt-get install -y libffi-dev libzarith-ocaml-dev m4 opam pkg-config zlib1g-dev
opam init -y
eval `opam config env`
opam update
opam install cryptokit ctypes ctypes-foreign yojson -y
cd ocaml-offchain/interpreter
make
```

#### Windows interpreter install
Follow the patterns above for Linux and macOS.  You may wish to use a Linux emulator.

### Starting up
We now walk through the steps to start IPFS, Clef, Geth, and then Truebit-OS.

By default, MacOS stores Clef files in `~/Library/Signer/` and Geth files in `~/Library/Ethereum/`. These locations differ from the location in the linux-based Docker container, which are `~/.clef` and `~/.geth`, `/mainnet.sh` startup templates. For testing purposes use [local fork](https://docs.truebit.io/v1docs/getting-started/synchronize-the-ethereum-node) This means that in MacOS you'll probably find Clef's IPC socket at:
```bash
~/Library/Signer/clef.ipc
```
Geth's IPC socket at one of these:
```bash
~/Library/Ethereum/geth.ipc
```
and the keystore files at one of these:
```bash
~/Library/Ethereum/keystore
```
The `--chainid` for mainnet is still 1.

For Ethereum mainnet, it might look like this:
```bash
ipfs daemon &
clef --advanced --rules ~/Library/Signer/ruleset.js --chainid 1
geth console --syncmode light --signer ~/Library/Signer/clef.ipc
./truebit-os -p ~/Library/Ethereum/geth.ipc
```
For Linux, try one of the following.
```bash
ipfs daemon &
clef --advanced --rules ~/.clef/ruleset.js --chainid 1GörliGörli
geth console --syncmode light --signer ~/.clef/clef.ipc
./truebit-os -p ~/.ethereum/geth.ipc
```
For Windows, follow the templates above.

# Contract API reference

The following reference highlights some key [Solidity](https://solidity.readthedocs.io/) functions that you may wish to use in your own smart contracts or interact with via [web3.js](https://web3js.readthedocs.io/).  For testing purposes use [local fork](https://docs.truebit.io/v1docs/getting-started/synchronize-the-ethereum-node).  An analogous file for Ethereum mainnet appears in the same directory.  The `tru` token contract follows the standard [ERC-20 interface](https://docs.openzeppelin.com/contracts/3.x/api/token/erc20#IERC20).

Below is a simple "hello world" JavaScript example which prints task data from Truebit's `fileSystem` and `incentiveLayer`.
```js
const fs = require('fs')
const Web3 = require('web3')
const net = require('net')
const web3 = new Web3('/root/.ethereum/mainnet/geth.ipc', net)

// Get contract artifacts
let artifacts = JSON.parse(fs.readFileSync('/truebit-eth/wasm-client/mainnet.json'))
let FileSystem = new web3.eth.Contract(artifacts.fileSystem.abi, artifacts.fileSystem.address)
let IncentiveLayer = new web3.eth.Contract(artifacts.incentiveLayer.abi, artifacts.incentiveLayer.address)

// Sample contract interaction
let example
(async () => {
  let taskID = '0x50ee4af6810cf64ea04c1f9818101a200f3b8c00c4f6a5e85a14b327a1f8d03f'
  let taskInfo = await IncentiveLayer.methods.taskParameters(taskID).call()
  console.log(taskInfo)
  let bundleID = taskInfo.bundleId
  let codeFileID = await FileSystem.methods.getCodeFileId(bundleID).call()
  console.log(await FileSystem.methods.vmParameters(codeFileID).call())
  process.exit(1)
})()
```
To execute the example above or the [auxiliary functions](#Preparing-task-inputs) in the next section, first [install](https://nodejs.org/en/download/package-manager/) Node.js and npm, [check](https://www.npmjs.com/get-npm) your installations, and install the prerequisite packages:
```bash
npm i truebit-util web3
```
Each code template can then be pasted into a `.js` file and run using Node.js, e.g. `node example.js`. 
The following script provides an additional template for interacting with Truebit's smart contract API.
```bash
truebit-eth/wasm-ports/samples/deploy.js
```
For a template interaction with Solidity.
```bash
truebit-eth/wasm-ports/samples/scrypt/contract.sol
truebit-eth/wasm-ports/samples/scrypt/send.js
```


## Preparing task inputs

We present three JavaScript functions and one Truebit OS method to assist in preparing code and data for use in Truebit.  Their uses will become clear in the [creating files](#creating-files) section below.   In order to run the following code templates, your working directory must include a data file called `example.txt` containing the input you wish to process.

### getRoot
When writing CONTRACT and IPFS files, one must tell Truebit the [Merkle root](https://en.wikipedia.org/wiki/Merkle_tree) of the data.  Such a root for a file `example.txt` may be computed using the following [web3.js](https://github.com/ethereum/web3.js) template.

```js
const fs = require('fs')
const merkleRoot = require('truebit-util').merkleRoot.web3
const Web3 = require('web3')
const web3 = new Web3('http://localhost:8545')

function getRoot(filePath) {
  let fileBuf = fs.readFileSync(filePath)
  return merkleRoot(web3, fileBuf)
}

let root = getRoot("./example.txt")
console.log(root)
```

### getSize
Truebit also needs to know the size of the file being created.  Size can be computed as follows in [web3.js](https://github.com/ethereum/web3.js):
```js
const fs = require('fs')

function getSize(filePath) {
  let fileBuf = fs.readFileSync(filePath)
  return fileBuf.byteLength
}

let size = getSize("./example.txt")
console.log(size)
```

### uploadOnchain
CONTRACT files should be created with [web3.js](https://web3js.readthedocs.io/en/v1.2.0/web3-eth-contract.html#new-contract) using the template function `uploadOnchain` below.  This function returns the contract address for the new CONTRACT file prefixed with a string needed for retrieval.  You must be connected to an Ethereum-compatible backend, (e.g. geth) in order to run this function.
```js
const fs = require('fs')
const Web3 = require('web3')
const net = require('net');
const web3 = new Web3('/root/.ethereum/mainnet/geth.ipc', net)

async function uploadOnchain(filePath) {

  let fileBuf = fs.readFileSync(filePath)
  let sz = fileBuf.length.toString(16)
  if (sz.length == 1) sz = "000" + sz
  else if (sz.length == 2) sz = "00" + sz
  else if (sz.length == 3) sz = "0" + sz

  let init_code = "61" + sz + "600061" + sz + "600e600039f3"
  let hex_data = Buffer.from(fileBuf).toString("hex")

  let contract = new web3.eth.Contract([])
  let accounts = await web3.eth.getAccounts()
  deployedContract = await contract.deploy({ data: '0x' + init_code + hex_data }).send({ from: accounts[0], gas: 1000000 })
  return deployedContract.options.address
}

let contractAddress = uploadOnchain("./example.txt")
contractAddress.then(address => console.log(address))
```

### Obtaining codeRoot

Truebit requires a `codeRoot` input when registering a .wasm or .wast program file to Truebit's file system.  The `codeRoot` for a task program file can be obtained inside Truebit OS using the `task initial` command and read off from the `vm.code` entry. In order to use the template command below, create a task .json.  Be sure to run `task initial` with the same virtual machine parameters that you plan to use when you later issue the task.
```sh
truebit-os:> task -f scrypt.json initial
[03-04 19:05:12] info: TASK GIVER: Created local directory: /truebit-eth/tmp.giver_kquvus9u7680
Executing: ./../wasm-client/ocaml-offchain/interpreter/wasm -m -disable-float -input -memory-size 20 -stack-size 20 -table-size 20 -globals-size 8 -call-stack-size 10 -file output.data -file input.data -wasm task.wasm
{
  vm: {
    code: '0xef34a351f42869ed0a1c4f5ba39f4be2377415082083f18592d858bc4361629b',
    stack: '0xb4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d30',
    memory: '0xb4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d30',
    input_size: '0x7c047c6a0b7e3f293efb6009eca04353577f88f7a88afd4b6d53c11d724c442f',
    input_name: '0xd3e24e0303f49b3dd3032fa2523603b320c2b2b0eea3693532c6401d315e8a32',
    input_data: '0xb9646f6bfbecf908827f695715a6774c4eb652c305f9da846d12157eaed6b428',
    call_stack: '0xb4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d30',
    globals: '0xb4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d30',
    calltable: '0x7bf9aa8e0ce11d87877e8b7a304e8e7105531771dbff77d1b00366ecb1549624',
    calltypes: '0xb4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d30',
    pc: 0,
    stack_ptr: 0,
    call_ptr: 0,
    memsize: 0
  },
  hash: '0x60d2429c93b96f2ccc81b06525dfb5538fe18ef096dee42834562fcfedadfb91'
}
```
In this example, the `codeRoot` of `task.wasm` is `0xc8ada82e770779e03b2058b5e0b9809c0c2dbbdc6532ebf626d1f03b61e0a28d`.

## fileSystem API

Recall that Truebit reads and writes three [file types], 0: BYTES, 1: CONTRACT, and 2: IPFS.  Truebit stores BYTES file contents as bytes32 arrays.

### Creating files

We enumerate methods for creating Truebit files.

```solidity
function createFileFromBytes(string calldata name, uint nonce, bytes calldata data) external returns (bytes32);
```
`createFileFromBytes` returns a fileID for a BYTES file called `name` with content `data`.  Here `nonce` is a random, non-negative integer that uniquely identifies the newly created file.  This method converts `data`and stores it as a bytes32 array.

*EXAMPLE:*

`bytes32 fileID = createFileFromBytes("input.data", 12345, "hello world!");`

```solidity
function createFileFromArray(string calldata name, uint nonce, bytes32[] calldata arr, uint fileSize) external returns (bytes32);
```
`createFileFromArray` returns a fileID for a BYTES file called `name` whose contents consist of a concatenation of array `arr`.  `nonce` can be any random, non-negative integer that uniquely identifies the new file. `fileSize` should be the total number of bytes in the concatenation of elements in `arr`, excluding any "empty" bytes in the final element.  This operation adds `arr` to contract storage.

*EXAMPLE:*

`bytes32[] memory empty = new bytes32[](0);`

`filesystem.createFileFromArray("output.data", 67890, empty, 0);`

```solidity
function addContractFile(string calldata name, uint size, address contractAddress, bytes32 root, uint nonce) external returns (bytes32);
```
`addContractFile` returns a fileID for a CONTRACT file called `name` using existing data stored at address `contractAddress`.  The data stored at `contractAddress` must conform to the [`uploadOnchain`](#uploadOnchain) format above, and `root` must conform to [`getRoot`](#getRoot).  The `size` parameter can be obtained using [`getSize`](#getSize).  `nonce` can be any random, non-negative integer that uniquely identifies the new file.

```solidity
function addIpfsFile(string calldata name, uint size, string calldata IPFShash, bytes32 root, uint nonce) external returns (bytes32);
```
`addIpfsFile` returns a fileID for an IPFS file called `name` using existing data stored at IPFS address `IPFShash`.  `Root` must conform to [`getRoot`](#getRoot), and the `size` parameter can be obtained using [`getSize`](#getSize).  `nonce` can be any random, non-negative integer that uniquely identifies the new file.

<!-- ```solidity
function addIPFSCodeFile(string memory name, uint size, string memory IPFShash, bytes32 root, bytes32 codeRoot, uint8 codeType, uint nonce) external returns (bytes32);
```
`addIPFSCodeFile` is similar to `addIPFSFile` except the file associated with `name` and `IPFShash` is designated as a code file (with `name` having .wasm or .wast extension).  The `codeRoot` can be obtained using the template [above](#obtaining-codeRoot) and is distinct from `root`.  The entered `codeType` must match the code type of the associated code file (0=WAST, 1=WASM). -->

<!-- A `codeRoot` is required for all WebAssembly program files, regardless of file type, but IPFS programs that deploy using `addIPFSCodeFile` need not use the `setCodeRoot` method.   -->

```solidity
function setCodeRoot(uint nonce, bytes32 codeRoot, uint8 codeType, uint8 stack, uint8 memory, uint8 globals, uint8 table, uint8 call) external;
```
`setCodeRoot` designates the fileID associated with `nonce` as an executable WebAssembly program file.  It also sets the virtual machine parameters to be used when executing the program file as part of a Truebit task.  `setCodeRoot` must be called from the same address that originally generated the fileID.

* See the directions [above](#obtaining-codeRoot) for calculating the appropriate `codeRoot`.  

* The entered `codeType` must match the code type of the associated code file (0=WAST, 1=WASM).  The code type selected should match the program file extension (.wasm or .wast).

* `stack`, `memory`, `globals`, `table`, `call`: These are the same VM parameters `stack-size`, `memory-size`, `globals-size`, `table-size`, `call-stack-size` discussed [above](#Building-your-own-tasks).  You may need to tweak these value to get your task to run, and try changing `memory-size` first.  The task is more likely to succeed with larger parameters.


### Naming files and bundles

```solidity
function calculateId(uint nonce) external view returns (bytes32);
```
`calculateId` returns the public fileID/bundleID for the corresponding `nonce` used when generating file/bundle content.  Truebit's filesystem derives fileID's and bundleID's identically from nonces.  Distinct addresses yield distinct fileID/bundleID's for the same `nonce`.

### Managing bundles

Bundles are the glue that hold together the files for tasks.  Each task has a single bundle which in turn references a program file, input files, and output files.

```solidity
function addToBundle(uint nonce, bytes32 fid) external;
```
`addtoBundle` adds a fileID `fid` to bundleID `makeBundle(nonce)`.  All files must be added to the bundle from the same account.  If the bundleID is unused, this method creates a new bundle.

```solidity
function finalizeBundle(uint nonce, bytes32 codeFileID) external returns (bytes32);
```
`finalizeBundle` returns the initial machine state for bundleID `makeBundle(nonce)` and readies the corresponding bundle for task deployment.  The caller designates a fileID `codeFileID` containing the .wasm (or .wast) program file.  This method must be called after all files have been added to the bundle by the same account that added the files.


Once a bundle has been created, one can access its contents via the following calls.

```solidity
function getCodeFileId(bytes32 bid) external view returns (bytes32);
```
`getCodeFileId` returns the fileID for bundle `bid`'s WASM code file.

```solidity
function getFileList(bytes32 bid) external view returns (bytes32[] memory);
```
`getFileList` returns an array of fileID's contained in the bundle `bid`.  If `bid` was created via standard task procedure, this array contains fileID's from the Task Giver but not the Solver.

```solidity
function getInitialHash(bytes32 bid) external view returns (bytes32);
```
`getInitialHash` returns the initial machine state corresponding to the code root and data files in bundle `bid`.  Solvers and Verifiers reconstruct this value locally from fileID and VM metadata before executing the task.

### Reading file data

The following methods retrieve data from fileID's.

<!-- ```solidity
function getByteData(bytes32 id) external view returns (bytes memory);
```
`getByteData` returns the data for fileID `id` as a string of bytes.  `id` must have file type BYTES. -->

```solidity
function getBytesData(bytes32 fid) external view returns (bytes32[] memory);
```
`getBytesData` returns the data for fileID `fid` as a bytes32 array, as it is stored in EVM contract storage.  `fid` must have file type BYTES.

```solidity
function getFormattedBytesData(bytes32 fid) external view returns (bytes memory);
```
`getFormattedBytesData` converts the data for fileID `fid` to a bytes type.  `fid` must have file type BYTES.

```solidity
function getContractCode(bytes32 fid) external view returns (bytes memory);
```
`getContractCode` returns the data for fileID `fid` as a string of bytes.  `fid` must have file type CONTRACT.

```solidity
function getContractAddress(bytes32 fid) external view returns (address);
```
`getContractAddress` returns the contract address associated with fileID `fid` where `fid` must have file type CONTRACT.

```solidity
function getIpfsHash(bytes32 fid) external view returns (string memory);
```
`getIpfsHash` returns the IPFS content address associated with fileID `fid` where `fid` must have file type IPFS.

```solidity
function vmParameters(bytes32 codeFileID) external view returns (bytes32, uint8, uint8, uint8, uint8, uint8, uint8);
```
`vmParameters` returns the Truebit virtual machine parameters associated with a program file fileID `codeFileID` in the following order, namely:
* 0: bytes32 [`codeRoot`](#Obtaining-codeRoot): initial machine state restricted to the program code
* 1: uint8 `codeType`: the program code format (0=WAST, 1=WASM)
* 2: uint8 `stackSize`: depth of Merkle tree for the stack
* 3: uint8 `memorySize`: depth of the Merkle tree for memory
* 4: uint8 `globalsSize`: depth of Merkle tree for the globals table
* 5: uint8 `tableSize`: depth of Merkle tree for the call table
* 6: uint8 `callSize`: depth of Merkle tree for the call stack

When calling `vmParameters` from web3.js, the created dictionary will automatically contain the above parameter names as attributes.

```solidity
function forwardData(bytes32 fid, address a) external;
```
`forwardData` sends the data associated with fileID `fid` to the contract at address `a`.  `fid` must have filetype BYTES, and the contract at address `a` must have a function called `consume` with interface `function consume(bytes32 fid, bytes32[] calldata dta) external;` that determines how to process the incoming data.

### Reading file metadata

The following methods retrieve metadata from files of any type.

```solidity
function getFileType(bytes32 fid) external view returns (uint);
```
`getFileType` returns an integer corresponding to the file type for fileID `fid`.  0 = BYTES, 1 = CONTRACT, and 2 = IPFS.

```solidity
function getRoot(bytes32 fid) external view returns (bytes32);
```
`getRoot` returns the authorative Merkle root associated with fileID `fid`'s content.  This Solidity function should not be confused with the example web3.js function [above](#getRoot) sharing the same name which computes a Merkle root from raw data.

```solidity
function getName(bytes32 fid) external view returns (string memory);
```
`getName` returns the file name associated with fileID `fid`.

<!-- ```solidity
function getNameHash(bytes32 id) external view returns (bytes32).
```
`getNameHash` returns the authoritative Merkle root associated with fileID's filename. -->


```solidity
function hashName(string memory filename) external returns (bytes32);
```
`hashName` returns the authoritative Merkle hash for `filename`.

```solidity
function getSize(bytes32 fid) external view returns (uint);
```
`getSize` returns the size of the data associated with fileID `fid` in bytes.  If `fid` is a BYTES file, it will return the actual file size.  For CONTRACT or IPFS files, it will return the size indicated by the file's creator.  This Solidity function should not be confused with the example web3.js function [above](#getSize) sharing the same name which computes file size from raw data.

## incentiveLayer API

We describe some methods used to issue tasks, manage payments, and enhance security.

### Creating tasks

Task Givers must specify task parameters, including filesystem, economic, virtual machine (VM), and output files when requesting a computation from the network.  The network uniquely identifies each task by its taskID.

```solidity
function createTaskId(bytes32 bundleID, uint minDeposit, uint solverReward, uint verifierTax, uint ownerFee, uint blockLimit) external returns (bytes32);
```
`createTaskId` stores task parameters to the Incentive Layer, including filesystem, economics and VM and assigns them a taskID.  The inputs are as follows:

* `bundleID`: the bundleID containing all files and VM parameters for the task
* `mindeposit`: the minimum TRU deposit required for a Solver or Verifier to participate
* `solverReward`: the reward paid to the Solver for correctly solving the task
* `verifierTax`: the payment to be split among all Verifiers
* `ownerFee`: the fee paid by the Task Submitter to the smart contract issuing the task (if any)
* `blockLimit`: the maximum number of blocks a Solver or Verifier spends executing the task


```solidity
function requireFile(bytes32 tid, bytes32 namehash, uint8 fileType) external;
```
`requireFile` tells the Solver to upload a file with `fileType` (0:BYTES, 1:CONTRACT, 2:IPFS) upon obtaining a solution to task `tid`. `tid`'s filesystem bundle must include an (empty) file whose file name hashes to `namehash`.  `namehash` can be computed using `hashName` from the fileSystem API.  This method must be called once for each output file after calling `createTaskId` but before calling `submitTask`.

```solidity
function submitTask(bytes32 tid) external payable;
```
`submitTask` broadcasts details of task `tid` to the Truebit network and requests a Solver solution.  This method finalizes all task parameters, and the Task Submitter pays the platform fee.

<!-- ```solidity
function submitEmitTask(bytes32 initTaskHash, uint8 codeType, bytes32 bundleId, uint minDeposit, uint solverReward, uint verifierTax, uint ownerFee, uint8 stack, uint8 mem, uint8 globals, uint8 table, uint8 call, uint limit) external payable returns (bytes32);
```
`submitEmitTask` combines `submitTask` with `commitRequiredFiles` into a single transaction.  It can be used when there are no output files.  This method may overload the EVM when called from a smart contract. -->

### Managing tokens

```solidity
function makeDeposit(uint amount) external returns (uint);
```
`makeDeposit` deposits `amount` TRU (in wei) from the sender's account into the Incentive Layer and returns the sender's resulting deposit balance.

```solidity
function withdrawDeposit(uint amount) external returns (uint);
```
`withdrawDeposit` withdraws `amount` TRU (in wei) from the Incentive Layer into the sender's account and returns the sender's resulting deposit balance.

```solidity
function getBondedDeposit(bytes32 tid, address account) external view returns (uint);
```
`getBondedDeposit` returns the amount of TRU (in wei) that `account` has bonded to task `tid`.

```solidity
function getUnbondedDeposit(address account) external view returns (uint);
```
`getUnbondedDeposit` returns the number of TRU (in wei) that `account` has stored in Truebit's incentive layer which are not bonded to any task.

```solidity
function PLATFORM_FEE_TASK_GIVER() external view returns (uint);
```
`PLATFORM_FEE_TASK_GIVER` returns the ETH platform fee (in wei) for Task Submitters.

### Browsing the task ledger

One may wish to browse inputs, outputs, and parameters for previously issued tasks.

```solidity
function taskParameters(tid) external view returns (bytes32, uint, uint, uint, uint, uint, address, address, address, bytes32, uint8);
```
`taskParameters()` returns a list of information about data inputs, participants, and economics for task `tid`.  The first 6 return outputs mirror those of the [`createTaskId`](#Creating-tasks) method, namely

* 0: bytes32 `bundleId`
* 1: uint `mindeposit`
* 2: uint `solverReward`
* 3: uint `verifierTax`
* 4: uint `ownerFee`
* 5: uint`blockLimit`

One can retrieve the list of input files by plugging `bundleID` into the [`getFileList`](#Managing-bundles) method.  The final 3 return outputs are as follows.

* 6: address `owner`: the address of the Task Owner's smart contract (if any)
* 7: address `submitter`: the address of the "human" Task Submitter's address (may be same as Task Owner)
* 8: address `selectedSolver`: the address of the Solver that performs the task
* 9: bytes32 `currentGame`: gameID for current verification game (if any)
* 10: uint8 `state`: task progress.  7 = successfully finalized, 8 = terminated with error

When calling `taskParameters` from web3.js, the created dictionary will automatically contain the above parameter names as attributes.

```solidity
function getSolverUploads(bytes32 tid) external view returns (bytes32[] memory);
```
`getSolverUploads` returns the verified outputs uploaded by the Solver for task `tid` as a list of fileID's.  Note that the Merkle root returned by [`getRoot`](Reading-file-data) is authoritative, whereas the content address returned by [`getIpfsHash`](Reading-file-data) or [`getContractCode`](Reading-file-data) is just a hint.  Thus, when downloading an output from IPFS or a contract file, one should also compute its [Merkle root](#getRoot) to confirm correctness.  [`getBytesData`](Reading-file-data) is always authoritative.

```solidity
function getVerifierList(bytes32 tid) external view returns (address[] memory);
```
`getVerifierList` returns the list of Verifiers who checked task `tid`.


### Security

If a Solver reveals his private random bits before the designated time, anyone can call the method below to claim his deposit.  See the [Truebit whitepaper](https://people.cs.uchicago.edu/~teutsch/papers/truebit.pdf), Section A.1.
```solidity
function prematureReveal(bytes32 taskID, uint originalRandomBits) external;
```
`prematureReveal` slashes the Solver's deposit and transfers half of it to the caller of this method if both:
* a Solver has been selected but not yet instructed to reveal his solution in the clear, and
* the Solver's private `originalRandombits` match those of the `taskID`.


## Contract callbacks

Upon completion or cancellation of a task, Truebit will call back to the Task Owner's (contract) address with a result.  In order to process the result, the Task Owner's contract must include one or more of the following methods.

```solidity
function solved(bytes32 taskID, bytes32[] calldata files) external;
```
Truebit calls the Task Owner's `solved` method when `taskID` successfully terminates with a solution.  The input `files` will be an array consisting of fileID's for the Solver's uploaded solutions.


```solidity
function cancelled(bytes32 taskID) external;
```
Truebit calls the Task Owner's `cancelled` method when `taskID` terminates without a solution due to a Solver timeout, loss of verification game, blockLimit error, or prematureReveal.

  
# Windows and Mac considerations

If you are using Windows or Mac and its your first time clonning this repository, run the following git commands to 
ensure that the repo files are using the correct EOL config.

```
git rm --cached -r .
git reset --hard
```
