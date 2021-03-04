const fs = require('fs')
const ipfs = require('ipfs-api')("localhost", '5001', { protocol: 'http' })
const getNetwork = require('truebit-util').getNetwork
const merkleRoot = require('truebit-util').merkleRoot.web3
const Web3 = require('web3')
const net = require('net');

// Network configuration
const web3 = new Web3('/root/.ethereum/goerli/geth.ipc', net)
//const web3 = new Web3('http://localhost:8545')

// Load interface for sample contract
let abi = JSON.parse(fs.readFileSync('./build/SampleContract.abi'))
let bin = fs.readFileSync('./build/SampleContract.bin')

// This function is used to add a "random file" in some samples
async function addRandomIPFSFile(tbFileSystem, account, name, buf) {
    let ipfsFile = (await ipfs.files.add([{ content: buf, path: name }]))[0]
    let ipfsHash = ipfsFile.hash
    let size = buf.length

    //setup file
    let fileNonce = Math.floor(Math.random() * Math.pow(2, 30))
    let mr = merkleRoot(web3, buf)
    let fileID = await tbFileSystem.methods.calculateId(fileNonce).call({ from: account })
    await tbFileSystem.methods.addIpfsFile(name, size, ipfsHash, mr, fileNonce).send({ from: account, gas: 300000 })
    console.log("Uploaded file", name, "with root", mr)
    return fileID
}

// Main function
async function deploy() {

    // Upload .wasm codefile to IPFS
    let codeBuf = fs.readFileSync("./task.wasm")
    let ipfsFile = (await ipfs.files.add([{ content: codeBuf, path: "task.wasm" }]))[0]
    console.log(ipfsFile)
    let ipfsHash = ipfsFile.hash
    let size = codeBuf.byteLength
    let name = ipfsFile.path
    console.log("Uploaded codefile to IPFS")

    // Get artifacts for Truebit fileSystem and token contract
    let networkName = await getNetwork(web3)
    let artifacts = JSON.parse(fs.readFileSync('../../../wasm-client/' + networkName + '.json'))
    let tbFileSystem = new web3.eth.Contract(artifacts.fileSystem.abi, artifacts.fileSystem.address)
    let tru = new web3.eth.Contract(artifacts.tru.abi, artifacts.tru.address)

    // Get precomputed initial machine state for sample task
    let info = JSON.parse(fs.readFileSync('./info.json'))
    let codeRoot = info.codehash

    // Set account options for contract deploy
    let accounts = await web3.eth.getAccounts()
    let account = accounts[1]
    let options = { from: account.toLowerCase(), gas: 4000000 }

    // upload random file, if applicable
    let randomFile
    try {
        randomFile = await addRandomIPFSFile(tbFileSystem, account, "_dev_urandom", fs.readFileSync("_dev_urandom"))
    }
    catch (e) {
        console.log("Random file does't exist")
    }

    // List constructor parameters for sample contract
    let fileNonce = Math.floor(Math.random() * Math.pow(2, 30))
    let codeFileID = await tbFileSystem.methods.calculateId(fileNonce).call({ from: account })
    let args = [
        artifacts.incentiveLayer.address,
        artifacts.tru.address,
        artifacts.fileSystem.address,
        codeFileID,
        info.blocklimit || 3
    ]
    if (randomFile) args.push(randomFile)

    // Add codefile to Truebit filesystem
    let mr = merkleRoot(web3, codeBuf)
    await tbFileSystem.methods.addIpfsFile(name, size, ipfsHash, mr, fileNonce).send({ from: account, gas: 300000 })
    await tbFileSystem.methods.setCodeRoot(fileNonce, codeRoot, 1, 20, info.memsize, 8, 20, 10).send({ from: account, gas: 300000 } )
    console.log("Registered codefile with Truebit filesystem")
    console.log(await tbFileSystem.methods.vmParameters(codeFileID).call({from:account}))

    // Deploy sample contract
    let contract = new web3.eth.Contract(abi)
    let c = await contract.deploy({ data: "0x" + bin, arguments: args }).send(options)
    artifacts["sample"] = { address: c.options.address, abi: abi }
    fs.writeFileSync("public/" + networkName + ".json", JSON.stringify(artifacts))

    // UNCOMMENT TO PRELOAD CONTRACT WITH FEES
    //tru.methods.transfer(c.options.address, "100000000000000000000").send({ from: accounts[0], gas: 200000 })

    console.log("Contract has been deployed at " + c.options.address)
}

deploy()
