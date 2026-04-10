// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title TreasurerVault
 * @notice Personal savings vault: deposit native coin, withdraw, optional auto-save bps, yield allocation accounting.
 */
contract TreasurerVault {
    address public owner;
    address public strategyExecutor;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public autoSaveBps;
    mapping(address => uint256) public yieldAllocated;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "TreasurerVault: not owner");
        _;
    }

    function setStrategyExecutor(address exec) external onlyOwner {
        strategyExecutor = exec;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "TreasurerVault: zero");
        owner = newOwner;
    }

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event AutoSaveUpdated(address indexed user, uint256 bps);
    event YieldAllocated(address indexed user, uint256 amount);
    event YieldWithdrawn(address indexed user, uint256 amount);

    function deposit() external payable {
        require(msg.value > 0, "TreasurerVault: zero deposit");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "TreasurerVault: insufficient balance");
        balances[msg.sender] -= amount;
        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        require(ok, "TreasurerVault: transfer failed");
        emit Withdrawn(msg.sender, amount);
    }

    function setAutoSaveBps(uint256 bps) external {
        require(bps <= 10_000, "TreasurerVault: bps max 10000");
        autoSaveBps[msg.sender] = bps;
        emit AutoSaveUpdated(msg.sender, bps);
    }

    /// @notice Move balance from user vault into tracked "yield" (simplified internal accounting).
    function allocateToYield(uint256 amount) external {
        require(balances[msg.sender] >= amount, "TreasurerVault: insufficient balance");
        balances[msg.sender] -= amount;
        yieldAllocated[msg.sender] += amount;
        emit YieldAllocated(msg.sender, amount);
    }

    /// @notice Executor (StrategyExecutor contract) moves a user's vault into yield after user authorized agent off-chain UX.
    function allocateToYieldFor(address user, uint256 amount) external {
        require(msg.sender == strategyExecutor, "TreasurerVault: not executor");
        require(balances[user] >= amount, "TreasurerVault: insufficient balance");
        balances[user] -= amount;
        yieldAllocated[user] += amount;
        emit YieldAllocated(user, amount);
    }

    function withdrawFromYield(uint256 amount) external {
        require(yieldAllocated[msg.sender] >= amount, "TreasurerVault: insufficient yield");
        yieldAllocated[msg.sender] -= amount;
        balances[msg.sender] += amount;
        emit YieldWithdrawn(msg.sender, amount);
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
}
