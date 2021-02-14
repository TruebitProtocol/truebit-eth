
const fs = require('fs')
const Web3 = require('web3')
const net = require('net')
const getNetwork = require('truebit-util').getNetwork

// Network configuration
const web3 = new Web3('/root/.ethereum/goerli/geth.ipc', net)
//const web3 = new Web3('http://localhost:8545')

let account, fileSystem, sampleSubmitter
let timeout = async (ms) => new Promise((resolve, reject) => setTimeout(resolve, ms))

async function main() {
    // Set account for Task Submitter
    let accounts = await web3.eth.getAccounts()
    account = accounts[1]
    let networkName = await getNetwork(web3)

    // Get Task Owner and file system artifacts
    const artifacts = JSON.parse(fs.readFileSync("public/" + networkName + ".json"))
    sampleSubmitter = new web3.eth.Contract(artifacts.sample.abi, artifacts.sample.address)

    // Read task input
    let str = process.argv[2] || "hjklwoeijdwoeijdowiejdowiejdoiwjeodiwjoeidjwoeidjwoeijd"
    if (str.length < 32) console.log("Warning! The input should be more than 32 characters")
    console.log("Computing bilinear pairing for", str)
    let dta = new Buffer.from(str)

    // Deposit task fees
    let tru = new web3.eth.Contract(artifacts.tru.abi, artifacts.tru.address)
    await tru.methods.transfer(sampleSubmitter.options.address, web3.utils.toWei('9', 'ether')).send({ from: account, gas: 200000, gasPrice: web3.gp })
    while (await tru.methods.balanceOf(account).call({from:account}) < 9) await timeout(1000)
    console.log('Deposited TRU task fee')

    // Create Task ID
    let taskID = await sampleSubmitter.methods.makeTaskID(dta).call({from:account})
    console.log("TaskID:", taskID);
    await sampleSubmitter.methods.makeTaskID(dta).send({ gas: 2000000, from: account, gasPrice: web3.gp })

    // Broadcast task
    let IncentiveLayer = new web3.eth.Contract(artifacts.incentiveLayer.abi, artifacts.incentiveLayer.address)
    console.log('DEBUG:', await IncentiveLayer.methods.getTaskInfo(taskID).call({from:account})) // Debug (optional)
    let platformFee = await IncentiveLayer.methods.PLATFORM_FEE_TASK_GIVER().call({from:account})
    await sampleSubmitter.methods.emitTask(taskID).send({ gas: 100000, from: account, value: platformFee, gasPrice: web3.gp })
    console.log('Task submitted.  Waiting for solution...')

    // Wait for solution
    let solution = "0x0000000000000000000000000000000000000000000000000000000000000000"
    while (solution == "0x0000000000000000000000000000000000000000000000000000000000000000") {
        await timeout(1000)
        solution = await sampleSubmitter.methods.getResult(dta).call({from:account})
    }
    console.log("Got solution", solution)
}

main()
