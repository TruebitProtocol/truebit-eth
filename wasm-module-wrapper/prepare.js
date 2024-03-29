
const fs = require('fs-extra');
let argv = require('minimist')(process.argv.slice(2));
const ipfsAPI = require('ipfs-api');
const { spawn, execFile } = require('child_process');
const path = require('path');

let dir = path.dirname(fs.realpathSync(__filename)) + '/';

let tmp_dir = "/tmp/wasm-module-wrapper" + Math.floor(Math.random() * Math.pow(2, 32)).toString(32)
if (argv.out) tmp_dir = path.resolve(process.cwd(), argv.out);

fs.mkdirpSync(tmp_dir);

let debug = false
if (argv.debug) debug = true

// fix pathing so we don't need to worry about what dir we are in.
const fixPaths = (targetDir, relativePathsArray) => {
  //  console.log(targetDir, relativePathsArray)
  if (typeof relativePathsArray == "string") relativePathsArray = [relativePathsArray]
  return relativePathsArray.map(filePath => {
    let start = path.resolve(process.cwd(), filePath);
    let localPath = path.basename(filePath)
    let end = path.resolve(targetDir, localPath);
    fs.copySync(start, end);
    return localPath;
  });
};

const localizeArgv = argv => {
  fixPaths(tmp_dir, argv._);
  argv._ = [fixPaths(tmp_dir, argv._)[0]];

  // move files
  if (!argv.file) argv.file = []
  fixPaths(tmp_dir, argv.file);
  argv.file = fixPaths(tmp_dir, argv.file);
  return argv;
};

argv = localizeArgv(argv);

let config = [];

function readConfig() {
  try {
    config = JSON.parse(
      fs.readFileSync(dir + '../webasm-solidity/node/config.json')
    );
  } catch (e) { }
}

readConfig();

let wasm = dir + '../ocaml-offchain/interpreter/wasm';

function exec(cmd, args) {
  return new Promise((resolve, reject) => {
    if (debug) console.log(cmd, args.join(" "))
    execFile(cmd, args, { cwd: tmp_dir }, (error, stdout, stderr) => {
      if (error) {
        console.error('error ', error);
        reject(error);
      }
      if (stderr) {
        if (debug) console.error('error ', stderr, args);
        // reject(stderr);
      }
      if (stdout) {
        if (debug) console.log('output ', stdout, args);
      }
      resolve(stdout);
    });
  });
}

function spawnPromise(cmd, args) {
  return new Promise((resolve, reject) => {
    var res = '';
    if (debug) console.log(cmd, args.join(" "))
    const p = spawn(cmd, args, { cwd: tmp_dir });

    p.on('error', err => {
      console.log('Failed to start subprocess.');
      reject(err);
    });

    p.stdout.on('data', data => {
      res += data;
      if (debug) console.log(`stdout: ${data}`);
    });

    p.stderr.on('data', data => {
      if (debug) console.log(`stderr: ${data}`);
    });

    p.on('close', code => {
      if (debug) console.log(`child process exited with code ${code}`);
      resolve(res);
    });
  });
}

function flatten(lst) {
  return [].concat.apply([], lst);
}

function clean(obj, field) {
  var x = obj[field];
  if (typeof x == 'object') return;
  if (typeof x == 'undefined') obj[field] = [];
  else obj[field] = [x];
}

async function processTask(fname) {
  var wasm_file = fname;

  clean(argv, 'arg');
  clean(argv, 'file');

  await exec('wasm2wat', [wasm_file, '-o', 'test.wat'])
  await exec('sed', ['-i', 's/[(]export "memory" [(]memory 0[)][)]/(export "memory" (memory 0))\\n(export "env_malloc" (func $malloc))/g', 'test.wat'])
  await exec('sed', ['-i', 's/wasi_unstable/wasi_snapshot_preview1/g', 'test.wat'])
  await exec('wat2wasm', ['test.wat', '-o', 'withmalloc.wasm'])
  if (!argv.rust) {
    await exec(dir+'../memory-ops/ops.native', ['withmalloc.wasm', dir+'bulkmemory.wasm', 'tomerge.wasm'])
  } else {
    await exec('cp', ['withmalloc.wasm', 'tomerge.wasm'])
  }
  let gas = 10000
  if (argv.metering) {
    gas = parseInt(argv.metering)
  }
  await exec(wasm, [
    '-u', '-gas-limit', gas, '-merge',
    'tomerge.wasm',
    dir + 'filesystem.wasm'
  ]);
  await exec(wasm, ['-u', '-underscore', 'merge.wasm']);


  let mem_size = argv['memory-size'] || '25';
  let result_wasm = 'underscore.wasm';

  let args = flatten(argv.arg.map(a => ['-arg', a]));
  args = args.concat(flatten(argv.file.map(a => ['-file', a])));
  if (config.interpreter_args) args = args.concat(config.interpreter_args);

  let float_memory = 10 * 1024;
  if (argv.float) {
    await exec(wasm, ['-shift-mem', float_memory, result_wasm]);
    await exec(wasm, [
      '-u', '-memory-offset', float_memory,
      '-int-float', dir + 'softfloat.wasm',
      'shiftmem.wasm'
    ]);
    result_wasm = 'intfloat.wasm';
  }

  let run_wasm = result_wasm

  if (argv.metering) {
    const dta = fs.readFileSync(tmp_dir + '/' + result_wasm);
    const metering = require('wasm-metering-tb');
    const meteredWasm = metering.meterWASM(dta, {
      moduleStr: 'env',
      fieldStr: 'usegas',
      meterType: 'i32'
    });
    fs.writeFileSync(tmp_dir + '/metered.wasm', meteredWasm);
    run_wasm = 'metered.wasm';
  }

  if (argv['limit-stack']) {
    await exec(wasm, ['-u', '-limit-stack', run_wasm]);
    run_wasm = "stacklimit.wasm"
  }

  const info = await spawnPromise(
    wasm,
    [
      '-u',
      '-m',
      '-disable-float',
      '-input',
      '-table-size', '20',
      '-stack-size', '20',
      '-memory-size', mem_size,
      '-wasm', run_wasm
    ].concat(args)
  );

  if (argv.run)
    await spawnPromise(
      wasm,
      [
        '-u',
        '-m',
        '-disable-float',
        '-table-size',
        '20',
        '-stack-size',
        '20',
        '-memory-size',
        mem_size,
        '-wasm',
        run_wasm
      ].concat(args)
    );

  if (!argv['upload-ipfs']) {
    console.log(JSON.stringify(JSON.parse(info), null, 2));
  }

  if (argv['upload-ipfs']) {
    const host = argv['ipfs-host'] || 'localhost';

    const ipfs = ipfsAPI(host, '5001', { protocol: 'http' });

    const uploadIPFS = fname => {
      return new Promise(function (cont, err) {
        fs.readFile(tmp_dir + '/' + fname, function (err, buf) {
          ipfs.files.add([{ content: buf, path: fname }], function (err, res) {
            cont(res[0]);
          });
        });
      });
    };

    const hash = await uploadIPFS(result_wasm);

    let infoJson = JSON.stringify(
      {
        ipfshash: hash.hash,
        codehash: JSON.parse(info).vm.code,
        info: JSON.parse(info),
        memsize: mem_size,
        gas: gas,
      },
      null,
      2
    );

    console.log(infoJson);

    fs.writeFileSync(path.join(tmp_dir, 'info.json'), infoJson);
  }
  // cleanUpAfterInstrumenting();
}

argv._.forEach(processTask);
