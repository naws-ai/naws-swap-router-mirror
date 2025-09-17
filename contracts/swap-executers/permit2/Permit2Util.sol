// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;

import {IPermit2} from './interfaces/IPermit2.sol';
import {IERC20} from '../../utils/interfaces/IERC20.sol';

contract Permit2Util {
  
  address internal immutable PERMIT2; 

  constructor(address permit2) {
     PERMIT2 = permit2;
  }

  function approve(address token, address spender, uint256 amount) internal {
    IPermit2(PERMIT2).approve(token, spender, uint160(amount), uint48(block.timestamp + 60 * 5));
  }

  modifier checkPermit2Allowance(address owner, address token, uint256 amount) {
    if (token != address(0) && IERC20(token).allowance(owner, PERMIT2) < amount) {
      IERC20(token).approve(PERMIT2, type(uint256).max);
    }
    _;
  }
}