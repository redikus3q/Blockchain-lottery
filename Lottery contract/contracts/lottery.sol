// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract LotteryContract {
    struct Lottery {
        string name;
        uint startDate;
        uint totalPrize;
        bool finalized;
    }

    address public m_owner;
    uint public m_lotteryId = 0;
    uint public m_ticketPrice = 0.01 ether;
    uint public m_commision = 5;
    mapping(uint => Lottery) public m_lotteries;
    mapping(uint => address[]) public m_tickets;

    constructor() {
        m_owner = msg.sender;
    }

    modifier OnlyOwner() {
        require(msg.sender == m_owner, "Only the owner of the contract can do this.");
        _;
    }

    function CreateLottery(string memory name, uint startDate) public OnlyOwner {
        m_lotteries[m_lotteryId] = Lottery(name, startDate, 0, false);
        m_lotteryId++;
    }

    function BuyTicket(uint lotteryId) public payable {
        require(lotteryId < m_lotteryId, "The lottery does not exist!");
        require(!m_lotteries[lotteryId].finalized, "This lottery is already finished!");
        require(msg.value == m_ticketPrice, "You need to pay exactly for one ticket!");
        m_tickets[lotteryId].push(msg.sender);
        m_lotteries[lotteryId].totalPrize += m_ticketPrice;
    }

    function RandomWinner(uint range) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.basefee, m_tickets[m_lotteryId].length))) % range;
    }

    function FinishLottery(uint lotteryId) public OnlyOwner {
        require(lotteryId < m_lotteryId, "The lottery does not exist!");
        require(!m_lotteries[lotteryId].finalized, "This lottery is already finished!");
        require(m_tickets[lotteryId].length > 1, "This lottery doesn't have enough participants!");
        m_lotteries[lotteryId].finalized = true;
        uint prizePool = m_lotteries[lotteryId].totalPrize;
        uint winner1Prize = prizePool * 8 / 10;
        uint winner2Prize = prizePool * 15 / 100;
        uint comissionAmount = prizePool * m_commision / 100;
        payable(m_owner).transfer(comissionAmount);
        uint winner1 = RandomWinner(m_tickets[lotteryId].length);
        uint winner2 = RandomWinner(m_tickets[lotteryId].length);
        payable(m_tickets[lotteryId][winner1]).transfer(winner1Prize);
        payable(m_tickets[lotteryId][winner2]).transfer(winner2Prize);
    }
}