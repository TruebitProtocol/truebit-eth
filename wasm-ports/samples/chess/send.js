
const fs = require('fs')

const host = "http://localhost:8545"
const assert = require('assert')

const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.HttpProvider(host))

const getNetwork = require('truebit-util').getNetwork

let account, fileSystem, sampleSubmitter

let timeout = async (ms) => new Promise((resolve, reject) => setTimeout(resolve, ms))

async function main() {
    let accounts = await web3.eth.getAccounts()
    account = accounts[1]
    let networkName = await getNetwork(web3)

    //get scrypt submitter artifact
    const artifacts = JSON.parse(fs.readFileSync("public/" + networkName + ".json"))

    // fileSystem = new web3.eth.Contract(artifacts.fileSystem.abi, artifacts.fileSystem.address)
    sampleSubmitter = new web3.eth.Contract(artifacts.sample.abi, artifacts.sample.address)
    let str = process.argv[2] || "hjkl"
    console.log("checking chess moves", str)
    let dta = new Buffer(str)

    // Deposit task fees
    let tru = new web3.eth.Contract(artifacts.tru.abi, artifacts.tru.address)
    await tru.methods.transfer(sampleSubmitter.options.address, web3.utils.toWei('9', 'ether')).send({ from: account, gas: 200000, gasPrice: web3.gp })
    while (await tru.methods.balanceOf(account).call({from:account}) < 9) await timeout(1000)

    // Make Task ID
    let taskID = await sampleSubmitter.methods.makeTaskID(dta).call({from:account})
    console.log("TaskID:", taskID);
    await sampleSubmitter.methods.makeTaskID(dta).send({ gas: 2000000, from: account, gasPrice: web3.gp })

    let IncentiveLayer = new web3.eth.Contract(artifacts.incentiveLayer.abi, artifacts.incentiveLayer.address)
    // Debug (optional)
    info = await IncentiveLayer.methods.getTaskInfo(taskID).call({from:account})
    console.log('DEBUG:', info)
    console.log('Task submitted.  Waiting for solution...')

    // Broadcast task
    let platformFee = await IncentiveLayer.methods.PLATFORM_FEE_TASK_GIVER().call({from:account})
    await sampleSubmitter.methods.emitTask(taskID).send({ gas: 100000, from: account, value: platformFee, gasPrice: web3.gp })

    // Wait for solution
    let solution = ""
    while (solution == "") {
        await timeout(1000)
        let raw = await sampleSubmitter.methods.getResult(dta).call({from:account})
        solution = Buffer.from(raw.map(a => a.substr(2)).join(""), "hex").toString()
    }
    console.log("Got solution:", solution)

}

main()
