pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import 'base64-sol/base64.sol';

import './HexStrings.sol';
import './ToColor.sol';
//learn more: https://docs.openzeppelin.com/contracts/3.x/erc721

// GET LISTED ON OPENSEA: https://testnets.opensea.io/get-listed/step-two

contract Worlds is ERC721, Ownable {

  using Strings for uint256;
  using HexStrings for uint160;
  using ToColor for bytes3;
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  constructor() ERC721("Worlds", "WORLDS") {
      // Incrementing _tokenIds in the constructor lowers gas costs for the first mint
      _tokenIds.increment();
    // 
  }


  /// The color of the sphere determines it's recharge rate
  mapping (uint256 => bytes3) public color;
  /// The energy represents the radiated energy
  mapping (uint256 => uint256) public energy;

  /// Mapping of tokenId to rand used to generate properties
  mapping (uint256 => bytes32) public properties;

  /// The array of different climates a planet might have
  string[] private climates = [
    "Frozen",
    "Desert",
    "Ocean",
    "Temperate"
  ];

  string[] private resources = [
    "Iron",
    "Copper",
    "Gold",
    "Organics",
    "Silicate",
    "Gravity Shards",
    "Unobtainium"
  ];

  uint256[] private sizeRanges = [
    1000,
    10000000
  ];

  uint256[] private energyLevel = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10
  ];

  string[] private artifact = [
    "Miner",
    "Terraformer",
    "World Computer",
    "Contained Antimatter",
    "Transmitter",
    "Fleet",
    "Drones"
  ];

  string[] private atmosphere = [
    "Oxygen",
    "Nitrogen",
    "Methane",
    "Helium"
  ];

  string[] private object = [
    "Excession",
    "Moon",
    "Orbital",
    "Gate",
    "Shroud"
  ];

  string[] private named = [
    "Elder",
    "Hive",
    "Annointed",
    "Augmented"
  ];

  string[] private suffixes = [
    "of the DAO",
    "of the Queen",
    "of the Known",
    "of stars",
    "of moons",
    "of the Sublimed",
    "of souls"
  ];

  function predictableRandom() internal view returns(bytes32) {
    return keccak256(abi.encodePacked( blockhash(block.number-1), msg.sender, address(this) ));
  } 

  function getType(uint256 tokenId) internal view returns(string memory) {
    return determineProperty(tokenId, "Climate", climates);
  }

  function getResource(uint256 tokenId) internal view returns(string memory) {
    return determineProperty(tokenId, "Resource", resources);
  }

  function getSize(uint256 tokenId) internal pure returns(uint256) {
    return uint256(keccak256(abi.encodePacked(tokenId)));
  }

  function getEnergyLevel(uint256 tokenId) internal view returns(uint256) {
    bytes32 tempBytes = keccak256(abi.encodePacked(properties[tokenId]));
    return uint256(keccak256(abi.encodePacked(properties[tokenId]))) % tempBytes.length;
  }

  function getArtifact(uint256 tokenId) internal view returns(string memory) {
    return determineProperty(tokenId, "Artifact", artifact);
  }

  function getAtmosphere(uint256 tokenId) internal view returns(string memory) {
    return determineProperty(tokenId, "Atmosphere", atmosphere);
  }

  function getObject(uint256 tokenId) internal view returns(string memory) {
    return determineProperty(tokenId, "Object", object);
  }

  function bytes32ToUint(bytes32 bs, uint start) internal pure returns (uint) {
    require(bs.length >= start + 32, "slicing out of range");
    uint x;
    assembly {
      x := mload(add(bs, add(0x20, start)))
    }
    return x;
}
  

  function determineProperty(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        //uint256 rand = uint256(properties[tokenId]);
        uint256 rand = uint256(keccak256(abi.encodePacked(properties[tokenId])));
        string memory output = sourceArray[rand % sourceArray.length];
        uint256 greatness = rand % 21;
        if (greatness > 14) {
            output = string(abi.encodePacked(output, " ", suffixes[rand % suffixes.length]));
        }
        if (greatness >= 19) {
            string[2] memory name;
            name[0] = named[rand % named.length];
            //name[1] = nameSuffixes[rand % nameSuffixes.length];
            if (greatness == 19) {
                output = string(abi.encodePacked('"', name[0], ' ', '" ', output));
            } else {
                output = string(abi.encodePacked('"', name[0], ' ', '" ', output, " +1"));
            }
        }
        return output;
    }

  uint256 mintDeadline = block.timestamp + 24 hours;

  function mintItem()
      public
      returns (uint256)
  {
      require( block.timestamp < mintDeadline, "DONE MINTING");

      bytes32 rand = predictableRandom();

      uint256 id = _tokenIds.current();
      properties[id] = rand;
      _mint(msg.sender, id);
      _tokenIds.increment();

       
      //color[id] = bytes2(predictableRandom[0]) | ( bytes2(predictableRandom[1]) >> 8 ) | ( bytes3(predictableRandom[2]) >> 16 );
      //energy[id] = 35+((55*uint256(uint8(predictableRandom[3])))/255);

      return id;
  }

  function tokenURI(uint256 id) public view override returns (string memory) {
      require(_exists(id), "not exist");
      //string memory name = string(abi.encodePacked('World #',id.toString()));
      //string memory description = string(abi.encodePacked('This Sphere is the color #',color[id].toColor(),' with a energy capacity of ',uint2str(energy[id]),'!!!'));
      //string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

      string[16] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

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

        parts[15] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        output = string(abi.encodePacked(output, parts[9], parts[10], parts[11], parts[12], parts[13], parts[14], parts[15]));

        string memory json = Base64.encode(
          bytes(string(abi.encodePacked(
            '{"name": "World #', uint2str(id), '", "description": ">>>transmissionStart>>streamStatus:OPEN>>spoolingSentience...>>>complete...>>>_initSentience...>>>complete>>>transmissionEnd", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));


        output = string(abi.encodePacked('data:application/json;base64,', json));
      return output;
          
  }

  function generateSVGofTokenById(uint256 id) internal view returns (string memory) {
    require(_exists(id), "not exist");
    //string memory svg = string(abi.encodePacked(
      //string memory name = string(abi.encodePacked('World #',id.toString()));
      //string memory description = string(abi.encodePacked('This Sphere is the color #',color[id].toColor(),' with a energy capacity of ',uint2str(energy[id]),'!!!'));
      //string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

      string[16] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

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

        parts[15] = '</text></svg>';

        string memory svg = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        svg = string(abi.encodePacked(svg, parts[9], parts[10], parts[11], parts[12], parts[13], parts[14], parts[15]));

    return svg;
  }

  // Visibility is `public` to enable it being called by other contracts for composition.
  function renderTokenById(uint256 id) public view returns (string memory) {

    
    string memory render = string(abi.encodePacked(
      
      ));

    return render;
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