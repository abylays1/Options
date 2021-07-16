// SPDX-License-Identifier: UNLICENSED
// This contract is the sample contract for the covered collateralized call option (American style) with physical settlement
// for any ERC20 Token. The contract has not gone through the security audit, therefore use at your own risk.

pragma solidity > 0.8.0 <0.9.0;

import "./Ownable.sol";

abstract contract ERC20Token {
    
    function balanceOf(address account) external view returns (uint256){
    }
    function transfer(address recipient, uint256 amount) external returns (bool){
    }
    
} 

contract CallOption is Ownable {
    
    // Address of the Buyer of the Call option
    address private buyer;
    // Quantity of the tokens at stake in the option contract
    uint private immutable quantity; 
    // Strike price of the call option in Wei/Token
    uint private immutable strikePrice;
    // Purchase price of the call option contract in Wei
    uint private immutable purchasePrice;
    // Expiry time of the option
    uint private immutable expiryTime;
    // Contract Address of the ERC20 Token (can be any ERC20 token, for the purposes of testing CleverWizardToken in the folder can be used)
    address private immutable tokenContractAddress;
    // ERC20 Token's instance in the contract
    ERC20Token private Token;
    // Boolean for whether the contract has been purchased by any buyer or not
    bool private wasPurchased;
    //Whether option is Call or Put
    bytes32 private optionType; 
    
    event optionPurchased(address indexed _from, address indexed _by, uint256 _time);
    event optionExecuted(address indexed _by, uint256 _time);


    constructor(uint _quantity, uint _strikePrice, uint _purchasePrice, uint _expiryTime, address _tokenContractAddress) Ownable() {
        quantity = _quantity;
        strikePrice = _strikePrice;
        purchasePrice = _purchasePrice;
        expiryTime = _expiryTime;
        tokenContractAddress = _tokenContractAddress;
        Token = ERC20Token(_tokenContractAddress);
        wasPurchased = false;
        optionType = "call";
    }
    
    // Returns all the terms of the Call option contract
    function getOptionConditions() public view returns(uint _quantity, uint _strikePrice, uint _purchasePrice, uint _expiryTime, bool _tokenTransfered, bool _wasPurchased, bytes32 _optionType, address _tokenContractAddress){
        if(Token.balanceOf(address(this)) == quantity){
            _tokenTransfered = true;   
        }
        return (quantity, strikePrice, purchasePrice, expiryTime, _tokenTransfered, wasPurchased, optionType, tokenContractAddress);
    }
    
    // Allows the Buyer of the contract to buy the option contract.
    // For convenience the buyer can be from any address. If needed, the function can be modified to serve a specific buyer's address.
    // Note: The buyer cannot buy the option contract unless the owner of the contract first collaterlizes it with tokens.
    function purchase() public payable {
        require(!wasPurchased, "Option is already purchased");
        require(Token.balanceOf(address(this)) == quantity, "Option is not collateralized yet");
        require(msg.value == purchasePrice, "Incorrect purchase price");
        buyer = msg.sender;
        wasPurchased = true;
        emit optionPurchased(owner(), msg.sender, block.timestamp);
    }

    // Allows the buyer to execute the option contract at any time before the Option contract.
    function execute() public payable {
        require(wasPurchased, "Option is unpurchased");
        require(msg.sender == buyer, "You are unauthorized for the option contract");   
        require(block.timestamp < expiryTime, "Option is Expired");
        require(msg.value == strikePrice*quantity, "Payment error");
        Token.transfer(buyer, quantity);
        emit optionExecuted(msg.sender, block.timestamp);
        selfdestruct(payable(owner()));
    }
    
    //Refunds and sends the funds back to the Owner of the contract.
    //Can not refund if it was purchased before the contract has expired
    function refund() public onlyOwner {
        if(wasPurchased) {
            require(block.timestamp > expiryTime, "Option contract has not expired yet");
        }
        Token.transfer(owner(), quantity);
        selfdestruct(payable(owner()));
    }

    function getBuyer() public view returns (address) {
        return buyer;
    }

     //Contract can accept deposits
    receive() external payable {}
    fallback() external payable {}
}