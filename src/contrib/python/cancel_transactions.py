from bs4 import BeautifulSoup
import requests
import argparse
from web3 import Web3
# TODO - this script should not really be used

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--address", required=True, help="Address of the user to cancel all transactions")
    parser.add_argument("--network", default="goerli", help="Which network to cancel the transactions from")
    parser.add_argument("--geth_host", default="localhost", help="Which hostname the geth instance is located at")
    parser.add_argument("--gas_price", default=43.3, type=float, help="Which hostname the geth instance is located at")

    args = parser.parse_args()

    network_urls = dict(
        goerli="https://goerli.etherscan.io/address/%s",
        mainnet="https://etherscan.io/address/%s"
    )

    assert args.network in network_urls, f"The network {args.network} does not exists in our database."

    response = requests.get(network_urls[args.network] % (args.address, ), headers={
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36"
    })

    soup = BeautifulSoup(response.content, "html.parser")
    pending_rows = [x.parent.parent for x in soup.find_all("i", text="(pending)")]
    pending_transactions = [list(x.children)[1].text for x in pending_rows]

    w3 = Web3(Web3.HTTPProvider(f'http://{args.geth_host}:8545'))

    for pt in reversed(pending_transactions):
        transaction_info = dict(w3.eth.get_transaction(pt))
        transaction_info["gas"] = int(7500000) #w3.toHex(int(args.gas_cost * 1000.0)),
        price = min(int(args.gas_price * 1000.0), int(transaction_info["gasPrice"] * 1.5))
        transaction_info["gasPrice"] = price #w3.toHex()
        # https://goerli.etherscan.io/address/0x0860Ec7299828B97028cE5742C5588471Fcfc333

        print(transaction_info)
        w3.eth.send_transaction(transaction_info)


