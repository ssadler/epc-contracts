// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;


import "./Ownership.sol";

import '@solady/utils/CREATE3.sol';
import '@solady/utils/LibString.sol';



/*
 * Derive EPC address given key and deploying contract.
 */
function deriveEpcAddressWithDeployer(address deployer, string memory epcKey) pure returns (address) {
  bytes32 salt = getEpcSalt(epcKey);
  return CREATE3.predictDeterministicAddress(salt, deployer);
}

/*
 * Returns the salt for an EPC key, used to derive the future deployment address.
 *
 * Effectively: keccak256("ETHEREUM PLACE CODE\0\0\0\0\0\0\0\0\0\0\0\0\0{epcKey}")
 */
function getEpcSalt(string memory epcKey) pure returns (bytes32 salt) {
  /// @solidity memory-safe-assembly
  assembly {
    let len := mload(epcKey)
    mstore(epcKey, "ETHEREUM PLACE CODE")       // Overwrite length word with our prefix
    salt := keccak256(epcKey, add(len, 0x20))
    mstore(epcKey, len)                         // Restore length word
  }
}


/*
 * Contract to mint EPCs
 */
contract EPCMint is OwnedInternal, HasOwnershipAuthProxyClient {

  constructor(AuthProxy proxy) AuthProxyClient(proxy) {}

  /*
   * Derive EPC address for this instance.
   */
  function epcAddress(string memory epcKey) public view returns (address) {
    return deriveEpcAddressWithDeployer(address(this), epcKey);
  }

  /*
   * Run a sanity test
   */
  function sanityTest() public onlyOwner returns (address created) {
    string memory epcKey = "EPC_MINT_TEST";
    created = CREATE3.deployDeterministic(type(EpcMintTest).creationCode, getEpcSalt(epcKey));
    if (created != epcAddress(epcKey)) {
      revert("EPC mint test failed: address");
    }
    if (EpcMintTest(created).abc() != 111) {
      revert("EPC mint test failed: uncallable");
    }
  }
}


contract EpcMintTest {
  function abc() public pure returns (uint) {
    return 111;
  }
}
