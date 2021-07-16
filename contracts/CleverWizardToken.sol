// SPDX-License-Identifier: UNLICENSED
// This is an example ERC20 Token called CleverWizardToken (CLWZ)
// Apart from the standard and optional functions and parameters, the Token allows its users to burn their tokens.

pragma solidity > 0.8.0 <0.9.0;


interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface Additional {
    function burn(uint256 amount) external returns (bool);
}

contract CleverWizardToken is ERC20, Additional {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    // Total supply is equal to 10 million
    uint256 private _totalSupply = 10000000;

    string private constant _name = "CleverWizardToken";
    string private constant _symbol = "CLWZ";

    constructor() {
        _balances[msg.sender] = _totalSupply;        
    }

    // Returns the name of the token
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    //Returns the symbol of the token
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    // Returns the number of decimals used to get token's user representation.
    function decimals() public view virtual override returns (uint8) {
        return 1;
    }

    //Returns total supply of the token
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    //Returns the balance of an address in tokens
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    
    // Transfers `amount` from the msg.sender to the recepient's address
    // The caller must have a balance of at least `amount`.
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    // Shows how much allowance does a spender have given by the owner
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    // Msg.sender approves 'amount' of tokens for spending to the spender    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        require(_balances[msg.sender] >= amount, "Not enough balance to approve for spending");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    //Msg.sender spends his allowance amount from the sender's account to the recient
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        _allowances[sender][msg.sender] = currentAllowance - amount;
        _transfer(sender, recipient, amount);
        return true;
    }

    // Moves `amount` of tokens from `sender` to `recipient`.
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    // Destroys `amount` tokens from `account`, reducing the total supply.
    function burn(uint256 amount) external virtual override returns (bool){
        uint256 accountBalance = _balances[msg.sender];
        require(accountBalance >= amount, "Burn amount exceeds balance");
        _balances[msg.sender] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }
}