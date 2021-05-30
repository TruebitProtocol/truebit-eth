import json
import pathlib
import tempfile
import zipfile
from io import BytesIO

import zmq
from loguru import logger
import subprocess
import os

"""
This file is in charge of recieving wasm requests from os and running it locally. 
on args it sends different results
"""


class DirectoryDiff:

    def __init__(self, f_path):
        self.f_path = pathlib.Path(f_path)
        self.pre_f_structure = set()

    def _get_dir_structure(self):
        return set(self.f_path.glob("**/*.*"))

    def __enter__(self):
        self.pre_f_structure = self._get_dir_structure()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        pass

    def diff(self):
        post_f_structure = self._get_dir_structure()
        return post_f_structure - self.pre_f_structure


class JobService:

    def __init__(self, host, port):
        context = zmq.Context()
        self.socket = context.socket(zmq.REP)
        self.addr = f"tcp://{host}:{port}"

        self.WASM_LOCATION = os.getenv("TRUEBIT_WASM_LOCATION",
                                       str(pathlib.Path("/truebit-toolchain/interpreter/wasm")))

    def extract_zip(self, td, binary):
        with zipfile.ZipFile(BytesIO(binary)) as thezip:
            for zipinfo in thezip.infolist():
                with thezip.open(zipinfo) as thefile:
                    file_path = pathlib.Path(td).joinpath(zipinfo.filename)
                    if not zipinfo.is_dir():
                        file_path.parent.mkdir(parents=True, exist_ok=True)
                        file_path.write_bytes(thefile.read())

    def zip_diff(self, td, diff_files):

        in_memory = BytesIO()
        zf = zipfile.ZipFile(in_memory, mode="w")
        for f in diff_files:
            f_rel = f.relative_to(td)
            zf.writestr(str(f_rel), f.read_bytes())
        zf.close()
        in_memory.seek(0)
        data = in_memory.read()
        return data

    def run(self):
        RESULT_TYPE_VERIFY_COMPLTE = "verifier_complete"
        RESULT_TYPE_SOLVER_COMPLETE = "solver_task_complete"
        RESULT_TYPE_TASK_GIVER_INITIAL_STATE = "task_giver_initial_state"

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

            result_type = None
            if "-input" in job_data["args"]:
                # TASK Giver creates initial state
                result_type = RESULT_TYPE_TASK_GIVER_INITIAL_STATE
            elif "-input2" in job_data["args"]:
                # SOLVER Sends back solved task
                result_type = RESULT_TYPE_SOLVER_COMPLETE
            elif "-output-io" in job_data["args"]:
                # VERIFIER Task done
                result_type = RESULT_TYPE_VERIFY_COMPLTE

            zip_file = None
            try:
                if job_data["command"] == "wasm":
                    cmd = [str(self.WASM_LOCATION)] + job_data["args"]
                    logger.info("Received job {}. Running", cmd)

                    with tempfile.TemporaryDirectory() as td:
                        # todo. not able to zip results .... check where files are located with ls -la or smthing
                        os.chdir(td)
                        self.extract_zip(td, job_data["zip"])

                        with DirectoryDiff(td) as directory:
                            proc = subprocess.run(cmd, stdout=subprocess.PIPE)
                            result = proc.stdout.decode()

                            pathlib.Path(td).joinpath("test.out").write_text("lel")
                            new_files = directory.diff()

                            zip_file = self.zip_diff(td, new_files)

                    logger.info("Result: {}", result)
            except Exception as e:
                print(e)

            self.socket.send_pyobj(dict(
                result_type=result_type,
                data=result,
                zip=zip_file
            ))


if __name__ == "__main__":
    server_port = os.getenv("TRUEBIT_WASM_SERVICE_PORT", "5700")
    x = JobService("0.0.0.0", server_port)
    x.run()
