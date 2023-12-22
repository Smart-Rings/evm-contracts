# Smart Rings Protocol - Contracts

## Overview

The Smart Rings Protocol - Contracts repository houses the Solidity contracts essential for the operation of the Smart Rings Protocol. These contracts are integral to the functioning of the protocol, providing various capabilities to interact securely and efficiently with blockchain functionalities.

## Features

The repository contains several contracts with distinct functionalities:

- **Chainlink Interaction**: Contracts designed to interact with Chainlink functions. This is crucial for checking whether all addresses in the 'ring' possess at least the minimum required amount of tokens on another blockchain.

- **Cryptographic Verifier**: A contract that validates the cryptographic authenticity of a proof. This ensures that the proof adheres to the required cryptographic standards.

- **Characteristic Verifier**: This contract verifies that all addresses in the ring meet specific characteristics, such as holding a minimum amount of tokens (demonstrated in this proof of concept).

- **Off-Chain Cryptographic Verifier**: A specialized contract to verify cryptographic proofs for non-EVM addresses, including Bitcoin and XRPL (Ripple).

- **Modified ERC721 Contract for SBT**: An adaptation of the standard ERC721 contract to transform it into a Soulbound Token (SBT), enhancing its capabilities and use cases within the protocol.

## Getting Started

### Prerequisites
- [Node.js](https://nodejs.org/en/)
- [hardhat](https://hardhat.org/getting-started/)

### Installation

1. Clone the repository
```sh
git clone
```
2. Install NPM packages
```sh
npm install
```
3. Compile the contracts
```sh
npx hardhat compile
```

## Contribution

We welcome contributions from the community. If you wish to contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Commit your changes with clear, descriptive messages.
4. Push your changes and create a pull request.

For any major changes, please open an issue first to discuss what you would like to change.


## Contact

If you have any questions, please contact us at `contact@cypherlab.fr`
