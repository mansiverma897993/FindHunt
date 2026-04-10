// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SubscriptionManager
 * @notice Pre-funded recurring native transfers: user deposits, creates subscription, anyone can execute when due.
 */
contract SubscriptionManager {
    struct Subscription {
        address payer;
        address recipient;
        uint256 amountWei;
        uint256 periodSeconds;
        uint256 nextDue;
        bool active;
    }

    Subscription[] public subscriptions;
    mapping(address => uint256) public prepaidBalance;

    event PrepaidDeposit(address indexed user, uint256 amount);
    event PrepaidWithdraw(address indexed user, uint256 amount);
    event SubscriptionCreated(uint256 indexed id, address payer, address recipient, uint256 amountWei, uint256 periodSeconds);
    event SubscriptionExecuted(uint256 indexed id, uint256 when);
    event SubscriptionCancelled(uint256 indexed id);

    function depositPrepaid() external payable {
        require(msg.value > 0, "SubscriptionManager: zero");
        prepaidBalance[msg.sender] += msg.value;
        emit PrepaidDeposit(msg.sender, msg.value);
    }

    function withdrawPrepaid(uint256 amount) external {
        require(prepaidBalance[msg.sender] >= amount, "SubscriptionManager: insufficient prepaid");
        prepaidBalance[msg.sender] -= amount;
        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        require(ok, "SubscriptionManager: transfer failed");
        emit PrepaidWithdraw(msg.sender, amount);
    }

    function createSubscription(
        address recipient,
        uint256 amountWei,
        uint256 periodSeconds
    ) external returns (uint256 id) {
        require(recipient != address(0), "SubscriptionManager: bad recipient");
        require(amountWei > 0 && periodSeconds > 0, "SubscriptionManager: bad params");
        require(prepaidBalance[msg.sender] >= amountWei, "SubscriptionManager: fund prepaid first");

        id = subscriptions.length;
        subscriptions.push(
            Subscription({
                payer: msg.sender,
                recipient: recipient,
                amountWei: amountWei,
                periodSeconds: periodSeconds,
                nextDue: block.timestamp,
                active: true
            })
        );
        emit SubscriptionCreated(id, msg.sender, recipient, amountWei, periodSeconds);
    }

    function executeSubscription(uint256 id) external {
        require(id < subscriptions.length, "SubscriptionManager: bad id");
        Subscription storage s = subscriptions[id];
        require(s.active, "SubscriptionManager: inactive");
        require(block.timestamp >= s.nextDue, "SubscriptionManager: not due");
        require(prepaidBalance[s.payer] >= s.amountWei, "SubscriptionManager: insufficient prepaid");

        prepaidBalance[s.payer] -= s.amountWei;
        (bool ok, ) = payable(s.recipient).call{value: s.amountWei}("");
        require(ok, "SubscriptionManager: payout failed");

        s.nextDue = block.timestamp + s.periodSeconds;
        emit SubscriptionExecuted(id, block.timestamp);
    }

    function cancelSubscription(uint256 id) external {
        require(id < subscriptions.length, "SubscriptionManager: bad id");
        Subscription storage s = subscriptions[id];
        require(s.payer == msg.sender, "SubscriptionManager: not payer");
        s.active = false;
        emit SubscriptionCancelled(id);
    }

    function subscriptionCount() external view returns (uint256) {
        return subscriptions.length;
    }
}
