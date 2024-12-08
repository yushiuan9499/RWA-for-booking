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

    mapping(uint256 => uint256) availableAmount;
    mapping(uint256 => TicketData) ticketData;

    uint256 public fee; //fee for each ticket
    uint256 public counter;

    constructor(uint256 fee_ , string memory name_, string memory symbol_) ERC721(name_, symbol_) Ownable(msg.sender){ 
        fee = fee_;
        counter = 0;
    }    
    // To check if the ticket has expired.
    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        if(_ownerOf(tokenId) == address(0)){
            return super._update(to, tokenId, auth);
        }
        require(!ticketExpired(tokenId), "Token has expired");
        return super._update(to, tokenId, auth);
    }
    //burn the token if it has expired
    function burnExpired(uint256 tokenId) external {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        require(ticketExpired(tokenId), "Token is not expired yet");

        address previousOwner = super._update(address(0), tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        delete ticketData[tokenId];
    }

    /**************************************************************************
     * Owner functions
     *************************************************************************/
    function changeFee(uint256 fee_) external onlyOwner{
        fee = fee_;
        return;
    }
    function setTicketAmount(uint256 time, uint256 amount) external onlyOwner{
        require(time > block.timestamp, "Invalid time");
        availableAmount[time] = amount;
        return;
    }

    /**************************************************************************
     * Buyer functions
     *************************************************************************/
    function book(uint256 time) public payable returns(uint256){
        require(msg.value == fee, "Invalid fee");
        require(time > block.timestamp, "Invalid time");
        require(availableAmount[time] > 0, "No tickets available");
        availableAmount[time] -= 1;
        ticketData[counter].time = time;
        ticketData[counter].fee = fee;
        counter += 1;
        _safeMint(msg.sender, counter-1);
        return counter - 1;
    }


    /**************************************************************************
     * View functions
     *************************************************************************/
    function ticketExpired(uint256 tokenId) public view returns(bool){
        require(_ownerOf(tokenId) != address(0), "Invalid token");
        return ticketData[tokenId].time < block.timestamp;
    }
    function getAvailableAmount(uint256 time) public view returns(uint256){
        if(time < block.timestamp){
            return 0;
        }
        return availableAmount[time];
    }
    function getTimeOfTicket(uint256 tokenId) public view returns(uint256){
        require(ownerOf(tokenId) != address(0), "Invalid token");
        return ticketData[tokenId].time;
    }
    function getFeeOfTicket(uint256 tokenId) public view returns(uint256){
        require(ownerOf(tokenId) != address(0), "Invalid token");
        return ticketData[tokenId].fee;
    }
}
