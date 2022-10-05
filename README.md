# Smart Contract Development

We follow [this tutorial](https://hardhat.org/tutorial) from the HardHat website.


## Environment Setup

First, you should [install `npm` and `Node.js`](https://hardhat.org/tutorial/setting-up-the-environment#installing-node.js).

I also suggest to install [Sublime Text](https://www.sublimetext.com/) as a text editor.

Once you have that, create a folder with the name of the project (e.g. `words`), and `cd` into it on your terminal.


## Initialize the Project

Run the following commands and respond with `return` to every question -- no need to fill-in any data at this point

```
npm init
npm install --save-dev hardhat
npm install --save-dev @nomicfoundation/hardhat-toolbox
```

Then run `npx hardhat` and choose `Create an empty hardhat.config.js`.



## HardHat Configuration

To deploy to a remote network such as mainnet or any testnet, you need to add a network entry to your config file, containing the private key of your wallet.

To do so, edit the `hardhat.config.js` file as follows. 

Notice that you need to add your wallet's private key (you can get it [from MetaMask](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-export-an-account-s-private-key)), an [Alchemy](https://www.alchemy.com/) API key and a [Etherscan](https://etherscan.io/) API key. You can use the ones I sent you in the `Canvas` announcement, but please don't share them.

```
require("@nomicfoundation/hardhat-toolbox");

const GOERLI_ALCHEMY_API_KEY = "...";
const ETHERSCAN_API_KEY      = "...";
const GOERLI_PRIVATE_KEY     = "...";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${GOERLI_ALCHEMY_API_KEY}`,
      accounts: [GOERLI_PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};
```

## Smart Contract

Create a directory `contracts` and a file `words.sol` inside it.

Write your contract code in Solidity there, or paste the code from the [provided file](https://github.com/AndreaBarbon/Fintech-smart-contract/blob/main/words.sol).


## Test Locally

Create a directory `test` and a file `words.js` inside it.

Write some tests followin [this guide](https://hardhat.org/tutorial/testing-contracts#writing-tests), or paste the code from the [provided file](https://github.com/AndreaBarbon/Fintech-smart-contract/blob/main/words.js), then use `npx hardhat test` to run them.


## Deploy to Testnet

Create a directory `scripts`, and paste the following into a `deploy.js` file in that directory:

```
async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Words = await ethers.getContractFactory("Words");
  const words = await Words.deploy();

  console.log("Words address:", words.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => { console.error(error); process.exit(1); });
```

Make sure you have some Goerli ETH on your wallet, and finally run

`npx hardhat run scripts/deploy.js --network goerli`

and take note of the new contract's address.


## Verify your Contract

Wait a few seconds, then run

`npx hardhat verify --network goerli CONTRACT_ADDRESS`

where `CONTRACT_ADDRESS` is the address of the deployed contract.






