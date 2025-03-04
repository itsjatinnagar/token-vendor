// SPDX-License-Identifier: MIT
pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfEth);

    YourToken public yourToken;
    uint256 public constant tokensPerEth = 100;

    constructor(address tokenAddress) Ownable(msg.sender) {
        yourToken = YourToken(tokenAddress);
    }

    function buyTokens() public payable {
        uint256 tokenAmount = msg.value * tokensPerEth;
        yourToken.transfer(msg.sender, tokenAmount);
        emit BuyTokens(msg.sender, msg.value, tokenAmount);
    }

    function withdraw() public onlyOwner {
        (bool success, ) = msg.sender.call{ value: address(this).balance }("");
        require(success, "Withdraw Failed");
    }

    function sellTokens(uint256 _amount) public {
        uint256 ethAmount = _amount / tokensPerEth;
        bool success = yourToken.transferFrom(msg.sender, address(this), _amount);
        require(success, "Token Transfer Failed");
        (success, ) = msg.sender.call{ value: ethAmount }("");
        require(success, "Ether Transfer Failed");
        emit SellTokens(msg.sender, _amount, ethAmount);
    }
}
