/// @title    Worlds SVG NFTs: Searching for energy in this NFT universe!
/// @author   @lourenslinde || lourens.eth
/// @notice   This contract controls the "Worlds" NFT collection and associated token actions
/// @dev      The contract splits functionality between WorldGen and WorldUtils
/// @custom   Credit goes to Loot, for the inspiration, and Austin Griffith / BuidlGuidl for the challenge. 
pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Worlds.sol";

contract WorldsMain is Worlds {

    IERC20 private energyToken;
    bool private init;

    /// @notice Sets the pointer to the Energy token
    /// @dev    Initializes the Energy token address
    /// @param  tokenAddress The address of the Energy token
    /// @return bool Was the init successful?
    function initToken(address tokenAddress) public returns (bool) {
        require(init == true,"init");
        energyToken = IERC20(tokenAddress);
        init = true;
        return init;
  }
  
    /// @notice Allows NFT holder to claim tokens
    /// @dev    Checks an NFT for Energy and transfers Energy from the Worlds contract to the recipient
    /// @param  to Address where the tokens must be transferred
    /// @param  tokenId The id of the NFT being drained
    function claimTokens(
    address payable to, 
    uint256 tokenId) 
    public {
      require(init,"!init");
      require(msg.sender == ownerOf(tokenId),"!owner");
      require(energyToken.transfer(to, ((block.timestamp - lastExtraction[tokenId]) / 1 minutes)*(getEnergyLevel(tokenId)/100) + ((balanceOf(msg.sender)*(((block.timestamp - lastExtraction[tokenId]) / 1 minutes)*(getEnergyLevel(tokenId)/100))/100))), "failed");
      lastExtraction[tokenId] = block.timestamp;
  }

    
    /// @notice Pays out the funds in the contract
    /// @param  to The address where funds should be sent
    /// @param  amount The amount (in wei) which should be paid out to target address
    /// @return uint8 Payout amount
    function payOut(address payable to, uint256 amount) public payable returns (bool) {
        (bool success, )= to.call{value: amount}("");
        return success;
    }
}