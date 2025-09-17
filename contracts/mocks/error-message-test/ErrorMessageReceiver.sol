// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.7;

import {ErrorMessageEmitter} from './ErrorMessageEmitter.sol';

contract ErrorMessageReceiver {
  address private _errorMessageEmitter;

  constructor(address errorMessageEmitter) {
    _errorMessageEmitter = errorMessageEmitter;
  }

  function receiveErrorMessage(string memory errorMessage) external {
    (bool success,) = _errorMessageEmitter.call(abi.encodeWithSelector(ErrorMessageEmitter.emitErrorMessage.selector, errorMessage));
    if (success == false) {
      assembly {
        let ptr := mload(0x40)
        let size := returndatasize()
        returndatacopy(ptr, 0, size)
        revert(ptr, size)
      }
    }
  }
}