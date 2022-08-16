// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Heritage {
    address owner;

    event LogKidFundingReceived(
        address addr,
        uint256 amount,
        uint256 contractBalance
    );

    // Define a kid
    struct Kid {
        address payable walletAddress;
        string firstName;
        string lastName;
        uint256 releaseTime;
        uint256 amount;
        bool canWithdraw;
    }

    // Define Kid array
    Kid[] public kids;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can add kids");
        _;
    }

    // Add a kid
    function addKid(
        address payable walletAddress,
        string memory firstName,
        string memory lastName,
        uint256 releaseTime,
        uint256 amount,
        bool canWithdraw
    ) public onlyOwner {
        kids.push(
            Kid(
                walletAddress,
                firstName,
                lastName,
                releaseTime,
                amount,
                canWithdraw
            )
        );
    }

    // Get total balance of the account
    function balanceOf() public view returns (uint256) {
        return address(this).balance;
    }

    function addToKidBalance(address walletAddress) private onlyOwner {
        for (uint256 i = 0; i < kids.length; i++) {
            if (kids[i].walletAddress == walletAddress) {
                kids[i].amount += msg.value;
                emit LogKidFundingReceived(
                    walletAddress,
                    msg.value,
                    balanceOf()
                );
                break;
            }
        }
    }

    // add fund to the account
    function deposit(address walletAddress) public payable {
        addToKidBalance(walletAddress);
    }

    function getIndex(address walletAddress) private view returns (uint256) {
        uint256 index = 0;
        for (uint256 i = 0; i < kids.length; i++) {
            if (kids[i].walletAddress == walletAddress) {
                index = i;
                break;
            }
        }
        return index;
    }

    // can withdraw?
    function availableToWithdraw(address walletAddress) public returns (bool) {
        uint256 index = getIndex(walletAddress);

        require(
            block.timestamp > kids[index].releaseTime,
            "You are not allowed to withdraw at this time."
        );
        if (block.timestamp > kids[index].releaseTime) {
            kids[index].canWithdraw = true;
            return true;
        } else {
            return false;
        }
    }

    // Withdraw
    function withdraw(address walletAddress) public payable {
        uint256 i = getIndex(walletAddress);
        require(
            msg.sender == kids[i].walletAddress,
            "You can only send your own money."
        );
        require(
            kids[i].canWithdraw == true,
            "You are not able to withdraw at this time."
        );
        kids[i].walletAddress.transfer(kids[i].amount);
    }
}
