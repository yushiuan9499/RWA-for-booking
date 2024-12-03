const { ethers } = require("hardhat");
const fs = require("fs");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    const fee = ethers.parseEther("0.001");
    const rwaName = "RWA";
    const rwaSymbol = "RWA";
    const rwa = await ethers.deployContract("RWAForBooking", [fee, rwaName, rwaSymbol]);
    address = {
        rwa: rwa.target,
    }
    fs.writeFileSync("address.json", JSON.stringify(address, null, 4));
}

main();
