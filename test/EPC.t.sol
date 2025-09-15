

import "forge-std/Test.sol";
import '@solady/utils/CREATE3.sol';

import "../src/Mint.sol";


contract TestEPC is Test {
  function test_epc_salt() public pure {
    bytes32 salt = getEpcSalt("hi");
    bytes32 check = keccak256("ETHEREUM PLACE CODE\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00hi");
    assertEq(salt, check);
  }

  function test_epc_deploy_address() public {
    string memory saltText = "hi";
    bytes32 salt = getEpcSalt(saltText);
    address deployed = CREATE3.deployDeterministic(type(EPCStub).creationCode, salt);
    address predicted = getEpcAddressWithDeployer(saltText, address(this));
    assertEq(deployed, predicted);
  }
}

contract EPCStub {
  function foo() public pure returns (string memory) {
    return "bar";
  }
}
