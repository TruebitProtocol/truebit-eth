import time
import os
import subprocess
import pathlib
import json


def clef_init():
    if master_seed_file.exists():
        print("master key already exists... Skipping.")
        return True

    p = subprocess.Popen(["clef", "--stdio-ui", "init"],
                         stdout=subprocess.PIPE, stdin=subprocess.PIPE, stderr=subprocess.STDOUT, shell=False)
    out = p.communicate(master_secret.encode() + b"\n" + master_secret.encode() + b"\n")[0]
    print(out.decode())

    # Set permissions
    master_seed_file.chmod(0o400)


def clef_attest():
    print("Clef-attest----")
    p = subprocess.Popen(["clef", "--stdio-ui", "attest", attest],
                         stdout=subprocess.PIPE, stdin=subprocess.PIPE, stderr=subprocess.STDOUT, shell=False)
    out = p.communicate(master_secret.encode() + b"\n" + master_secret.encode() + b"\n")[0]
    print(out.decode())


def clef_autologin():
    print("Clef-autologin----")

    keystore_file = list(keystore.glob("*--*--*"))[0]
    public_address = keystore_file.name.split("--")[-1]

    p = subprocess.Popen(["clef", "--stdio-ui", "setpw", public_address],
                         stdout=subprocess.PIPE, stdin=subprocess.PIPE, stderr=subprocess.STDOUT, shell=False)
    out = p.communicate(
        account_secret.encode() + b"\n" +
        account_secret.encode() + b"\n" +
        master_secret.encode() + b"\n" +
        master_secret.encode() + b"\n"
    )[0]
    print(out.decode())


def clef_account_init():
    if len(list(keystore.glob("*--*--*"))):
        print("Account already exists... Skipping!")
        return True

    p = subprocess.Popen(["clef", "--stdio-ui", "newaccount", f"--keystore={str(keystore)}"],
                         stdout=subprocess.PIPE, stdin=subprocess.PIPE, stderr=subprocess.STDOUT, shell=False)
    out = p.communicate(input=account_secret.encode() + b"\n")[0]
    print(out.decode())


def clef_run():
    ruleset = pathlib.Path("/rules/rules.js")
    audit_log = log_dir.joinpath("clef_audit.log")

    login = {"jsonrpc": "2.0", "id": 1, "result": {"text": master_secret}}

    p = subprocess.Popen(
        [
            "clef",
            "--stdio-ui",
            "--advanced",
            "--nousb",
            "--chainid=5",
            f"--keystore={str(keystore)}",
            f"--rules={str(ruleset)}",
            "--http",
            "--http.addr=0.0.0.0",
            "--http.vhosts=*",
            f"--auditlog={str(audit_log)}",
            "--ipcdisable"
        ],
        stdin=subprocess.PIPE, stderr=subprocess.STDOUT, shell=False)
    time.sleep(.5)
    out = p.communicate(input=json.dumps(login).encode() + b"\n")[0]

    while p.poll():
        print("POLL")
        time.sleep(.1)


if __name__ == "__main__":
    attest = os.getenv("CLEF_ATTEST")
    assert attest, "CLEF_ATTEST environment variable must be set!"

    master_secret = os.getenv("CLEF_MASTER_SECRET")
    assert master_secret, "CLEF_MASTER_SECRET environment variable must be set!"

    account_secret = os.getenv("CLEF_ACCOUNT_SECRET")
    assert account_secret, "SECRET environment variable must be set!"

    network = os.getenv("CLEF_NETWORK")
    assert network, "NETWORK environment variable must be set!"

    # Path definitions
    home_dir = pathlib.Path.home()
    keystore = home_dir.joinpath(f".ethereum/{network}/keystore")
    master_seed_file = home_dir.joinpath(".clef/masterseed.json")
    log_dir = home_dir.joinpath("logs/")
    log_dir.mkdir(exist_ok=True)

    # First initialize clef
    clef_init()
    clef_attest()

    # Create account if no exists
    clef_account_init()
    clef_autologin()

    # Run clef
    clef_run()
