// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DeFiLendingBorrowing {

    address public owner;
    uint256 public interestRate = 5; // 5% interest

    struct Loan {
        uint256 amount;
        bool active;
    }

    mapping(address => uint256) public deposits;
    mapping(address => Loan) public loans;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount);
    event Repaid(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    // Deposit ETH to lend
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        deposits[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    // Withdraw deposited ETH
    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    // Borrow ETH
    function borrow(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(address(this).balance >= amount, "Not enough liquidity");
        require(!loans[msg.sender].active, "Loan already active");

        loans[msg.sender] = Loan(amount, true);
        payable(msg.sender).transfer(amount);
        emit Borrowed(msg.sender, amount);
    }

    // Repay borrowed ETH + interest
    function repay() external payable {
        Loan storage loan = loans[msg.sender];
        require(loan.active, "No active loan");

        uint256 interest = (loan.amount * interestRate) / 100;
        uint256 totalRepayment = loan.amount + interest;

        require(msg.value >= totalRepayment, "Insufficient repayment");

        loan.active = false;
        loan.amount = 0;

        emit Repaid(msg.sender, msg.value);
    }

    // View contract balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
