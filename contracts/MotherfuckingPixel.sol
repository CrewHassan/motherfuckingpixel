//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MotherfuckingPixel is ERC721 {
  address _owner;
  uint256 _step;
  uint256 _minPrice;
  uint256 _payableFee;
  uint16 _currentId;
  uint16 _maxMintable;

  struct Tile {
    address payable _owner;
    uint8 _r;
    uint8 _g;
    uint8 _b;
    uint256 _currentValue;
    uint256 _paidValue;
  }

  struct Canvas {
    Tile[1024] tiles;
    uint256 cvl;
    uint256 startedAt;
    uint16 paintedTilesCount;
    bool finished;
    address owner;
  }

  mapping(uint256 => Canvas) public gallery;

  event Painted(uint16 coordinate, address indexed owner, uint256 value);

  constructor() ERC721("MfPGallery", "MfPG") {
    _owner = msg.sender;
    _minPrice = 0.05 ether;
    _step = 5;
    _payableFee = 95;
    _maxMintable = 7777;
    _currentId = 1;
  }

  function getTiles(uint8 page) public view returns (Tile[512] memory) {
    require(page < 2, "Invalid page");
    Tile[512] memory temp;
    uint16 maximumIndex = (page + 1) * 512;

    for (uint16 i = page * 512; i < maximumIndex; i++) {
      temp[i] = gallery[_currentId].tiles[i];
    }

    return temp;
  }

  function paint(
    uint16 coordinate,
    uint8 r,
    uint8 g,
    uint8 b
  ) public payable {
    require(msg.value >= _minPrice, "Too low");

    Tile memory currentTile = gallery[_currentId].tiles[coordinate];

    require(msg.value > currentTile._currentValue, "Bid too low");

    uint256 newValue = msg.value + (msg.value * _step) / 100;
    gallery[_currentId].tiles[coordinate] = Tile(payable(msg.sender), r, g, b, newValue, msg.value);
    gallery[_currentId].cvl += msg.value;

    emit Painted(coordinate, msg.sender, msg.value);

    if (currentTile._owner == address(0)) return;

    uint256 fee = ((msg.value - currentTile._paidValue) * _payableFee) / 100;
    currentTile._owner.transfer(currentTile._paidValue + fee);
  }

  function isRunning() public view returns (bool) {
    return _currentId <= _maxMintable;
  }

  function _shouldMint() private pure returns (bool) {
    return false;
  }

  function _customMint(address owner) private {
    require(_currentId <= _maxMintable, "Minting finished");
    require(!gallery[_currentId].finished, "Minting finished");

    gallery[_currentId].owner = owner;
    gallery[_currentId].finished = true;
    _mint(owner, _currentId);

    _currentId += 1;
  }
}
