// SPDX-License-Identifier: MIT
/// @title  WorldGen
/// @author @lourenslinde || lourens.eth
/// @notice World Generation logic for Worlds NFTs
pragma solidity >=0.8.0 <0.9.0;

//import "./WorldsBase.sol";
import "./WorldStorage.sol";
import "./WorldUtils.sol";

contract WorldGenerator is WorldStorage, WorldUtils {

  // Mapping of tokenId to rand used to generate properties
  mapping (uint256 => bytes32) public properties;

  // Mapping of tokenId to timestamp of last token claim. Upon claiming tokens the timer is reset
  mapping (uint256 => uint256) public lastExtraction;
  
  /// @notice Generates a pseudorandom number
  /// @return bytes32 Pseudorandom number used for determining the World's properties
  function predictableRandom() 
    internal 
    view 
    returns(bytes32) {
      return keccak256(abi.encodePacked( blockhash(block.number-1), msg.sender, address(this) ));
  } 

  //  These "get" functions are public to allow for other contracts to read the properties of Worlds
  //  Type of environment
  function getType(uint256 tokenId) 
    public 
    view 
    returns(string memory) {
      return determineEnv(tokenId, "Climate", climates);
  }

  //  Type of resource
  function getResource(uint256 tokenId) 
    public 
    view 
    returns(string memory) {
      return determineEnv(tokenId, "Resource", resources);
  }

  //  Energy level of the World
  function getEnergyLevel(uint256 tokenId) 
    public 
    pure 
    returns(uint256) {
      return (uint256(keccak256(abi.encodePacked(tokenId))) % 900) + 100;
  }

  //  Size of the World
  function getSize(uint256 tokenId) 
    public 
    view 
    returns(uint256) {
      return (uint256(keccak256(abi.encodePacked(properties[tokenId]))) % 9000) + 1000;
  }

  //  Artifact on World
  function getArtifact(uint256 tokenId) 
    public 
    view 
    returns(string memory) {
      return determineProperty(tokenId, "Artifact", artifact);
  }

  //  Atmosphere on World
  function getAtmosphere(uint256 tokenId) 
    public 
    view 
    returns(string memory) {
      return determineEnv(tokenId, "Atmosphere", atmosphere);
  }

  //  Mysterious object close to World
  function getObject(uint256 tokenId) 
    public 
    view 
    returns(string memory) {
      return determineProperty(tokenId, "Object", object);
  }  

  //  Generic object property determination
  function determineProperty(
    uint256 tokenId, 
    string memory keyPrefix, 
    string[] memory sourceArray) 
    internal 
    view 
    returns (string memory) {
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

  //  Determine environment and prefix
  function determineEnv(
    uint256 tokenId, 
    string memory keyPrefix, 
    string[] memory sourceArray) 
    internal 
    view 
    returns (string memory) {
        return sourceArray[uint256(keccak256(abi.encodePacked(keyPrefix, properties[tokenId]))) % sourceArray.length];
    }

  /// @notice Generates SVG image for a given token id
  /// @param  id Target World
  /// @return string Representation of the SVG image in string format
  function generateSVGofTokenById(uint256 id) 
    public 
    view 
    returns (string memory) {
        //  Why sacrifice readability here? Because adding another string memory variable creates contract bloat, leading to increased gas costs.
        string memory svg = string(abi.encodePacked(svgParts[0], getType(id), svgParts[1], getResource(id), svgParts[2], uint2str(getSize(id)), svgParts[3], uint2str(getEnergyLevel(id)), svgParts[4]));
        svg = string(abi.encodePacked(svg, getArtifact(id), svgParts[5], getAtmosphere(id), svgParts[6], getObject(id), svgParts[7], uint2str(((block.timestamp - lastExtraction[id]) / 1 minutes)*(getEnergyLevel(id)/100)), svgParts[8], svgParts[9]));
    return svg;
  }
}