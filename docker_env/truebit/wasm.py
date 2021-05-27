#!/usr/bin/env python3

# This is a wasm relay.

import os
import uuid
from zipfile import ZipFile
from io import BytesIO
import pathlib

def zip_current_dir():
    in_memory = BytesIO()
    zf = ZipFile(in_memory, mode="w")
    cwd = os.getcwd()
    for f in pathlib.Path(cwd).glob("**/*.*"):
        f_rel = f.relative_to(cwd)
        zf.writestr(str(f_rel), f_rel.read_bytes())
    zf.close()
    in_memory.seek(0)
    data = in_memory.read()
    return data


if __name__ == "__main__":
    import sys
    import zmq

    server_port = os.getenv("TRUEBIT_WASM_SERVICE_PORT", "5700")
    server_host = os.getenv("TRUEBIT_WASM_SERVICE_HOST", "localhost")

    # job request data creation
    request_data = dict(
        id=str(uuid.uuid4()),
        type="job",
        command="wasm",
        zip=zip_current_dir(),
        args=sys.argv[1:]
    )

    # Connect to the job server
    context = zmq.Context()
    socket = context.socket(zmq.REQ)
    socket.connect(f"tcp://{server_host}:{server_port}")

    # Sends a work request
    socket.send_pyobj(request_data)

    # Hangs until it gets response
    message = socket.recv_pyobj()

    # Outputs the resulting json
    print(message["data"])

    # Finishing up
    socket.close()
