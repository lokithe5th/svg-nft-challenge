/// @title    Worlds SVG NFTs: Searching for energy in this NFT universe!
/// @author   @lourenslinde || lourens.eth
/// @notice   This contract controls the "Worlds" NFT collection and associated token actions
/// @dev      The contract is a gas-efficient implementation of ERC721 standards
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

contract Worlds is ERC721Enumerable, Ownable, WorldGenerator {

  using Strings for uint256;
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  uint256 private mintDeadline;
  //  The associated token for rewards
  IERC20 private energyToken;
  //  The contract controlled tokenPrice
  //  This is an incentive mechanism
  uint256 private tokenPrice;
  //  Tracking if the energyToken has been set yet
  bool private init;

  constructor() ERC721("Worlds", "WORLDS") {
    // Incrementing _tokenIds in the constructor lowers gas costs for the first mint
    mintDeadline = block.timestamp + 24 hours;
  }

  // Mapping of tokenId to timestamp of last token claim. Upon claiming tokens the timer is reset
  mapping (uint256 => uint256) private lastExtraction;

  function initToken(address tokenAddress) external returns (bool) {
    require(!init,"Energy stream already initialized.");
    energyToken = IERC20(tokenAddress);
    init = true;
    tokenPrice = energyToken.balanceOf(address(this));
    return init;
  }

  function claimTokens(address payable to, uint256 tokenId) external returns (uint256) {
    require(init,"Energy stream must be initiliazed first.");
    require(msg.sender == ownerOf(tokenId),"This world's energy is not yours to claim.");
    uint256 tokensClaimable = worldEnergy(tokenId);
    require(energyToken.transfer(to, tokensClaimable), "Energy transfer failed!");
    lastExtraction[tokenId] = block.timestamp;
    return tokensClaimable;
  }

  function mintItem() public payable returns (uint256) {
    require(msg.value >= 0.001 ether);
    require( block.timestamp < mintDeadline, "DONE MINTING");

    bytes32 rand = predictableRandom();
    uint256 id = _tokenIds.current();

    properties[id] = rand;
    _mint(msg.sender, id);
    lastExtraction[id] = block.timestamp;
    _tokenIds.increment();

    return id;
  }

  function tokenURI(uint256 id) public view override returns (string memory) {
      require(_exists(id), "not exist");
      string memory description = ">>>spoolingSentience...succes";
      string memory output = generateSVGofTokenById(id);

      string memory json = Base64.encode(
        bytes(string(abi.encodePacked(
          '{"name": "World #', uint2str(id), '", "description":"', description,'", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));

        output = string(abi.encodePacked('data:application/json;base64,', json));
      return output;
          
  }

  function generateSVGofTokenById(uint256 id) internal view returns (string memory) {
    require(_exists(id), "not exist");
      string[18] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 400"><style>.base { fill: white; font-family: monospace; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

        parts[1] = getType(id);

        parts[2] = '</text><text x="10" y="40" class="base">';

        parts[3] = getResource(id);

        parts[4] = '</text><text x="10" y="60" class="base">';

        parts[5] = uint2str(getSize(id));

        parts[6] = '</text><text x="10" y="80" class="base">';

        parts[7] = uint2str(getEnergyLevel(id));

        parts[8] = '</text><text x="10" y="100" class="base">';

        parts[9] = getArtifact(id);

        parts[10] = '</text><text x="10" y="120" class="base">';

        parts[11] = getAtmosphere(id);

        parts[12] = '</text><text x="10" y="140" class="base">';

        parts[13] = getObject(id);

        parts[14] = '</text><text x="10" y="160" class="base">';

        parts[15] = uint2str(worldEnergy(id));

        parts[16] = '</text><text x="10" y="160" class="base">';

        parts[17] = '</text></svg>';

        string memory svg = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        svg = string(abi.encodePacked(svg, parts[9], parts[10], parts[11], parts[12], parts[13], parts[14], parts[15], parts[16], parts[17]));

    return svg;
  }

  // Visibility is `public` to enable it being called by other contracts for composition.
  function renderTokenById(uint256 id) public view returns (string memory) {
    string memory render = string(abi.encodePacked(generateSVGofTokenById(id)));
    return render;
  }


  function worldEnergy(uint256 id) public view returns (uint256) {
    return ((block.timestamp - lastExtraction[id]) / 1 minutes)*(getEnergyLevel(id)/100);
  }

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
      if (_i == 0) {
          return "0";
      }
      uint j = _i;
      uint len;
      while (j != 0) {
          len++;
          j /= 10;
      }
      bytes memory bstr = new bytes(len);
      uint k = len;
      while (_i != 0) {
          k = k-1;
          uint8 temp = (48 + uint8(_i - _i / 10 * 10));
          bytes1 b1 = bytes1(temp);
          bstr[k] = b1;
          _i /= 10;
      }
      return string(bstr);
  }
}