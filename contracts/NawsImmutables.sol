// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;

contract NawsImmutables {
  
  address internal immutable WETH9; 
  
  constructor() {
    // bsc - wbnb
     WETH9 = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
  }
}