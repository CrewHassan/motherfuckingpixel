import { expect } from "chai";
import { ethers } from "hardhat";

describe("MotherfuckingPixel", function () {
  beforeEach(async function () {
    const MotherfuckingPixel = await ethers.getContractFactory("MotherfuckingPixel");
    this.mfp = await MotherfuckingPixel.deploy();
    await this.mfp.deployed();

    let [deployer, otherUser] = await ethers.getSigners();
    this.deployer = deployer;
    this.otherUser = otherUser;
  });

  describe("paint", function () {
    it("Should paint", async function () {
      const xx = 0;
      const yy = 0;
      const coordinate = xx * 25 + yy;
      const amount = ethers.utils.parseEther("0.5");
      const transaction = this.mfp.paint(coordinate, 0, 0, 0, { value: amount });

      await expect(() => transaction).to.changeEtherBalance(this.deployer, amount.mul(-1));
      await expect(() => transaction).to.changeEtherBalance(this.mfp, amount);

      await expect(transaction).to.emit(this.mfp, "Painted").withArgs(coordinate, this.deployer.address, amount);

      const newAmount = ethers.utils.parseEther("1");
      const payableFee = ethers.utils.parseEther("0.975");
      const ourFee = ethers.utils.parseEther("0.025");
      const newTransaction = this.mfp.connect(this.otherUser).paint(coordinate, 1, 1, 1, { value: newAmount });
      await expect(() => newTransaction).to.changeEtherBalance(this.otherUser, newAmount.mul(-1));
      await expect(() => newTransaction).to.changeEtherBalance(this.mfp, ourFee);
      await expect(() => newTransaction).to.changeEtherBalance(this.deployer, payableFee);
    });

    it("returns the pixel color array", async function () {
      const xx = 0;
      const yy = 0;
      const coordinate = xx * 25 + yy;
      const amount = ethers.utils.parseEther("0.5");
      await this.mfp.paint(coordinate, 1, 0, 0, { value: amount });

      const tilesColor = await this.mfp.getTilesColor();
      const tilesInfo = await this.mfp.getTilesInfo();
      expect(tilesColor[coordinate]._r).to.equal(1);
      expect(tilesInfo[coordinate]._owner).to.equal(this.deployer.address);
    });
  });
});
