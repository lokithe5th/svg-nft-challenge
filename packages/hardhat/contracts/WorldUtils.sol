// SPDX-License-Identifier: MIT

/// @title  Utility contract for Worlds NFTs
/// @author @lourenslinde || lourens.eth
/// @notice Contains necessary functions for Worlds NFTs
pragma solidity >=0.8.0 <0.9.0;

contract WorldUtils { 

    //  Refactoring required storage of this string to reduce main Worlds contract size
    string internal svgDescription = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 400"><style>.base { fill: white; font-family: monospace; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

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

    /// @notice Pays out the funds in the contract
    /// @param  to The address where funds should be sent
    /// @param  amount The amount (in wei) which should be paid out to target address
    /// @return bool Payout success
    function payOut(address payable to, uint256 amount) public payable returns (bool) {
        (bool success, )= to.call{value: amount}("");
        return success;
    }

}