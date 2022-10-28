require("dotenv").config({ path: ".env" });
require("@nomiclabs/hardhat-etherscan");


async function main() {
  // Verify the contract after deploying
  await hre.run("verify:verify", {
    address: "0xDb3071925173Fee9C72cB274a38c0E60F0246B75",
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