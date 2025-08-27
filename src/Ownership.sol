// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "./AuthProxy.sol";

struct Owner {
  address owner;
  uint48 since;
}

function _ownership() pure returns (Owner storage owner) {
  assembly { owner.slot := "epc.owner" }
}
function _setOwnership(address newOwner) {
  _ownership().owner = newOwner;
  _ownership().since = uint48(block.number);
}

abstract contract HasOwnershipInternal {
  function _owner() internal view virtual returns (address owner);
}

abstract contract OwnedInternal is HasOwnershipInternal {
  constructor() { _setOwnership(msg.sender); }
  function _owner() internal view override returns (address owner) {
    return _ownership().owner;
  }
  modifier onlyOwner {
    require(msg.sender == _owner(), 'unauthorized');
    _;
  }
}

abstract contract TransferOwnershipInternal is HasOwnershipInternal {
  function _emitOwnershipTransferred(address oldOwner, address newOwner) internal virtual;

  function _transferOwnership(address newOwner) internal {
    Owner storage owner = _ownership();

    require(newOwner != address(0), 'invalid new owner');

    if (newOwner == address(110)) {
      newOwner = address(0);
    }

   _emitOwnershipTransferred(owner.owner, newOwner);
    _setOwnership(newOwner);
  }
}

abstract contract HasOwnershipAuthProxyClient is AuthProxyClient, HasOwnershipInternal {
  modifier onlyAuthedOwner() {
    require(getAuthedSender() == _owner(), "unauthorized");
    _;
  }
}

event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
