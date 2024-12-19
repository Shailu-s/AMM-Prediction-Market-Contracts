// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/AMMPredictionMarket.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("MockToken", "MTK") {
        _mint(msg.sender, 1e24); // 1M tokens
    }
}

contract AMMPredictionMarketTest is Test {
    AMMPredictionMarket market;
    MockToken token;

    address owner = address(0x10);
    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        token = new MockToken();
        market = new AMMPredictionMarket(IERC20(address(token)), owner);

        // Distribute tokens
        token.transfer(user1, 1e22); // 10k tokens
        token.transfer(user2, 1e22);
    }

    function testAddLiquidity() public {
        vm.startPrank(user1);
        token.approve(address(market), 1e18);
        market.addLiquidity(1e18);

        assertEq(market.userLiquidity(user1), 1e18);
        assertGt(market.totalLiquidity(), 0);
        vm.stopPrank();
    }

    function testBuyShares() public {
        vm.startPrank(user1);

        // Add initial liquidity to allow buying shares
        token.approve(address(market), 1e18);
        market.addLiquidity(1e18);

        // Allowance must include fees; calculate total
        uint256 yesAmount = 5e17;
        uint256 noAmount = 5e17;
        uint256 fee = ((yesAmount + noAmount) * market.FEE_PERCENTAGE()) / 100;
        uint256 totalCost = yesAmount + noAmount + fee;

        // Approve and buy shares
        token.approve(address(market), totalCost);
        market.buyShares(yesAmount, noAmount);

        assertEq(market.userYesShares(user1), yesAmount);
        assertEq(market.userNoShares(user1), noAmount);
        vm.stopPrank();
    }

    function testMarketResolution() public {
        vm.startPrank(owner);

        // Resolve market with a valid winner address
        market.resolveMarket(address(market));
        assertEq(market.winner(), address(market));

        vm.stopPrank();
    }
}
