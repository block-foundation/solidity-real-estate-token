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


pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/// @title RealEstateToken Contract
/// @notice This contract represents a tokenized real estate asset, allowing stakeholder voting and revenue distribution
contract RealEstateToken is ERC20, Pausable, Ownable {
    using Address for address payable;
    
    /// @notice Struct to represent proposals for voting
    struct Proposal {
        string description;
        uint voteCount;
        mapping(address => bool) voted;
    }

    Proposal[] public proposals;

    /// @notice Mapping to track stakeholders
    mapping (address => bool) public stakeholders;
    /// @notice Mapping to track revenue for each stakeholder
    mapping (address => uint256) public revenue;

    /// @notice Modifier to restrict function to stakeholders only
    modifier onlyStakeholder() {
        require(stakeholders[msg.sender] == true, "Only stakeholder can call this function");
        _;
    }

    /// @notice Contract constructor
    /// @param name The name of the token
    /// @param symbol The symbol of the token
    /// @param initialSupply The initial supply of the token
    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _setStakeholder(msg.sender);
    }

    /// @notice Mint tokens to an address
    /// @param to The address to mint tokens to
    /// @param amount The amount of tokens to mint
    function mint(address to, uint256 amount) external onlyStakeholder {
        _mint(to, amount);
    }

    /// @notice Burn tokens from an address
    /// @param from The address to burn tokens from
    /// @param amount The amount of tokens to burn
    function burn(address from, uint256 amount) external onlyStakeholder {
        _burn(from, amount);
    }

    /// @notice Pause all token transfers
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpause all token transfers
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Override OpenZeppelin's beforeTokenTransfer function to include pause functionality
    /// @param from Address tokens are transferred from
    /// @param to Address tokens are transferred to
    /// @param amount Amount of tokens transferred
    function beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        super.beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }

    /// @notice Create a new proposal
    /// @param description The description of the proposal
    /// @return The ID of the new proposal
    function propose(string memory description) external returns (uint proposalId) {
        proposals.push();
        proposalId = proposals.length - 1;
        Proposal storage proposal = proposals[proposalId];
        proposal.description = description;
    }

    /// @notice Vote on a proposal
    /// @param proposalId The ID of the proposal to vote on
    function vote(uint proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.voted[msg.sender], "You have already voted on this proposal.");

        proposal.voted[msg.sender] = true;
        proposal.voteCount += balanceOf(msg.sender);
    }

    /// @notice Add a stakeholder
    /// @param stakeholder The address to add as a stakeholder
    function addStakeholder(address stakeholder) external onlyOwner {
        _setStakeholder(stakeholder);
    }

    /// @notice Remove a stakeholder
    /// @param stakeholder The address to remove as a stakeholder
    function removeStakeholder(address stakeholder) external onlyOwner {
        _unsetStakeholder(stakeholder);
    }

    /// @notice Distribute revenue among token holders
    function distributeRevenue() external payable onlyOwner {
        uint256 totalSupply = totalSupply();
        require(totalSupply > 0, "No tokens are issued");

        // Distribute the incoming revenue proportionally to all token holders
        for (uint i = 0; i < totalSupply; i++) {
            address owner = ownerOf(i);
            // Calculating the proportional share of the current owner
            uint256 share = (balanceOf(owner) * msg.value) / totalSupply;
            revenue[owner] += share;
        }
    }

    /// @notice Withdraw revenue
    function withdraw() external {
        require(revenue[msg.sender] > 0, "No revenue to withdraw");
        uint256 amount = revenue[msg.sender];
        revenue[msg.sender] = 0;

        // Transfer the revenue to the stakeholder
        payable(msg.sender).sendValue(amount);
    }

    /// @dev Set an address as a stakeholder
    /// @param stakeholder The address to set as a stakeholder
    function _setStakeholder(address stakeholder) private {
        stakeholders[stakeholder] = true;
    }

    /// @dev Unset an address as a stakeholder
    /// @param stakeholder The address to unset as a stakeholder
    function _unsetStakeholder(address stakeholder) private {
        stakeholders[stakeholder] = false;
    }
}
