// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

pragma experimental ABIEncoderV2;

import '@diamond-3-hardhat/libraries/LibDiamond.sol';
import '@solady/utils/LibString.sol';

import "./Ownership.sol";


contract EPCRouter is OwnedInternal {

  function diamondCut(
    IDiamondCut.FacetCut[] calldata _diamondCut,
    address _init,
    bytes calldata _calldata
  ) external onlyOwner {
    LibDiamond.diamondCut(_diamondCut, _init, _calldata);
  }

  fallback() external payable {

    if (msg.sender != _owner()) {
      bool disabled;
      assembly { disabled := sload(SLOT_DISABLED) }
      require(!disabled, "EPC is disabled temporarily");
    }

    address implementation = lookupSelector(msg.sig);

    if (implementation == address(0)) {
      revert(
        string.concat(
          "method not found: ",
          LibString.toHexString(uint32(msg.sig), 4)
        )
      );
    }

    assembly {
      // Copy msg.data. We take full control of memory in this inline assembly
      // block because it will not return to Solidity code. We overwrite the
      // Solidity scratch pad at memory position 0.
      calldatacopy(0, 0, calldatasize())

      // Call the implementation.
      // out and outsize are 0 because we don't know the size yet.
      let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

      // Copy the returned data.
      returndatacopy(0, 0, returndatasize())

      switch result
      // delegatecall returns 0 on error.
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }

  event ReceiveCallFail(bytes data);

  receive() external payable {
    bytes memory sig = abi.encodeWithSignature("receive()");
    address facet = lookupSelector(bytes4(sig));
    if (facet != address(0)) {
      (bool success, bytes memory rdata) = facet.call{value: msg.value}(sig);
      if (!success) emit ReceiveCallFail(rdata);
    }
  }

  bytes32 constant SLOT_DISABLED = "epc.router.disabled";
  
  function setDisabled(bool disabled) external onlyOwner {
    assembly { sstore(SLOT_DISABLED, gt(disabled, 0)) }
  }
}


function lookupSelector(bytes4 selector) view returns (address) {
  return LibDiamond.diamondStorage().selectorToFacetAndPosition[selector].facetAddress;
}
