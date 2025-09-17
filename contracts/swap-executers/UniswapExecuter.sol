// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;

import {ISwapExecuter} from './interfaces/ISwapExecuter.sol';
import {Permit2Util} from './permit2/Permit2Util.sol';
import {IERC20} from '../utils/interfaces/IERC20.sol';

contract UniswapExecuter is ISwapExecuter, Permit2Util {

  address private immutable UNISWAP_ROUTER;

  constructor() Permit2Util(0x000000000022D473030F116dDEE9F6B43aC78BA3) {
  // bsc - uniswap(universal router)
    UNISWAP_ROUTER = 0x4Dae2f939ACf50408e13d58534Ff8c2776d45265;
  }

  receive() external payable {}

  function swap(SwapParams calldata params, address payable payer) 
    override external payable 
    checkPermit2Allowance(address(this), params.inToken, params.amountInMaximum) 
    returns(uint256 amountIn) {

    bool isNativeIn = msg.value > 0;
    if (!isNativeIn) approve(params.inToken, UNISWAP_ROUTER, params.amountInMaximum);

    (bool success, ) = UNISWAP_ROUTER.call{value: msg.value}(params.swapCalldata);
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
    emit ExecutedViaSwap(UNISWAP_ROUTER, params.recipient);
  }
}
