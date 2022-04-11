// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract WorldGenerator {

    // Mapping of tokenId to rand used to generate properties
  mapping (uint256 => bytes32) public properties;

/// The array of different climates a planet might have
    string[] internal climates = [
        "Frozen",
        "Desert",
        "Ocean",
        "Jungle"
        ];

  //  Base resources found on planet
    string[] internal resources = [
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
    string[] internal artifact = [
        "Miner",
        "Terraformer",
        "World Computer",
        "Contained Antimatter",
        "Transmitter",
        "Fleet",
        "Drone Factory"
        ];

  //  Type of atmosphere that is dominant ion planet
    string[] internal atmosphere = [
        "Oxygen",
        "Nitrogen",
        "Methane",
        "Helium"
        ];

  //  Mysterious object close to world. What is it's purpose?
    string[] internal object = [
        "Excession",
        "Moon",
        "Orbital",
        "Gate",
        "Shroud",
        "Solar Farm",
        "Fabrication Hub"
        ];

  //  These ancient and powerful civilizations may leave powerful versions of their technologies
    string[] internal named = [
        "Elder",
        "Hive",
        "Annointed",
        "Augmented"
        ];

  //  Some technologies are so advanced as to seem like magic
    string[] internal suffixes = [
        "of the DAO",
        "of the Queen",
        "of the Known",
        "of overproduction",
        "of enhanced defense",
        "of the Sublimed",
        "of empowerment"
        ];

  function predictableRandom() internal view returns(bytes32) {
    return keccak256(abi.encodePacked( blockhash(block.number-1), msg.sender, address(this) ));
  } 

  function getType(uint256 tokenId) internal view returns(string memory) {
    return determineEnv(tokenId, "Climate", climates);
  }

  function getResource(uint256 tokenId) internal view returns(string memory) {
    return determineEnv(tokenId, "Resource", resources);
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
    return determineEnv(tokenId, "Atmosphere", atmosphere);
  }

  function getObject(uint256 tokenId) internal view returns(string memory) {
    return determineProperty(tokenId, "Object", object);
  }  

  function determineProperty(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        uint256 rand = uint256(keccak256(abi.encodePacked(keyPrefix, properties[tokenId], sourceArray.length)));
        string memory output = sourceArray[rand % sourceArray.length];
        uint256 greatness = rand % 21;
        if (greatness > 15) {
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

  function determineEnv(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal view returns (string memory) {
        uint256 rand = uint256(keccak256(abi.encodePacked(keyPrefix, properties[tokenId])));
        string memory output = sourceArray[rand % sourceArray.length];
        return output;
    }
}