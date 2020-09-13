<p align="center">
  <img src="./images/truebit-logo.png"/>
</p>

<!-- [![Build Status](https://travis-ci.org/TrueBitFoundation/Truebit2020.svg?branch=master)](https://travis-ci.org/TrueBitFoundation/Truebit2020) -->
[![Docker Image](https://img.shields.io/docker/cloud/build/truja/truebit?style=flat-square)](https://hub.docker.com/repository/docker/TrueBitFoundation/truebit-eth)

# What is Truebit?
[Truebit](https://truebit.io/) is a blockchain enhancement which enables smart contracts to securely perform complex computations in standard programming languages.  This comprehensive Ethereum implementation includes everything you need to create (from C, C++, or Rust code), issue, solve, and verify Truebit tasks.  This repo includes the Truebit-OS command line [client](https://github.com/TrueBitFoundation/truebit-eth/tree/master/wasm-client) for solving and verifying tasks, [WASM ports](https://github.com/TrueBitFoundation/truebit-eth/tree/master/wasm-ports) and [Emscripten module wrapper](https://github.com/TrueBitFoundation/truebit-eth/tree/master/emscripten-module-wrapper) for generating them, the [off-chain interpreter](https://github.com/TrueBitFoundation/truebit-eth/tree/master/ocaml-offchain), as well as [sample tasks](#More-sample-tasks).  You can install Truebit using Docker or build it from source for Linux or MacOS.  One can install the system locally or run over a public Ethereum blockchain.

Feel free to browse the [legacy Wiki](https://github.com/TrueBitFoundation/wiki), start a new one, or check out these classic development blog posts:
* [Developing with Truebit: An Overview](https://medium.com/truebit/developing-with-truebit-an-overview-86a2e3565e22)
* [Using the Truebit Filesystem](https://medium.com/truebit/using-the-truebit-filesystem-f6a5d4ac9604)
* [Truebit Toolchain & Transmute](https://medium.com/truebit/truebit-toolchain-transmute-4984928364a7)
* [Writing a Truebit Task in Rust](https://medium.com/truebit/writing-a-truebit-task-in-rust-6d96f2ee0a4b)
* [JIT for Truebit](https://medium.com/truebit/jit-for-truebit-e5299afc72d8)

If you would like to speak with developers working on this project, come say hello on Truebit's [Gitter](https://gitter.im/TrueBitFoundation/Lobby) channel.  

# Quickstart guide: computational playground

This tutorial shows how to install Truebit, connect to Görli or Ethereum mainnet networks, solve, verify and issue tasks, and finally build your own tasks.  Use the following steps to connect to the Görli testnet blockchain and solve tasks with your friends!

## Install or update Truebit-OS

Follow the following steps to run a containerized Truebit-OS client for Solvers, Verifiers, and Task Givers on any system.  Docker provides a replicable interface for running Truebit-OS and streamlines the installation process.  First, download and install [Docker](https://docs.docker.com/get-docker/).  Then run the following at your machine's command line.
```
docker pull truja/truebit:latest
```

## Docker incantations

Building the image above will take some minutes, but thereafter running the container should give you a prompt instantly.  While you are waiting for the download to complete, familiarize yourself with the following three command classes with which you will access the Truebit network.

### "Start container"

We first open a new container with two parts

1. **Truebit-OS**. Solvers and Verifiers can solve and verify tasks via command-line interface.

2. **Truebit Toolchain** Task Givers can build and issue tasks.

Select a directory where you plan to usually run the Docker container and store your private keys and type the following, substituting `YYY` for the *full path* to a directory where you wish to cache files.  To get the full path for your current working directory in UNIX, type `pwd`.
```
docker run --network host -v YYY/geth-docker-cache:/root/.ethereum --rm -it truja/truebit:latest /bin/bash
```
Docker will then store your files in the folder you specified as `geth-docker-cache`.  The incantation `--network host -v YYY/geth-docker-cache:/root/.ethereum` avoids having to synchronize the blockchain and your accounts from genesis when you later restart the container.

### "Open terminal window"

When you [connect to the network](Connect-to-the-network), you will need to open multiple windows *in the same Docker container*.  Running Geth or IPFS locally or in a different container from Truebit OS will not work.  When it is time to open a new terminal window for your existing container, find the name of your container running `truja/truebit:latest` by using `docker ps`, open a new local terminal window and enter the following at the command line.
```
docker exec -it _yourContainerName_ /bin/bash
```
_yourContainerName_ might look something like `xenodochial_fermat`.  If you instead wish to run all processes in a single terminal window, initiate `tmux` and create sub-windows by typing `ctrl-b "` or `ctrl-b %` and using `ctrl-b (arrow)` to switch between sub-windows.

You can share files between your native machine and the Docker container by copying them into your `geth-docker-cache` folder.  Alternatively, you may copy into (or out of) the container with commands of the following form.
```
docker cp truebit-eth/supersecret.txt f7b994c94911:/truebit-eth/supersecret.txt
```
Here `f7b994c94911` is the name of the container's ID.To exit a container, type `exit`.  Your container process will remain alive in other windows.

### "Connect to the network"

One must simultaneously run [Geth](https://geth.ethereum.org/) and [IPFS](https://ipfs.io/) nodes to communicate with the blockchain and collect data submitted to the network, respectively.  When you start up a new Truebit container, start IPFS in the background and configure the compiler with the following pair of commands (in this order).
```
source /emsdk/emsdk_env.sh
bash startup.sh
```
You can terminate IPFS at any time by typing `ipfs shutdown`.

Geth demands more nuanced setup compared to IPFS.  Below we'll connect to Truebit on the Görli testnet.  As we will see, connecting on Ethereum mainnet is quite similar.  Truebit OS automatically detects which Ethereum blockchain network you are connected to (Görli or Mainnet).

#### Initializing accounts

If you don't already have a local Görli account in your Docker container, create a new one inside the Docker container with the following command.
```
geth --goerli account new
```
Geth will prompt you for an account password.  You may wish to create more than one account.  Paste each of your account passwords on separate lines, in order, into a text file.  Drop this text file into your `geth-docker-cache` folder.  For example, your password file might have the name `supersecret.txt` might look something like this:
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
```
geth --goerli --rpc --unlock "0,1,2,3" --password /root/.ethereum/supersecret.txt --syncmode "light" --allow-insecure-unlock console
```
Here `0,1,2,3` denotes the indices of the accounts you wish to use with Truebit OS.  If we wanted to connect to mainnet instead of Görli, we would simply substitute `--mainnet` for `--goerli` in the incantation above.  Your Geth client should now begin syncing with the network and be up to date within a minute.  If you are have trouble connecting to a light client peer, try the following.

1. Exit `geth` (`Ctrl-C` or `exit`) and re-run the `geth` incantation above.

2. Change your IP address.

3. Reconnect later, or consider running a full Ethereum node.

To view a list of connected addresses inside the `geth console`, type `personal.listWallets` at the Geth command line.

# Issue, solve, and verify sample tasks

We are now ready to run Truebit Solver and Verifier nodes.  Use an ["open terminal window"](Open-terminal-window) incantation to connect to your Docker container in a terminal window separate from Geth.  Then start Truebit OS!
```
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

For a self-guided tour or additional options not provided in this tutorial, type `help` at the command line, and (optionally) include a command that you want to learn more about.

## Staking tokens

In order to start a Solver or Verifier, one must first stake TRU into the incentive layer.  Let's purchase 100 TRU tokens for account 0.
```
token purchase -v 1000 -a 0
```
Now we can stake some of our TRU.
```
token deposit -v 500 -a 0
```
We can repeat this process for account 1, if desired.  We are ready to start a Verifier, but if we wish to run a Solver, there is one additional step.  We must purchase a Solver license.
```
license purchase -a 0
```

## Running Solvers and Verifiers

We can now start our Solver and Verifier as follows.
```
start solve -a 0
start verify -a 1
```
If the Solver and Verifier do not immediately find a task on the network, try issuing a sample task yourself.
```
task -f factorial.json submit -a 0
```
The Task Submitter address always has first right-of-refusal to solve its own task, so your Solver should pick this one up!  You can check progress of your task here:
```
https://goerli.etherscan.io/address/0x0E1Cb897F1Fca830228a03dcEd0F85e7bF6cD77E
```

## "Real" sample tasks

In general, Dapps will issue tasks from smart contracts rather than the Truebit OS command line.  This allows Truebit to call back to the smart contract with a Truebit-verified solution.  To demonstrate this method, we deploy and issue some tasks that are preinstalled in your Truebit container.  One can deploy all of the samples onto the blockchain as follows.
```
cd wasm-ports/samples
sh deploy.sh
```
To run a sample task, `cd` into that directory and run `node send.js` as detailed below.  You may wish to edit `../deploy.js` or `send.js` by replacing `accounts[0]` with the index for your Geth account.  

### Scrypt
 ```
 cd /wasm-ports/samples/scrypt
 node send.js <text>
 ```
 Computes scrypt, the string is extended to 80 bytes. See source at https://github.com/TrueBitFoundation/wasm-ports/blob/v2/samples/scrypt/scrypthash.cpp
 Originally by @chriseth

 ### Bilinear pairing (enter a string with more than 32 characters)
 ```
 cd /wasm-ports/samples/pairing
 node send.js <text>
 ```
 Uses libff to compute bilinear pairing for bn128 curve. Reads two 32 byte data pieces `a` and `b`, they are used like private keys to get `a*O` and `b*O`. Then bilinear pairing is computed. The result has several components, one of them is posted. (To be clear, the code just shows that libff can be used to implement bilinear pairings with Truebit)
 See source at https://github.com/TrueBitFoundation/wasm-ports/blob/v2/samples/pairing/pairing.cpp

 ### Chess
 ```
 cd /wasm-ports/samples/chess
 node send.js <text>
 ```
 Checks a game of chess. For example the players could use a state channel to play a match. If there is a disagreement, then the game can be posted to Truebit. This will always work for state channels, because both parties have the data available.
 Source at https://github.com/TrueBitFoundation/wasm-ports/blob/v2/samples/chess/chess.cpp
 Doesn't implement all the rules, and not much tested.

 ### Validate WASM file
 ```
 cd /wasm-ports/samples/wasm
 node send.js <wasm file>
 ```
 Uses parity-wasm to read and write a WASM file.
 Source at https://github.com/TrueBitFoundation/wasm-ports/blob/v2/samples/wasm/src/main.rs

 ### Size of video packets in a file:
 ```
 cd /wasm-ports/samples/ffmpeg
 node send.js input.ts
 ```
 Source at https://github.com/mrsmkl/FFmpeg/blob/truebit_check/fftools/ffcheck.c

# Building your own tasks with the Truebit toolchain
If you haven't already, from your Truebit container, run the following commands (in order):
```
source /emsdk/emsdk_env.sh
bash startup.sh
```
You should now be able to compile the sample tasks yourself in C++ (chess, scrypt, pairing), and C (ffmpeg) below.
```
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
```
( ipfs daemon & )
mv /truebit-eth/wasm-ports/samples/wasm /
cd /
git clone https://github.com/georgeroman/emscripten-module-wrapper.git
cd /emscripten-module-wrapper && npm install
/emsdk/emsdk activate 1.39.8
source /emsdk/emsdk_env.sh && source $HOME/.cargo/env
cd /wasm
npm i
sh compile.sh
```
Once you have the samples running, try using the files `compile.sh`, `contract.sol`, and `send.js`, and `../deploy.js` as templates for issuing your own tasks directly from smart contracts.

When building and executing your own tasks, you may have to adjust some of the interpreter execution parameters, including:

`memory-size`: how deep the merkle tree for memory should be

`table-size`: how deep the merkle tree for the call table should be

`globals-size`: how deep the merkle tree for the globals table have

`stack-size`: how deep the merkle tree for the stack have

`call-stack-size`: how deep the merkle tree for the call stack have

 See this [file](https://github.com/TrueBitFoundation/truebit-eth/blob/master/ocaml-offchain/interpreter/main/main.ml#L138) for a complete list of interpreter options.


# Further development references

Here are a [tutorial](https://github.com/TrueBitFoundation/wasm-ports/blob/v2/samples/scrypt/README.md) for creating and deploying Truebit tasks as well as Harley's [demo video](https://www.youtube.com/watch?v=dDzPCMBlZN4) illustrating this process.
