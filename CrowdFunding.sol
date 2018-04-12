pragma solidity ^0.4.18;

contract CrowdFunding {
    struct Investor {
        address addr;
        uint    amount;
    }
    
    address public owner;
    uint public    numInvestors;
    uint public    deadline;
    string public  status;
    bool public    ended;
    uint public    goalAmount;
    uint public    totalAmount;
    mapping (uint => Investor) public investors;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /* Constructor */
    function CrowdFunding(uint _duration, uint _goalAmount) public {
        owner        = msg.sender;
        deadline     = now + _duration;
        goalAmount   = _goalAmount;
        status       = "Funding";
        ended        = false;
        
        numInvestors = 0;
        totalAmount  = 0;
    }
    
    function fund() public payable {
        require(!ended);
        
        Investor storage inv = investors[numInvestors++];
        inv.addr             = msg.sender;
        inv.amount           = msg.value;
        totalAmount          += inv.amount;
    }
    
    function checkGoalReached () public onlyOwner {
        require(!ended);
        require(now >= deadline);

        ended = true;
        if(totalAmount >= goalAmount) {
            status = "Campaign Succeeded";
            if(!owner.send(address(this).balance)) {
                revert();
            }
        } else {
            status = "Campaign Failed";
            for(uint i; i < numInvestors; i++) {
                if(!investors[i].addr.send(investors[i].amount)) {
                    revert();
                }
            }
        }
    }
    
    function kill() public onlyOwner {
        selfdestruct(owner);
    }
}
