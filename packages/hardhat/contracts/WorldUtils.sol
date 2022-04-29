// SPDX-License-Identifier: MIT

/// @title  Utility contract for Worlds NFTs
/// @author @lourenslinde || lourens.eth
/// @notice Contains supporting function for Worlds NFTs, specifically uint2str functionality
pragma solidity >=0.8.0 <0.9.0;

contract WorldUtils { 
    /// @notice Converts an unsigned integer to string
    /// @param _i Integer variable to be converted to string
    /// @return _uintAsString String representing given integer
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