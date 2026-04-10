// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITreasurerVaultForExec {
    function allocateToYieldFor(address user, uint256 amount) external;
    function balances(address user) external view returns (uint256);
}

/**
 * @title StrategyExecutor
 * @notice User-designated agent can call vault.allocateToYieldFor for that user (gas can be paid by agent).
 */
contract StrategyExecutor {
    ITreasurerVaultForExec public immutable vault;
    mapping(address => address) public agentOf;

    event AgentSet(address indexed user, address indexed agent);
    event StrategyYieldAllocate(address indexed user, uint256 amount, string action);

    constructor(address vault_) {
        vault = ITreasurerVaultForExec(vault_);
    }

    function setAgent(address agent) external {
        agentOf[msg.sender] = agent;
        emit AgentSet(msg.sender, agent);
    }

    modifier onlyUserOrAgent(address user) {
        require(msg.sender == user || msg.sender == agentOf[user], "StrategyExecutor: not authorized");
        _;
    }

    function executeAllocateYield(address user, uint256 amount, string calldata actionLabel)
        external
        onlyUserOrAgent(user)
    {
        require(vault.balances(user) >= amount, "StrategyExecutor: insufficient vault");
        vault.allocateToYieldFor(user, amount);
        emit StrategyYieldAllocate(user, amount, actionLabel);
    }
}
