// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;

import {ISwapExecuter} from './interfaces/ISwapExecuter.sol';
import {Permit2Util} from './permit2/Permit2Util.sol';
import {IERC20} from '../utils/interfaces/IERC20.sol';

contract PancakeswapExecuter is ISwapExecuter, Permit2Util {
  
  address private immutable PANCAKESWAP_ROUTER; 

  constructor() Permit2Util(0x31c2F6fcFf4F8759b3Bd5Bf0e1084A055615c768) {
  // bsc - pancakeswap(universal router)
    PANCAKESWAP_ROUTER = 0x1A0A18AC4BECDDbd6389559687d1A73d8927E416; 
  }

  receive() external payable {}

  function swap(SwapParams calldata params, address payable payer) 
    override external payable 
    checkPermit2Allowance(address(this), params.inToken, params.amountInMaximum) 
    returns(uint256 amountIn) {

    bool isNativeIn = msg.value > 0;
    if (!isNativeIn) approve(params.inToken, PANCAKESWAP_ROUTER, params.amountInMaximum);

    (bool success, ) = PANCAKESWAP_ROUTER.call{value: msg.value}(params.swapCalldata);
    if (success == false) {
      assembly {
        let ptr := mload(0x40)
        let size := returndatasize()
        returndatacopy(ptr, 0, size)
        revert(ptr, size)
      }
    }

    uint256 restBalance = isNativeIn ? address(this).balance : IERC20(params.inToken).balanceOf(address(this));
    amountIn = params.amountInMaximum - restBalance;

    if (restBalance > 0) {
      returnRestBalance(isNativeIn, params.inToken, restBalance, payer);
    }
    emit ExecutedViaSwap(PANCAKESWAP_ROUTER, params.recipient);
  }
}