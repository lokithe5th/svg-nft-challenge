/// @title    Worlds SVG NFTs: Searching for energy in this NFT universe!
/// @author   @lourenslinde || lourens.eth
/// @notice   This contract controls the "Worlds" NFT collection and associated token actions
/// @dev      The contract is a gas-efficient implementation of ERC721 standards
pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import 'base64-sol/base64.sol';

import './HexStrings.sol';
import './ToColor.sol';

contract Worlds is ERC721, Ownable {

  using Strings for uint256;
  using HexStrings for uint160;
  using ToColor for bytes3;
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
    _tokenIds.increment();
    mintDeadline = block.timestamp + 24 hours;
  }


  // Mapping of tokenId to rand used to generate properties
  mapping (uint256 => bytes32) public properties;

  // Mapping of tokenId to timestamp of last token claim. Upon claiming tokens the timer is reset
  mapping (uint256 => uint256) private lastExtraction;

  /// The array of different climates a planet might have
  string[] private climates = [
    "Frozen",
    "Desert",
    "Ocean",
    "Jungle"
  ];

  //  Climate modifiers to increase variety and rarity of climates
  string[] private climateModifiers = [
    "Inhospitable",
    "Hostile",
    "Transdimensional",
    "Radioactive"
  ];

  //  Resource modifiers to increase variety and rarity of climates
  string[] private resourceModifiers = [
    "Concealed",
    "Artificial",
    "Multiplicative"
  ];

  //  Atmosphere modifiers to increase variety and rarity of atmospheres
  string[] private atmosphereModifiers = [
    "Nourishing",
    "Corrosive"
  ];

  //  Base resources found on planet
  string[] private resources = [
    "Iron",
    "Copper",
    "Gold",
    "Organics",
    "Silicate",
    "Gravity Shards",
    "Unobtainium",
    "Uranium"
  ];

  //  Artifact available on planet
  string[] private artifact = [
    "Miner",
    "Terraformer",
    "World Computer",
    "Contained Antimatter",
    "Transmitter",
    "Fleet",
    "Drone Factory"
  ];

  //  Type of atmosphere that is dominant ion planet
  string[] private atmosphere = [
    "Oxygen",
    "Nitrogen",
    "Methane",
    "Helium"
  ];

  //  Mysterious object close to world. What is it's purpose?
  string[] private object = [
    "Excession",
    "Moon",
    "Orbital",
    "Gate",
    "Shroud",
    "Solar Farm",
    "Fabrication Hub"
  ];

  //  These ancient and powerful civilizations may leave powerful versions of their technologies
  string[] private named = [
    "Elder",
    "Hive",
    "Annointed",
    "Augmented"
  ];

  //  Some technologies are so advanced as to seem like magic
  string[] private suffixes = [
    "of the DAO",
    "of the Queen",
    "of the Known",
    "of overproduction",
    "of enhanced defense",
    "of the Sublimed",
    "of empowerment"
  ];

  /// @notice   Initializes the associated Energy Token
  /// @dev      Takes an ERC20 token address and sets the energyToken variable
  /// @param    tokenAddress:address of the Energy Token
  /// @return   bool: was init succesful? If false make sure it is an ERC20 token!
  function initToken(address tokenAddress) external returns (bool) {
    require(!init,"Energy stream already initialized.");
    energyToken = IERC20(tokenAddress);
    init = true;
    return init;
  }

  /// @notice Explain to an end user what this does
  /// @dev Explain to a developer any extra details
  /// @param to:address a parameter just like in doxygen (must be followed by parameter name)
  /// @param tokenId:uint256
  /// @return uint256 the return variables of a contract’s function state variable
  function claimTokens(address payable to, uint256 tokenId) external returns (uint256) {
    require(!init,"Energy stream must be initiliazed first.");
    require(msg.sender == ownerOf(tokenId),"This world's energy is not yours to claim.");
    uint256 tokensClaimable = worldEnergy(tokenId);
    require(energyToken.transfer(to, tokensClaimable), "Energy transfer failed!");
    lastExtraction[tokenId] = block.timestamp;
    return tokensClaimable;
  }

  function exchangeTokensForEth(address payable to, uint256 amount) external returns (uint256) {
    uint256 totalEth = tokenPrice*amount;
    require(energyToken.approve(address(this), amount), "Must approve tokens for spending.");
    require(energyToken.transferFrom(msg.sender, address(this), amount));
    (bool sent, ) = to.call{value: totalEth}("");
    require(sent, "Failed to send Ether");
    tokenPrice = tokenPrice + (tokenPrice*1/100);
    return totalEth;
  }

  function predictableRandom() internal view returns(bytes32) {
    return keccak256(abi.encodePacked( blockhash(block.number-1), msg.sender, address(this) ));
  } 

  function getType(uint256 tokenId) internal view returns(string memory) {
    return determineClimate(tokenId, "Climate", climates);
  }

  function getResource(uint256 tokenId) internal view returns(string memory) {
    return determineResource(tokenId, "Resource", resources);
  }

  function getEnergyLevel(uint256 tokenId) internal pure returns(uint256) {
    return (uint256(keccak256(abi.encodePacked(tokenId))) % 900) + 100;
  }

  function getSize(uint256 tokenId) internal view returns(uint256) {
    return (uint256(keccak256(abi.encodePacked(properties[tokenId]))) % 9000) + 1000;
  }

  function getArtifact(uint256 tokenId) internal view returns(string memory) {
    return determineProperty(tokenId, "Artifact", artifact);
  }

  function getAtmosphere(uint256 tokenId) internal view returns(string memory) {
    return determineAtmosphere(tokenId, "Atmosphere", atmosphere);
  }

  function getObject(uint256 tokenId) internal view returns(string memory) {
    return determineProperty(tokenId, "Object", object);
  }  

  function determineProperty(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        uint256 rand = uint256(keccak256(abi.encodePacked(keyPrefix, properties[tokenId])));
        string memory output = sourceArray[rand % sourceArray.length];
        uint256 greatness = rand % 21;
        if (greatness > 14) {
            output = string(abi.encodePacked(output, " ", suffixes[rand % suffixes.length]));
        }
        if (greatness >= 19) {
            string[2] memory name;
            name[0] = named[rand % named.length];
            if (greatness == 19) {
                output = string(abi.encodePacked('"', name[0], '', '" ', output));
            } else {
                output = string(abi.encodePacked('"', name[0], '', '" ', output, " +1"));
            }
        }
        return output;
    }

  function determineClimate(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        uint256 rand = uint256(keccak256(abi.encodePacked(keyPrefix, properties[tokenId])));
        string memory output = sourceArray[rand % sourceArray.length];
        uint256 greatness = rand % 21;
        if (greatness >= 19) {
            string[2] memory name;
            name[0] = climateModifiers[rand % climateModifiers.length];
            if (greatness == 19) {
                output = string(abi.encodePacked('"', name[0], '', '" ', output));
            } else {
                output = string(abi.encodePacked('"', name[0], '', '" ', output, " +1"));
            }
        }
        return output;
    }

  function determineAtmosphere(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
    uint256 rand = uint256(keccak256(abi.encodePacked(keyPrefix, properties[tokenId])));
    string memory output = sourceArray[rand % sourceArray.length];
    uint256 greatness = rand % 21;
      if (greatness >= 19) {
        string[2] memory name;
        name[0] = atmosphereModifiers[rand % atmosphereModifiers.length];
        if (greatness == 19) {
          output = string(abi.encodePacked('"', name[0], '', '" ', output));
        } else {
          output = string(abi.encodePacked('"', name[0], '', '" ', output, " +1"));
        }
        }
        return output;
    }

    function determineResource(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        uint256 rand = uint256(keccak256(abi.encodePacked(keyPrefix, properties[tokenId])));
        string memory output = sourceArray[rand % sourceArray.length];
        uint256 greatness = rand % 21;
        if (greatness >= 19) {
            string[2] memory name;
            name[0] = resourceModifiers[rand % resourceModifiers.length];
            if (greatness == 19) {
                output = string(abi.encodePacked('"', name[0], '', '" ', output));
            } else {
                output = string(abi.encodePacked('"', name[0], '', '" ', output, " +1"));
            }
        }
        return output;
    }

  function mintItem() public returns (uint256) {
    //require(msg.value >= 0.05 ether);
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
      string memory description = "spoolingSentience...success!";

      string[16] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" width="300" height="300" viewBox="0 0 350 350"><style>.base { fill: white; font-family: monospace; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

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
            '{"name": "World #', uint2str(id), '", "description":"', description,'", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));


        output = string(abi.encodePacked('data:application/json;base64,', json));
      return output;
          
  }

  function generateSVGofTokenById(uint256 id) internal view returns (string memory) {
    require(_exists(id), "not exist");
    //string memory svg = string(abi.encodePacked(
      //string memory name = string(abi.encodePacked('World #',id.toString()));
      //string memory description = string(abi.encodePacked('This Sphere is the color #',color[id].toColor(),' with a energy capacity of ',uint2str(energy[id]),'!!!'));
      //string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

      string[18] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: monospace; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

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

  function totalSupply() public view returns (uint256) {
    return _tokenIds.current();
  }

  function worldEnergy(uint256 id) public view returns (uint256) {
    return (lastExtraction[id] / 1 days)*(getEnergyLevel(id)/100);
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