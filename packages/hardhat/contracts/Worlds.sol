/// @title    Worlds SVG NFTs: Searching for energy in this NFT universe!
/// @author   @lourenslinde || lourens.eth
/// @notice   This contract controls the "Worlds" NFT collection and associated token actions
/// @dev      The contract splits functionality between WorldGen and WorldUtils
/// @custom   Credit goes to Loot, for the inspiration, and Austin Griffith / BuidlGuidl for the challenge. 
pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import 'base64-sol/base64.sol';
import "./WorldGen.sol";
import "./WorldUtils.sol";

contract Worlds is ERC721Enumerable, Ownable, WorldGenerator, WorldUtils {

  using Strings for uint256;
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  IERC20 private energyToken;
  bool private init;

  constructor() ERC721("Worlds", "WORLDS") {  }

  // Mapping of tokenId to timestamp of last token claim. Upon claiming tokens the timer is reset
  mapping (uint256 => uint256) private lastExtraction;

  /// @notice Sets the pointer to the Energy token
  /// @dev    Initializes the Energy token address
  /// @param  tokenAddress The address of the Energy token
  /// @return bool Was the init successful?
  function initToken(address tokenAddress) external returns (bool) {
    require(!init,"init");
    energyToken = IERC20(tokenAddress);
    init = true;
    return init;
  }

  /// @notice Allows NFT holder to claim tokens
  /// @dev    Checks an NFT for Energy and transfers Energy from the Worlds contract to the recipient
  /// @param  to Address where the tokens must be transferred
  /// @param  tokenId The id of the NFT being drained
  /// @return uint256 The amount of Energy transferred
  function claimTokens(
    address payable to, 
    uint256 tokenId) 
    external 
    returns (uint256) {
      require(init,"!init");
      require(msg.sender == ownerOf(tokenId),"!owner");
      uint256 tokensClaimable = worldEnergy(tokenId);
      tokensClaimable = tokensClaimable + ((balanceOf(msg.sender)*tokensClaimable/100));
      require(energyToken.transfer(to, tokensClaimable), "failed");
      lastExtraction[tokenId] = block.timestamp;
      return tokensClaimable;
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

      bytes32 rand = predictableRandom();
      uint256 id = _tokenIds.current();

      properties[id] = rand;
      _mint(msg.sender, id);
      lastExtraction[id] = block.timestamp;
      _tokenIds.increment();

      return id;
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
      string memory description = ">>>spoolingSentience...";
      string memory output = generateSVGofTokenById(id);

      string memory json = Base64.encode(
        bytes(string(abi.encodePacked(
          '{"name": "World #', uint2str(id), '", "tokenId": ',uint2str(id),', "description":"', description,'", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));

        output = string(abi.encodePacked('data:application/json;base64,', json));
      return output;
          
  }

  /// @notice Generates SVG image for a given token id
  /// @param  id Target World
  /// @return string Representation of the SVG image in string format
  function generateSVGofTokenById(uint256 id) 
    internal 
    view 
    returns (string memory) {
    require(_exists(id), "!exist");
      string[18] memory parts;
        parts[0] = svgDescription;

        parts[1] = getType(id);

        parts[2] = svgPart2;

        parts[3] = getResource(id);

        parts[4] = svgPart4;

        parts[5] = uint2str(getSize(id));

        parts[6] = svgPart6;

        parts[7] = uint2str(getEnergyLevel(id));

        parts[8] = svgPart8;

        parts[9] = getArtifact(id);

        parts[10] = svgPart10;

        parts[11] = getAtmosphere(id);

        parts[12] = svgPart12;

        parts[13] = getObject(id);

        parts[14] = svgPart14;

        parts[15] = uint2str(worldEnergy(id));

        parts[16] = svgPart16;

        parts[17] = svgPart17;

        string memory svg = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        svg = string(abi.encodePacked(svg, parts[9], parts[10], parts[11], parts[12], parts[13], parts[14], parts[15], parts[16], parts[17]));

    return svg;
  }

  /// @notice Public facing render function
  /// @dev    Visibility is `public` to enable it being called by other contracts for composition.
  /// @param  id Target for rendering
  /// @return string SVG image represented as a string
  function renderTokenById(uint256 id) public view returns (string memory) {
    string memory render = string(abi.encodePacked(generateSVGofTokenById(id)));
    return render;
  }

  /// @notice Amount of energy the target world has generated
  /// @param  id Token id of the target world
  /// @return uint256 Amount of energy the world has amassed
  function worldEnergy(uint256 id) public view returns (uint256) {
    return ((block.timestamp - lastExtraction[id]) / 1 minutes)*(getEnergyLevel(id)/100);
  }

  //  Generic receive function to allow the reception of tokens
  receive() payable external {}

  //  Generic fallback function required by Solidity
  fallback() payable external {}

}