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
    const availableTime = [6000, 60, 10, 15 * 60, 3 * 60, 60 * 60, 5 * 60, 3, 2];
    const booking = [
        { buyer: 1, time: 0 },
        { buyer: 2, time: 0 },
        { buyer: 3, time: 4 },
        { buyer: 4, time: 3 },
        { buyer: 2, time: 5 },
        { buyer: 3, time: 1 },
        { buyer: 4, time: 2 },
    ]
    const bookingLater = [
        { buyer: 1, time: 8 },
        { buyer: 2, time: 7 },
    ]

    for (let i = 0; i < 20; i++) {
        try {
            await rwa.connect(seller).burnExpired(i);
            console.log("burned expired tickets");
        }
        catch (e) {
            console.log(e.shortMessage);
        }
    }
    const unixTime = 20 + await time.latest();
    for (let i = 0; i < availableTime.length; i++) {
        remainAmount = await rwa.getAvailableAmount(unixTime + availableTime[i]);
        await rwa.connect(seller).setTicketAmount(unixTime + availableTime[i], remainAmount + 1n);
        console.log(`Available amount for time ${i}: ${remainAmount + 1n}`);
    }
    for (let i = 0; i < booking.length; i++) {
        console.log(`counter: ${await rwa.counter()}`);
        try {
            let tx = await rwa.connect(accounts[booking[i].buyer]).book(
                unixTime + availableTime[booking[i].time],
                { value: await rwa.fee() }
            );
            let receipt = await tx.wait();
            //print everything in receipt
            let tokenId = receipt.logs[0].args[2];
            console.log(await rwa.getTimeOfTicket(tokenId));
            console.log(await rwa.getFeeOfTicket(tokenId));
        } catch (e) {
            console.log(e);
        }
    }

    //sleep 10 seconds
    await new Promise(resolve => setTimeout(resolve, 10000));

    for (let i = 0; i < bookingLater.length; i++) {
        console.log(`counter: ${await rwa.counter()}`);
        try {
            let tx = await rwa.connect(accounts[bookingLater[i].buyer]).book(unixTime + availableTime[bookingLater[i].time], { value: await rwa.fee() });
            let receipt = await tx.wait();
            //print everything in receipt
            let tokenId = receipt.logs[0].args[2];
            console.log(await rwa.getTimeOfTicket(tokenId));
        } catch (e) {
            console.log(e);
        }
    }
}

main();
