// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;

import {NawsImmutables} from './NawsImmutables.sol';
import {NawsV1Helper, TransferHelper} from './NawsV1Helper.sol';
import {SwapExecuteManager, ISwapExecuter} from './SwapExecuteManager.sol';
import {IWETH9, IERC20} from './utils/interfaces/IWETH9.sol';
import {ReentrancyGuard} from './utils/ReentrancyGuard.sol';

contract NawsV1 is NawsImmutables, NawsV1Helper, SwapExecuteManager, ReentrancyGuard {

  constructor(address payable feeReceiver) NawsV1Helper(feeReceiver) {}

  receive() external payable {}

  /** Main Functions */
  function buyDirect(
    string calldata orderId, 
    uint256 amount,
    address token,
    address payable recipient,
    uint64 feeRate
  ) payable external 
    onService 
    checkAmount(amount) 
    nonReentrant {

    if (msg.value > 0) {
      _buyViaNative(orderId, amount, token, recipient, feeRate);
    } else {
      _buyViaErc20(orderId, amount, token, recipient, feeRate);
    }
  }

  function buyViaSwap(
    string calldata orderId,
    uint256 swapExecuterId,
    ISwapExecuter.SwapParams memory swapParams,
    uint64 feeRate
  ) payable external 
    onService
    validSwapExecuter(swapExecuterId) 
    checkAmount(swapParams.amountInMaximum) 
    checkAmount(swapParams.amountOut)
    nonReentrant {

    address swapExecuter = _swapExecuter(swapExecuterId);
    bool isNativeIn = msg.value > 0;

    if (isNativeIn) require(msg.value == swapParams.amountInMaximum, 'NawsV1: wrong native amount-in');
    if (!isNativeIn) TransferHelper.safeTransferFrom(swapParams.inToken, msg.sender, swapExecuter, swapParams.amountInMaximum);

    uint256 amountIn = ISwapExecuter(swapExecuter).swap{value: msg.value}(swapParams, payable(msg.sender));

    bool isNativeOut = swapParams.outToken == address(0);
    require(_isSwappedAmountExact(isNativeOut, swapParams.outToken, swapParams.amountOut), 'NawsV1: wrong amount-out');

    _settleSwappedAmount(isNativeOut, swapParams.outToken, getAmountExceptFee(swapParams.amountOut, feeRate), swapParams.recipient);
    settleFee(isNativeOut, swapParams.outToken, swapParams.amountOut, feeRate);

    emit Bought(orderId, swapParams.outToken, swapParams.amountOut, swapParams.inToken, amountIn, feeRate);
  }

  /** Sub Functions */
  function _buyViaNative(
    string calldata orderId,
    uint256 amount,
    address token,
    address payable recipient,
    uint64 feeRate
  ) private 
    checkAmount(amount)
    ensure(msg.value >= amount, 'NawsV1: wrong native amount')
    ensure(token == address(0) || token == WETH9, 'NawsV1: wrong token') {

    uint256 amountExceptFee = getAmountExceptFee(amount, feeRate);
    emit ExecutedViaNative(recipient);

    if (token == WETH9) {
      IWETH9(WETH9).deposit{value: amountExceptFee}();
      IWETH9(WETH9).transfer(recipient, amountExceptFee);
      emit Bought(orderId, token, amount, address(0), amount, feeRate);
    } else {
      recipient.transfer(amountExceptFee);
      emit Bought(orderId, token, amount, token, amount, feeRate);
    }

    settleFee(true, address(0), amount, feeRate);
  }

  function _buyViaErc20(
    string calldata orderId,
    uint256 amount, 
    address token,
    address payable recipient,
    uint64 feeRate
  ) private checkAmount(amount) {

    uint256 amountExceptFee = getAmountExceptFee(amount, feeRate);
    bool isNativeOut = token == address(0);

    TransferHelper.safeTransferFrom((isNativeOut ? WETH9 : token), msg.sender, address(this), amount);
    emit ExecutedViaErc20(recipient);

    if(isNativeOut) {
      IWETH9(WETH9).withdraw(amountExceptFee);
      recipient.transfer(amountExceptFee);
      emit Bought(orderId, token, amount, WETH9, amount, feeRate);
    } else {
      TransferHelper.safeTransfer(token, recipient, amountExceptFee);
      emit Bought(orderId, token, amount, token, amount, feeRate);
    }

    settleFee(false, (isNativeOut ? WETH9 : token), amount, feeRate);

  }

  function _isSwappedAmountExact(bool isNativeOut, address token, uint256 amount) private view returns(bool) {
    return (isNativeOut ? address(this).balance : IERC20(token).balanceOf(address(this))) >= amount;
  }

  function _settleSwappedAmount(
    bool isNativeOut,  
    address outToken, 
    uint256 amountOutExceptFee,
    address recipient
  ) private {
    isNativeOut ?
      payable(recipient).transfer(amountOutExceptFee) :
      TransferHelper.safeTransfer(outToken, recipient, amountOutExceptFee);
  }

  /** MODIFIERS */
  modifier checkAmount(uint256 amount) {
    require(amount > 0, 'NawsV1: wrong amount');
    _;
  }
  modifier ensure(bool condition, string memory errorMessage) {
    require(condition, errorMessage);
    _;
  }

  /** EVENTS */
  event Bought(
    string orderId, 
    address settlementToken,
    uint256 productPrice,
    address paymentToken, 
    uint256 paymentAmount, 
    uint64 feeRate
  );
  event ExecutedViaNative(address recipient);
  event ExecutedViaErc20(address recipient);
}