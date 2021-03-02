
pragma solidity ^0.5.0;

interface Filesystem {
   function createFileFromArray(string calldata name, uint nonce, bytes32[] calldata arr, uint sz) external returns (bytes32);

   function calcId(uint num) external view returns (bytes32);
   function addToBundle(bytes32 id, bytes32 file_id) external;
   function finalizeBundle(bytes32 bundleID, bytes32 codeFileID) external;
   function hashName(string calldata name) external returns (bytes32);
}

interface TrueBit {
  function createTaskID(bytes32 bundleId, uint minDeposit, uint solverReward, uint verifierTax, uint ownerFee, uint limit) external returns (bytes32);
  function requireFile(bytes32 id, bytes32 hash, /* Storage */ uint8 st) external;
  function submitTask(bytes32 id) external payable;
  function makeDeposit(uint _deposit) external returns (uint);
  function PLATFORM_FEE_TASK_GIVER() external view returns (uint);
}

interface TRU {
    function approve(address spender, uint tokens) external returns (bool success);
}

contract SampleContract {

   event GotFiles(bytes32[] files);
   event InputData(bytes32 data);

   uint nonce;
   TrueBit truebit;
   Filesystem filesystem;
   TRU tru;

   bytes32 codeFileID;
   bytes32 randomFile;

   mapping (bytes32 => bytes32) task_to_file;
   mapping (bytes32 => bytes32) result;

   uint8 memsize;
   uint blocklimit;

   constructor(address tb, address tru_, address fs, bytes32 _codeFileID, uint _blocklimit, bytes32 _randomFileId) public {
       truebit = TrueBit(tb);
       tru = TRU(tru_);
       filesystem = Filesystem(fs);
       codeFileID = _codeFileID;
       randomFile = _randomFileId;
       blocklimit = _blocklimit;
   }

      // this is an axiliary function for makeTaskID
   function submitFileData(bytes32 dataFile) private returns (bytes32) {
      uint num = nonce;
      nonce++;

      emit InputData(dataFile);

      filesystem.addToBundle(num, dataFile);

      bytes32[] memory empty = new bytes32[](0);
      filesystem.addToBundle(num, filesystem.createFileFromArray("output.data", num+1000000000, empty, 0));
      filesystem.addToBundle(num, filesystem.createFileFromArray("output.wasm", num+2000000000, empty, 0));

      filesystem.finalizeBundle(num, codeFileID);
      bytes32 bundleID = filesystem.calcId(num);
      return bundleID;
  }

  // call this first
  function makeTaskID (bytes32 dataFile) external returns (bytes32) {
    bytes32 bundleID = submitFileData(dataFile);
    tru.approve(address(truebit), 9 ether);
    truebit.makeDeposit(9 ether);
    bytes32 taskID = truebit.createTaskID(bundleID, 10 ether, 2 ether, 6 ether, 1 ether, blocklimit);
    truebit.requireFile(taskID, filesystem.hashName("output.wasm"), 2); // 0: eth_bytes, 1: contract, 2: ipfs
    task_to_file[taskID] = dataFile;
    return taskID;
  }

   // call this after makeTaskID
   function emitTask (bytes32 taskID) external payable {
      truebit.submitTask.value(truebit.PLATFORM_FEE_TASK_GIVER())(taskID);
   }

   // this is the callback name
   function solved(bytes32 id, bytes32[] memory files) public {
      // could check the task id
      require(TrueBit(msg.sender) == truebit);
      emit GotFiles(files);
      result[task_to_file[id]] = files[0];
   }

   // need some way to get next state, perhaps shoud give all files as args
   function getResult(bytes32 dataFile) public view returns (bytes32) {
      return result[dataFile];
   }

}
