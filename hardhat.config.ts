import { task } from "hardhat/config";

import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-etherscan";

import "@typechain/hardhat";

import "hardhat-gas-reporter";
import "solidity-coverage";

import { NetworkUserConfig } from "hardhat/types";

const MNEMONIC = process.env.MNEMONIC || "";
const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY || "";
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

const chainIds = {
  ganache: 1337,
  goerli: 5,
  hardhat: 31337,
  kovan: 42,
  homestead: 1,
  rinkeby: 4,
  ropsten: 3,
};

function createConfig(network: keyof typeof chainIds): NetworkUserConfig {
  const url = `https://eth-${network}.alchemyapi.io/v2/${ALCHEMY_API_KEY}`;

  return {
    accounts: {
      count: 10,
      initialIndex: 0,
      mnemonic: MNEMONIC,
      path: "m/44'/60'/0'/0",
    },
    chainId: chainIds[network],
    url,
  };
}

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (_args, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more
export default {
  solidity: "0.8.4",

  networks: {
    hardhat: {
      blockGasLimit: 10000000,
      initialBaseFeePerGas: 0, // workaround from https://github.com/sc-forks/solidity-coverage/issues/652#issuecomment-896330136. Remove when that issue is closed.
    },
    rinkeby: createConfig("rinkeby"),
  },
  gasReporter: {
    currency: "ETH",
    coinmarketcap: COINMARKETCAP_API_KEY,
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};
