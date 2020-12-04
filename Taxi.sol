pragma solidity >=0.5.1<0.6.0;

contract TaxiPartnership{
    
    // Elections
    uint8 carPurcahseVoteCounter;
    uint8 carSellVoteCounter;
    uint approveDriver;
    
    // Owner
    address payable owner;
    
    // Contract Balance
    uint32 balance;
    
    // Taxi Unique ID
    int carID;
    
    // Car Status
    enum eStat {APPROVED,DENIED, EXPIRED}
    enum stat {CANDIDATE, ACTUAL}
    
    // Driver
    struct driver{
        address payable wallet;
        uint32 salary;
        stat status;
    }
    
    // Participants
    struct participant{
        address payable wallet;
        uint32 balance;
        bool check;
    }
    
    // Participants Mapped With addresses    
    mapping(address=>participant) internal participants;
    
    // Participants mapped With counter
    mapping(uint=>address) public Iparticipants;
    
    uint8 participantCounter;
    

    // Car
    struct Car{
        int carID;
        uint32 price;
        uint256 offerValidTime;
        eStat approvalState;
    }
    
    
    // Manager Account
    address payable manager;
    
    // Taxi Driver Account
    driver tDriver;
    
    // Dealer Account
    address payable dealer;
    
    
    Car proposedCar;
    Car proposeRepurcahse;
    
    
    
}