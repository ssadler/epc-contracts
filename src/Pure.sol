

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;


import { deriveEpcAddressWithDeployer } from './Mint.sol';


contract EPCPure {
  function epcAddressWithDeployer(string memory epcKey, address deployer) public pure returns (address) {
    return deriveEpcAddressWithDeployer(deployer, epcKey);
  }
}
