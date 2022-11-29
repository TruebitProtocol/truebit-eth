

<p align="center">
  <img src="./data/images/truebit-logo.png" width="650">
</p>
[![Docker Image](https://img.shields.io/docker/cloud/build/truebitprotocol/truebit-eth)](https://hub.docker.com/r/truebitprotocol/truebit-eth)
[![Docker size](https://img.shields.io/docker/image-size/truebitprotocol/truebit-eth/latest)](https://hub.docker.com/r/truebitprotocol/truebit-eth)
[![Truebit OS version](https://img.shields.io/github/package-json/v/TruebitProtocol/package-tracker?label=truebit-os)](https://truebit.io/downloads/)
[![Gitter](https://img.shields.io/gitter/room/TruebitProtocol/community?color=yellow)](https://gitter.im/TruebitProtocol/community)
[![Discord](https://img.shields.io/discord/681631420674080993?color=yellow&label=discord)](https://discord.gg/CpjSeGK4Px)

# What is Truebit?
[Truebit](https://truebit.io/) is a blockchain enhancement which enables smart contracts to securely perform complex computations in standard programming languages at reduced gas costs. As described in the [whitepaper](https://people.cs.uchicago.edu/~teutsch/papers/truebit.pdf) and this graphical, developer-oriented [overview](https://medium.com/truebit/truebit-the-marketplace-for-verifiable-computation-f51d1726798f), Task Givers can issue computational tasks while Solvers and Verifiers receive remuneration for correctly solving them.  You may wish to familiarize yourself with the practical, high-level [user guide](https://medium.com/truebit/getting-started-with-truebit-on-ethereum-ac1c7cdb0907) before proceeding.

This comprehensive Ethereum implementation includes everything you need to create (from C, C++, or Rust code), issue, solve, and verify Truebit tasks.  This repo includes the Truebit-OS command line [client configurations](https://github.com/TruebitProtocol/truebit-eth/tree/master/wasm-client) for solving and verifying tasks, some [libraries ported to WebAssembly](https://github.com/TruebitProtocol/truebit-eth/tree/master/wasm-ports), an [Emscripten module wrapper](https://github.com/TruebitProtocol/truebit-eth/tree/master/emscripten-module-wrapper) for adding runtime hooks, a [Rust tool](https://github.com/TruebitProtocol/truebit-eth/tree/master/rust-tool) for generating tasks, the [off-chain interpreter](https://github.com/TruebitProtocol/truebit-eth/tree/master/ocaml-offchain) for executing and snapshotting computations, as well as [sample tasks](#Sample-tasks-via-smart-contracts).  You can install Truebit using Docker or build it from source for Linux, MacOS, or Windows.

Feel free to browse the [legacy wiki](https://github.com/TruebitProtocol/wiki), contribute to this repo's wiki, or check out these classic development blog posts:
* [Developing with Truebit: An Overview](https://medium.com/truebit/developing-with-truebit-an-overview-86a2e3565e22)
* [Using the Truebit Filesystem](https://medium.com/truebit/using-the-truebit-filesystem-f6a5d4ac9604)
* [Truebit Toolchain & Transmute](https://medium.com/truebit/truebit-toolchain-transmute-4984928364a7)
* [Writing a Truebit Task in Rust](https://medium.com/truebit/writing-a-truebit-task-in-rust-6d96f2ee0a4b)
* [JIT for Truebit](https://medium.com/truebit/jit-for-truebit-e5299afc72d8)

In addition, Truebit's [Reddit](https://www.reddit.com/r/truebit/) channel features links to some excellent introductions and mainstream media articles about Truebit.  If you'd like to speak with developers working on this project, come say hello on Truebit's [Gitter](https://gitter.im/TruebitProtocol/Lobby) and [Discord](https://discord.gg/CzpsQ66) channels.

# Table of contents
1. [Quickstart guide: computational playground](#Quickstart-guide-computational-playground)
2. [Solve and verify tasks](#Solve-and-verify-tasks)
3. [Getting data into and out of Truebit](#Getting-data-into-and-out-of-Truebit)
4. [Client configuration](#Client-configuration)
5. [Building your own tasks](#Building-your-own-tasks)
6. [Native installation](#Native-installation)
7. [Contract API reference](#Contract-API-reference)

# Quickstart guide: computational playground

This tutorial demonstrates how to install Truebit, connect to Görli or Ethereum mainnet networks, solve, verify and issue tasks, and finally build your own tasks.  Use the following steps to connect to the Görli testnet blockchain and solve tasks with your friends!

## Install or update Truebit OS

Follow the following steps to run a containerized Truebit OS client for Solvers, Verifiers, and Task Givers on any Docker-supported system.  Docker provides a replicable interface for running Truebit OS and offers a streamlined installation process.  First, download and install [Docker](https://docs.docker.com/get-docker/).  Then run the following at your machine's command line.
```bash
docker pull truebitprotocol/truebit-eth:latest
```
If you are running older version of Truebit OS and receive errors in your client, you should update to the latest Docker container via the same command.  The current Truebit OS version is listed in the badge at the top of this README file, and you can compare this against the local version which Truebit OS displays at startup.

## Docker incantations

Building the image above will take some minutes, but thereafter running the container will give an instant prompt.  While you are waiting for the image download to complete, familiarize yourself with the following three command classes with which you will access the Truebit network.

### "Start container"

We first open a new container with two parts:

1. **Truebit OS**. Solvers and Verifiers can solve and verify tasks via command-line interface.

2. **Truebit Toolchain**. Task Givers can build and issue tasks.

Select a directory where you wish to store network cache and private keys.  For convenience, we let `$YYY` denote the *full path* to this directory.  To get the full path for your current working directory in MacOS or Linux, type `pwd`.  For example, if we wish to place the files at `~/truebit-docker`, we would write
```bash
YYY=$HOME'/truebit-docker'
docker run --network host -v $YYY/docker-clef:/root/.clef -v $YYY/docker-geth:/root/.ethereum -v $YYY/docker-ipfs:/root/.ipfs --name truebit --rm -it truebitprotocol/truebit-eth:latest /bin/bash
```
Docker will then store your Clef, Geth, and IPFS configuration files in the directories `docker-clef`, `docker-geth` and `docker-ipfs` respectively.  The `-v` flags in the incantation above avoid having to synchronize the blockchain and reconstruct your accounts, IPFS ID's, master seed, and rule attestation from genesis when you later restart the container.

If you are using Windows,  try the following incantation.
```bash
SET YYY=%userprofile%/truebit-docker
docker run --network host -v %YYY%/docker-clef:/root/.clef -v %YYY%/docker-geth:/root/.ethereum -v %YYY%/docker-ipfs:/root/.ipfs --name truebit --rm -it truebitprotocol/truebit-eth:latest /bin/bash
```

### "Open terminal window"

When you [connect to the network](#Connect-to-the-network), you will need to open multiple windows *in the same Docker container*.  Running Geth or IPFS locally or in a different container from Truebit OS will not work.  When it is time to open a new terminal window for your existing container, open a new local terminal window and enter the following at the command line.
```bash
docker exec -it truebit /bin/bash
```
If you omitted the `--name truebit` flag when starting your container (i.e., you did not cut and paste the command [above](#Start-container)), you will need to find the name of the container running `truebitprotocol/truebit-eth:latest` by using `docker ps`.  Then, in place of "`truebit`" in the `docker exec` incantation above, substitute either your container's name, which might look something like `xenodochial_fermat`, or the container's ID, which looks something like `859841f65999`.

If you instead wish to run all processes in a single terminal window, initiate [`tmux`](https://tmuxcheatsheet.com/) and create sub-windows by typing `ctrl-b "` or `ctrl-b %` and using `ctrl-b (arrow)` to switch between sub-windows.  To exit a container, type `exit`.  Your container process will remain alive in other windows unless you exited the original window which initiated with the `--rm` flag.

### "Share files"
You can share files between your native machine and the Docker container by copying them into the local `docker-clef`, `docker-geth`, or `docker-ipfs` folders you created [above](#Start-container) or the respective folders in the Docker container, namely `~/.clef`, `~/.geth`, or `~/.ipfs`.  If you wish to synchronize a specific local file with a container file which does not belong to one of these directories on the container, say [`config.json`](#Client-configuration), first copy `config.json` to your local directory [`$YYY`/config.json](#Start-container), and then restart the docker run [command](#Start-container) with an additional volume, e.g. `-v $YYY/config.json:/truebit-eth/wasm-client/config.json`.

Alternatively, you may copy into (or out of) the container with commands of the following [form](https://docs.docker.com/engine/reference/commandline/cp/).
```bash
docker cp truebit-eth/mydata.txt f7b994c94911:/root/.ethereum/mydata.txt
```
Here `f7b994c94911` is either the container's [name](#Open-terminal-window), namely `truebit` if you followed the convention [above](#Start-container), or the container's ID.  This example command copies a local file into the container.  If you wish to copy from container to local, reverse the order of the files in the incantation.

Finally, for quick text file sharing from your local machine, you can simply copy text into a buffer and then paste into a file on the Docker container via the `vim` or `nano` text editors.

## Initializing accounts

In order to interact with the Truebit network, you'll need account(s) to handle both Ethereum (ETH) and Truebit (TRU) tokens.  We'll use [Clef](https://geth.ethereum.org/docs/getting-started) to securely manage account keys and addresses.  The first time you [start](#Start-container) the Docker container, you'll need to initialize Clef with the following command.
```bash
clef init
```
Clef will ask you to create a master seed password which you'll use to unlock all your accounts.  Next run the following line exactly as it appears.
```bash
clef attest 6441d5def6ec7ebe4ade8a9cf5d74f81088efaef314d8c4bda91221d02a9d976
```
This will allow Clef to sign all transactions automatically.  Task Submitters, Solvers, and Verifiers must sign multiple transactions for each task, and you may find it inconvenient to sign each one manually.  For security, all connections to Truebit OS are by default IPC, hence only your local machine can sign your transactions.  If you wish to [modify](https://geth.ethereum.org/docs/clef/rules) the automatic signing script, go to `/truebit-eth/wasm-client/ruleset.js`, compute its `sha256sum` hash, and then call `clef attest` again with your new hash.  By default, clef will log its activities in a file called `audit.log`.  If you used the `docker run ...` command [above](#Start-container), you'll find your master seed file on your local computer in a folder called `~/truebit-docker/docker-clef`.

You may check your existing accounts in Geth's console using `personal.listWallets`, in Truebit OS using [`accounts -r`](#Purchasing-staking-and-retiring-TRU-tokens), or at the main Docker command prompt using `geth --goerli account list` (sans `--goerli` for mainnet).

### New accounts

Repeat the following steps for each new account you wish to create.  First, make a new private key for Görli testnet.
```bash
clef newaccount --keystore ~/.ethereum/goerli/keystore
```
Clef returns a "generated account" which is `<YOUR PUBLIC ADDRESS>`.  To add an account for mainnet instead, just use the vanilla command `clef newaccount`.  Clef will ask you to create a password for this account, and the next command will attach the account password to your master seed password keychain.
```bash
clef setpw <YOUR PUBLIC ADDRESS>
```
Clef can now autofill the keystore password for <YOUR PUBLIC ADDRESS> whenever you log in with your master seed password.  If you used the `docker run ...` command [above](#Start-container), you'll find your keystore files on your local computer in a folder called `~/truebit-docker/docker-geth`.

On testnet one can create keystore files with shorter passwords using `geth --goerli account new`.

### Importing existing accounts
For hardware wallets, you can either add the [`--privileged`](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities) flag when starting Docker or run Truebit OS outside the Docker container using a [native install](#Running-Truebit-OS-natively).  In either case, you will need to remove the `--nousb` flag from both the `clef` and `geth` startup incantations.

If you wish to use an existing keystore file with Truebit, simply paste it into your local folder `docker-geth/goerli/keystore` (for testnet) or `docker-geth/keystore` (for mainnet).  Alternatively use [`docker cp`](#Share-files) to paste into the Docker container at `~/.ethereum/goerli/keystore` (testnet) or `~/.ethereum/keystore` (mainnet).  MyCrypto's [Desktop App](https://download.mycrypto.com/) conveniently manages keystore files offline (i.e. outside the browser).

### Funding your accounts with ETH

Finally, get some ETH!  You can obtain Görli ETH from one of the free faucets below, or send ETH to your accounts from your favorite wallet (e.g. [Metamask](https://metamask.io/) or [MyCrypto](https://mycrypto.com/)).

https://goerli-faucet.slock.it/

https://faucet.goerli.mudit.blog/

As Ethereum mainnet lacks a faucet, you'll have to source ETH from an existing account (or mining).


## Connect to the network

One must simultaneously run [Geth](https://geth.ethereum.org/) and [IPFS](https://ipfs.io/) in order to communicate with the blockchain and data infrastructures.  When you start up a new Truebit container, initialize the Truebit toolchain compiler, start IPFS, and start Geth as with the following command.
```bash
bash /goerli.sh
```
If you wish to connect to Ethereum mainnet rather than Görli, use instead
```bash
bash /mainnet.sh
```
After running the startup script, the [Clef](https://geth.ethereum.org/docs/clef/tutorial) account management tool should pop up at the bottom of a split `tmux` screen with Geth waiting to start above.  After you enter the master seed password for your accounts, your Geth node should start to synchronize with the blockchain.

Once your Geth node is fully synchronized, you may enhance IPFS connectivity by running the last four lines in `/goerli.sh` (sans comment symbol `#`) or by running the [equivalent](#Faster-IPFS-uploads-and-downloads) commands in Truebit OS.  [Open](#Open-terminal-window) a new Docker terminal and type `cat /goerli.sh` to view the file contents, cut and paste to your command line, and `cat /ipfs-connect.log` for connection results.  Alternatively, you can [configure](#Client-configuration) Truebit OS to synchronize with an external IPFS node rather than running one in Docker.

Note that one can terminate an IPFS connection at any time by typing `ipfs shutdown`.  If you get an error message like `Error: execution aborted (timeout = 5s)` when running the commands described in the previous paragraph, check your connection in the Geth window and rerun the offending command.  Messages like `Error: Invalid JSON RPC response: "Error: connect ECONNREFUSED 127.0.0.1:8545` ... or `error: no suitable peers available` indicate that IPFS failed to obtain the list of registered Truebit nodes due to lack of Geth connection or synchronization.

Note that Truebit OS automatically detects the blockchain network to which Geth is connected (either Görli testnet or Ethereum mainnet).  If you are have trouble connecting to a light client peer, try the following.

1. Terminate the Clef/Geth split screen (`Ctrl-C`, `Ctrl-D` and/or `exit`) and re-run `sh /goerli.sh`.

2. Test your connection with a vanilla command at the main Docker prompt, e.g. `geth --goerli --syncmode "light"`, or for mainnet `geth --syncmode "fast"`.  Try `geth --help` for more options.

3. Test Truebit OS with a plug-and-play API, e.g. [Infura](https://infura.io/) or [others](https://ethereumnodes.com/).  See [below](#Client-configuration) for configuration instructions.

4. Change your IP address.

5. Try running Truebit OS [natively](#Running-Truebit-OS-natively) instead of using Docker.

6. Consider running a full Ethereum node on dedicated [hardware](https://ava.do/).

7. Reconnect later.

To view a list of your connected addresses inside the `geth console`, type `personal.listWallets` at the Geth command line.

# Solve and verify tasks

We are now ready to run Truebit Solver and Verifier nodes.  This walk-through assumes you've already [set up your accounts](#Initializing-accounts) and [connected to the network](#Connect-to-the-network).  Use the ["open terminal window"](#Open-terminal-window) incantation to connect to your Docker container in a terminal window separate from Geth.  Then start Truebit OS!  
```bash
cd /truebit-eth
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
[01-21 14:42:00] info: Truebit OS 1.2.6 has been initialized on goerli network at block 4145800 with throttle 3 and gas price 20.1 gwei.
```
Note that you must be connected to either Görli testnet or Ethereum mainnet in order to execute commands in Truebit OS.  You may see error messages at this point if your local node has not yet synchronized with the blockchain or is not connected to a suitable peer (e.g. `Error: CONNECTION ERROR: Couldn't connect to node on IPC.`, `Error: Invalid JSON RPC response: "Error: connect ECONNREFUSED 127.0.0.1:8545`, or `error: no suitable peers available`).  If this happens, `exit` Truebit OS and restart.  **To avoid gas waste on Ethereum mainnet, make sure your account(s) have sufficient ETH balance(s) to complete desired operation(s).  Try first a dry run on Görli testnet using account(s) with identical ETH balance(s) before moving to mainnet.**  Some methods, like uploading data onchain, may require your account to authorize an ETH equivalent of 5 million gas even if the corresponding transaction consumes only a small fraction of that amount.  Always close your Görli (respectively mainnet) connection before running `mainnet.sh` (respectively `goerli.sh`); clef can only handle one connection per masterseed, and `mainnet.sh` and `goerli.sh` each redirect Truebit OS's connection.

For a self-guided tour or to explore additional options not provided in this tutorial, type `help` at the command line, and (optionally) include a command that you want to learn more about.  Here is a list of available commands:
```
help [command...]        Provides help for a given command.
exit                     Exits application.
accounts [options]       List web3 account indices (-r to refresh).
balance [options]        Show account balances (-a account index).
bonus                    Display current per task subsidy.
gas [options] <cmd>      Check or set gas price.
ipfs [options] <cmd>     Manage IPFS nodes.
license [options] <cmd>  Obtain a Solver license.
ps                       List active Solvers and Verifiers along with their games and tasks.
start [options] <cmd>    Start a Solver or Verifier.
stop <num>               Stop a Solver or Verifier. Get process numbers with 'ps'.
task [options] <cmd>     Submit a task or run a utility.
token [options] <cmd>    Swap ETH for TRU.  Deposit to or withdraw from incentive layer.
version                  Display Truebit OS version.
```

## Purchasing, staking, and retiring TRU tokens

In order to start a Solver or Verifier, one must first stake TRU into Truebit's incentive layer.  Let's purchase 1000 TRU tokens for account 0.  First check the available account indices using `accounts` and the price in ETH using
```sh
token price -v 1000
```
If you add or remove node accounts while Truebit OS is open, you can refresh and synchronize Truebit OS's account list with
```sh
accounts -r
```
Truebit OS will retain the current list of account indices until one runs this command.  After checking balances for account 0 using `balance`, we are ready to purchase some TRU.  **WARNING: The `purchase` command will spend ETH from your account.  Please practice the commands in this section on Görli testnet before trying them on Ethereum mainnet.**
```sh
token purchase -v 1000 -a 0
```
We should now have 1000 freshly minted TRU in account 0.  We can now stake some of our TRU which will enable us to solve or verify a task.
```sh
token deposit -v 500 -a 0
```
We can repeat this process for account 1, if desired.  We are ready to start a Verifier, however if we wish to run a Solver, there is one additional step.  We must purchase a Solver license with ETH.  Check the price using `license price`, determine whether the account already has a license using `license check -a 0`, and then
```sh
license purchase -a 0
```
Finally, we can confirm account balances for ETH and TRU and the amount of TRU we have staked in Truebit's incentive layer.
```sh
balance -a 0
```
Eventually, when we are ready to discard TRU and recover ETH, we can retire the tokens as follows.  First check the buyback price using `token price -v 100`.  Then
```sh
token retire -v 100 -a 1
```
This transaction will destroy 100 TRU and send ETH from the reserve to account 1.  We can conveniently transfer TRU and ETH among accounts in Truebit OS using `token transfer-eth` and `token transfer-tru`.  For example,
```sh
token transfer-tru -a 0 -t 1 -v 20
```
will transfer 20 TRU from account 0 to account 1.

## Running Solvers and Verifiers

We can now start our Solver and Verifier as follows.  For clarity it is recommended, but not required, to run each Task Submitter, Solver, or Verifier in a [separate terminal window](#Open-terminal-window) with a distinct account.
```sh
start solve -a 0
start verify -a 1
```
Note that account 0 is assumed for the `start` command when the `-a` flag is not specified.  If the Solver and Verifier do not immediately find a task on the network, try issuing a sample task yourself.
```sh
task -f factorial.json submit -a 0
```
The Task Submitter address always has first right-of-refusal to solve its own task, so your Solver should pick this one up!  You can check progress of your Görli task here:

<https://goerli.etherscan.io/address/0x76c73774bC137F3229c422a8E054A022d9066b22>

For mainnet, check here:

<https://etherscan.io/address/0x388a3bD8f54F305266898e77B126609Ec6265f1e>

Solvers and Verifiers will continue to solve and verify new tasks until instructed to stop.  To limit task participation based on TRU rewards, Solvers and Verifiers can use the `-l` flag to set a minimum, (constant) non-zero reward threshold per task, or use `-p` to fix a minimum TRU reward per block of computation.  For example,
```sh
start verify -l 10 -p 0.5
```
will initialize a Solver who participates when the the total reward for Verifiers is at least 10 TRU and pays at least 0.5 TRU per block of computation.  Neither the `-l` nor the `-p` flag takes subsidy payments into consideration, so choose parameters accordingly.

You can terminate all Solvers and Verifiers in your terminal by `exit`ing Truebit OS, however it is safer to end them using `ps` and `stop`, illustrated below, as this will allow them to complete active tasks(s), active verification game(s) and unbond deposits before terminating.
```sh
truebit-os:> ps
SOLVERS
1. Account 4: 0xa1b4CbC091E9B15e334d95D92CA7677152F52ac4  
VERIFIERS
2. Account 5: 0x755908B829B8189a8B6D757da2A8ed4747506a84
 Task 1: 0x100a6f1a7fe990a2839ff3096b950bc5ff81ffaa9d5f87f328e77c5c624d23a9
truebit-os:> stop 1
[01-21 12:54:51] info: Preparing to exit Solver process 1.
SOLVERS
1. Account 4: 0xa1b4CbC091E9B15e334d95D92CA7677152F52ac4  Preparing to exit
VERIFIERS
2. Account 5: 0x755908B829B8189a8B6D757da2A8ed4747506a84
 Task 1: 0x100a6f1a7fe990a2839ff3096b950bc5ff81ffaa9d5f87f328e77c5c624d23a9
truebit-os:> [01-21 12:54:53] info: SOLVER: Exited.
```
If you make a mistake or lose Internet connectivity while your deposit is bonded to a task, try restarting in recovery mode.  For example,
```sh
start solve -r 20
```
will initialize a new Solver 20 blocks behind the current block and recover the intermediate events.  You can also try a command of the form `task unbond -a 1` to recover a stuck deposit.

## Subsidies and platform fees

In addition to TRU fees paid from Task Submitters to Solvers and Verifiers, Task Owners, Solvers, and Verifiers each receive freshly minted TRU subsidies for participating in each task.  Use the `bonus` command to check current subsidy amounts.  Task Submitter and Solvers will each pay a small, per-task platform fee.  Check `task fees` for the amount.  There is no platform fee for Verifiers, however Verifiers must pay the usual gas costs for sending transactions.  

## Faster IPFS uploads and downloads

IPFS's peer-to-peer network can route data more efficiently when it knows where to find Truebit Task Submitters, Solvers, and Verifiers.  It is recommended to register your IPFS node with Truebit via the following command which makes it easier for others to find your node while you are issuing or solving tasks:
```sh
ipfs register
```
You can then discover other nodes on Truebit's network by running:
```sh
ipfs connect
```
You can use `ipfs id` to display your node's various addresses and `ipfs list` to display a list of all registered addresses.  If you wish to register a specific address returned by `ipfs id`, you can specify it with the `-i` flag.  Note that the first address has index 0, so that
```sh
ipfs register -i 3
```
will register the 4th address in the `ipfs id` array.  Specifying an index can ensure that you register an address with a publicly visible IP rather than a strictly local one like `127.0.0.1`.

If you are running Truebit OS [natively](Running-Truebit-OS-natively), updating IPFS to the latest version may improve performance.  If your node didn't successfully connect to peers, try again in a few minutes as it can take some time for new addresses to propagate.  Note that some registered nodes may be offline.

## Logging sessions

The vanilla `./truebit-os` command generates a file `combined.log.json` containing a .json log spanning across all Truebit OS terminals but does not include everything displayed on the terminal screens.  You can inspect this log as follows:
```bash
cat /truebit-eth/combined.log.json | more
```
It is safe to delete this file.  If one wishes a more detailed log for a Truebit OS interactive session, one can use a command of the following form to record the full terminal output:
```bash
./truebit-os 2>&1 | tee mylog.txt
```
Alternatively, one can use the built-in `script` command to record a terminal session.
```bash
script
./truebit-os
```
After exiting Truebit OS, type `exit` to leave the `script` shell.  You can then find your session transcript in a file called `typescript`.  To display with proper formatting, use the following command.
```bash
cat typescript
```

## Command line execution

One can also execute Truebit OS commands directly from the native (Docker) command line using a `-c` flag.  For example, try:
```bash
./truebit-os -c "start solve -a 1" --batch > mylog.txt &
```
Here the `--batch` flag tells Truebit OS to run non-interactively, and `> mylog.txt &` tells Truebit OS to write the output to a log file called `mylog.txt` rather than the terminal.  The command above will return a process number at the command line (e.g. `[1] 412`).  You can stop the Solver process later using the `kill` command, (e.g. `kill 412`).  The following Unix shell command will return a list of active Truebit processes from all windows.
```bash
ps a
```
Use `cat mylog.txt` to review these logs with proper formatting.


# Client configuration

In the `/truebit-eth/wasm-client/` directory, you will find a file called `config.json` which looks something like this.
```json
{
  "geth": {
    "providerURL": "http://localhost:8545"
  },
  "ipfs": {
    "protocol": "http",
    "host": "localhost",
    "port": "5001"
  },
  "gasPrice": 20.1,
  "throttle": 3,
  "incentiveLayer": "incentiveLayer"
}
```

## Setting gas price

When running on Ethereum mainnet, you may wish to modify the `gasPrice` parameter to increase the chances that Ethereum miners will process your Truebit OS transactions or to economize on ETH costs.  Every Ethereum transaction invokes some ETH gas cost, and price per unit gas is given in [gwei](https://ethdocs.org/en/latest/ether.html).  The `gasPrice` can be set within Truebit OS.  For example,
```sh
gas set -v 47.3 --default
```
will set the running client gas price to 47.3 gwei, and the optional `--default` flag tells Truebit OS to write to `config.json` above so that this value becomes the starting `gasPrice` the next time you start Truebit OS.  Beware that in Ethereum's capricious DeFi environment, gas prices can fluctuate wildly.  Use the following command to get a real-time, suggested range of gas prices on mainnet.
```sh
gas check
```
On Görli, a `gasPrice` of 1 gwei may suffice.  Alternatively, one can use Geth's dynamic gas price oracle by setting the `--value` flag to `geth`:
```sh
gas set -v geth
```
By default, Geth's price oracle returns the 60th percentile gas price among transactions in the 20 most recent blocks.  You can tweak these parameters by starting Geth with `--gpopercentile` and `--gpoblocks` flags, e.g.
```bash
geth console --gpo.percentile 60 --gpo.blocks 20 --goerli --syncmode "light" --signer ~/.clef/clef.ipc
```

## Bounding the number of simultaneous tasks

The `throttle` parameter [above](#Client-configuration) is the maximum number of simultaneous tasks that your Solver or Verifier will process.  You can update `throttle` in the `config.json` file via a command of the following form.
```sh
task throttle -v 3
```
Changes to `throttle` take effect upon restart of Truebit OS.  Like `gas set -d`, the `throttle` command saves the current providerURL to `config.json`.  Thus `throttle` can be used to save a providerURL specified at startup via the `-p` flag (see next paragraph for details).

## Blockchain and IPFS connection settings

The `geth` and `ipfs` subkeys in [`config.json`](#Client-configuration) must match your Geth and IPFS network settings.  Valid prefixes for `geth.providerURL` include `http`, `https`, `ws`, and `wss` and determine the provider type for the connection.  If `geth.providerURL` does not have a valid prefix, it must have a `.ipc` suffix, e.g. `/root/.ethereum/goerli/geth.ipc`.  You can override the default `geth.providerURL` setting at Truebit OS startup using the `-p`.  For example
```bash
./truebit-os -p ws://localhost:8546
```
will set the RPC server listening port to 8546 and connect via WebSocket.  You can also try to use an external hosting provider, like `/truebit-os -p https://goerli.infura.io/v3/<YOUR API KEY>`.  As such APIs are not trusted, however, you will not be able to unlock your accounts for use in Truebit OS. Finally, **never unlock you accounts on a mainnet node using http or ws connections**, as anyone with access to the node can sign and broadcast transactions on behalf of your account(s).

The `-i` flag adjusts the IPFS connection settings analogously, e.g.
```bash
./truebit-os -i http://localhost:5001
```
will connect to IPFS via http on local port 5001.  Test your IPFS connection inside Truebit OS with `ipfs connect`, and confirm your blockchain connection in Truebit OS with this command:
```sh
version
```

You must restart Truebit OS for `config.json` changes to take effect.  For editing convenience and to save your changes to the next ["start container"](#Start-container), you may wish to [add](Share-files) a volume to your Docker run incantation.
Do not change the `incentiveLayer` key in `config.json` as Truebit on Ethereum only supports a single incentive layer.


# Getting data into and out of Truebit

Tasks can be issued directly from Truebit OS or from smart contracts.  We'll focus on task issuance from Truebit OS in this section and then issue tasks from smart contracts in the next [section](#Sample-tasks-via-smart-contracts).

## Filetypes

Truebit can read and write data to three file types.

0. **BYTES.**  These are standard Ethereum bytes stored in Truebit's filesystem smart contract.  Note that Truebit does *not* read data from arbitrary smart contracts.

1. **CONTRACT.**  This method uses a smart contract whose program code consists of the task data itself.  This is not a typical contract deployment as the contract may not function.

2. **IPFS.** Truebit can read and write to IPFS, a peer-to-peer, content-addressed storage system.

Ethereum has a limit of 5 million gas per contract deploy (~ 24 kilobytes) and roughly the same limit for other transactions.  This means that larger files should always sit on IPFS.

## Writing task outputs via Truebit OS

Let's inspect a sample task meta-file called `reverse.json` which can be found in the `/truebit-eth` directory:
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

### Task parameters

The filepaths above, e.g. `/data/reverse_alphabet.wasm`, are given relative to the working `truebit-os` directory.  The leading `/` does not refer to the top level system directory; instead Truebit OS reads from the concatenation of the working directory and this input string (e.g. `/truebit-eth/data/reverse_alphabet.wasm`).  You can experiment with the meta-file's configuration by adjusting parameters below.

1. `codeFile`.  This keyword specifies the compiled code that the Task Giver wishes to execute.  Truebit OS automatically detects code type based on the code file extension (.wasm or .wast), however the Task Giver must specify a file type for the code (BYTES, CONTRACT, or IPFS) telling Solvers and Verifiers where to find it.  Each task has exactly one `codeFile`.

2. `dataFiles`.  All input and output files for the task program must be listed under this keyword, and each must have a file type (BYTES, CONTRACT, or IPFS).

3. `outputs`.  The value(s) here are the subset of the data files which are produced and uploaded by the Solver.  In this example both the empty data file `/data/reverse_alphabet.txt` and the corresponding output file `reverse_alphabet.txt` have the same file type (BYTES), however in general they need not match.

4. `solverReward`, `verifierTax`, and `minDeposit` pertain to task economics.  The `solverReward` is the reward paid to the Solver for a correct computation, the `verifierTax` is the fee split among Verifiers, and `minDeposit` is the minimum unbonded deposit that Solvers and Verifiers must have staked in the Incentive Layer in order participate.  Note that the Task Owner's fee is automatically 0 since the Task Submitter is always the Task Owner when deploying from Truebit OS.

In a typical Ethereum deployment, the *Task Owner* is the Dapp smart contract that sends a task to Truebit which in turns calls back with a solution.  The *Task Submitter* is always a regular (i.e. human-controlled) blockchain address that initiates the task and pays for it.

5. `stackSize`, `memorySize`, `globalsSize`, `tableSize`, and `callSize`.  These are virtual machine parameters.  **You may need to tweak `memorySize` when you create your own task.**

6. `blockLimit`.  This is the length of time (in blocks) for which Solvers and Verifiers will attempt to run the task before reporting a timeout.

### Executing tasks

To run this example on-chain, enter the following commands in Truebit OS, preferably in [separate windows](#Open-terminal-window).
```sh
start solve
task -f reverse.json submit
```
Unless you specify otherwise with the `-a` flag, Truebit will issue the task from your account with index 0.  You can find names of other sample .json meta-files by typing `task -f` followed by a space and then press `tab` twice to request an autofill.  In the event that the Solver disappears in the middle of a task (or one never shows up), you can try a command of the form to recover both your and the Solver's deposits.
```sh
task cancel -t 0x361b1a715e94f56368f78e1c478a659cab4b9b4dec1edf13d5280a26d2f72442
```
You can review the progress of your task and its parameters with `task status`, e.g.
```sh
task status -t 0x361b1a715e94f56368f78e1c478a659cab4b9b4dec1edf13d5280a26d2f72442
```

If you wish to experiment with tasks locally without involving the blockchain, use `task initial` to get the initial state, `task final` to get the final state, or `task jit` to run with a faster, just-in-time compiler in place of the interpreter.  Truebit OS will then tell you the local directory where it is writing the output file(s) as well as the interpreter command it used to generate them.
```sh
truebit-os:> task -f scrypt.json final
[03-04 18:54:58] info: TASK GIVER: Created local directory: /truebit-eth/tmp.giver_1c5ek5jnhug0
Executing: ./../wasm-client/ocaml-offchain/interpreter/wasm -m -disable-float -output -memory-size 20 -stack-size 20 -table-size 20 -globals-size 8 -call-stack-size 10 -file output.data -file input.data -wasm task.wasm
{
  vm: {
    code: '0xef34a351f42869ed0a1c4f5ba39f4be2377415082083f18592d858bc4361629b',
    stack: '0xf40d787a5a1d95e83bf62e3650806b112627076873a7fa3cdd832250c3c82eea',
    memory: '0x9d71426bf458c911872b7ca15c8959dadfbf73d99e998df7553d5ab59f816836',
    input_size: '0x0e4622ec59dd318509b8d475728ec11bab6c05132b908f19bba96ab64ed8dd29',
    input_name: '0xd3e24e0303f49b3dd3032fa2523603b320c2b2b0eea3693532c6401d315e8a32',
    input_data: '0xccdcd022b89bec0246d141477e6631fc108e56e9b36287a0b3daee64898e1fd2',
    call_stack: '0x8e0167cb6a51b48d61c31c97ff5d8bb3e632a3de1939bb201c4507f908f8d0a7',
    globals: '0x92d1402fb000c5be1173aed60f2f554cabb4c1da645fbe3e093965c2f1b073d6',
    calltable: '0xfad9818866c5279d5125023e4085c3c9facea9cc0083afa0b42f487a0625f18e',
    calltypes: '0x32b4a5f01bf39b515516d7d98afc96803a1550319f3268d13c7055b6975ae994',
    pc: 1099511627775,
    stack_ptr: 1,
    call_ptr: 0,
    memsize: 128
  },
  hash: '0x5d459cf8bbcee56239d3d5f7e9a7df7132accdf09363d53e7ba02be67c5a1a5a',
  steps: 10423523,
  files: [ 'output.data.out', 'input.data.out' ]
}
```
Note that the Task Submitter, Solver, and Verifier always rename the task's code file to `task.wasm` when writing local `tmp.giver_`..., `tmp.solver_`..., and `tmp.verifier_`... files.  The JIT, on the other hand, *requires* that the task file submitted by the Task Giver be named `task.wasm`.

In the example above, one would find all the task files in the indicated directory `/truebit-eth/tmp.giver_1c5ek5jnhug0`.  Files derived from task processing will have a `.out` suffix.  In this example, one should expect to find both an empty file called `output.data`, which was supplied as a task data file, and a file called `output.data.out` containing data generated through task execution.  Note that the file contents of `output.data.out` do not depend on whether `output.data` was specified as one of the `outputs` in `scrypt.json`.


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
We now explore the Truebit Toolchain.  Each of the samples below produces a task code file called `task.wasm`, and each such file is produced by running a script called `compile.sh`.  You can use the `compile.sh` files as templates for generating your own tasks. Inspect sample source codes and their respective compile scripts [here](https://github.com/TruebitProtocol/truebit-eth/tree/master/wasm-ports/samples).  Each compile script first compiles C, C++, or Rust source code, along with included library dependencies, to a pair of WebAssembly JavaScript runtime files using [Emscripten](https://emscripten.org/).  Truebit's [Emscripten module wrapper](https://github.com/TruebitProtocol/truebit-eth/tree/master/emscripten-module-wrapper) then converts these files into a WebAssemebly format executable in Truebit.  Here are is a helpful, legacy [tutorial](https://github.com/TruebitProtocol/truebit-eth/tree/master/wasm-ports/samples/scrypt/README.md) for creating and deploying Truebit tasks as well as a [demo video](https://www.youtube.com/watch?v=dDzPCMBlZN4) illustrating this process.

To view the current Emscripten compiler configuration, which varies based on whether you are using the C/C++ or Rust pipeline, type the following command.
```bash
emcc -v
```

## Compiling from C/C++
From your Truebit container, run the following commands (in this order) to configure the compiler for C/C++ (if you are starting a fresh container, then the last line, `bash /goerli.sh`, will suffice).
```bash
/emsdk/emsdk activate sdk-fastcomp-1.37.36-64bit
/emsdk/emsdk activate binaryen-tag-1.37.36-64bit
source /emsdk/emsdk_env.sh
bash /goerli.sh
```
Note that `bash /goerli.sh` includes compiler setup, so don't skip it.  Exit the `tmux` shell using Ctrl-C, Ctrl-D.  You should now be able to re-compile the sample tasks yourself in C++ (chess, scrypt, pairing), and C (ffmpeg) below.
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
https://github.com/TruebitProtocol/truebit-eth/tree/master/rust-tool).  You can use this guide to re-compile the `/truebit-eth/wasm-ports/samples/wasm` task via the steps below.  First, set up the Rust compiler.
```bash
cd /
git clone https://github.com/georgeroman/emscripten-module-wrapper.git
cd /emscripten-module-wrapper && npm install
/emsdk/emsdk activate 1.39.8
source /emsdk/emsdk_env.sh
ipfs init
( ipfs daemon & )
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
Once you have compiled your task to Truebit-flavored WebAssmebly, try using the files `contract.sol`, and `send.js`, and `../deploy.js` as templates for issuing your own tasks directly from smart contracts.  The API reference [below](#Contract-API-reference) will help you navigate through these templates.  Alternatively, follow the .json template [above](#Writing-task-outputs-via-Truebit-OS) to launch your task within Truebit OS.

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

<https://truebit.io/downloads/>

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

By default, MacOS stores Clef files in `~/Library/Signer/` and Geth files in `~/Library/Ethereum/`. These locations differ from the location in the linux-based Docker container, which are `~/.clef` and `~/.geth`, so mind these differences when you follow the `/goerli.sh` or `/mainnet.sh` startup templates.  This means that in MacOS you'll probably find Clef's IPC socket at:
```bash
~/Library/Signer/clef.ipc
```
Geth's IPC socket at one of these:
```bash
~/Library/Ethereum/geth.ipc
~/Library/Ethereum/goerli/geth.ipc
```
and the keystore files at one of these:
```bash
~/Library/Ethereum/keystore
~/Library/Ethereum/goerli/keystore
```
The `--chainid` for Görli is still 5, and the `--chainid` for mainnet is still 1.

In MacOS, a startup cheatsheet for Görli testnet might look something like this.
```bash
ipfs daemon &
clef --advanced  --rules ~/Library/Signer/ruleset.js --keystore ~/Library/Ethereum/goerli/keystore --chainid 5
geth console --syncmode light --signer ~/Library/Signer/clef.ipc --goerli
./truebit-os -p ~/Library/Ethereum/goerli/geth.ipc
```
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
clef --advanced  --rules ~/.clef/ruleset.js --keystore ~/.ethereum/goerli/keystore --chainid 5
geth console --syncmode light --signer ~/.clef/clef.ipc --goerli
./truebit-os -p ~/.ethereum/goerli/geth.ipc

ipfs daemon &
clef --advanced --rules ~/.clef/ruleset.js --chainid 1
geth console --syncmode light --signer ~/.clef/clef.ipc
./truebit-os -p ~/.ethereum/geth.ipc
```
For Windows, follow the templates above.

# Contract API reference

The following reference highlights some key [Solidity](https://solidity.readthedocs.io/) functions that you may wish to use in your own smart contracts or interact with via [web3.js](https://web3js.readthedocs.io/).  Note that the file `truebit-eth/wasm-client/goerli.json` contains addresses and the ABI interface for Truebit's `fileSystem` and `incentiveLayer` contracts on Görli testnet.  An analogous file for Ethereum mainnet appears in the same directory.  The `tru` token contract follows the standard [ERC-20 interface](https://docs.openzeppelin.com/contracts/3.x/api/token/erc20#IERC20).

Below is a simple "hello world" JavaScript example which prints task data from Truebit's `fileSystem` and `incentiveLayer`.
```js
const fs = require('fs')
const Web3 = require('web3')
const net = require('net')
const web3 = new Web3('/root/.ethereum/goerli/geth.ipc', net)

// Get contract artifacts
let artifacts = JSON.parse(fs.readFileSync('/truebit-eth/wasm-client/goerli.json'))
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
Each code template can then be pasted into a `.js` file and run using Node.js, e.g. `node example.js`.  You'll need to be connected to Görli testnet using `bash /goerli.sh` or otherwise.
The following script provides an additional template for interacting with Truebit's smart contract API.
```bash
truebit-eth/wasm-ports/samples/deploy.js
```
For a template interaction with Solidity, see any one of the [sample tasks](#Sample-tasks-via-smart-contracts), e.g.
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
const web3 = new Web3('/root/.ethereum/goerli/geth.ipc', net)

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

Truebit requires a `codeRoot` input when registering a .wasm or .wast program file to Truebit's file system.  The `codeRoot` for a task program file can be obtained inside Truebit OS using the `task initial` command and read off from the `vm.code` entry. In order to use the template command below, first create a task .json file following the [example](#Writing-task-outputs-via-Truebit-OS) above.  Be sure to run `task initial` with the same virtual machine parameters that you plan to use when you later issue the task.
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

Recall that Truebit reads and writes three [file types](#Getting-data-into-and-out-of-Truebit), 0: BYTES, 1: CONTRACT, and 2: IPFS.  Truebit stores BYTES file contents as bytes32 arrays.

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

* `stack`, `memory`, `globals`, `table`, `call`: These are the same VM parameters `stack-size`, `memory-size`, `globals-size`, `table-size`, `call-stack-size` discussed [above](#Building-your-own-tasks).  You may need to tweak these value to get your task to run, and try changing `memory-size` first.  The task is more likely to succeed with larger parameters.  You may wish to experiment with these parameters by issuing the task [locally](#Writing-task-outputs-via-Truebit-OS) within Truebit OS using `task initial` (to get the `codeRoot`) and `task final` (to verify that the task executes correctly with the given VM parameters).


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

See also sample task [above](#Writing-task-outputs-via-Truebit-OS).

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


