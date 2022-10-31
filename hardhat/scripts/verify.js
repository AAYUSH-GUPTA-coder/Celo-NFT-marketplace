require("dotenv").config({ path: ".env" });
require("@nomiclabs/hardhat-etherscan");


async function main() {
  // Verify the contract after deploying
  await hre.run("verify:verify", {
    address: "0x6aBDEaBe80a763B4Bf3f86731608A69b994a7c13",
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