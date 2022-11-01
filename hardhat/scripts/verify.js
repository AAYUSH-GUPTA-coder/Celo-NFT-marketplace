require("dotenv").config({ path: ".env" });
require("@nomiclabs/hardhat-etherscan");

async function main() {
  // Verify the contract after deploying
  await hre.run("verify:verify", {
    address: "0x407CE252aB8A4e005052Bc85683362Bdd8040C9c",
    constructorArguments: [],
  });
}

// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
