const { ethers } = require("hardhat");
const address = require("../address.json");
const rwaAddress = address["rwa"];
const rwa = await ethers.getContractAt("IERC20", rwaAddress);
