import json
import pathlib
import tempfile
import zipfile
from io import BytesIO

import zmq
from loguru import logger
import subprocess
import os


class JobService:

    def __init__(self, host, port):
        context = zmq.Context()
        self.socket = context.socket(zmq.REP)
        self.addr = f"tcp://{host}:{port}"

        self.WASM_LOCATION = os.getenv("TRUEBIT_WASM_LOCATION", str(pathlib.Path("/truebit-toolchain/interpreter/wasm")))

    def extract_zip(self, td, binary):
        with zipfile.ZipFile(BytesIO(binary)) as thezip:
            for zipinfo in thezip.infolist():
                with thezip.open(zipinfo) as thefile:
                    file_path = pathlib.Path(td).joinpath(zipinfo.filename)
                    if not zipinfo.is_dir():
                        file_path.parent.mkdir(parents=True, exist_ok=True)
                        file_path.write_bytes(thefile.read())

    def run(self):
        self.socket.bind(self.addr)
        logger.info("Binding job-server on {}", self.addr)

        logger.info("Listening for new jobs....")
        while True:
            #  Wait for next request from client
            job_data = self.socket.recv_pyobj()
            logger.info("[{}] Job Created with command: {}", job_data["id"], job_data["command"])
            assert "id" in job_data, "must have id"
            assert "args" in job_data, "must have args"
            assert "command" in job_data, "must have command"
            assert "type" in job_data, "must have type"
            try:
                if job_data["command"] == "wasm":
                    cmd = [str(self.WASM_LOCATION)] + job_data["args"]
                    logger.info("Received job {}. Running", cmd)

                    with tempfile.TemporaryDirectory() as td:
                        os.chdir(td)
                        self.extract_zip(td, job_data["zip"])
                        proc = subprocess.run(cmd, stdout=subprocess.PIPE)
                        result = proc.stdout.decode()
                    logger.info("Result: {}", result)
            except Exception as e:
                print(e)

            self.socket.send_pyobj(dict(
                data=result
            ))

if __name__ == "__main__":
    server_port = os.getenv("TRUEBIT_WASM_SERVICE_PORT", "5700")
    x = JobService("0.0.0.0", server_port)
    x.run()
