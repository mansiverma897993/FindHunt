// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BudgetController
 * @notice Tracks per-user daily spending limits and cumulative outflows for the day.
 */
contract BudgetController {
    mapping(address => uint256) public dailyLimitWei;
    mapping(address => uint256) public currentDayStart;
    mapping(address => uint256) public spentToday;

    event DailyLimitSet(address indexed user, uint256 limitWei);
    event SpendRecorded(address indexed user, uint256 amount, uint256 newTotalToday);
    event DayReset(address indexed user);

    modifier rollDay(address user) {
        uint256 day = block.timestamp / 1 days;
        if (currentDayStart[user] != day) {
            currentDayStart[user] = day;
            spentToday[user] = 0;
            emit DayReset(user);
        }
        _;
    }

    function setDailyLimit(uint256 limitWei) external {
        dailyLimitWei[msg.sender] = limitWei;
        emit DailyLimitSet(msg.sender, limitWei);
    }

    /// @notice Record spend for msg.sender; reverts if over daily limit (when limit > 0).
    function recordSpend(uint256 amount) external rollDay(msg.sender) {
        uint256 limit = dailyLimitWei[msg.sender];
        if (limit > 0) {
            require(spentToday[msg.sender] + amount <= limit, "BudgetController: daily limit exceeded");
        }
        spentToday[msg.sender] += amount;
        emit SpendRecorded(msg.sender, amount, spentToday[msg.sender]);
    }

    /// @notice Check without reverting: returns (allowed, remainingToday).
    function canSpend(address user, uint256 amount) external view returns (bool allowed, uint256 remaining) {
        uint256 limit = dailyLimitWei[user];
        if (limit == 0) {
            return (true, type(uint256).max);
        }
        uint256 day = block.timestamp / 1 days;
        uint256 spent = currentDayStart[user] == day ? spentToday[user] : 0;
        if (spent + amount <= limit) {
            return (true, limit - spent - amount);
        }
        return (false, limit > spent ? limit - spent : 0);
    }
}
