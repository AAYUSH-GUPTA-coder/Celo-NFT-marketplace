require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("hardhat-celo");

// Initialize `dotenv` with the `.config()` function
require("dotenv").config({ path: ".env" });

// Environment variables should now be available
// under `process.env`
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const RPC_URL = process.env.RPC_URL;
const CELOSCAN_KEY = process.env.CELOSCAN_KEY;

// Show an error if environment variables are missing
if (!PRIVATE_KEY) {
  console.error("Missing PRIVATE_KEY environment variable");
}

if (!RPC_URL) {
  console.error("Missing RPC_URL environment variable");
}

if (!CELOSCAN_KEY) {
  console.error("Missing CELOSCAN_KEY environment variable");
}
// Add the alfajores network to the configuration
module.exports = {
  solidity: "0.8.4",
  networks: {
    alfajores: {
      url: RPC_URL,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      alfajores: CELOSCAN_KEY,
    },
  },
};
