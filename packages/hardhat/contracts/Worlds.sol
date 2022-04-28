/// @title    Worlds SVG NFTs: Searching for energy in this NFT universe!
/// @author   @lourenslinde || lourens.eth
/// @notice   This contract controls the "Worlds" NFT collection and associated token actions
/// @dev      The contract splits functionality between WorldGen and WorldUtils
/// @custom   Credit goes to Loot, for the inspiration, and Austin Griffith / BuidlGuidl for the challenge. 
pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/utils/Strings.sol";
import 'base64-sol/base64.sol';
import "./WorldGen.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Worlds is ERC721, Ownable, WorldGenerator {

  //using Strings for uint256;
  using Counters for Counters.Counter;
  Counters.Counter public _tokenIds;
  IERC20 private energyToken;
  bool private init;

  constructor() ERC721("Worlds", "WORLDS") { 
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
      require(energyToken.transfer(to, (block.timestamp - lastExtraction[tokenId]) / 1 minutes), "failed");
      lastExtraction[tokenId] = block.timestamp;
  }

    
    /// @notice Pays out the funds in the contract
    /// @param  to The address where funds should be sent
    /// @param  amount The amount (in wei) which should be paid out to target address
    function payOut(address payable to, uint256 amount) public payable {
        (bool success, )= to.call{value: amount}("");
    }


  /// @notice Mint function for Worlds NFT
  /// @dev    Checks if msg.value is greater than or equal to the asking price
  /// @return id The token id of the newly minted World
  function mintItem() 
    public 
    payable 
    returns (uint256) {
      require(msg.value >= 0.05 ether, "!funds");
      require(_tokenIds.current() < 64, "!supply");

      //uint256 id = ;

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
      //string memory output = generateSVGofTokenById(id);

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

  //  Generic receive function to allow the reception of tokens
  receive() payable external {}

  //  Generic fallback function required by Solidity
  fallback() payable external {}

}