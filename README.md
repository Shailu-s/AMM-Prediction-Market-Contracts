# AMM Prediction Market Contracts

This project implements a decentralized automated market maker (AMM) for prediction markets using Solidity. It allows users to add liquidity, buy shares, and predict outcomes in a decentralized manner. The contract is fully compatible with ERC20 tokens for collateral and integrates key functionalities like liquidity provision, share trading, and market resolution.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
  - [Deployment](#deployment)
  - [Testing](#testing)
- [Smart Contract Details](#smart-contract-details)
  - [AMMPredictionMarket](#amppredictionmarket)
  - [MockToken](#mocktoken)
- [Security Considerations](#security-considerations)
- [License](#license)

---

## Overview

The **AMM Prediction Market Contracts** allow users to:
- Provide liquidity in ERC20 tokens.
- Buy shares for `yes` or `no` outcomes of a prediction market.
- Resolve markets based on outcomes and redeem winnings.

The AMM uses a constant product formula to calculate the price of shares, ensuring liquidity is always available. A small fee is charged on each transaction to incentivize liquidity providers.

---

## Features

1. **Automated Market Maker (AMM):**
   - Liquidity pools for `yes` and `no` outcomes.
   - Dynamic pricing based on the constant product formula.

2. **Liquidity Provision:**
   - Add or remove liquidity in ERC20 tokens.
   - Reward liquidity providers with a share of the pool.

3. **Prediction Market:**
   - Buy shares for `yes` or `no` outcomes.
   - Resolve markets and redeem winnings.

4. **Fee Mechanism:**
   - 1% fee on every share purchase.

---

## Technology Stack

- **Solidity:** Smart contract programming language.
- **Foundry:** Development framework for Ethereum smart contracts.
- **OpenZeppelin:** Reusable, secure smart contract components.
- **ERC20 Standard:** Token standard for collateral.

---

## Getting Started

### Prerequisites

Before running the project, ensure you have the following installed:

- [Node.js](https://nodejs.org/)
- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Git](https://git-scm.com/)
- An Ethereum wallet with testnet tokens for deployment/testing.

### Installation

1. Clone the repository:
   ```
   git clone <repository_url>
   cd AMM-Prediction-Market-Contracts
   ```

2. Install dependencies:
    ```
    forge install
    ```

3. Compile the contracts:
    ```
    forge build
    ```

## Usage

### Developement

1. Deploy the contracts using Foundry:

```
forge script script/Deploy.s.sol --tc Deploy --broadcast --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

### Testing

1. Run the test using Foundry:
```
forge test
```

## Smart Contract Details

### AMMPredictionMarket

The main contract for the prediction market. Users can:
- Add liquidity to the pool.
- Buy `yes` or `no` shares.
- Resolve the market and redeem winnings.

#### Key Functions:
- `addLiquidity(uint256 amount)`: Add liquidity to the market.
- `buyShares(uint256 yesAmount, uint256 noAmount)`: Buy shares for `yes` or `no` outcomes.
- `resolveMarket(address winningOutcome)`: Resolve the market with the winning outcome.
- `redeemWinnings()`: Redeem winnings after the market is resolved.

#### Events:
- `LiquidityAdded`: Emitted when liquidity is added.
- `LiquidityRemoved`: Emitted when liquidity is removed.
- `SharesPurchased`: Emitted when shares are purchased.
- `MarketResolved`: Emitted when the market is resolved.

## Areas for Improvement and Future Enhancements

1. **Modular AMM Liquidity Management:**
   - Create a separate smart contract dedicated to managing AMM liquidity.
   - Improves code modularity, readability, and ease of maintenance.
   - Allows better scalability and flexibility in upgrading liquidity mechanisms.

2. **Decouple Auction Mechanism:**
   - Separate the auction logic from the main smart contract.
   - Facilitates cleaner architecture and enables independent upgrades or changes to the auction system.

3. **Support for Multiple Auction Types:**
   - Implement various auction mechanisms (e.g., Dutch auctions, English auctions, sealed-bid auctions).
   - Enhance the platform's functionality and cater to diverse use cases.

4. **Enhanced Administrative Controls:**
   - Introduce a more robust and granular administration framework for managing auctions and liquidity.
   - Implement role-based access control (RBAC) for better governance and reduced risk of misuse.

5. **Comprehensive Testing Suite:**
   - Write extensive test cases using Foundry to ensure reliability and security:
     - **Load Testing:** Simulate high transaction volumes to test contract performance under stress.
     - **Fuzzy Testing:** Use random inputs to uncover edge cases and unexpected behaviors.
     - **Negative Testing:** Test invalid scenarios to ensure the contract handles errors gracefully and securely.


---

### MockToken

A mock ERC20 token used for testing and as collateral in the AMM.

#### Key Features:
- Implements the ERC20 standard.
- Mints 1 million tokens to the deployer.

---

## Security Considerations

- Ensure the `owner` account is securely managed, as it has the ability to resolve the market.
- Validate external input carefully to avoid exploits.
- Perform rigorous testing, especially when deploying on a production network.
- Auditing by a third party is recommended before production deployment.



