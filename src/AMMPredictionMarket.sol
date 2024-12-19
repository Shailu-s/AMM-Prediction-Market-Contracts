// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AMMPredictionMarket is Ownable {
    IERC20 public collateralToken;

    uint256 public constant FEE_PERCENTAGE = 1; // 1% fee
    uint256 public constant MULTIPLIER = 1e18;
    uint256 public constant MAX_LIQUIDITY_PER_TX = 1_000_000 * MULTIPLIER; 

    enum MarketState { Open, Resolved }
    MarketState public marketState;

    uint256 public yesShares;
    uint256 public noShares;
    uint256 public totalLiquidity;

    mapping(address => uint256) public userLiquidity;
    mapping(address => uint256) public userYesShares;
    mapping(address => uint256) public userNoShares;

    address public winner;

    event LiquidityAdded(address indexed user, uint256 amount, uint256 yesShares, uint256 noShares, uint256 updatedTotalLiquidity);
    event LiquidityRemoved(address indexed user, uint256 amount);
    event SharesPurchased(address indexed user, uint256 yesShares, uint256 noShares);
    event MarketResolved(address winner);

    constructor(IERC20 _collateralToken, address initialOwner) Ownable(initialOwner) {
        collateralToken = _collateralToken;
        marketState = MarketState.Open;
    }

    modifier isOpen() {
        require(marketState == MarketState.Open, "Market is not open");
        _;
    }

    function addLiquidity(uint256 amount) external isOpen {
        require(amount > 0, "Amount must be greater than zero");
        require(amount <= MAX_LIQUIDITY_PER_TX, "Exceeds max liquidity per transaction");
        require(collateralToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        uint256 yesToAdd = yesShares == 0 ? amount / 2 : (amount * yesShares) / totalLiquidity;
        uint256 noToAdd = noShares == 0 ? amount / 2 : (amount * noShares) / totalLiquidity;

        yesShares += yesToAdd;
        noShares += noToAdd;
        totalLiquidity += amount;
        userLiquidity[msg.sender] += amount;

        emit LiquidityAdded(msg.sender, amount, yesToAdd, noToAdd, totalLiquidity);
    }

    function removeLiquidity(uint256 amount) external isOpen {
        require(amount > 0, "Amount must be greater than zero");
        require(userLiquidity[msg.sender] >= amount, "Insufficient liquidity");
        require(totalLiquidity > 0, "Total liquidity must be greater than zero");

        uint256 yesToRemove = (amount * yesShares) / totalLiquidity;
        uint256 noToRemove = (amount * noShares) / totalLiquidity;

        yesShares -= yesToRemove;
        noShares -= noToRemove;
        totalLiquidity -= amount;
        userLiquidity[msg.sender] -= amount;

        require(collateralToken.transfer(msg.sender, amount), "Transfer failed");

        emit LiquidityRemoved(msg.sender, amount);
    }

    function buyShares(uint256 yesAmount, uint256 noAmount) external isOpen {
        require(yesAmount > 0 || noAmount > 0, "At least one share must be purchased");
        require(yesAmount * noShares == noAmount * yesShares, "Shares must align with constant product formula");

        uint256 fee = ((yesAmount + noAmount) * FEE_PERCENTAGE) / 100;
        uint256 totalCost = yesAmount + noAmount + fee;

        require(collateralToken.transferFrom(msg.sender, address(this), totalCost), "Transfer failed");

        yesShares += yesAmount;
        noShares += noAmount;

        userYesShares[msg.sender] += yesAmount;
        userNoShares[msg.sender] += noAmount;

        emit SharesPurchased(msg.sender, yesAmount, noAmount);
    }

    function resolveMarket(address winningOutcome) external onlyOwner isOpen {
        require(winningOutcome == address(this) || winningOutcome == address(0), "Invalid winner address");

        marketState = MarketState.Resolved;
        winner = winningOutcome;

        emit MarketResolved(winner);
    }

    function redeemWinnings() external {
        require(marketState == MarketState.Resolved, "Market not resolved");

        uint256 userShares = winner == address(this) ? userYesShares[msg.sender] : userNoShares[msg.sender];
        require(userShares > 0, "No winnings to redeem");

        uint256 payout = (userShares * collateralToken.balanceOf(address(this))) / (winner == address(this) ? yesShares : noShares);

        if (winner == address(this)) {
            yesShares -= userShares;
            userYesShares[msg.sender] = 0;
        } else {
            noShares -= userShares;
            userNoShares[msg.sender] = 0;
        }

        require(collateralToken.transfer(msg.sender, payout), "Transfer failed");
    }
}
