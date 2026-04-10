// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MockLPPool
 * @notice Simplified mock AMM LP for demo: deposit paired native amounts, withdraw pro-rata.
 */
contract MockLPPool {
    string public name;
    uint256 public reserveA;
    uint256 public reserveB;
    mapping(address => uint256) public lpShares;

    event LiquidityAdded(address indexed user, uint256 amountA, uint256 amountB, uint256 shares);
    event LiquidityRemoved(address indexed user, uint256 shares, uint256 amountA, uint256 amountB);

    constructor(string memory name_) {
        name = name_;
    }

    function addLiquidity() external payable {
        uint256 value = msg.value;
        require(value >= 2, "MockLPPool: too small");
        uint256 half = value / 2;
        uint256 other = value - half;
        uint256 shares = half + other;
        reserveA += half;
        reserveB += other;
        lpShares[msg.sender] += shares;
        emit LiquidityAdded(msg.sender, half, other, shares);
    }

    function removeLiquidity(uint256 shares) external {
        require(shares > 0 && lpShares[msg.sender] >= shares, "MockLPPool: bad shares");
        uint256 totalShares = totalSupplyShares();
        require(totalShares > 0, "MockLPPool: empty");
        uint256 outA = (shares * reserveA) / totalShares;
        uint256 outB = (shares * reserveB) / totalShares;
        lpShares[msg.sender] -= shares;
        reserveA -= outA;
        reserveB -= outB;
        uint256 out = outA + outB;
        (bool ok, ) = payable(msg.sender).call{value: out}("");
        require(ok, "MockLPPool: transfer failed");
        emit LiquidityRemoved(msg.sender, shares, outA, outB);
    }

    function totalSupplyShares() public view returns (uint256) {
        return reserveA + reserveB;
    }

    receive() external payable {
        reserveA += msg.value;
    }
}
