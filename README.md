# NAWS.AI On-Chain Swap Router (Mirror)

This repository is a read-only mirror of the **on-chain router smart contracts**, which are a part of the NAWS.AI swap aggregator system.

NAWS.AI utilizes an AI-powered off-chain engine to find optimal swap routes. The contracts in this repository are responsible for executing the actual on-chain transactions based on the results from that engine. As these contracts serve as the entry point for users to send transactions and initiate swaps, we are making the code public to ensure trust and transparency. This code is identical to the version deployed in production.

## Architecture Overview

The on-chain router is designed with a modular architecture to ensure scalability and flexibility:

-   **Entrypoint Contract**
    Acts as the single point of entry for user swap requests. It receives the optimal route data found by the off-chain engine and initiates the transaction.

-   **Router Manager**
    Serves as a central hub for managing integrations with various decentralized exchanges (DEXs). When support for a new DEX protocol is needed, its corresponding Executer can be registered here, allowing for feature expansion without requiring an upgrade to the entire system.

-   **DEX Executers**
    These are modules that execute the actual swaps according to the unique specifications of individual DEX protocols. Each executer is responsible for interacting with a specific DEX (e.g., Uniswap, PancakeSwap), ensuring a clear separation of concerns.

This architecture allows NAWS.AI to quickly and securely integrate new DEXs, providing users with a wider range of liquidity and the best possible exchange rates.

## Service Information

-   **Service**: [GetBlobs](https://getblobs.com/)
-   **Integrated Wallets**: Binance Wallet, Coin98, Gate Wallet, OKX Wallet, and more.
