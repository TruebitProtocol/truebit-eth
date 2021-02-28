
pragma solidity ^0.5.0;

interface Filesystem {
   function createFileFromBytes(string calldata name, uint nonce, bytes calldata arr) external returns (bytes32);
   function createFileFromArray(string calldata name, uint nonce, bytes32[] calldata arr, uint sz) external returns (bytes32);
   function getBytesData(bytes32 id) external view returns (bytes32[] memory);

   function calcId(uint num) external view returns (bytes32);
   function addToBundle(bytes32 id, bytes32 file_id) external;
   function finalizeBundle(bytes32 bundleID, bytes32 codeFileID) external;
   function addIPFSFile(string calldata name, uint size, string calldata hash, bytes32 root, uint nonce) external returns (bytes32);
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

   event NewTask(bytes data);
   event FinishedTask(bytes data, bytes32 result);

   uint nonce;
   TrueBit truebit;
   Filesystem filesystem;
   TRU tru;

   bytes32 codeFileID;
   bytes32 randomFile;

   mapping (bytes => bytes32) string_to_file;
   mapping (bytes32 => bytes) task_to_string;
   mapping (bytes => bytes32) result;

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
    function submitFileData(bytes memory data) private returns (bytes32) {
      uint num = nonce;
      nonce++;

      emit NewTask(data);

      bytes32 inputFileID = filesystem.createFileFromBytes("input.data", num, data);
      string_to_file[data] = inputFileID;
      filesystem.addToBundle(num, inputFileID);

      filesystem.addToBundle(num, randomFile);

      bytes32[] memory empty = new bytes32[](0);
      filesystem.addToBundle(num, filesystem.createFileFromArray("output.data", num+1000000000, empty, 0));

      filesystem.finalizeBundle(num, codeFileID);
      bytes32 bundleID = filesystem.calcId(num);
      return bundleID;
    }

    // call this first
    function makeTaskID (bytes calldata data) external returns (bytes32) {
      bytes32 bundleID = submitFileData(data);
      tru.approve(address(truebit), 9 ether);
      truebit.makeDeposit(9 ether);
      bytes32 taskID = truebit.createTaskID(bundleID, 10 ether, 2 ether, 6 ether, 1 ether, blocklimit);
      truebit.requireFile(taskID, filesystem.hashName("output.data"), 0); // 0: eth_bytes, 1: contract, 2: ipfs
      task_to_string[taskID] = data;
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
      bytes32[] memory arr = filesystem.getBytesData(files[0]);
      result[task_to_string[id]] = arr[0];
      emit FinishedTask(task_to_string[id], arr[0]);
   }

   // need some way to get next state, perhaps shoud give all files as args
   function getResult(bytes memory data) public view returns (bytes32) {
      return result[data];
   }

}
