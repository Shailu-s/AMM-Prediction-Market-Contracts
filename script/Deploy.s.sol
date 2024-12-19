// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/AMMPredictionMarket.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("MockToken", "MTK") {
        _mint(msg.sender, 1e24); // Mint 1M tokens to the deployer
    }
}

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy MockToken
        MockToken token = new MockToken();

        // Deploy AMMPredictionMarket
        AMMPredictionMarket market = new AMMPredictionMarket(IERC20(address(token)), msg.sender);

        vm.stopBroadcast();

        console.log("MockToken deployed at:", address(token));
        console.log("AMMPredictionMarket deployed at:", address(market));
        //   AMMPredictionMarket deployed at: 0x913e41F8144b7208e284e28120464A8FBE7cE16E
    }
}
