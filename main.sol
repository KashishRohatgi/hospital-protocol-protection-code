// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HospitalProtocolManager {

    address public admin;

    mapping(address => bool) public reviewers;
    mapping(address => bool) public sponsors;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin allowed");
        _;
    }

    modifier onlyReviewer() {
        require(reviewers[msg.sender], "Only reviewer allowed");
        _;
    }

    modifier onlySponsor() {
        require(sponsors[msg.sender], "Only sponsor allowed");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    enum Status {
        Draft,
        Submitted,
        Approved,
        Rejected
    }

    struct Protocol {
        uint id;
        string title;
        string documentHash;
        address sponsor;
        Status status;
    }

    uint public protocolCount;
    mapping(uint => Protocol) public protocols;

    event SponsorAdded(address sponsor);
    event ReviewerAdded(address reviewer);
    event ProtocolCreated(uint protocolId);
    event ProtocolSubmitted(uint protocolId);
    event ProtocolReviewed(uint protocolId, Status status);

    function addSponsor(address _sponsor) public onlyAdmin {
        sponsors[_sponsor] = true;
        emit SponsorAdded(_sponsor);
    }

    function addReviewer(address _reviewer) public onlyAdmin {
        reviewers[_reviewer] = true;
        emit ReviewerAdded(_reviewer);
    }

    function createProtocol(
        string memory _title,
        string memory _documentHash
    ) public onlySponsor {

        protocolCount++;

        protocols[protocolCount] = Protocol({
            id: protocolCount,
            title: _title,
            documentHash: _documentHash,
            sponsor: msg.sender,
            status: Status.Draft
        });

        emit ProtocolCreated(protocolCount);
    }

    function submitProtocol(uint _id) public onlySponsor {
        Protocol storage protocol = protocols[_id];
        require(protocol.sponsor == msg.sender, "Not protocol owner");
        require(protocol.status == Status.Draft, "Invalid state");

        protocol.status = Status.Submitted;
        emit ProtocolSubmitted(_id);
    }

    function reviewProtocol(uint _id, bool approve) public onlyReviewer {
        Protocol storage protocol = protocols[_id];
        require(protocol.status == Status.Subitted, "Not submitted");

        if (approve) {
            protocol.status = Status.Approved;
        } else {
            protocol.status = Status.Rejected;
        }

        emit ProtocolReviewed(_id, protocol.status);
    }

    function getProtocol(uint _id) public view returns (Protocol memory) {
        return protocols[_id];
    }
}
