// SPDX-License-Identifier: MIT
/// @title  WorldGen
/// @author @lourenslinde || lourens.eth
/// @notice World Generation logic for Worlds NFTs
pragma solidity >=0.8.0 <0.9.0;

import "./WorldUtils.sol";

contract WorldBase is WorldUtils {

  /// The array of different climates a planet might have
  string[] public climates = [
        "Frozen",
        "Desert",
        "Ocean",
        "Jungle"
        ];

  //  Base resources found on planet
  string[] public resources = [
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
  string[] public artifact = [
        "Miner",
        "Terraformer",
        "World Computer",
        "Contained Antimatter",
        "Transmitter",
        "Fleet",
        "Drone Factory"
        ];

  //  Type of atmosphere that is dominant on planet
  string[] public atmosphere = [
        "Oxygen",
        "Nitrogen",
        "Methane",
        "Helium"
        ];

  //  Mysterious object close to world. What is it's purpose?
  string[] public object = [
        "Excession",
        "Moon",
        "Orbital",
        "Gate",
        "Shroud",
        "Solar Farm",
        "Fabrication Hub"
        ];

  //  These ancient civilizations may leave powerful versions of their technologies
  string[] public named = [
        "Elder",
        "Hive",
        "Annointed",
        "Augmented"
        ];

  //  Some technologies are so advanced as to seem like magic
  string[] public suffixes = [
        "of the DAO",
        "of the Queen",
        "of the Known",
        "of overproduction",
        "of enhanced defense",
        "of the Sublimed",
        "of empowerment"
        ];
}