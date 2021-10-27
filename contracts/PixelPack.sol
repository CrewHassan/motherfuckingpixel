//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

library PixelPack {
  function change(
    uint256 pack,
    uint32 idx,
    uint32 rgba
  ) internal pure returns (uint256) {
    uint256 shift = (7 - idx) * 32;
    uint256 pixel = uint256(rgba) << shift;
    uint256 mask = ~(((1 << 32) - 1) << shift);

    return (pack & mask) | pixel;
  }
}
