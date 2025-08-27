// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;


import "./Ownership.sol";

import '@solady/utils/CREATE3.sol';


contract EPCMint is OwnedInternal, HasOwnershipAuthProxyClient {

  constructor(AuthProxy proxy) AuthProxyClient(proxy) {}

  function epcAddress(string memory epcKey) public view returns (address) {
    return epcAddressWithDeployer(epcKey, address(this));
  }

  function epcAddressWithDeployer(string memory epcKey, address deployer) public pure returns (address) {
    bytes32 hash = keccak256(abi.encode("epc", epcKey));
    return CREATE3.predictDeterministicAddress(hash, deployer);
  }
}


