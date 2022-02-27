const { expect } = require("chai");
const { ethers } = require("hardhat");
const {toWei} = require("./utils.js")

describe("Token721", function() {

  let Token721, voting, owner, address1, address2, address3, address4, address5;

  beforeEach( async() => {
    Token721 = await ethers.getContractFactory("Token721");
    
    [owner, address1, address2, address3, address4, address5] = await ethers.getSigners()
    token = await Token721.deploy([]);
  })

  describe("check initial states", () => {
        it("Should set the right initial values", async () => {
          expect (await token.notRevealedUri()).to.equal("https://ipfs.io/ipfs/QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/unrevealed.json");
          expect (await token.baseURI()).to.equal("https://ipfs.io/ipfs/QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT");
          expect (await token.existingRole("ADMIN")).to.equal(true);
          expect (await token.existingRole("MINTER")).to.equal(true);
        })

        it("Check setting functions", async () => {
        
        expect (await token.maxAmountOfNftsByUser()).to.equal(10)
        expect (await token.maxAmountOfNfts()).to.equal(1000)
        expect (await token.cost()).to.equal(toWei(0.1))

        await token.setNftPerAddressLimit(100)
        await token.setCost(toWei(1))
        await token.setMaxMintAmount(10000)
        
         expect (await token.maxAmountOfNftsByUser()).to.equal(100)
         expect (await token.maxAmountOfNfts()).to.equal(10000)
         expect (await token.cost()).to.equal(toWei(1)) 

        })

        it("Check role related functions", async () => {
           
           expect (await token.existingRole("DOCTOR")).to.equal(false)
           
            await expect(
            token.addUserToRole("DOCTOR", address2.address)
            ).to.be.revertedWith("This role does not exist");

            await expect(
            token.removeUserFromRole("DOCTOR", address2.address)
            ).to.be.revertedWith("This role does not exist");

            await expect(
            token.connect(address2).addUserToWhiteList(address3.address)
            ).to.be.revertedWith("You are not allowed to do this action");

            await expect(
            token.connect(address2).removeUserFromWhiteList(address3.address)
            ).to.be.revertedWith("You are not allowed to do this action");

            await expect(
            token.connect(address2).reveal()
            ).to.be.revertedWith("You are not allowed to do this action");

            await expect(
            token.connect(address2).setNftPerAddressLimit(20)
            ).to.be.revertedWith("You are not allowed to do this action");

            await expect(
            token.connect(address2).setCost(100)
            ).to.be.revertedWith("You are not allowed to do this action");

            await expect(
            token.connect(address2).setMaxMintAmount(100000)
            ).to.be.revertedWith("You are not allowed to do this action");

            await expect(
            token.connect(address2).pause(false)
            ).to.be.revertedWith("You are not allowed to do this action");                                                                                  
        })

        it("Check minting", async () => {
            await expect(
            token.connect(address2).mint(1, {value: toWei(0.1)})
            ).to.be.revertedWith("the contract is paused");   

                    await token.pause(false)

        await expect(
            token.connect(address2).mint(1, {value: toWei(0.1)})
            ).to.be.revertedWith("You are not allowed to mint");   

        await token.addUserToRole("ADMIN", address2.address)


        await expect(
            token.connect(address2).mint(0, {value: toWei(0.1)})
            ).to.be.revertedWith("need to mint at least 1 NFT");   

        await expect(
            token.connect(address2).mint(100000000, {value: toWei(0.1)})
            ).to.be.revertedWith("You can exceed the max amount of nfts");       

        await expect(
            token.connect(address2).mint(15, {value: toWei(0.1)})
        ).to.be.revertedWith("Each user has a max amount of nfts");

        await expect(
            token.connect(address2).mint(5, {value: toWei(0.1)})
        ).to.be.revertedWith("You have to pay the right price"); 

        token.connect(address2).mint(5, {value: toWei(0.5)})
        
        let numberOfTokensInAddress = await token.addressMintedBalance(address2.address)
        expect(await token.addressMintedBalance(address2.address)).to.be.equal(5)

        expect(await token.tokenURI(2)).to.be.equal("https://ipfs.io/ipfs/QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/unrevealed.json")

        await token.reveal()

        expect(await token.tokenURI(2)).to.be.equal("https://ipfs.io/ipfs/QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/2.json")

        token.mint(6, {value: toWei(0.6)})

        expect(await token.addressMintedBalance(owner.address)).to.be.equal(6)

        expect(await token.tokenURI(11)).to.be.equal("https://ipfs.io/ipfs/QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/0.json")

        expect(await token.ownerByToken(5)).to.be.equal(address2.address)

        expect(await token.ownerByToken(11)).to.be.equal(owner.address)   

        await token.burn(11)

        await expect(
            token.tokenURI(11)
        ).to.be.revertedWith("ERC721Metadata: URI query for nonexistent token"); 

        expect(await token.contractBalance()).to.be.equal(toWei(1.1))

        await token.withdraw()

        expect(await token.contractBalance()).to.be.equal(toWei(0))
 
        })

        it("Check White list", async () => {
          
            await expect(
            token.connect(address2).mint(3, {value: toWei(0.3)})
            ).to.be.revertedWith("the contract is paused"); 

            await token.addUserToWhiteList(address2.address) 

            await token.connect(address2).mint(3, {value: toWei(0.3)})
            
            expect(await token.addressMintedBalance(address2.address)).to.be.equal(3)   

            await token.removeUserFromWhiteList(address2.address) 

                        await expect(
            token.connect(address2).mint(3, {value: toWei(0.3)})
            ).to.be.revertedWith("the contract is paused"); 
            
        })

  })

})