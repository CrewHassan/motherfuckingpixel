//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MotherfuckingPixel is ERC721 {
  address _owner;
  uint256 _step;
  uint256 public _minPrice;
  uint256 _payableFee;
  uint16 public _currentId;
  uint16 public _maxMintable;

  struct TileColor {
    uint8 _r;
    uint8 _g;
    uint8 _b;
  }

  struct TileInfo {
    address payable _owner;
    uint256 _currentValue;
    uint256 _paidValue;
  }

  struct Canvas {
    TileInfo[625] tilesInfo;
    TileColor[625] tilesColor;
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

  function getTilesColor() public view returns (TileColor[625] memory) {
    return gallery[_currentId].tilesColor;
  }

  function getTilesInfo() public view returns (TileInfo[625] memory) {
    return gallery[_currentId].tilesInfo;
  }

  function getNftSpentValue() public view returns (uint256) {
    return gallery[_currentId].cvl;
  }

  function paint(
    uint16 coordinate,
    uint8 r,
    uint8 g,
    uint8 b
  ) public payable {
    require(msg.value >= _minPrice, "Too low");

    TileInfo memory currentTileInfo = gallery[_currentId].tilesInfo[coordinate];

    require(msg.value > currentTileInfo._currentValue, "Bid too low");

    uint256 newValue = msg.value + (msg.value * _step) / 100;
    gallery[_currentId].tilesInfo[coordinate] = TileInfo(payable(msg.sender), newValue, msg.value);
    gallery[_currentId].tilesColor[coordinate] = TileColor(r, g, b);
    gallery[_currentId].cvl += msg.value;

    if (gallery[_currentId].paintedTilesCount == 0) {
      gallery[_currentId].startedAt = block.timestamp;
    }

    gallery[_currentId].paintedTilesCount += 1;

    if (_shouldMint()) {
      _customMint(msg.sender);
    }

    emit Painted(coordinate, msg.sender, msg.value);

    if (currentTileInfo._owner == address(0)) return;

    uint256 fee = ((msg.value - currentTileInfo._paidValue) * _payableFee) / 100;
    currentTileInfo._owner.transfer(currentTileInfo._paidValue + fee);
  }

  function isRunning() public view returns (bool) {
    return _currentId <= _maxMintable;
  }

  function _shouldMint() private view returns (bool) {
    return _mintProbability() > _random();
  }

  function _customMint(address owner) private {
    require(_currentId <= _maxMintable, "Minting finished");
    require(!gallery[_currentId].finished, "Minting finished");

    gallery[_currentId].owner = owner;
    gallery[_currentId].finished = true;
    _mint(owner, _currentId);

    _currentId += 1;
  }

  function _mintProbability() private view returns (uint16) {
    uint256 timestamp = block.timestamp - gallery[_currentId].startedAt;
    if (timestamp <= 43200) { // 12h
      return 100 + 100 * gallery[_currentId].paintedTilesCount / 1024;
    } else if (timestamp <= 72000) { // 20h
      return 200 + 100 * uint16(timestamp / 72000);
    } else if (timestamp <= 86400) { // 24h
      return  500 * 100 * gallery[_currentId].paintedTilesCount / 1024;
    }
    return 5000;
  }

  function _random() private view returns (uint8) {
    return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 10000);
  }
}
