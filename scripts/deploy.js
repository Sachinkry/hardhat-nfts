const { ethers } = require("hardhat")

async function main() {
  const basicNFTFactory = await ethers.getContractFactory("BasicNFT");
  const basicNFTContract = await basicNFTFactory.deploy();
  await basicNFTContract.deployed();

  console.log("BasicNFT contract Address: ", basicNFTContract.address);
}

// call main function and catch if there's an error
main()
   .then(() => process.exit(0))
   .catch((error) => {
      console.error(error);
      process.exit(1);
   })