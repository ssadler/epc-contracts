// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;


import "./Ownership.sol";


contract EPCAdmin is OwnedInternal, TransferOwnershipInternal {

  function owner() public view returns (address) {
    return _owner();
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _emitOwnershipTransferred(address oldOwner, address newOwner) internal override {
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}
