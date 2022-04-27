// SPDX-License-Identifier: MIT

/// @title  Utility contract for Worlds NFTs
/// @author @lourenslinde || lourens.eth
/// @notice Contains necessary functions for Worlds NFTs
pragma solidity >=0.8.0 <0.9.0;

contract WorldStorage { 

    /*  Refactoring required storage of this string to reduce main Worlds contract size
    //string internal svgDescription = ;
    //string internal svgPart2 = ;
    string internal svgPart4 = ;
    string internal svgPart6 = ;
    string internal svgPart8 = ;
    string internal svgPart10 = ;
    string internal svgPart12 = ;
    string internal svgPart14 = ;
    string internal svgPart16 = ;
    string internal svgPart17 = ; */

    string[10] internal svgParts = [
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 400"><style>.base { fill: white; font-family: monospace; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">',
        '</text><text x="10" y="40" class="base">',
        '</text><text x="10" y="60" class="base">',
        '</text><text x="10" y="80" class="base">',
        '</text><text x="10" y="100" class="base">',
        '</text><text x="10" y="120" class="base">',
        '</text><text x="10" y="140" class="base">',
        '</text><text x="10" y="160" class="base">',
        '</text><text x="10" y="160" class="base">',
        '</text></svg>'
    ];

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
        "Gravity Shards",
        "Unobtainium"
        ];

    //  Artifact available on planet
    string[] internal artifact = [
        "Miner",
        "Terraformer",
        "Transmitter",
        "Fleet",
        "Drone Factory"
        ];

    //  Type of atmosphere that is dominant on planet
    string[] internal atmosphere = [
        "Oxygen",
        "Nitrogen",
        "Methane",
        "Helium"
        ];

    //  Mysterious object close to world. What is it's purpose?
    string[] internal object = [
        "Excession",
        "Orbital",
        "Solar Farm",
        "Fabrication Hub"
        ];

    //  These ancient civilizations may leave powerful versions of their technologies
    string[] internal named = [
        "Elder",
        "Hive",
        "Augmented"
        ];

    //  Some technologies are so advanced as to seem like magic
    string[] internal suffixes = [
        "of the DAO",
        "of the Queen",
        "of the Sublimed"
        ];


}