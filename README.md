# Truebit OS 2020

<!-- [![Build Status](https://travis-ci.org/TrueBitFoundation/Truebit2020.svg?branch=master)](https://travis-ci.org/TrueBitFoundation/Truebit2020) -->
[![Docker Image](https://img.shields.io/docker/cloud/build/truja/autobuild?style=flat-square)](https://hub.docker.com/repository/docker/truja/autobuild)

<p align="center">
  <img src="./gundam2.jpeg"/>
</p>

# What is Truebit?
[Truebit](https://truebit.io/) is a blockchain enhancement which enables smart contracts to securely perform complex computations in standard programming languages.  This comprehensive Ethereum implementation includes everything you need to create (from C, C++, or Rust code), issue, solve, and verify Truebit tasks.  This repo includes the Truebit-OS command line [client](https://github.com/TrueBitFoundation/Truebit2020/tree/master/wasm-client) for solving and verifying tasks, [WASM ports](https://github.com/TrueBitFoundation/Truebit2020/tree/master/wasm-ports) and [Emscripten module wrapper](https://github.com/TrueBitFoundation/Truebit2020/tree/master/emscripten-module-wrapper) for generating them, the [off-chain interpreter](https://github.com/TrueBitFoundation/Truebit2020/tree/master/ocaml-offchain), and [smart contracts](https://github.com/TrueBitFoundation/Truebit2020/tree/master/ocaml-offchain) as well as [sample tasks](#More-sample-tasks).  You can install Truebit using Docker or build it from source for Linux or MacOS.  One can install the system locally or run over a public Ethereum blockchain.

Feel free to browse the [legacy Wiki](https://github.com/TrueBitFoundation/wiki), start a new one, or check out these classic development blog posts:
* [Developing with Truebit: An Overview](https://medium.com/truebit/developing-with-truebit-an-overview-86a2e3565e22)
* [Using the Truebit Filesystem](https://medium.com/truebit/using-the-truebit-filesystem-f6a5d4ac9604)
* [Truebit Toolchain & Transmute](https://medium.com/truebit/truebit-toolchain-transmute-4984928364a7)
* [Writing a Truebit Task in Rust](https://medium.com/truebit/writing-a-truebit-task-in-rust-6d96f2ee0a4b)
* [JIT for Truebit](https://medium.com/truebit/jit-for-truebit-e5299afc72d8)

If you would like to speak with developers working on this project, come say hello on Truebit's [Gitter](https://gitter.im/TrueBitFoundation/Lobby) channel.  


## Contents

1. [Computational playground on testnet (Docker, MacOS and Ubuntu)](Computational-playground-on-testnet-Docker-MacOS-and-Ubuntu)
2. [Building your own tasks with Truebit Toolchain](Building-your-own-tasks-with-Truebit-Toolchain)
3. [Local blockchain on Ganache](Local-blockchain-on-Ganache)
4. [Further development references](Further-development-references)


## FAQ

TO APPEAR


## To do

* Fix `ffmpeg` sample timeouts error for Verifier when running in Docker.



# Computational playground on testnet (Docker, MacOS, and Ubuntu)

This tutorial shows how to install Truebit, connect to the testnet network, solve, verify and issue tasks, and finally build your own tasks.  Use the following steps to connect to the Görli testnet blockchain and solve tasks with your friends!

## Install Truebit-OS

Follow the following steps to run Truebi-OS as a container on any system.  For those who happen to be running MacOS or Ubuntu, we recommend local installation and provide instructions below.

### Docker install

Docker provides a replicable interface for running Truebit-OS.  First, download and install [Docker](https://docs.docker.com/get-docker/).  Then run the following at your machine's command line.
```
docker build . -t truebit-os:latest
```
Building the image will take some minutes, but running the container should give you a prompt instantly.

From the directory where you plan to usually run the container, type the following, substituting `YYY` for the *full path* to a directory where you wish to cache files.  to get the full path to your current working directory, type `pwd`.
```
docker run --network host -v YYY/dcache:/root/.ethereum --rm -it truebit-os:latest /bin/bash
```
The optional parameter `--network host -v YYY/dcache:/root/.ethereum` automatically stores cached blockchain data into a local subfolder called `dcache`.  This avoids having to synchronize the blockchain and your accounts from genesis when you later restart the container.  To avoid generating local files (not recommended), you can start with this simpler command instead.
```
docker run --rm -it truebit-os:latest /bin/bash
```

When you [connect to the network](Connect-to-the-network), you will need to open multiple windows *in the same Docker container*.  Running Truebit-OS locally or in a separate container from Geth or IPFS will not work.

When it is time to open a new container window, find the name of your container running `truebit-os:latest` by using `docker ps`, open a new local terminal window and enter the following at the command line.
```
docker exec -it yourcontainerNAME /bin/bash
```
_yourcontainerNAME_ might look like `xenodochial_fermat`.  To exit the container, type `exit`.  This will keep your container process alive in other windows.

Finally, you can copy your password or other local files into the container with the following command.
```
docker cp Truebit2020/supersecret.txt f7b994c94911:/Truebit2020/supersecret.txt
```
Here `f7b994c94911` is the name of the container's ID.


### Mac OS install

Install Truebit-OS from the MacOS command line.  Download and install [brew](https://brew.sh/) via the following command.
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
The next step assumes that you already have `git` configured, but one can alternatively download the repository from the indicated website.
```
git clone https://github.com/TrueBitFoundation/Truebit2020
cd Truebit2020
sh macinstall.sh
```
Installation will take several minutes.


### Ubuntu install

For an Ubuntu Linux install, follow the steps outlined in `Dockerfile` located in the root Truebit2020 directory.


## Connect to the network

Next we connect to Görli testnet.  Open a new terminal window, and generate a new account if you do not have one already.  You will need to create and store a password.
```
echo plort > supersecret.txt
geth --goerli account new --password=supersecret.txt
```
To verify your existing addresses, type
```
geth --goerli account list
```
and note the index of the account you want to use (1 in the example below).  To start running a Görli node, use an incantation of the following form.
```
geth --goerli --rpc --unlock 1 --password supersecret.txt --syncmode "light" --allow-insecure-unlock
```
You may have to exit `geth` (`Ctrl-C`) and restart it again in order to connect to a peer upon initialization.  The light client should begin syncing with the network and be up to date within a minute.

Now open another terminal and start IPFS.
```
ipfs daemon
```
Alteratively, one can save a window by running `ipfs daemon &` and running `ipfs shutdown` if you later want to kill it.


## Issue and solve a sample task

First, obtain Görli ETH from one of the following faucets.

https://goerli-faucet.slock.it/

https://faucet.goerli.mudit.blog/

Then start Truebit-OS and claim some testnet TRU tokens for the respective account.  If you prefer to send Görli ETH from another address, you can use `node send.js` _youraddress_ to send test ETH from an existing `account[0]`, or else transfer using a web application like [Metamask](https://metamask.io/) or [MyCrypto](https://mycrypto.com/).  The following commands will assume that you are using Account #1 on your local machine, so substitute "`1`" as needed in the instructions below.
```
cd Truebit2020
npm run truebit
claim -a 1
```
Now issue a sample task.
```
task -a 1 -t testWasmTask.json
```
Spawn Solver and Verifier to solve the task
```
start solve -a 1
start verify -a 1
```
Check your progress here or look up your address on Görli.
```
https://goerli.etherscan.io/address/0x6dac0a17f50497321785a07b531b8e42c1123757
```
use `help` followed by the name of any command to get more options.  Or type `help` to get a list of commands.  Use `exit` to return to the main terminal.


### More sample tasks

The Truebit2020 repo includes some precompiled sample tasks.  To deploy them onto the blockchain, do the following
```
cd wasm-ports/samples
sh deploy.sh
```
You may need to edit `deploy.js` and other files and replace
 `accounts[0]` with the index for your Geth account.  To run a sample task, `cd` into that diretory and run `node send.js` in the appropriate directory as described below.

 Testing samples, Scrypt
 ```
 cd /wasm-ports/samples/scrypt
 node send.js <text>
 ```
 Computes scrypt, the string is extended to 80 bytes. See source at https://github.com/TrueBitFoundation/wasm-ports/blob/v2/samples/scrypt/scrypthash.cpp
 Originally by @chriseth

 Bilinear pairing (enter a string with more than 32 characters)
 ```
 cd /wasm-ports/samples/pairing
 node send.js <text>
 ```
 Uses libff to compute bilinear pairing for bn128 curve. Reads two 32 byte data pieces `a` and `b`, they are used like private keys to get `a*O` and `b*O`. Then bilinear pairing is computed. The result has several components, one of them is posted. (To be clear, the code just shows that libff can be used to implement bilinear pairings with Truebit)
 See source at https://github.com/TrueBitFoundation/wasm-ports/blob/v2/samples/pairing/pairing.cpp

 Chess sample
 ```
 cd /wasm-ports/samples/chess
 node send.js <text>
 ```
 Checks a game of chess. For example the players could use a state channel to play a match. If there is a disagreement, then the game can be posted to Truebit. This will always work for state channels, because both parties have the data available.
 Source at https://github.com/TrueBitFoundation/wasm-ports/blob/v2/samples/chess/chess.cpp
 Doesn't implement all the rules, and not much tested.

 Validate WASM file
 ```
 cd /wasm-ports/samples/wasm
 node send.js <wasm file>
 ```
 Uses parity-wasm to read and write a WASM file.
 Source at https://github.com/TrueBitFoundation/wasm-ports/blob/v2/samples/wasm/src/main.rs

 Size of video packets in a file:
 ```
 cd /wasm-ports/samples/ffmpeg
 node send.js input.ts
 ```
 Source at https://github.com/mrsmkl/FFmpeg/blob/truebit_check/fftools/ffcheck.c


### Execution variants

 To initiate a verification game, start a Verifier with flag `-t`:
 ```
 start verify -a 1 -t
 ```
 You'll also need an active Solver and task.  For faster off-chain processing, your can try solving tasks with the just-in-time compiler (JIT).  Start Truebit-OS with the following configuration:
 ```
 node cli/index.js wasm-client/config-jit.json
 ```
 Then issue one of the sample tasks [above](More-sample-tasks).  You may need to make a manual deposit before solving the task, e.g. `deposit -a 1 -v 2000`.  Note that the JIT interfaces with `wasm-client/merke-computer.js`.  If you want to experiment with the JIT outside of Truebit-OS, try the following example.  The name of the WASM input file is hardcoded as `task.wasm`.
 ```
cd Truebit2020/wasm-ports/samples/pairing
node ../../../jit-runner/jit.js --file input.data --file output.data --file _dev_urandom --memory-size 4096
 ```
 Compare this with an interpreter run of the same file:
 ```
./../../../wasm-client/ocaml-offchain/interpreter/wasm -m -disable-float -output-io -memory-size 25 -stack-size 20 -table-size 20 -globals-size 8 -call-stack-size 10 -file output.data -file _dev_urandom -file input.data -wasm task.wasm
```

# Building your own tasks with Truebit toolchain
Use a Docker container to compile programs from C or C++ into Truebit tasks.
```
cd wasm-ports
docker build . -t truebit-toolchain:latest

```
It may take some hours to compile the image.  Start the Docker container via the first line below, then initiate Emscripten and IPFS inside the container.
```
docker run --rm -it truebit-os:latest /bin/bash
cd emsdk
source ./emsdk_env.sh
( ipfs daemon & )
```
You should now be able to compile the sample tasks from C and C++.
```
cd /Truebit2020/wasm-ports/samples/scrypt
sh compile.sh
cd ../pairing
sh compile.sh
cd ../chess
sh compile.sh
cd ../wasm
sh compile.sh
cd ../ffmpeg
sh compile.sh
```
For Rust tasks, try George's [tutorial](
https://github.com/TrueBitFoundation/Truebit2020/tree/master/emscripten_workaround).

When building and executing your own tasks, you may have to adjust some of the interprter execution parameters, including:

`memory-size`: how deep the merkle tree for memory should be

`table-size`: how deep the merkle tree for the call table should be

`globals-size`: how deep the merkle tree for the globals table have

`stack-size`: how deep the merkle tree for the stack have

`call-stack-size`: how deep the merkle tree for the call stack have

 See this [file](https://github.com/TrueBitFoundation/Truebit2020/blob/master/ocaml-offchain/interpreter/main/main.ml#L138) for a complete list of interpreter options.


# Local blockchain on Ganache (Docker/Mac)

We shall assume that the

1. Open a Terminal and start a local Ethereum blockchain.
```
ganache-cli -h 0.0.0.0
```
and optionally open another terminal with IPFS via `ipfs daemon`.  Finally, start Truebit-OS!


2. Compile and deploy the contracts.
```
npm run compile
npm run deploy
```
Check that everything works with `npm run test`. Type `npm run` for more options.


3. Task-Solve-Verify.  Start Truebit-OS with the local configuration chosen in Steps 1 & 2 above.
```
npm run truebit
```
Unlike on a public blockchain, one can fast-forward through time in local blockchain mode.  Use`skip` to jump ahead some blocks.  Otherwise, follow the same [tutorial steps](#Issue-and-solve-a-sample-task) to get started.


# Further development references

Here is a [tutorial](https://github.com/TrueBitFoundation/wasm-ports/tree/v2/samples/scrypt) for creating and deploying Truebit tasks.  Here's Harley's [demo video](https://www.youtube.com/watch?v=dDzPCMBlZN4) illustrating this process.

### Running tests

To run the tests on a local Ganache blockchain, use: `npm run test`.

### WASM Client

The `wasm-client` directory houses the primary Truebit client. It contains 4 relevant JS modules that wrap the internal details of the protocol for a user friendly experience. These modules are designed to interact with the Truebit OS kernel and shell. The four modules are taskGiver, taskSubmitter, solver, and verifier. These modules can be run independently from each other. With the exception of taskGiver and taskSubmitter being recommended to run together.

### Usage
The way that Truebit OS knows where to load the relevant modules is with a config file. This is a simple JSON file with a couple fields, that tell the OS where to find the modules at. Here is the example config.json provided used for `basic-client`:
```javascript
{
    "http-url": "http://localhost:8545",
    "verifier": "../wasm-client/verifier",
    "solver": "../wasm-client/solver",
    "task-giver": "../wasm-client/taskGiver"
}
```

### Logging

Logging is provided by [winston](https://github.com/winstonjs/winston). If you would like to disable console logging, you can set the NODE_ENV to production, like so:

```
NODE_ENV='production' npm run test
```

### Git Submodule Commands

Add submodule
```
git submodule add *url*
```

Cloning repo with submodule
```
git clone *repo*
cd *submodule_name*
git submodule init
git submodule update
```

If you want to include all the submodules with the repo you clone
```
git clone --recurse-submodules *url*
```

Fetching submodule updates
```
git submodule update --remote *submodule_name*
```

Pushing changes of a submodule to remote
```
git submodule update --remote --merge
```

Deleting submodules
```
git rm *submodule_name*
rm -rf .git/modules/*submodule_name*

```
