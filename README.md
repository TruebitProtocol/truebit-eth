<p align="center">
  <img src="./images/truebit-logo.png" width="650">
</p>

[![Docker Image](https://img.shields.io/docker/cloud/build/truja/truebit-beta)](https://hub.docker.com/r/truja/truebit-beta)

# What is Truebit?
[Truebit](https://truebit.io/) is a blockchain enhancement which enables smart contracts to securely perform complex computations in standard programming languages at reduced gas costs.  This comprehensive Ethereum implementation includes everything you need to create (from C, C++, or Rust code), issue, solve, and verify Truebit tasks.  This repo includes the Truebit-OS command line [client](https://github.com/TrueBitFoundation/truebit-eth/tree/master/wasm-client) for solving and verifying tasks, [WASM ports](https://github.com/TrueBitFoundation/truebit-eth/tree/master/wasm-ports) and [Emscripten module wrapper](https://github.com/TrueBitFoundation/truebit-eth/tree/master/emscripten-module-wrapper) for generating them, the [off-chain interpreter](https://github.com/TrueBitFoundation/truebit-eth/tree/master/ocaml-offchain), as well as [sample tasks](##Sample-tasks-via-smart-contracts).  You can install Truebit using Docker or build it from source for Linux, MacOS, or Windows.

Feel free to browse the [legacy Wiki](https://github.com/TrueBitFoundation/wiki), contribute to this repo's wiki, or check out these classic development blog posts:
* [Developing with Truebit: An Overview](https://medium.com/truebit/developing-with-truebit-an-overview-86a2e3565e22)
* [Using the Truebit Filesystem](https://medium.com/truebit/using-the-truebit-filesystem-f6a5d4ac9604)
* [Truebit Toolchain & Transmute](https://medium.com/truebit/truebit-toolchain-transmute-4984928364a7)
* [Writing a Truebit Task in Rust](https://medium.com/truebit/writing-a-truebit-task-in-rust-6d96f2ee0a4b)
* [JIT for Truebit](https://medium.com/truebit/jit-for-truebit-e5299afc72d8)

If you would like to speak with developers working on this project, come say hello on Truebit's [Gitter](https://gitter.im/TrueBitFoundation/Lobby) channel.

# Table of contents
1. [Quickstart guide: computational playground](#Quickstart-guide-computational-playground)
2. [Solve and verify tasks](#Solve-and-verify-tasks)
3. [Getting data into and out of Truebit](#Getting-data-into-and-out-of-Truebit)
4. [Building your own tasks with the Truebit toolchain](#Building-your-own-tasks-with-the-Truebit-toolchain)
5. [Native installation](#Native-installation)
6. [Contract API reference](#Contract-API-reference)

# Quickstart guide: computational playground

This tutorial shows how to install Truebit, connect to Görli or Ethereum mainnet networks, solve, verify and issue tasks, and finally build your own tasks.  Use the following steps to connect to the Görli testnet blockchain and solve tasks with your friends!

## Install or update Truebit OS

Follow the following steps to run a containerized Truebit OS client for Solvers, Verifiers, and Task Givers on any system.  Docker provides a replicable interface for running Truebit OS and streamlines the installation process.  First, download and install [Docker](https://docs.docker.com/get-docker/).  Then run the following at your machine's command line.
```bash
docker pull truja/truebit-beta:latest
```

## Docker incantations

Building the image above will take some minutes, but thereafter running the container should give you a prompt instantly.  While you are waiting for the download to complete, familiarize yourself with the following three command classes with which you will access the Truebit network.

### "Start container"

We first open a new container with two parts:

1. **Truebit OS**. Solvers and Verifiers can solve and verify tasks via command-line interface.

2. **Truebit Toolchain** Task Givers can build and issue tasks.

Select a directory where you plan to usually run the Docker container and store your private keys and type the following, substituting `YYY` for the *full path* to a directory where you wish to cache files.  To get the full path for your current working directory in UNIX, type `pwd`.
```bash
docker run --network host -v YYY/truebit-docker-home:/root --rm -it truja/truebit-beta:latest /bin/bash
```
Docker will then store your Docker container's home directory files in the folder you specified as `truebit-docker-home`.  The incantation above avoids having to synchronize the blockchain and your accounts from genesis and also stores your IPFS "ID" for better connectivity when you later restart the container.

### "Open terminal window"

When you [connect to the network](###Connect-to-the-network), you will need to open multiple windows *in the same Docker container*.  Running Geth or IPFS locally or in a different container from Truebit OS will not work.  When it is time to open a new terminal window for your existing container, find the name of your container running `truja/truebit-beta:latest` by using `docker ps`, open a new local terminal window and enter the following at the command line.
```bash
docker exec -it _yourContainerName_ /bin/bash
```
_yourContainerName_ might look something like `xenodochial_fermat`.  If you instead wish to run all processes in a single terminal window, initiate `tmux` and create sub-windows by typing `ctrl-b "` or `ctrl-b %` and using `ctrl-b (arrow)` to switch between sub-windows.

You can share files between your native machine and the Docker container by copying them into your `truebit-docker-home` folder.  Alternatively, you may copy into (or out of) the container with commands of the following form.
```bash
docker cp truebit-eth/supersecret.txt f7b994c94911:/truebit-eth/supersecret.txt
```
Here `f7b994c94911` is the name of the container's ID.To exit a container, type `exit`.  Your container process will remain alive in other windows.

### "Connect to the network"

One must simultaneously run [Geth](https://geth.ethereum.org/) and [IPFS](https://ipfs.io/) nodes to communicate with the blockchain and collect data submitted to the network, respectively.  When you start up a new Truebit container, start IPFS in the background and configure the compiler with the following pair of commands (in this order).
```bash
source /emsdk/emsdk_env.sh
bash startup.sh
```
You can terminate IPFS at any time by typing `ipfs shutdown`.

Geth demands more nuanced setup compared to IPFS.  Below we'll connect to Truebit on the Görli testnet.  As we will see, connecting on Ethereum mainnet is quite similar.  Truebit OS automatically detects which Ethereum blockchain network you are connected to (Görli or Mainnet).

#### Initializing accounts

If you don't already have a local Görli account in your Docker container, create a new one inside the Docker container with the following command.
```bash
geth --goerli account new
```
Geth will prompt you for an account password.  You may wish to create more than one account.  Paste each of your account passwords on separate lines, in order, into a text file.  Drop this text file into your `geth-docker-cache` folder.  For example, your password file might have the name `supersecret.txt` and might look something like this:
```
truebit
task
solve
verify
```
Finally, fund your accounts!  You can obtain Görli ETH from one of the faucets below, or send your accounts ETH from your favorite wallet (e.g. [Metamask](https://metamask.io/) or [MyCrypto](https://mycrypto.com/)).

https://goerli-faucet.slock.it/

https://faucet.goerli.mudit.blog/

#### Connecting with Geth

In your Truebit Docker container, connect your account(s) to the Görli network using an incantation of the following form:
```bash
geth --goerli --rpc --unlock "0,1,2,3" --password /root/.ethereum/supersecret.txt --syncmode "light" --allow-insecure-unlock console
```
Here `0,1,2,3` denotes the indices of the accounts you wish to use with Truebit OS.  If we wanted to connect to mainnet instead of Görli, we would simply delete the term `--goerli` in the incantation above.  Your Geth client should now begin syncing with the network and be up to date within a minute.  If you are have trouble connecting to a light client peer, try the following.

1. Exit `geth` (`Ctrl-C` or `exit`) and re-run the `geth` incantation above.

2. Change your IP address.

3. Reconnect later, or consider running a full Ethereum node.

To view a list of connected addresses inside the `geth console`, type `personal.listWallets` at the Geth command line.

# Solve and verify tasks

We are now ready to run Truebit Solver and Verifier nodes.  Use an ["open terminal window"](###Open-terminal-window) incantation to connect to your Docker container in a terminal window separate from Geth.  Then start Truebit OS!
```bash
cd truebit-eth
./truebit-os
```
You should now see a new shell prompt.
```
THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. YOU MAY NOT MODIFY, REVERSE ENGINEER, DISASSEMBLE, DECOMPILE, OR ATTEMPT TO DERIVE THIS FILE'S SOURCE CODE.
  _____                         _       _   _       
 |_   _|  _ __   _   _    ___  | |__   (_) | |_   _
   | |   | '__| | | | |  / _ \ | '_ \  | | | __| (_)
   | |   | |    | |_| | |  __/ | |_) | | | | |_   _
   |_|   |_|     \__,_|  \___| |_.__/  |_|  \__| (_)

  _            _                _                            _  __       
 | |_ __ _ ___| | __  ___  ___ | |_   _____  __   _____ _ __(_)/ _|_   _
 | __/ _` / __| |/ / / __|/ _ \| \ \ / / _ \ \ \ / / _ \ '__| | |_| | | |
 | || (_| \__ \   <  \__ \ (_) | |\ V /  __/  \ V /  __/ |  | |  _| |_| |
  \__\__,_|___/_|\_\ |___/\___/|_| \_/ \___|   \_/ \___|_|  |_|_|  \__, |
                                                                   |___/
$ [09-08 00:20:00] info: Truebit OS 1.0.0 has been initialized on goerli network at block 3365229.
```

For a self-guided tour or additional options not provided in this tutorial, type `help` at the command line, and (optionally) include a command that you want to learn more about.  Here is a list of available commands:
```
help [command...]         Provides help for a given command.
exit                      Exits application.
accounts                  List available network accounts.
balance [options]         Show account balances.
bonus                     Display current per task bonus payout.
ipfsnode [options] <cmd>  Manage IPFS nodes.
license [options] <cmd>   Obtain a Solver license.
ps                        List active Solvers and Verifiers along with their games and tasks.
start [options] <cmd>     Start a Solver or Verifier.
stop <num>                Stop a Solver or Verifier. Get process numbers with 'ps'.
task [options] <cmd>      Submit a task or run a utility.
token [options] <cmd>     Swap ETH for TRU.  Deposit to or withdraw from incentive layer.
version                   Display Truebit OS version.
```

## Staking tokens

In order to start a Solver or Verifier, one must first stake TRU into the incentive layer.  Let's purchase 1000 TRU tokens for account 0.  Check the price using `token price`, then
```sh
token purchase -v 1000 -a 0
```
Now we can stake some of our TRU.
```sh
token deposit -v 500 -a 0
```
We can repeat this process for account 1, if desired.  We are ready to start a Verifier, but if we wish to run a Solver, there is one additional step.  We must purchase a Solver license with ETH.  Check the price using `license price`, then
```sh
license purchase -a 0
```
Finally, we can confirm account balances for ETH and TRU and the amount of TRU we have staked in Truebit's incentive layer.
```sh
balance -a 0
```

## Running Solvers and Verifiers

We can now start our Solver and Verifier as follows.
```sh
start solve -a 0
start verify -a 1
```
If the Solver and Verifier do not immediately find a task on the network, try issuing a sample task yourself.
```sh
task -f factorial.json submit -a 0
```
The Task Submitter address always has first right-of-refusal to solve its own task, so your Solver should pick this one up!  You can check progress of your Görli task here:

<https://goerli.etherscan.io/address/0x0E1Cb897F1Fca830228a03dcEd0F85e7bF6cD77E>

## Faster IPFS uploads and downloads

IPFS's peer-to-peer network can route data more efficiently when it knows where to find Truebit Task Submitters, Solvers, and Verifiers.  It is recommended to register your IPFS node with Truebit via the following command which makes it easier for others to find your node while you are issuing or solving tasks:
```
ipfsnode register
```
You can then try to discover other nodes on Truebit's network by running:
```
ipfsnode connect
```

## Logging sessions

The file `truebit-eth/combined.log.json` contains a log spanning across all Truebit OS terminals but does not include everything displayed on the terminal screens.  It is safe to delete this file.

If one wishes to record a more detailed log for a Truebit OS container, one can use a command of the following form to obtain the full terminal output:
```bash
./truebit-os 2>&1 | tee mylog.txt
```


# Getting data into and out of Truebit

Truebit can read and write data to three file types.

0. **BYTES.**  These are standard Ethereum bytes stored in Truebit's filesystem smart contract.  Note that Truebit does *not* read data from arbitrary smart contracts.

1. **CONTRACT.**  This method uses a smart contract whose program code consists of the task data itself.  This is not a typical contract deployment as the contract may not function.

2. **IPFS.** Truebit can read and write to IPFS, a peer-to-peer, content-addressed storage system.

Ethereum has a limit of 5 million gas per contract deploy (~ 24 kilobytes) and roughly the same limit for other transactions.  This means that larger files should always sit on IPFS.

## Writing task outputs via Truebit OS

Let's inspect a sample task meta file called `reverse.json` which can be found in the `/truebit-eth` directory:
```json
{
    "codeFile": {
      "path": "/data/reverse_alphabet.wasm",
      "fileType": "IPFS"
    },
    "dataFiles": {
      "/data/alphabet.txt": "CONTRACT",
      "/data/reverse_alphabet.txt": "BYTES"
    },
    "outputs": {
      "reverse_alphabet.txt": "BYTES"
    },
    "solverReward": "2",
    "verifierTax": "6",
    "minDeposit": "10",
    "stackSize": "14",
    "memorySize": "20",
    "globalsSize": "8",
    "tableSize": "8",
    "callSize": "10",
    "blockLimit": "1"
}
```
You can experiment with its filesystem configuration by adjusting parameters below.

1. `codeFile`.  This keyword specifies the compiled code that the Task Giver wishes to execute.  Truebit OS automatically detects code type based on the code file extension (.wasm or .wast), however the Task Giver must specify a file type for the code (BYTES, CONTRACT, or IPFS) telling Solvers and Verifiers where to find it.  Each task has exactly one `codeFile`.

2. `dataFiles`.  All input and output files for the task program must be listed under this keyword, and each must have a file type (BYTES, CONTRACT, or IPFS).

3. `outputs`.  The value(s) here are the subset of the data files which are produced and uploaded by the Solver.  In this example both the empty data file `/data/reverse_alphabet.txt` and the corresponding output file `reverse_alphabet.txt` have the same file type (BYTES), however in general they need not match.

4. `solverReward`, `verifierTax`, and `minDeposit` pertain to task economics.  The `solverReward` is the reward paid to the Solver for a correct computation, the `verifierTax` is the fee split among Verifiers, and `minDeposit` is the minimum unbonded deposit that Solvers and Verifiers must have staked in the Incentive Layer in order participate.  Note that the task owner fee is automatically 0 since the Task Submitter is always the Task Owner when deploying from Truebit OS.

5. `stackSize`, `memorySize`, `globalsSize`, `tableSize`, and `callSize`.  These are virtual machine parameters.  You may need to tweak `memorySize` when you create your own task.

6. `blockLimit`.  This is the length of time (in blocks) for which Solvers and Verifiers will attempt to run the task before reporting a timeout.

To run this example, enter the following commands in Truebit OS.
```sh
start solve
task -f reverse.json submit
```

## Sample tasks via smart contracts

In general, Dapps will issue tasks from smart contracts rather than the Truebit OS command line.  This allows Truebit to call back to the smart contract with a Truebit-verified solution.  To demonstrate this method, we deploy and issue some tasks that are preinstalled in your Truebit container.  One can deploy each of the samples onto the blockchain as follows.
```bash
cd wasm-ports/samples
sh deploy.sh
```
To run a sample task, `cd` into that directory and run `node send.js` as explained below.  You may wish to edit `../deploy.js` or `send.js` by replacing the '`0`' in `accounts[0]` with the index of your Geth account.  

### Scrypt
```bash
cd /wasm-ports/samples/scrypt
node send.js <text>
```
Computes scrypt.  The string is extended to 80 bytes. See the source code [here](https://github.com/TrueBitFoundation/truebit-eth/blob/master/wasm-ports/samples/scrypt/scrypthash.cpp).  Originally by @chriseth.

### Bilinear pairing
```bash
cd /wasm-ports/samples/pairing
node send.js <text>
```
For `<text>`, enter a string with more than 32 characters.  This example uses the `libff` library to compute bilinear pairings for a bn128 curve. It reads two 32 byte data pieces `a` and `b` which are used like private keys to get `a*O` and `b*O`. Then a bilinear pairing is computed. The result has several components, and one of them is posted as output. (To be clear, the code just shows that `libff` can be used to implement bilinear pairings with Truebit).
See the source code [here](https://github.com/TrueBitFoundation/truebit-eth/blob/master/wasm-ports/samples/pairing/pairing.cpp).

### Chess
```bash
cd /wasm-ports/samples/chess
node send.js <text>
```
This example checks moves in a game of chess. Players could use a state channel to play a chess match, and if there is a disagreement, then the game sequence can be posted to Truebit. This method will always work for state channels because both parties have the data available. See the source code [here](https://github.com/TrueBitFoundation/truebit-eth/blob/master/wasm-ports/samples/chess/chess.cpp).
The source code doesn't implement all the rules chess rules, and is not much tested.

### Validate WASM file
```bash
cd /wasm-ports/samples/wasm
node send.js <wasm file>
```
Uses `parity-wasm` to read and write a WASM file.  See the source code [here](https://github.com/TrueBitFoundation/truebit-eth/blob/master/wasm-ports/samples/wasm/src/main.rs).

### Size of video packets in a file
```bash
cd /wasm-ports/samples/ffmpeg
node send.js input.ts
```
See the source code [here](https://github.com/mrsmkl/FFmpeg/blob/truebit_check/fftools/ffcheck.c).

# Building your own tasks with the Truebit toolchain
If you haven't already, from your Truebit container, run the following commands (in order):
```bash
source /emsdk/emsdk_env.sh
bash startup.sh
```
You should now be able to compile the sample tasks yourself in C++ (chess, scrypt, pairing), and C (ffmpeg) below.
```bash
cd /truebit-eth/wasm-ports/samples/chess
sh compile.sh
cd ../scrypt
sh compile.sh
cd ../pairing
sh compile.sh
cd ../ffmpeg
sh compile.sh
```
For Rust tasks, take a look @georgeroman's [workaround](
https://github.com/TrueBitFoundation/truebit-eth/tree/master/rust_workaround).  You can use his guide to build the `../wasm` task via the steps below.
```bash
( ipfs daemon & )
mv /truebit-eth/wasm-ports/samples/wasm
cd /
git clone https://github.com/georgeroman/emscripten-module-wrapper.git
cd /emscripten-module-wrapper && npm install
/emsdk/emsdk activate 1.39.8
source /emsdk/emsdk_env.sh && source $HOME/.cargo/env
cd /wasm
npm i
sh compile.sh
```
Once you have the samples running, try using the files `compile.sh`, `contract.sol`, and `send.js`, and `../deploy.js` as templates for issuing your own tasks directly from smart contracts.  Alternatively, follow the .json template [above](#Writing-task-outputs-via-Truebit-OS) to launch your task within Truebit OS.   Here are is a helpful, legacy [tutorial](https://github.com/TrueBitFoundation/truebit-eth/tree/master/wasm-ports/samples/scrypt/README.md) for creating and deploying Truebit tasks as well as Harley's [demo video](https://www.youtube.com/watch?v=dDzPCMBlZN4) illustrating this process.

When building and executing your own tasks, you may have to adjust some of the interpreter execution parameters, including:

`memory-size`: depth of the Merkle tree for memory

`table-size`: depth of Merkle tree for the call table

`globals-size`: depth of Merkle tree for the globals table

`stack-size`: depth of Merkle tree for the stack

`call-stack-size`: depth of Merkle tree for the call stack

 See this [file](https://github.com/TrueBitFoundation/truebit-eth/blob/master/ocaml-offchain/interpreter/main/main.ml#L138) for a complete list of interpreter options.



# Native installation

You may wish to experiment with this tutorial on your native command line rather than running them inside the Docker container.  To set up natively, clone truebit-eth repo:
```bash
git clone https://github.com/TrueBitFoundation/truebit-eth
```
## Running samples at native command prompt
A [Node.js](https://nodejs.org/en/download/) installation is a prerequisite for running the smart contract samples.  If you are running MacOS, the software can be obtained via [Brew](https://formulae.brew.sh/formula/node).  Now install Truebit's node packages from the repository's top-level directory:
```bash
cd truebit-eth
npm i
```
Truebit toolchain task compilations should be done inside the Docker container as native setup is relatively [complicated](https://github.com/TrueBitFoundation/truebit-eth/tree/master/Dockerfile).

## Running Truebit OS natively

If you wish to run Truebit OS on the native machine, you will need to build the Truebit WASM interpreter from source.  You must also run both [Geth](https://geth.ethereum.org/docs/install-and-build/installing-geth) & [IPFS](https://docs.ipfs.io/install/command-line/) natively (not in the Docker container).  The instructions below assume that you are starting in the top level of the `truebit-eth` directory.  You will also want to download the Truebit OS executable from the Docker container using `docker cp`.  For Linux, copy `truebit-os`, for MacOS, copy `other-builds/truebit-macos`, and for Windows, copy `other-builds/truebit-win.exe`.  Paste your chosen executable into the top level of the `truebit-eth` directory.

### Ubuntu interpreter install
In Linux, your interpreter install might look something like the following:
```bash
apt-get install -y libffi-dev libzarith-ocaml-dev m4 opam pkg-config zlib1g-dev
opam init -y
eval `opam config env`
opam update
opam install cryptokit ctypes ctypes-foreign yojson -y
cd /ocaml-offchain/interpreter
make
```
Check the [Dockerfile](https://github.com/TrueBitFoundation/truebit-eth/tree/master/Dockerfile) for missing `apt-get` dependencies.  

### macOS interpreter install

In macOS, once [Brew](https://brew.sh/) is installed, one can install the interpreter as follows, starting from the truebit-eth directory:
```bash
brew install libffi ocaml ocamlbuild opam pkg-config
opam init -y
eval $(opam config env)
opam install cryptokit ctypes ctypes-foreign yojson -y
cd wasm-client/ocaml-offchain/interpreter
make
```
### Windows interpreter install

Follow the patterns above for Linux and macOS.


# Contract API reference

The following reference highlights some key [Solidity](https://solidity.readthedocs.io/) functions that you may wish to use in your own smart contracts or interact with via [web3.js](https://web3js.readthedocs.io/).  The files `truebit-eth/wasm-client/goerli.json`, `truebit-eth/wasm-ports/samples/deploy.js` reference the contracts named in the headers below.  The `tru` token contract follows the standard ERC-20 interface described [here](https://docs.openzeppelin.com/contracts/3.x/api/token/erc20#IERC20).

## fileSystem

Recall that Truebit reads and writes three [file types](#Getting-data-into-and-out-of-Truebit), 0: BYTES, 1: CONTRACT, and 2: IPFS.  Truebit stores BYTES file contents as bytes32 arrays.

### Auxiliary functions

We present three functions to assist in preparing data for use in Truebit.

#### getRoot
When writing CONTRACT and IPFS files, one must tell Truebit the [Merkle root](https://en.wikipedia.org/wiki/Merkle_tree) of the data.  Such a root for a file `example.txt` may be computed using the following [web3.js](https://github.com/ethereum/web3.js) template.

```js
const fs = require("fs")
const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.HttpProvider(host))
const merkleRoot = require('truebit-util').merkleRoot.web3

async function getRoot(filePath) {
  let fileBuf = fs.readFileSync(filePath)
  return merkleRoot(web3, fileBuf)
}

let root = getRoot("./example.txt")
```

#### getSize
Truebit also needs to know the size of the file being created.  This can be done as follows:
```js
const fs = require("fs")

async function getSize(filePath) {
  let fileBuf = await readFile(filePath)
  return fileBuf.byteLength
}

let size = getSize("./example.txt")
```

#### uploadOnchain
CONTRACT files themselves should be created with [web3.js](https://web3js.readthedocs.io/en/v1.2.0/web3-eth-contract.html#new-contract) using the template function `uploadOnchain` below.  This function returns the contract address for the new CONTRACT file prefixed with a string needed for retrieval.
```js
const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.HttpProvider(host))
const accounts = await web3.eth.getAccounts()

async function uploadOnchain(filePath) {
  let fileBuf = await readFile(filePath)

  let sz = fileBuf.length.toString(16)
  if (sz.length == 1) sz = "000" + sz
  else if (sz.length == 2) sz = "00" + sz
  else if (sz.length == 3) sz = "0" + sz

  let init_code = "61" + sz + "600061" + sz + "600e600039f3"
  let contract = new web3.eth.Contract([])
  let hex_data = Buffer.from(fileBuf).toString("hex")

  contract = await contract.deploy({ data: '0x' + init_code + hex_data }).send({ from: accounts[0], gas: 200000, gasPrice: web3.gp })
  return contract.options.address
}

let contractAddress = uploadOnchain("./example.txt")
```

#### obtaining codeRoot and hash

The `codeRoot` and `hash` for a task program file can be obtained inside Truebit OS using the `task initial` command, read off as `vm.code` and `hash` respectively:
```sh
$ task -f scrypt.json initial
[10-12 12:25:20] info: TASK GIVER: Created local directory: /Users/Shared/truebit/tmp.giver_fukrnufpj9g0
Executing: ./../wasm-client/ocaml-offchain/interpreter/wasm -m -disable-float -input -memory-size 20 -stack-size 20 -table-size 20 -globals-size 8 -call-stack-size 10 -file output.data -file input.data -wasm task.wasm
{
  vm: {
    code: '0xc8ada82e770779e03b2058b5e0b9809c0c2dbbdc6532ebf626d1f03b61e0a28d',
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
  hash: '0x156eca8fb73785621b1bf3a28354ee8e022275a1ac1ffedcc049b029480de4c5'
}
```
In this example, the `codeRoot` of `task.wasm` is `0xc8ada82e770779e03b2058b5e0b9809c0c2dbbdc6532ebf626d1f03b61e0a28d` and its `hash` is `0xa4a3ba42f33ca42ce51ecd61c7955239806d416e6d93ceb8416f686f2649f3ad`.

### creating files

We enumerate methods for creating Truebit files.

```solidity
function createFileFromBytes(string memory name, uint nonce, bytes calldata arr) external returns (bytes32);
```
`createFileFromBytes` returns a fileID for a BYTES file called `name` with content `data`.  Here `nonce` is a random, non-negative integer that uniquely identifies the newly created file.

*EXAMPLE:*

`bytes32 fileID = createFileFromBytes("input.data", 12345, "hello world!");`


```solidity
function createFileWithContents(string memory name, uint nonce, bytes32[] calldata arr, uint fileSize) external returns (bytes32);
```
`createFileWithContents` returns a fileID for a BYTES file called `name` whose contents consist of a concatenation of array `arr`.  `nonce` can be any random, non-negative integer that uniquely identifies the new file, and `fileSize` should be the total number of bytes in the concatenation of elements in `arr`, excluding any "empty" bytes in the final element.

*EXAMPLE:*

`bytes32[] memory empty = new bytes32[](0);`

`filesystem.createFileWithContents("output.data", 67890, empty, 0);`

```solidity
function addContractFile(string memory name, uint size, address contractAddress, bytes32 root, uint nonce) external returns (bytes32);
```
`addContractFile` returns a fileID for a CONTRACT file called `name` using existing data stored at address `contractAddress`.  The data stored at `contractAddress` must conform to the [`uploadOnchain`](####uploadOnchain) format above, and `root` must conform to [`getRoot`](####getRoot).  The `size` parameter can be obtained using [`getSize`](####getSize).  `nonce` can be any random, non-negative integer that uniquely identifies the new file.

```solidity
function addIPFSFile(string memory name, uint size, string calldata IPFShash, bytes32 root, uint nonce) external returns (bytes32);
```
`addIPFSFile` returns a fileID for an IPFS file called `name` using existing data stored at IPFS address `IPFShash`.  `Root` must conform to [`getRoot`](####getRoot), and the `size` parameter can be obtained using [`getSize`](####getSize).  `nonce` can be any random, non-negative integer that uniquely identifies the new file.

```solidity
function addIPFSCodeFile(string memory name, uint size, string memory IPFShash, bytes32 root, bytes32 codeRoot, uint nonce) external returns (bytes32);
```
`addIPFSCodeFile` is similar to `addIPFSFile` except the file designated by `name` and `IPFShash` is designated as a code file (with .wasm or .wast extension).  The `codeRoot` can be obtained using the template [above](####obtaining-codeRoot-and-hash).

```solidity
function setCodeRoot(uint nonce, bytes32 codeRoot) external;
```
`setCodeRoot` sets the `codeRoot` (see template [above](####obtaining-codeRoot-and-hash)) for the fileID corresponding to `nonce`.  `setCodeRoot` must be called from the same address that originally generated the fileID.  A `codeRoot` is required for all WebAssembly program files, regardless of file type, but IPFS programs that deploy using `addIPFSCodeFile` need not use the `setCodeRoot` method.

### managing bundles

Bundles are the glue that hold together the files for tasks.  Each task has a single bundle which in turn references a program file, input files, and output files.

```solidity
function makeBundle(uint num) external view returns (bytes32);
```
`makeBundle` returns a bundleID corresponding to the nonce `num`.  Distinct addresses will yield distinct bundleID's for the same `num`.

```solidity
function addToBundle(bytes32 bid, bytes32 fid) external;
```
`addtoBundle` adds a fileID `fid` to bundleID `bid`.

```solidity
function finalizeBundle(bytes32 bid, bytes32 codeFileID) external;
```
`finalizeBundle` adds the initial machine state to the bundleID `bid`.  The caller must designate a program file `codeFileID`.  This method must be called after all fileID's have been added to `bid`.


### reading file data

The following methods retrieve data from fileID's

<!-- ```solidity
function getByteData(bytes32 id) external view returns (bytes memory);
```
`getByteData` returns the data for fileID `id` as a string of bytes.  `id` must have file type BYTES. -->

```solidity
function getData(bytes32 id) external view returns (bytes32[] memory);
```
`getData` returns the data for fileID `id` as an bytes32 array, as it is stored in the EVM.  `id` must have file type BYTES.


```solidity
function getCode(bytes32 id) external view returns (bytes memory);
```
`getCode` returns the data for fileID `id` as a string of bytes.  `id` must have file type CONTRACT.

```solidity
function getContractAddress(bytes32 id) external view returns (address);
```
`getContractAddress` returns the contract address associated with fileID `id` where `id` must have file type CONTRACT.

```solidity
function getHash(bytes32 id) external view returns (string memory);
```
`getHash` returns the IPFS content address associated with fileID `id` where `id` must have file type IPFS.

```solidity
function forwardData(bytes32 id, address a) external;
```
`forwardData` sends the data associated with fileID `id` to the contract at address `a`.  `id` must have filetype BYTES, and the contract at address `a` must have a function called `consume` with interface `function consume(bytes32 id, bytes32[] calldata dta) external;` that determines how to process the incoming data.

### reading metadata

The following methods retrieve metadata from files of any type.

```solidity
function getByteSize(bytes32 id) external view returns (uint);
```
`getByteSize` returns the size of the data associated with fileID `id`, in bytes, as indicated by the file's creator.

```solidity
function getFileType(bytes32 id) external view returns (uint);
```
`getFileType` returns an integer corresponding to the file type for fileID `id`.  0 = BYTES, 1 = CONTRACT, and 2 = IPFS.

```solidity
function getName(bytes32 id) external view returns (string memory);
```
`getName` returns the file name associated with fileID `id`.

```solidity
function getRoot(bytes32 id) external view returns (bytes32);
```
`getRoot` returns the Merkle root associated with fileID `id`.

## incentiveLayer

We describe some methods used to issue tasks, manage payments, and enhance security.

### creating tasks

Task Givers must specify task parameters, including filesystem, economic, virtual machine (VM), and output files when requesting a computation from the network.  The network uniquely identifies each task by its taskID.

```solidity
function submitTask(bytes32 initTaskHash, uint8 codeType, bytes32 bundleId, uint minDeposit, uint solverReward, uint verifierTax, uint ownerFee, uint8 stack, uint8 mem, uint8 globals, uint8 table, uint8 call, uint blockLimit) external returns (bytes32);
```
`submitTask` stores task parameters to the Incentive Layer, including filesystem, economics and VM and assigns them a taskID.  The inputs are as follows:
* `initTaskHash`: initial machine state `hash` for the interpreter.  This `hash` can be obtained through Truebit OS as described [above](####obtaining-codeRoot-and-hash).
* `codeType`: The program file is either WAST or WASM as determined by the file extension.
* `bundleID`: The bundleID containing all fileID's for the task.
* `ownerFee`: The fee paid by the Task Submitter to the smart contract issuing the task.
* `mindeposit`, `solverReward`, `verifierTax`, `blockLimit`: See sample task [above](##Writing-task-outputs-via-Truebit-OS).
* `stack`, `mem`, `globals`, `table`, `call`: These are the VM parameters `stack-size`, `memory-size`, `globals-size`, `table-size`, `call-stack-size` discussed [above](#Building-your-own-tasks-with-the-Truebit-toolchain).

```solidity
function requireFile(bytes32 tid, bytes32 fid, uint8 fileType) external;
```
`requireFile` tells the Solver to upload fileID `fid` with file type `fileType` upon completion of task `tid`. `tid`'s filesystem bundle must include the file `fid`.  This method must be called once for each output file after calling `submitTask` but before calling `commitRequiredFiles`.

```solidity
function commitRequiredFiles(bytes32 id) external payable;
```
`commitRequiredFiles` broadcasts details of task `id` to the Truebit network and requests a Solver solution.  This method finalizes all task parameters, and the Task Submitter pays the liquidity fee.

```solidity
function submitEmitTask(bytes32 initTaskHash, CodeType codeType, bytes32 bundleId, uint minDeposit, uint solverReward, uint verifierTax, uint ownerFee, uint8 stack, uint8 mem, uint8 globals, uint8 table, uint8 call, uint limit) external payable returns (bytes32);
```
`submitEmitTask` combines `submitTask` with `commitRequiredFiles` into a single transaction.  It can be used when there are no output files.  This method may overload the EVM when called from a smart contract.

### token payments

```solidity
function makeDeposit(uint amount) external returns (uint);
```
`makeDeposit` deposits `amount` TRU (in wei) from the sender's account into the Incentive Layer and returns the sender's resulting deposit balance.

```solidity
function withdrawDeposit(uint amount) external returns (uint);
```
`withdrawDeposit` withdraws `amount` TRU (in wei) from the Incentive Layer into the sender's account and returns the sender's resulting deposit balance.

```solidity
function getBondedDeposit(bytes32 id, address account) external view returns (uint);
```
`getBondedDeposit` returns the amount of TRU (in wei) that `account` has bonded to task `id`.

```solidity
function getLiquidityFeeTaskGiver() external view returns (uint);
```
`getLiquidityFeeTaskGiver` returns the ETH liquidity fee (in wei) for Task Submitters.

### security

If a Solver reveals his private random bits before the designated time, anyone can call the method below to claim his deposit.  See the [Truebit whitepaper](https://people.cs.uchicago.edu/~teutsch/papers/truebit.pdf), Section A.1.
```solidity
function prematureReveal(bytes32 taskID, uint originalRandomBits) external;
```
`prematureReveal` slashes the Solver's deposit and transfers half of it to the caller of this method if both:
* a Solver has been selected but not yet instructed to reveal his solution in the clear, and
* the Solver's private `originalRandombits` match those of the `taskID`.

## callbacks

Upon completion of a task, Truebit will call back to the Task Owner's (contract) address with a result.  In order to make use of the result, the Task Owner's contract must include one or more of the following methods.

```solidity
function solved(bytes32 taskID, bytes32[] calldata files) external;
```
Truebit calls the Task Owner's `solved` method when `taskID` successfully terminates with a solution.  The input `files` will be an array consisting of fileID's for the Solver's uploaded solutions.


```solidity
function cancelled(bytes32 taskID) external;
```
Truebit calls the Task Owner's `cancelled` method when `taskID` terminates without a solution due to a Solver timeout, loss of verification game, blockLimit error, or prematureReveal.
