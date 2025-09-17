// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;

import {TransferHelper} from "./libraries/TransferHelper.sol";
import {ManagerRole} from './utils/ManagerRole.sol';

contract NawsV1Helper is ManagerRole {

  address payable private _feeReceiver;
  uint256 private _feeDenominator = 10000;  
  bool private _isServiceOn = true;

  constructor(address payable feeReceiver) {
    _feeReceiver = feeReceiver;
  }

  /** MAIN FUNCTIONS */
  // feeRate 100 -> 1%, 125 -> 1.25%
  function getAmountExceptFee(uint256 amount, uint64 feeRate) internal view returns(uint256) {
    return amount - _getFee(amount, feeRate);
  }
  function settleFee(bool isNativeOut, address token, uint256 amount, uint64 feeRate) internal {
    isNativeOut ? 
      _transferFeeNative(amount, feeRate) : 
      _transferFeeErc20(token, amount, feeRate);
  }
  function getFeeDenominator() external view returns(uint256) {
    return _feeDenominator;
  }

  /** PRIVATE FUNCTIONS */
  function _getFee(uint256 amount, uint64 feeRate) private view returns(uint256) {
    return ((amount * feeRate ) / _feeDenominator);
  }
  function _transferFeeErc20(address token, uint256 amount, uint64 feeRate) private {
    TransferHelper.safeTransfer(token, _feeReceiver, _getFee(amount, feeRate));
  }
  function _transferFeeNative(uint256 amount, uint64 feeRate) private {
    _feeReceiver.transfer(_getFee(amount, feeRate));
  }

  /** SETTER */
  function setServiceStatus(bool status) external onlyManager {
    _isServiceOn = status;
  }
  function setFeeReceiver(address payable newFeeReceiver) external onlyManager {
    _feeReceiver = newFeeReceiver;
  }
  function setFeeDenominator(uint256 newFeeDenominator) external onlyManager {
    _feeDenominator = newFeeDenominator;
  }

  /** MODIFIER */
  modifier onService {
    require(_isServiceOn, 'NawsV1: closed');
    _;
  }
}