// SPDX-License-Identifier: UNLICENSED
// This contract is the sample contract for the collateralized Put option (American style) with physical settlement
// for any ERC20 Token. The contract has not gone through the security audit, therefore use at your own risk.

pragma solidity > 0.8.0 <0.9.0;

import "./Ownable.sol";

abstract contract ERC20Token {
    
    function balanceOf(address account) external view returns (uint256){
    }
    function transfer(address recipient, uint256 amount) external returns (bool){
    }
    
} 

contract PutOption is Ownable {
    
    // Address of the Buyer of the Put option
    address private buyer;
    // Quantity of the tokens at stake in the option contract
    uint private immutable quantity; 
    // Strike price of the put option in Wei/Token
    uint private immutable strikePrice;
    // Purchase price of the put option contract in Wei
    uint private immutable purchasePrice;
    // Expiry time of the put option
    uint private immutable expiryTime;
    // Contract Address of the ERC20 Token (can be any ERC20 token, for the purposes of testing CleverWizardToken in the folder can be used)
    address private immutable tokenContractAddress;
    // ERC20 Token's instance in the contract
    ERC20Token private Token;
    // Boolean for whether the contract has been purchased by any buyer or not
    bool private wasPurchased; 
    // Boolean for whether the contract is collateralized by the seller or not
    bool private wasCollateralized;
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
        wasCollateralized = false;
        optionType = "put";
    }
    
    // Returns all the terms of the put option contract
    function getOptionConditions() public view returns(uint _quantity, uint _strikePrice, uint _purchasePrice, uint _expiryTime, bool _wasCollateralized, bool _wasPurchased, bytes32 _optionType, address _tokenContractAddress){
        return (quantity, strikePrice, purchasePrice, expiryTime, wasCollateralized, wasPurchased, optionType, tokenContractAddress);
    }
    
    //Allows the seller of the put contract to collateralize the option
    function collateralize() public payable onlyOwner {
        require(msg.value == quantity * strikePrice, "Not the right amount of collateral transferred");
        wasCollateralized = true;
    }
    
    // Allows the Buyer of the contract to buy the option contract.
    // For convenience the buyer can be from any address. If needed, the function can be modified to serve a specific buyer's address.
    // Note: The buyer cannot buy the option contract unless the Seller of the contract first collaterlizes it with ETH.
    function purchase() public payable {
        require(!wasPurchased, "Option is already purchased");
        require(wasCollateralized == true, "Option is not collateralized yet");
        require(msg.value == purchasePrice, "Incorrect purchase price");
        buyer = msg.sender;
        wasPurchased = true;
        emit optionPurchased(owner(), msg.sender, block.timestamp);
    }
    
    // Allows the buyer to execute the option contract at any time before the Option contract.
    function execute() public {
        require(wasPurchased, "Option is unpurchased");
        require(msg.sender == buyer, "You are unauthorized for the option contract");   
        require(block.timestamp < expiryTime, "Option is Expired");
        require(Token.balanceOf(address(this)) == quantity, "Tokens have not been transferred yet");
        Token.transfer(owner(), quantity);
        payable(buyer).transfer(quantity*strikePrice);
        emit optionExecuted(msg.sender, block.timestamp);
        selfdestruct(payable(owner()));
    }
    
    //Refunds and sends the funds back to the Seller of the contract.
    //Can not refund if it was purchased before the contract has expired
    function refund() public onlyOwner {
        if(wasPurchased) {
            require(block.timestamp > expiryTime, "Option contract has not expired yet");
        }
        wasCollateralized = false;
        selfdestruct(payable(owner()));
    }

    function getBuyer() public view returns (address) {
        return buyer;
    }

     //Contract can accept deposits
    receive() external payable {}
    fallback() external payable {}
}