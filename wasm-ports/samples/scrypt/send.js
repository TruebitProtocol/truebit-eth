
const fs = require('fs')
const Web3 = require('web3')
const net = require('net')
const getNetwork = require('truebit-util').getNetwork

// Network configuration
const web3 = new Web3('/root/.ethereum/goerli/geth.ipc', net)
//const web3 = new Web3('http://localhost:8545')

let account, fileSystem, scryptSubmitter
let timeout = async (ms) => new Promise((resolve, reject) => setTimeout(resolve, ms))

async function main() {
    // Set account for Task Submitter
    let accounts = await web3.eth.getAccounts()
    account = accounts[1]
    let networkName = await getNetwork(web3)

	  // Get Task Owner artifacts
	  const artifacts = JSON.parse(fs.readFileSync("public/" + networkName + ".json"))

	  // Read task input
    scryptSubmitter = new web3.eth.Contract(artifacts.sample.abi, artifacts.sample.address)
    let str = process.argv[2] || "hjkl"
    console.log("Computing scrypt for", str)
    let dta = new Buffer.from(str)

    // Deposit task fees
    let tru = new web3.eth.Contract(artifacts.tru.abi, artifacts.tru.address)
    await tru.methods.transfer(scryptSubmitter.options.address, web3.utils.toWei('9', 'ether')).send({ from: account, gas: 200000, gasPrice: web3.gp })
    while (await tru.methods.balanceOf(account).call({from:account}) < 9) await timeout(1000)
    console.log('Paid TRU task fee')

    // Create Task ID
    let taskID = await scryptSubmitter.methods.makeTaskID(dta).call({from:account})
    console.log("TaskID:", taskID);
    await scryptSubmitter.methods.makeTaskID(dta).send({ gas: 2000000, from: account, gasPrice: web3.gp })

    // Broadcast task
    let IncentiveLayer = new web3.eth.Contract(artifacts.incentiveLayer.abi, artifacts.incentiveLayer.address)
    console.log('DEBUG:', await IncentiveLayer.methods.taskParameters(taskID).call({from:account})) // Debug (optional)
    let platformFee = await IncentiveLayer.methods.PLATFORM_FEE_TASK_GIVER().call({from:account})
    await scryptSubmitter.methods.emitTask(taskID).send({ gas: 100000, from: account, value: platformFee, gasPrice: web3.gp })
    console.log('Task submitted.  Waiting for solution...')

    // Wait for solution
    let solution = "0x0000000000000000000000000000000000000000000000000000000000000000"
    while (solution == "0x0000000000000000000000000000000000000000000000000000000000000000") {
        await timeout(1000)
        solution = await scryptSubmitter.methods.scrypt(dta).call({from:account})
    }
   console.log("Got solution", solution)
}

main()
