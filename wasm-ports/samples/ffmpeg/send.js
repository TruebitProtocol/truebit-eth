
const fs = require('fs')

const host = "http://localhost:8545"
const ipfs = require('ipfs-api')("localhost", '5001', {protocol: 'http'})

const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.HttpProvider(host))

const getNetwork = require('truebit-util').getNetwork
const merkleRoot = require('truebit-util').merkleRoot.web3

async function addIPFSFile(tbFileSystem, account, name, buf) {
    let ipfsFile = (await ipfs.files.add([{content: buf, path: name}]))[0]

    let ipfsHash = ipfsFile.hash
    let size = buf.length
    // let name = ipfsFile.path

    //setup file
    let fileNonce = Math.floor(Math.random()*Math.pow(2, 30))
    let mr = merkleRoot(web3, buf)

    let fileID = await tbFileSystem.methods.calcId(fileNonce).call({from: account})

    await tbFileSystem.methods.addIPFSFile(name, size, ipfsHash, mr, fileNonce).send({from: account, gas: 300000, gasPrice: web3.gp})

    console.log("Uploaded file", name, "with root", mr)

    return fileID
}

let account, fileSystem, sampleSubmitter

let timeout = async (ms) => new Promise((resolve, reject) => setTimeout(resolve, ms))

async function main() {
    let accounts = await web3.eth.getAccounts()
    account = accounts[1]
    let networkName = await getNetwork(web3)

    //get scrypt submitter artifact
    const artifacts = JSON.parse(fs.readFileSync("public/" + networkName + ".json"))

    fileSystem = new web3.eth.Contract(artifacts.fileSystem.abi, artifacts.fileSystem.address)
    sampleSubmitter = new web3.eth.Contract(artifacts.sample.abi, artifacts.sample.address)
    let fname = process.argv[2] || "input.ts"
    console.log("validating video clip", fname)

    let wasmFile = await addIPFSFile(fileSystem, account, "input.ts", fs.readFileSync(fname))

    // Deposit task fees
    let tru = new web3.eth.Contract(artifacts.tru.abi, artifacts.tru.address)
    await tru.methods.transfer(sampleSubmitter.options.address, web3.utils.toWei('9', 'ether')).send({ from: account, gas: 200000, gasPrice: web3.gp })
    while (await tru.methods.balanceOf(account).call({from:account}) < 9) await timeout(1000)

    // Make Task ID
    let taskID = await sampleSubmitter.methods.makeTaskID(wasmFile).call({from:account})
    console.log("TaskID:", taskID);
    await sampleSubmitter.methods.makeTaskID(wasmFile).send({ gas: 2000000, from: account, gasPrice: web3.gp })

    // Debug (optional)
    IncentiveLayer = new web3.eth.Contract(artifacts.incentiveLayer.abi, artifacts.incentiveLayer.address)
    info = await IncentiveLayer.methods.getTaskInfo(taskID).call({from:account})
    console.log('DEBUG:', info)
    console.log('Task submitted.  Waiting for solution...')

    // Broadcast task
    let platformFee = await sampleSubmitter.methods.getPlatformFee().call({from:account})
    await sampleSubmitter.methods.emitTask(taskID).send({ gas: 100000, from: account, value: platformFee, gasPrice: web3.gp })

    // Wait for solution
    let solution = "0x0000000000000000000000000000000000000000000000000000000000000000"
    while (solution == "0x0000000000000000000000000000000000000000000000000000000000000000") {
        await timeout(1000)
        solution = await sampleSubmitter.methods.getResult(wasmFile).call()
    }
    console.log("Got solution", solution)
}

main()
