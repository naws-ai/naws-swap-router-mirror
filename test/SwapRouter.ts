// import { expect } from "chai";
// import { ethers } from "hardhat";
// import { Token } from "../typechain-types/contracts/Token";
// import { MockSwapRouter } from "../typechain-types";
// import { MockSwapper } from "../typechain-types";
// import { ethers as eth } from "ethers";

// const abi = [
//   {
//     "inputs": [
//       {
//         "internalType": "address",
//         "name": "_mockSwapper",
//         "type": "address"
//       }
//     ],
//     "stateMutability": "nonpayable",
//     "type": "constructor"
//   },
//   {
//     "anonymous": false,
//     "inputs": [
//       {
//         "indexed": false,
//         "internalType": "string",
//         "name": "orderId",
//         "type": "string"
//       },
//       {
//         "indexed": false,
//         "internalType": "address",
//         "name": "paymentToken",
//         "type": "address"
//       },
//       {
//         "indexed": false,
//         "internalType": "uint256",
//         "name": "paymentAmount",
//         "type": "uint256"
//       }
//     ],
//     "name": "Swap",
//     "type": "event"
//   },
//   {
//     "inputs": [
//       {
//         "internalType": "string",
//         "name": "_orderId",
//         "type": "string"
//       },
//       {
//         "internalType": "uint256",
//         "name": "_amountOut",
//         "type": "uint256"
//       },
//       {
//         "internalType": "uint256",
//         "name": "_amountInMaximum",
//         "type": "uint256"
//       },
//       {
//         "internalType": "address",
//         "name": "_inToken",
//         "type": "address"
//       },
//       {
//         "internalType": "address",
//         "name": "_outToken",
//         "type": "address"
//       },
//       {
//         "internalType": "address",
//         "name": "_recipient",
//         "type": "address"
//       },
//       {
//         "internalType": "bytes",
//         "name": "_path",
//         "type": "bytes"
//       }
//     ],
//     "name": "swapExactOutputByPancakeswap",
//     "outputs": [
//       {
//         "internalType": "uint256",
//         "name": "amountIn",
//         "type": "uint256"
//       }
//     ],
//     "stateMutability": "nonpayable",
//     "type": "function"
//   },
//   {
//     "inputs": [
//       {
//         "internalType": "string",
//         "name": "_orderId",
//         "type": "string"
//       },
//       {
//         "internalType": "uint256",
//         "name": "_amountOut",
//         "type": "uint256"
//       },
//       {
//         "internalType": "uint256",
//         "name": "_amountInMaximum",
//         "type": "uint256"
//       },
//       {
//         "internalType": "address",
//         "name": "_inToken",
//         "type": "address"
//       },
//       {
//         "internalType": "address",
//         "name": "_outToken",
//         "type": "address"
//       },
//       {
//         "internalType": "address",
//         "name": "_recipient",
//         "type": "address"
//       },
//       {
//         "internalType": "bytes",
//         "name": "_path",
//         "type": "bytes"
//       }
//     ],
//     "name": "swapExactOutputByUniswap",
//     "outputs": [
//       {
//         "internalType": "uint256",
//         "name": "amountIn",
//         "type": "uint256"
//       }
//     ],
//     "stateMutability": "nonpayable",
//     "type": "function"
//   }
// ]

// describe('MockSwap', () => {
//   let TokenFactory: any;
//   let SwapperFactory: any;
//   let SwapRouterFactory: any;

//   let buyer: any;
//   let seller: any;
//   let inToken: Token;
//   let outToken: Token;
//   let nawsRouter: MockSwapRouter
//   let uniswap: MockSwapper

//   const getSwapParams = (amountOut: number, amountInMaximum: number) => ['orderId', amountOut, amountInMaximum, inToken, outToken, seller, '0x00']
  
//   before(async () => {
//     // factory, buyer, seller 초기화
//     [TokenFactory, SwapperFactory, SwapRouterFactory, [buyer, seller]] = await Promise.all([
//       ethers.getContractFactory("Token"), 
//       ethers.getContractFactory("MockSwapper"),
//       ethers.getContractFactory("MockSwapRouter"),
//       ethers.getSigners(),
//     ]);
//   })

//   beforeEach(async () => {
//     // 토큰 초기화
//     [inToken, outToken] = await Promise.all([
//       TokenFactory.deploy("InToken", "IN", 1_000_000),
//       TokenFactory.deploy("OutToken", "OUT", 1_000_000),
//     ]);
//     uniswap = await SwapperFactory.deploy(inToken, outToken);
//     nawsRouter = await SwapRouterFactory.deploy(uniswap);

//     // buyer에 IN, uniswap에 OUT 토큰 충전
//     // 가짜 스왑: uniswap contract가 IN토큰을 받으면 OUT토큰을 보내주는 방식
//     await Promise.all([
//       inToken.transfer(buyer, 1_000_000), 
//       outToken.transfer(uniswap, 1_000_000)
//     ]);
//   });

//   it('통과한다', async () => {
//     const amountOut = 100;
//     const amountInMaximum = 120;
//     await inToken.approve(nawsRouter, amountInMaximum);

//     await nawsRouter.swapExactOutputByUniswap(...getSwapParams(amountOut, amountInMaximum) as any);

//     expect(await outToken.balanceOf(seller)).equal(100);
//   });

//   it('통과한다 - amountInMaximum 값보다 amountIn 값이 작은 경우', async () => {
//     const amountOut = 100;
//     const amountInMaximum = 120;
//     await inToken.approve(nawsRouter, amountInMaximum);

//     await uniswap.setAmountInAlpha(-10);

//     await nawsRouter.swapExactOutputByUniswap(...getSwapParams(amountOut, amountInMaximum) as any);

//     expect(await outToken.balanceOf(seller)).equal(100);
//   });

//   it('에러 발생한다 - amountInMaximum보다 amountIn 값이 큰 경우', async () => {
//     const amountOut = 100;
//     const amountInMaximum = 120;
//     await inToken.approve(nawsRouter, amountInMaximum);

//     await uniswap.setAmountInAlpha(+10);

//     try {
//       await nawsRouter.swapExactOutputByUniswap(...getSwapParams(amountOut, amountInMaximum) as any);
//     } catch (e: any) {
//       expect(await outToken.balanceOf(seller)).equal(0);  
//     }
//   });

//   it('에러 발생한다 - amountOut값보다 작은 값이 우리 라우터로 스왑된 경우', async () => {
//     const amountOut = 100;
//     const amountInMaximum = 120;
//     await inToken.approve(nawsRouter, amountInMaximum);

//     await uniswap.setAmountOutAlpha(-10);

//     try {
//       await nawsRouter.swapExactOutputByUniswap(...getSwapParams(amountOut, amountInMaximum) as any);
//     } catch (e: any) {
//       expect(await outToken.balanceOf(seller)).equal(0);  
//     }
//   });

//   // for chain-connector-server
//   it('tests for chain-connector-server', async () => {
//     const amountOut = 100;
//     const amountInMaximum = 120;
//     await inToken.approve(nawsRouter, amountInMaximum);

//     const tx = await nawsRouter.swapExactOutputByUniswap(...getSwapParams(amountOut, amountInMaximum) as any);

//     const ethersInterface = new ethers.Interface(abi)
//     const addr = await nawsRouter.getAddress()
//     const isSwapRouterTx = ( transaction: any ) => transaction.to === addr;
//     const isSwappedLog = ( event: any ) => { 
//       // console.log(event); 
//       return event?.name === 'Swap'};
//     const getReceipt = ( transaction: any ) => transaction.wait();
//     const parseLog = ( log: any ) => {
//       return ethersInterface.parseLog({ data: log.data, topics: log.topics });
//     }
//     const getSwapInfo = ( swapEvent: any ) => {
//       const [ orderId, paymentToken, paymentAmount ] = swapEvent.args;
//       return { orderId, paymentToken, paymentAmount };
//     };
//     const getTxWithSwapInfo = ( receipt: any ) => ({
//       txIndex: receipt.index,
//       txHash: receipt.hash,
//       buyer: receipt.from, 
//       swapInfo: receipt.logs.map( parseLog ).filter( isSwappedLog ).map( getSwapInfo ).pop(), 
//     });
//     const checkProp = ( prop: any ) => ( param: any ) => {
//       if ( !prop || typeof param !== 'object' ) {
//         return false;
//       }
//       return param[prop] !== undefined;
//     };
    

//     /**real test */
//     // const block = await provider.getBlockWithTransactions( tx.blockNumber );
//     const txReceipts = await Promise.all( [tx]
//       .filter( isSwapRouterTx )
//       .map( getReceipt )
//     );
//     // console.log(txReceipts[0])
//     const txsWithSwapInfo = txReceipts
//       .map( getTxWithSwapInfo )
//       .filter( checkProp( 'swapInfo' ) );

//     const result = { 
//       // hash: block.hash,
//       // number: block.number,
//       // parentHash: block.parentHash,
//       // timestamp: block.timestamp,
//       txsWithSwapInfo,
//     };
//     console.log(result)
//     console.log(result?.txsWithSwapInfo[0].swapInfo)
//     /** */

//     expect(await outToken.balanceOf(seller)).equal(100);
//   })
// })