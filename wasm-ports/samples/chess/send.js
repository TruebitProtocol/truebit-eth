
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
    account = accounts[0]
    let networkName = await getNetwork(web3)

    //get scrypt submitter artifact
    const artifacts = JSON.parse(fs.readFileSync("public/" + networkName + ".json"))

    // fileSystem = new web3.eth.Contract(artifacts.fileSystem.abi, artifacts.fileSystem.address)
    sampleSubmitter = new web3.eth.Contract(artifacts.sample.abi, artifacts.sample.address)
    let str = process.argv[2] || "hjkl"
    console.log("checking chess moves", str)
    let dta = new Buffer(str)

    let tru = new web3.eth.Contract(artifacts.tru.abi, artifacts.tru.address)
    tru.methods.transfer(sampleSubmitter.options.address, web3.utils.toWei('9', 'ether')).send({ from: account, gas: 200000 })

    let bundleID = await sampleSubmitter.methods.submitFileData(dta).call()
    await sampleSubmitter.methods.submitFileData(dta).send({ gas: 1000000, from: account, gasPrice: web3.gp })
    let taskID = await sampleSubmitter.methods.initializeTask(bundleID,dta).call()
    await sampleSubmitter.methods.initializeTask(bundleID,dta).send({ gas: 500000, from: account, gasPrice: web3.gp })
    let liquidityFee = await sampleSubmitter.methods.getLiquidityFee().call()
    await sampleSubmitter.methods.deployTask(taskID).send({ gas: 500000, from: account, value: liquidityFee, gasPrice: web3.gp })
    
    let solution = ""
    while (solution == "") {
        await timeout(1000)
        let raw = await sampleSubmitter.methods.getResult(dta).call()
        solution = Buffer.from(raw.map(a => a.substr(2)).join(""), "hex").toString()
    }
    console.log("Got solution:", solution)

}

main()
