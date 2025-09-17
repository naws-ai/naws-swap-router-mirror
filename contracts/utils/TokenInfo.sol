// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;

import {IERC20} from './interfaces/IERC20.sol';

contract TokenInfo {
  
  function getBalances(address[] calldata tokens, address user) public view returns(uint256[] memory) {
    uint256[] memory result = new uint256[](tokens.length);
    for(uint256 i = 0; i < tokens.length; i++) {
      result[i] = IERC20(tokens[i]).balanceOf(user);
    }
    return result;
  }
}