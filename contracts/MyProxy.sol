// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyProxy {
    // hardcoded slot for implementation (standard OZ proxy pattern)
    bytes32 private constant IMPLEMENTATION_SLOT = 0x360894A13BA1A3210667C828492DB98DCA3E2076CC3735A920A3CA505D382BBC;
    address public admin;

    constructor(address _logic, bytes memory _data) {
        admin = msg.sender;
        assembly {
            sstore(IMPLEMENTATION_SLOT, _logic)
        }
        if (_data.length > 0) {
            (bool success, ) = _logic.delegatecall(_data);
            require(success, "Initialization failed");
        }
    }

    fallback() external payable {
        assembly {
            let impl := sload(IMPLEMENTATION_SLOT)
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    // Optional receive to suppress warning
    receive() external payable {}
}
