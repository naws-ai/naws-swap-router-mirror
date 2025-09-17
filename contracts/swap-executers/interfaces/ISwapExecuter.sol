// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;

import {IERC20} from '../../utils/interfaces/IERC20.sol';
import {TransferHelper} from '../../libraries/TransferHelper.sol';
import {Constants} from '../../libraries/Constants.sol';

abstract contract ISwapExecuter {
  
  struct SwapParams {
    uint256 amountOut; 
    uint256 amountInMaximum; 
    address inToken; 
    address outToken;
    address recipient;
    bytes swapCalldata;
  }

  function swap(SwapParams calldata params, address payable payer) external virtual payable returns(uint256);

  function executerId() external virtual pure returns(bytes32) {
    return Constants.NAWS_EXECUTER_ID;
  }

  function returnRestBalance(bool isNativeIn, address token, uint256 rest, address payable payer) internal {
    if (isNativeIn) {
      payer.transfer(rest);
    } else {
      TransferHelper.safeTransfer(token, payer, rest);
    }
  }

  event ExecutedViaSwap(
    address swapContract,
    address recipient
  );
}