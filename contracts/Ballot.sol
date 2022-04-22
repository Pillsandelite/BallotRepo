// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/security/Pausable.sol";

contract Ballot is Pausable {
    // Variables
    struct vote{
        address voterAddress;
        bool choice;
    }
    struct voter{
        string voterName;
        bool voted;
    }

    uint private countResult = 0;
    uint public finalResult = 0;
    uint public totalVoter = 0;
    uint public totalVote = 0;

    address public ballotChairman;
    string public chairMan;
    string public election;

    mapping(uint => vote) private votes;
    mapping(address =>voter) public voterStakeholder;

    enum State { Created, Voting, Ended }
    State public state;

    // Modifiers
    modifier condition(bool _condition) {
        require(_condition);
        _;
    }
    modifier onlyChairman() {
        require(msg.sender == ballotChairman);
        _;
    }
    modifier inState (State _state) {
        require(state == _state);
        _;
    }
    
    constructor (
        string memory _chairMan,
        string memory _election
    )
    {
        ballotChairman = msg.sender;
        chairMan = _chairMan;
        election = _election;

        state = State.Created;
    }
        // functions
    function addVoter(address _voterAddress, string memory _voterName)
        public
        inState(State.Created)
        onlyChairman
    {
        voter memory v;
        v.voterName = _voterName;
        v.voted = false;
        voterStakeholder[_voterAddress] = v;
        totalVoter++;
    }
    function startVote()
        public
        inState(State.Created)
        onlyChairman
    {
        state = State.Voting;
    }
    function doVote(bool _choice)
        public
        inState(State.Voting)
        returns (bool voted)
    {
        bool found = false;

    if  (bytes(voterStakeholder[msg.sender].voterName).length !=0
    &&  !voterStakeholder[msg.sender].voted){
        voterStakeholder[msg.sender].voted = true;
        vote memory v;
        v.voterAddress = msg.sender;
        v.choice = _choice;
        if(_choice) {
            countResult++;
        }
        votes[totalVote] = v;
        totalVote++;
        found = true;
    }
    return found;
    }
    function endVote() 
        public inState(State.Voting)
        onlyChairman
    {
        state = State.Ended;
        finalResult = countResult;
    }
}