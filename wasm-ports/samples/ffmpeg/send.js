
const fs = require('fs')
const Web3 = require('web3')
const net = require('net')
const ipfs = require('ipfs-api')("localhost", '5001', {protocol: 'http'})
const getNetwork = require('truebit-util').getNetwork
const merkleRoot = require('truebit-util').merkleRoot.web3

// Network configuration
const web3 = new Web3('/root/.ethereum/goerli/geth.ipc', net)
//const web3 = new Web3('http://localhost:8545')

let account, fileSystem, sampleSubmitter
let timeout = async (ms) => new Promise((resolve, reject) => setTimeout(resolve, ms))

// Subroutine to upload input file to Truebit file system via IPFS
async function addIPFSFile(tbFileSystem, account, name, buf) {
    // Upload input file to IPFS
    let ipfsFile = (await ipfs.files.add([{content: buf, path: name}]))[0]
    let ipfsHash = ipfsFile.hash
    let size = buf.length

    // Register input file with Truebit filesysten
    let fileNonce = Math.floor(Math.random()*Math.pow(2, 30))
    let mr = merkleRoot(web3, buf)
    let fileID = await tbFileSystem.methods.calcId(fileNonce).call({from: account})
    await tbFileSystem.methods.addIpfsFile(name, size, ipfsHash, mr, fileNonce).send({from: account, gas: 300000, gasPrice: web3.gp})
    console.log("Uploaded and registered file", name, "with root", mr)
    return fileID
}

async function main() {
    // Set account for Task Submitter
    let accounts = await web3.eth.getAccounts()
    account = accounts[1]
    let networkName = await getNetwork(web3)

    // Get Task Owner and file system artifacts
    const artifacts = JSON.parse(fs.readFileSync("public/" + networkName + ".json"))
    sampleSubmitter = new web3.eth.Contract(artifacts.sample.abi, artifacts.sample.address)
    fileSystem = new web3.eth.Contract(artifacts.fileSystem.abi, artifacts.fileSystem.address)

    // Read task input
    let fname = process.argv[2] || "input.ts"
    console.log("validating video clip", fname)
    let videoFile = await addIPFSFile(fileSystem, account, "input.ts", fs.readFileSync(fname))

    // Deposit task fees
    let tru = new web3.eth.Contract(artifacts.tru.abi, artifacts.tru.address)
    await tru.methods.transfer(sampleSubmitter.options.address, web3.utils.toWei('9', 'ether')).send({ from: account, gas: 200000, gasPrice: web3.gp })
    while (await tru.methods.balanceOf(account).call({from:account}) < 9) await timeout(1000)
    console.log('Paid TRU task fee')

    // Create Task ID
    let taskID = await sampleSubmitter.methods.makeTaskID(videoFile).call({from:account})
    console.log("TaskID:", taskID);
    await sampleSubmitter.methods.makeTaskID(videoFile).send({ gas: 2000000, from: account, gasPrice: web3.gp })

    // Broadcast task
    let IncentiveLayer = new web3.eth.Contract(artifacts.incentiveLayer.abi, artifacts.incentiveLayer.address)
    console.log('DEBUG:', await IncentiveLayer.methods.taskParameters(taskID).call({from:account})) // Debug (optional)
    let platformFee = await IncentiveLayer.methods.PLATFORM_FEE_TASK_GIVER().call({from:account})
    await sampleSubmitter.methods.emitTask(taskID).send({ gas: 100000, from: account, value: platformFee, gasPrice: web3.gp })
    console.log('Task submitted.  Waiting for solution...')

    // Wait for solution
    let solution = "0x0000000000000000000000000000000000000000000000000000000000000000"
    while (solution == "0x0000000000000000000000000000000000000000000000000000000000000000") {
        await timeout(1000)
        solution = await sampleSubmitter.methods.getResult(videoFile).call()
    }
    console.log("Got solution", solution)
}

main()
