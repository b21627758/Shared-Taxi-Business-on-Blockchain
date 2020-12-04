pragma solidity >=0.5.1<0.6.0;

contract TaxiPartnership{
    
    // Elections
    uint8 carPurcahseVoteCounter;
    mapping(bytes32=>eStat) voteInk1;
    uint32 version1;
    
    uint8 carSellVoteCounter;
    mapping(bytes32=>eStat) voteInk2;
    uint32 version2;
    
    
    uint approveDriverVoteCounter;
    mapping(bytes32=>eStat) voteInk3;
    uint32 version3;
    
    uint256 salaryTimer;
    uint256 expencesTimer;
    uint256 payDivTimer;
    
    
    // Owner
    address payable owner;
    
    // Contract Balance
    uint256 balance;
    
    // Taxi Unique ID
    int32 carID;
    
    // Car Status
    enum eStat {EXPIRED,APPROVED,DENIED, WAITING}
    
    // Driver
    struct driver{
        address payable wallet;
        uint32 salary;
        uint32 balance;
        
    }
    
    // Participants
    struct participant{
        address payable wallet;
        uint256 balance;
        bool flag;
    }
    
    // Participants Mapped With addresses    
    mapping(address=>participant) internal participants;
    
    // Participants mapped With counter
    mapping(uint=>participant) public Iparticipants;
    
    uint8 participantCounter;
    

    // Car
    struct Car{
        int32 carID;
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
    
    driver actualDriver;
    driver candidateDriver;
    
    constructor () public {
        owner = msg.sender;
        manager = msg.sender;
        participantCounter = 0;
        payDivTimer = now;
    }
    
    modifier checkPlace(){
        require(participantCounter<9);
        _;
    }
    
    modifier checkFee(){
        require(msg.value==100 ether);
        _;
    }
    
    modifier checkExistance(){
        require(!participants[msg.sender].flag);
        _;
    }
    
    modifier managerPrivilege(){
        require(manager == msg.sender);
        _;
    }
    
    modifier dealerPrivilege(){
        require(dealer == msg.sender);
        _;
    }
    
    modifier participantPrivilege(){
        require(participants[msg.sender].flag);
        _;
    }
    
    modifier checkBuyStateWaiting(){
        require(proposedCar.approvalState == eStat.WAITING);
        _;
    }
    
    modifier onlyOnce1(){
        require(voteInk1[keccak256(version1, msg.sender)] == eStat.EXPIRED);
        _;
    }
    
    modifier checkBuyStateApproved(){
        require(proposedCar.approvalState == eStat.APPROVED);
        _;
    }
    
    modifier checkBuyPayment(){
        require(balance >= (actualDriver.salary+10 ether + proposedCar.price));
        _;
    }
    
    modifier checkSellStateWaiting(){
        require(proposeRepurcahse.approvalState == eStat.WAITING);
        _;
    }
    
     modifier onlyOnce2(){
        require(voteInk2[keccak256(version2, msg.sender)] == eStat.EXPIRED);
        _;
    }
    
    modifier checkSellState(){
        require(proposeRepurcahse.approvalState == eStat.APPROVED);
        _;
    }
    
    modifier checkSellPayment(){
        require(msg.value == proposeRepurcahse.price);
        _;
    }
    
     modifier onlyOnce3(){
        require(voteInk3[keccak256(version3, msg.sender)] == eStat.EXPIRED);
        _;
    }
    
    modifier checkFired(){
        require(actualDriver.salary == 0);
        _;
    }
    
    modifier checkTaxiCharge(){
        require(msg.value > 0);
        _;
    }
    
    modifier checkOnceAMonth(){
        require(now >= salaryTimer + 30 days );
        _;
    }
    
    modifier checkActualDriverExistance(){
        require(actualDriver.salary != 0);
        _;
    }
    
    modifier checkSalBalance(){
        require(balance>=actualDriver.salary);
        _;
    }
    
    modifier driverPivilege(){
        require(actualDriver.wallet == msg.sender);
        _;
    }
    
    
     modifier checkOnceInSixMonthExp(){
         require(now >= expencesTimer + 180 days );
         _;
     }
     
     modifier checkExpBalance(){
         require(balance >= 10 ether);
         _;
     }
     
     modifier checkCarExistance(){
         require(carID > 0);
         _;
     }
     
     modifier checkOnceInSixMonthPay(){
         require(now >= payDivTimer + 180 days);
         _;
     }
     
     modifier checkBalanceSalaryAndExpenses(){
         require(balance >= (actualDriver.salary + 10 ether));
         _;
     }
     
    function join() public
    checkPlace
    checkFee
    checkExistance
    {
        balance+=msg.value;
        participant memory temp = participant(msg.sender,0,true);
        participants[msg.sender] = temp;
        Iparticipants[participantCounter++] = temp;
    }
    
    function SetCarDealer(address payable _dealer) public
    managerPrivilege
    {
        dealer = _dealer;
    }
    
    function CarProposeToBusiness(int32 _carID, uint32 _price, uint256 _offerValidTime) public
    dealerPrivilege
    {   
        delete proposedCar;
        version1++;
        delete carPurcahseVoteCounter;
        proposedCar = Car(_carID, _price,_offerValidTime, eStat.WAITING);
    }
    
    function approvePurchaseCar() public
    participantPrivilege
    checkBuyStateWaiting
    onlyOnce1
    {
        voteInk1[keccak256(version1, msg.sender)] = eStat.APPROVED;
        carPurcahseVoteCounter++;
    }
    
    function PurchaseCar() payable public
    managerPrivilege
    checkBuyStateApproved
    checkBuyPayment
    {
        
        balance-=proposedCar.price;
        dealer.transfer(proposedCar.price);
        balance+=proposedCar.price;
        carID = proposedCar.carID;
        expencesTimer = now;
        delete proposedCar;
        version1++;
        delete carPurcahseVoteCounter;
        
    }
    
    function RepurchaseCarPropose(int32 _carID, uint32 _price, uint256 _offerValidTime) public
    dealerPrivilege
    {
        delete proposeRepurcahse;
        version2++;
        delete carSellVoteCounter;
        proposeRepurcahse = Car(_carID, _price, _offerValidTime, eStat.WAITING);
    }
    
    function ApproveSellProposal() public
    participantPrivilege
    checkSellStateWaiting
    onlyOnce2
    {
        voteInk2[keccak256(version2, msg.sender)] = eStat.APPROVED;
        carSellVoteCounter++;
    }
    
    function Repurchasecar() public payable
    dealerPrivilege
    checkSellState
    checkSellPayment
    {
        balance+=msg.value;
        delete proposeRepurcahse;
        version2 ++;
        delete carID;
        delete expencesTimer;
        delete carSellVoteCounter;
    }
    
    function ProposeDriver(address payable _driver, uint32 salary ) public
    managerPrivilege
    {
        delete approveDriverVoteCounter;
        version3++;
        delete candidateDriver;
        candidateDriver = driver(_driver, salary, 0);
    }
    
    function ApproveDriver() public
    participantPrivilege
    onlyOnce3
    {
        voteInk3[keccak256(version3, msg.sender)] = eStat.APPROVED;
        approveDriverVoteCounter++;
    }
    
    function SetDriver() public
    managerPrivilege
    checkFired
    {
        actualDriver = driver(candidateDriver.wallet, 0,0);
        salaryTimer = now;
        delete candidateDriver;
        version3++;
        delete approveDriverVoteCounter;
    }
    
    function FireDriver() public
    managerPrivilege
    checkActualDriverExistance
    checkSalBalance
    {
        balance-=actualDriver.salary;
        actualDriver.balance+=actualDriver.salary;
        salaryTimer = 0;
        delete actualDriver;
    }
    
    function PayTaxiCharge() public
    checkTaxiCharge
    {
        balance+=msg.value;
    }
    
    function ReleaseSalary() public
    managerPrivilege
    checkOnceAMonth
    checkActualDriverExistance
    checkSalBalance
    {
        balance-=actualDriver.salary;
        actualDriver.balance+=actualDriver.salary;
        salaryTimer = now;
    }
    
    function GetSalary() public
    driverPivilege
    {
        
        actualDriver.wallet.transfer(actualDriver.balance);
        actualDriver.balance = 0;
        
    }
    
    function PayCarExpenses() public
    managerPrivilege
    checkOnceInSixMonthExp
    checkExpBalance
    checkCarExistance
    {
        expencesTimer = now;
        balance-=10 ether;
        dealer.transfer(10 ether);
        
    }
    
    function PayDivided() public
    managerPrivilege
    checkOnceInSixMonthPay
    checkBalanceSalaryAndExpenses
    {
        payDivTimer = now;
        uint temp = balance - actualDriver.salary - 10 ether ;
        balance-= temp;
        for(uint i = 0 ; i < participantCounter-1; i++){
            Iparticipants[i].balance += temp/(participantCounter+1);
        }
    }
    
    function GetDivided() public
    participantPrivilege
    {
        participants[msg.sender].wallet.transfer(participants[msg.sender].balance);
        participants[msg.sender].balance = 0; 
    }
    
    function() external{
        revert();
    }
}
