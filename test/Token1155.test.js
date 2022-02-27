
const { expect } = require("chai");

describe("Token1155 contract", function () {
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    Token1155 = await ethers.getContractFactory("Token1155");
    [owner, addr1, addr2] = await ethers.getSigners();

    token = await Token1155.deploy();
  });

  describe("Deployment", function () {

    it("Should assign the tokens to the users", async function () {
      const ownerBalanceOfToken1 = await token.balanceOf(owner.address, 1);
      const ownerBalanceOfToken2 = await token.balanceOf(owner.address, 2);
      expect(await ownerBalanceOfToken1).to.equal(10);
      expect(await ownerBalanceOfToken1).to.equal(10);
    });
  });

  describe("Transactions", function () {

    it("Should transfer tokens between accounts", async function () {
        let ownerBalanceOfToken1 = await token.balanceOf(owner.address, 1);
        expect(await ownerBalanceOfToken1).to.equal(10);
        let address1BalanceOfToken1 = await token.balanceOf(addr1.address, 1);
        expect(await address1BalanceOfToken1).to.equal(0);

        await token.setApprovalForAll(addr1.address, true);
        await token.safeTransferFrom(owner.address, addr1.address, 1, 5, [])
        
        ownerBalanceOfToken1 = await token.balanceOf(owner.address, 1);
        address1BalanceOfToken1 = await token.balanceOf(addr1.address, 1);

        expect(await ownerBalanceOfToken1).to.equal(5);
        expect(await address1BalanceOfToken1).to.equal(5);

    });
  });
});