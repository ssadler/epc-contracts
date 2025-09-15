// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;


import "./Ownership.sol";

import '@solady/utils/CREATE3.sol';



contract EPCMint is OwnedInternal, HasOwnershipAuthProxyClient {

  constructor(AuthProxy proxy) AuthProxyClient(proxy) {}

  function epcAddress(string memory epcKey) public view returns (address) {
    return getEpcAddressWithDeployer(epcKey, address(this));
  }
}

function getEpcSalt(string memory epcKey) pure returns (bytes32 salt) {
  /// @solidity memory-safe-assembly
  assembly {
    let len := mload(epcKey)
    mstore(epcKey, "ETHEREUM PLACE CODE")
    salt := keccak256(epcKey, add(len, 0x20))
    mstore(epcKey, len)
  }
}


function getEpcAddressWithDeployer(string memory epcKey, address deployer) pure returns (address) {

  bytes32 salt = getEpcSalt(epcKey);
  return CREATE3.predictDeterministicAddress(salt, deployer);
}

