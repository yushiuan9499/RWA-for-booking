const { ethers } = require("hardhat");
const { time } = require('@nomicfoundation/hardhat-network-helpers');
const address = require("../address.json");
async function main() {
    const rwaAddress = address["rwa"];
    const rwa = await ethers.getContractAt("RWAForBooking", rwaAddress);
    console.log("Current fee: ", (await rwa.fee()).toString());

    const provider = new ethers.JsonRpcProvider("http://localhost:8545");
    const accounts = await provider.listAccounts();
    const seller = accounts[0];
    await rwa.connect(seller).changeFee(200n);
    console.log("New fee: ", (await rwa.fee()).toString());
}

main();
