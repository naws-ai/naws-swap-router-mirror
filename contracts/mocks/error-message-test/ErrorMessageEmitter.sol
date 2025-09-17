// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.7;

contract ErrorMessageEmitter {
  function emitErrorMessage(string memory errorMessage) external {
    require(false, errorMessage);
  }
}