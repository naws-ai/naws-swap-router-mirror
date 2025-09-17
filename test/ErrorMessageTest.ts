import { expect } from "chai";
import { ethers } from "hardhat";
import { ErrorMessageEmitter } from '../typechain-types/mocks/error-message-test/ErrorMessageEmitter';
import { ErrorMessageReceiver } from '../typechain-types/mocks/error-message-test/ErrorMessageReceiver';

describe('ErrorMessageTest', () => {
  let ErrorMessageEmitterFactory: any;
  let ErrorMessageEmitter: ErrorMessageEmitter;
  let ErrorMessageReceiverFactory: any;
  let errorMessageReceiver: ErrorMessageReceiver;

  beforeEach(async () => {
    [ErrorMessageEmitterFactory, ErrorMessageReceiverFactory] = await Promise.all([ethers.getContractFactory("ErrorMessageEmitter"), ethers.getContractFactory("ErrorMessageReceiver")]);
    ErrorMessageEmitter = await ErrorMessageEmitterFactory.deploy();
    errorMessageReceiver = await ErrorMessageReceiverFactory.deploy(ErrorMessageEmitter.target);
  })

  it('receive error message', async () => {
    const message  = 'test error messageeeeee';
    try {
      await errorMessageReceiver.receiveErrorMessage(message);
    } catch (error: any) {
      console.log('--------------------------------')
      console.log(error);
      console.log('--------------------------------')
      expect(error.message).revertedWith(message);
    }
  })
})

// "VM Exception while processing transaction: reverted with reason string 'test error message'"