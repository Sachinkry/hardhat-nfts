require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });

const ALCHEMY_KEY_URL = process.env.ALCHEMY_KEY_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

module.exports = {
  solidity: "0.8.17",
  networks: {
    mumbai: {
      url: ALCHEMY_KEY_URL,
      accounts: [PRIVATE_KEY],
    },
  },
};
