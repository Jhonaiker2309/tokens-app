const hre = require("hardhat");

async function main() {
	const Token721 = await hre.ethers.getContractFactory("Token721");
    const Token1155 = await hre.ethers.getContractFactory("Token1155");
	const Token20 = await hre.ethers.getContractFactory("Token20");

	const token721 = await Token721.deploy([]);
	await token721.deployed();

	const token1155 = await Token1155.deploy();
	await token1155.deployed();

	const token20 = await Token20.deploy(10 ** 6);
	await token20.deployed();

	console.log("Token721 deployed to:", token721.address);
	console.log("Token1155 deployed to:", token1155.address);
	console.log("Token20 deployed to:", token20.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
