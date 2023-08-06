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

async function main() {
    // We get the ContractFactory for the RealEstateToken contract
    // ContractFactory in ethers.js is an abstraction used to deploy new smart contracts, 
    // so RealEstateToken here is a factory for instances of our token contract.
    const RealEstateToken = await ethers.getContractFactory("RealEstateToken");

    // Calling `deploy()` on a ContractFactory will start the deployment, 
    // and return a Promise that resolves to a Contract. This is the object 
    // that has a method for each of your smart contract functions.
    // Here, we are passing the parameters needed for the construction of the RealEstateToken.
    const token = await RealEstateToken.deploy("RealEstateToken", "RET", 1000);

    // The transaction that was sent to the network to deploy the Contract
    // hasn't been confirmed yet, so we wait here until it is confirmed.
    await token.deployed();

    // Log the address of the deployed contract to the console.
    // We use the `address` property of the Contract object 
    // as this contains the Ethereum address where the contract is located.
    console.log("RealEstateToken deployed to:", token.address);
}

// We call the asynchronous function main()
// We use .then() and .catch() to handle promises and errors
main()
    .then(() => process.exit(0)) // Node process exits with a success code
    .catch((error) => {
        console.error(error); // Logs the error
        process.exit(1); // Node process exits with a failure code
    });
