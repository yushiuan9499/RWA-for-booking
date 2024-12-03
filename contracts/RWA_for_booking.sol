// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RWAForBooking is ERC721 , Ownable {
    //store the time of the ticket
    struct TicketData{
        uint256 time;
        uint256 fee;
    }

    mapping(uint256 => uint256) availableTime;
    mapping(uint256 => TicketData) ticketData;

    uint256 _fee;
    uint256 counter;

    constructor(uint256 fee , string memory name_, string memory symbol_) ERC721(name_, symbol_) Ownable(msg.sender){ 
        _fee = fee;
        counter = 0;
    }    
    // To check if the ticket has expired.
    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        require(!ticketExpired(tokenId), "Token has expired");
        return super._update(to, tokenId, auth);
    }
    //burn the token if it has expired
    function burnExpired(uint256 tokenId) external {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        require(ticketExpired(tokenId), "Token is not expired yet");

        _burn(tokenId);
        delete ticketData[tokenId];
    }

    /**************************************************************************
     * Owner functions
     *************************************************************************/
    function changeFee(uint256 fee) external onlyOwner{
        _fee = fee;
        return;
    }
    function setTicketAmount(uint256 time, uint256 amount) external onlyOwner{
        require(time > block.timestamp, "Invalid time");
        availableTime[time] = amount;
        return;
    }

    /**************************************************************************
     * Buyer functions
     *************************************************************************/
    function book(uint256 time) public payable {
        require(msg.value == _fee, "Invalid fee");
        require(time > block.timestamp, "Invalid time");
        require(availableTime[time] > 0, "No tickets available");
        availableTime[time] -= 1;
        ticketData[counter].time = time;
        ticketData[counter].fee = _fee;
        _safeMint(msg.sender, counter);
        counter += 1;
        return;
    }


    /**************************************************************************
     * View functions
     *************************************************************************/
    function getFee() public view returns(uint256){
        return _fee;
    }
    function getTime(uint256 tokenId) public view returns(uint256){
        return ticketData[tokenId].time;
    }
    function getAvailableTime(uint256 time) public view returns(uint256){
        return availableTime[time];
    }
    function ticketExpired(uint256 tokenId) public view returns(bool){
        require(ownerOf(tokenId) != address(0), "Invalid token");
        return ticketData[tokenId].time < block.timestamp;
    }
}
