// SPDX-License-Identifier: Apache-2.0


// Copyright 2023 Stichting Block Foundation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import { ethers } from "hardhat";
import { expect } from "chai";

// Define the test suite
describe("RealEstateToken", function() {
  // Test case to check the initial values of the contract
  it("Should return the right name and symbol", async function() {
    // Get the ContractFactory for the RealEstateToken contract and deploy a new instance
    const RealEstateToken = await ethers.getContractFactory("RealEstateToken");
    const token = await RealEstateToken.deploy("RealEstateToken", "RET", 1000);

    // Assert that the contract's name and symbol are correctly initialized
    expect(await token.name()).to.equal("RealEstateToken");
    expect(await token.symbol()).to.equal("RET");
    expect(await token.totalSupply()).to.equal(1000);
  });

  // Test case to check the minting functionality
  it("Should allow the owner to mint tokens", async function() {
    // Get the signers from the ethers provider
    const [owner, addr1] = await ethers.getSigners();

    // Deploy a new instance of the token
    const RealEstateToken = await ethers.getContractFactory("RealEstateToken");
    const token = await RealEstateToken.deploy("RealEstateToken", "RET", 1000);
    
    // Mint new tokens
    await token.connect(owner).mint(addr1.address, 500);

    // Assert that the minted tokens were correctly assigned to the account
    expect(await token.balanceOf(addr1.address)).to.equal(500);
  });

  // Test case to check for permissions
  it("Should not allow non-owners to mint tokens", async function() {
    // Get the signers from the ethers provider
    const [owner, addr1] = await ethers.getSigners();

    // Deploy a new instance of the token
    const RealEstateToken = await ethers.getContractFactory("RealEstateToken");
    const token = await RealEstateToken.deploy("RealEstateToken", "RET", 1000);

    // Attempt to mint new tokens from an address that isn't the owner, expect it to be reverted
    await expect(token.connect(addr1).mint(addr1.address, 500)).to.be.revertedWith("Ownable: caller is not the owner");
  });

  // Test case to check revenue distribution and withdrawal
  it("Should allow stakeholders to withdraw their share of the revenue", async function() {
    // Get the signers from the ethers provider
    const [owner, addr1] = await ethers.getSigners();

    // Deploy a new instance of the token
    const RealEstateToken = await ethers.getContractFactory("RealEstateToken");
    const token = await RealEstateToken.deploy("RealEstateToken", "RET", 1000);
    
    // Mint some tokens to addr1 and add addr1 as a stakeholder
    await token.connect(owner).mint(addr1.address, 500);
    await token.connect(owner).addStakeholder(addr1.address);

    // Distribute some revenue
    await token.connect(owner).distributeRevenue({ value: ethers.utils.parseEther("1.0") });

    // Withdraw the revenue
    await token.connect(addr1).withdraw();
    let balance = await ethers.provider.getBalance(addr1.address);

    // Assert that the stakeholder received their share of the revenue
    expect(balance).to.be.above(ethers.utils.parseEther("0.5")); // Since addr1 has half the tokens, they should receive at least half the revenue
  });
});
