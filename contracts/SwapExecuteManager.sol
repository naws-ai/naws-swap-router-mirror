// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;

import {ISwapExecuter} from './swap-executers/interfaces/ISwapExecuter.sol';
import {ManagerRole} from './utils/ManagerRole.sol';
import {Constants} from './libraries/Constants.sol';

contract SwapExecuteManager is ManagerRole {

  mapping(uint256 => address) private _swapExecuters;
  address[] private _swapExecuterAddresses;

  function _swapExecuter(uint256 executerId) internal view returns(address) {
    return _swapExecuters[executerId];
  }

  function swapExecuterAddresses() public view onlyManager returns(address[] memory) {
    return _swapExecuterAddresses;
  }

  /** SETTER */
  function setSwapExecuter(address executerAddr) external onlyManager returns(uint256 swapExecuterId) {
    require( 
      ISwapExecuter(executerAddr).executerId() == Constants.NAWS_EXECUTER_ID, 
      'SwapExecuteManager: wrong contract'
    );

    _swapExecuterAddresses.push(executerAddr);
    swapExecuterId = _swapExecuterAddresses.length;
    _swapExecuters[swapExecuterId] = executerAddr;
  }

  function deleteSwapExecuter(uint256 executerId) external 
    onlyManager 
    validSwapExecuter(executerId) 
    returns(bool) {

    _swapExecuters[executerId] = address(0);
    _swapExecuterAddresses[executerId - 1] = address(0);
    return true;
  }

  /** MODIFIER */
  modifier validSwapExecuter(uint256 executerId) {
    require(_swapExecuters[executerId] != address(0), 'SwapExecuteManager: wrong swap-executer');
    _;
  }
}