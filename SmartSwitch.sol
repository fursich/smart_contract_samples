pragma solidity ^0.4.18;

contract SmartSwitch {
    struct Switch {
        address addr;
        uint endTime;
        bool status;
    }
    
    address public owner;
    address public iot;
    
    mapping (uint => Switch) public switches;
    uint public numPaid;
    uint public duration;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyIoT() {
        require(msg.sender == iot);
        _;
    }

    /* Constructor */
    function SmartSwitch(address _iot, uint _duration) public {
        owner = msg.sender;
        iot = _iot;
        duration = _duration;
        numPaid = 0;
    }
    
    function payToSwitch() public payable {
        require(msg.value == 1000000000000000000);
        
        Switch storage s = switches[numPaid++];
        s.addr           = msg.sender;
        s.endTime        = now + duration;
        s.status         = true;
    }
    
    function updateStatus(uint _index) public onlyIoT {
        require(switches[_index].addr != 0);
        
        require(now > switches[_index].endTime);
        
        switches[_index].status = false;
    }
    
    function withdrawFunds() public onlyOwner {
        if (!owner.send(address(this).balance))
        revert();
    }
    
    function kill() public onlyOwner {
        selfdestruct(owner);
    }
}
