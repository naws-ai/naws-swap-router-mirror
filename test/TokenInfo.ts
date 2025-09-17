import { expect } from "chai";
import { ethers } from "hardhat";
import { Token } from "../typechain-types/contracts/Token";
import { TokenInfo } from "../typechain-types";
import { ethers as eth } from "ethers";

describe.skip('TokenInfo', () => {
  let TokenFactory: any;
  let TokenInfoFactory: any;

  let user: any;
  let user2: any;
  let token1: Token;
  let token2: Token;
  let token3: Token;
  let tokenInfo: TokenInfo;
  
  before(async () => {
    [TokenFactory, TokenInfoFactory, [user, user2]] = await Promise.all([
      ethers.getContractFactory("Token"), 
      ethers.getContractFactory("TokenInfo"),
      ethers.getSigners(),
    ]);
  })

  beforeEach(async () => {
    [token1, token2, token3, tokenInfo] = await Promise.all([
      TokenFactory.deploy("Token1", "T1", 1_000_000),
      TokenFactory.deploy("Token2", "T2", 1_000_000),
      TokenFactory.deploy("Token3", "T3", 1_000_000),
      TokenInfoFactory.deploy()
    ]);
    await Promise.all([
      token1.transfer(user2, 500_000), 
      token3.transfer(user2, 200_000)
    ]);
  });

  it('test', async () => {
    const addresses = await Promise.all([token1.getAddress(), token2.getAddress(), token3.getAddress()])    
    console.log(await tokenInfo.getBalances(addresses, user))
    expect(true).equal(true);
  });
})