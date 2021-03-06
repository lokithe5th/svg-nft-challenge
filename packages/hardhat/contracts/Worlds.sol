/// @title    Worlds SVG NFTs: Searching for energy in this NFT universe!
/// @author   @lourenslinde || lourens.eth
/// @notice   This contract controls the "Worlds" NFT collection and associated token actions
/// @dev      The contract splits functionality between WorldGen and WorldUtils
/// @custom   Credit goes to Loot, for the inspiration, and Austin Griffith / BuidlGuidl for the challenge. 

pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

//                                    \\\\\\\\\\\\\\\\\\\\\
//              //                            \\\\\\\\\\\\\
//              ///                                \\\\\\\\
//              /////               *                 \\\\\
//              ////////                                \\\
//              /////////////                            \\
//              /////////////////////


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import 'base64-sol/base64.sol';
import "./WorldGen.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Worlds is ERC721, Ownable, WorldGenerator {

  //  Using a counter to negate need for ERC721Enumerable, which increases gas costs for collection
  using Counters for Counters.Counter;
  Counters.Counter public _tokenIds;
  //  Interface for the Energy token which is emitted by the "Worlds" NFTs
  IERC20 private energyToken;
  //  Init variable for setting token
  bool private init;

  //  Events
  event energyExtracted(address _extractor, uint256 _tokenId, uint256 _amount);
  event paidOut(address _to, uint256 _amount);

  constructor() ERC721("Worlds", "WORLDS") { 
    //  Note that incrementing the counter in the constructor costs slightly more gas on deployment, but results in lower gas costs
    _tokenIds.increment();
   }

    /// @notice Sets the pointer to the Energy token
    /// @dev    Initializes the Energy token address
    /// @param  tokenAddress The address of the Energy token
    function initToken(address tokenAddress) public {
        require(init == false,"init");
        energyToken = IERC20(tokenAddress);
        init = true;
  }

  /// @notice Mint function for Worlds NFT
  /// @dev    Checks if msg.value is greater than or equal to the asking price
  /// @return id The token id of the newly minted World
  function mintItem() 
    public 
    payable 
    returns (uint256) {
      require(msg.value >= 0.02 ether, "!funds");
      require(_tokenIds.current() < 69, "!supply");

      properties[_tokenIds.current()] = predictableRandom();
      _mint(msg.sender, _tokenIds.current());
      lastExtraction[_tokenIds.current()] = block.timestamp;
      _tokenIds.increment();

      return _tokenIds.current() -1;
  }

  /// @notice Token URI generation logic 
  /// @param  id Generates the token URI for the given token id 
  /// @return string Represenation of token URI in string format
  function tokenURI(uint256 id) 
    public 
    view 
    override 
    returns (string memory) {
      require(_exists(id), "!exist");

      string memory json = Base64.encode(
        bytes(string(abi.encodePacked(
          '{"name": "World #', uint2str(id), '", "tokenId": ',uint2str(id),', "description": "Worlds", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(generateSVGofTokenById(id))), '"}'))));

        json = string(abi.encodePacked('data:application/json;base64,', json));
      return json;
          
  }

  /// @notice Public facing render function
  /// @dev    Visibility is `public` to enable it being called by other contracts for composition.
  /// @param  id Target for rendering
  /// @return string SVG image represented as a string
  function renderTokenById(uint256 id) public view returns (string memory) {
    require(_exists(id), "!exist");
    //string memory render = ;
    return string(abi.encodePacked(generateSVGofTokenById(id)));
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
      //  Energy is emitted at the World Energy Level, on a per minute basis
      require(energyToken.transfer(to, getEnergyLevel(tokenId)*(block.timestamp - lastExtraction[tokenId]) / 1 minutes), "failed");
      emit energyExtracted(msg.sender, tokenId, getEnergyLevel(tokenId)*(block.timestamp - lastExtraction[tokenId]) / 1 minutes);
      //  Once Energy is extracted from a World, it has to build up again.
      lastExtraction[tokenId] = block.timestamp;
      
  }

    /// @notice Pays out the funds in the contract
    /// @param  to The address where funds should be sent
    /// @param  amount The amount (in wei) which should be paid out to target address
    function payOut(address payable to, uint256 amount) public payable onlyOwner() returns (bool) {
        (bool success, )= to.call{value: amount}("");
        emit paidOut(to, amount);
        return success;
    }

  //  Generic receive function to allow the reception of tokens
  receive() payable external {}

  //  Generic fallback function required by Solidity
  fallback() payable external {}

}