pragma solidity ^0.4.18;

contract commodityVoucher {
	// Generic Voucher Language https://tools.ietf.org/html/draft-ietf-trade-voucher-lang-07
	// The Ricardian Financial Instrument Contract http://www.systemics.com/docs/ricardo/issuer/contract.html
	
    // Owner of this smart contract, the legal entity signing the Ricardian Contract
    address public legalEntity ;
  
// Public variables of the ERC20 token 
    string public standard = 'Token 0.1';
    string public name = 'voucher';
    string public symbol = '∏';
    uint public decimals = 2;
    uint public totalSupply;

// Public variables of the sellers associaton
// total Debt in vts 
    int public totalDebt;
    uint public numberSellers;

// Public variables of the Bancor protocol
// Constant Reserve Ratio (CRR)
    uint CRR = 100;
// Tax
    uint tax = 20;
// Relay related
// reserve in Ξ
    uint public totalReserve;
    uint public price;
    
// A Ricardian contract is a document which is legible to both a court of law and to a software application
// Ricardian Contract legal entity operating the token
    string brandname = 'the name normally known in the street'; 
    string shortname = 'short name is displayed by trading software, 8 chars'; 
    string longname = 'full legal name'; 
    string postaAddress = 'formal address for snail-mail notices'; 
    string country = 'ISO code that indicates the jurisdiction'; 
    string registration = 'legal registration code of the legal person or legal entity';
    string contractHash = 'swarm hash of the human readable legal document, signed, preferably XML generated to be parsevable'; 

// Contract details as in the legal document
// Duration of the contract
    uint duration = 1 years;
// validity time of the contract
    uint public expiration; 				   
    uint public start;
// Lenght of selling periods in time
    uint public period = 4 weeks;
    uint public currentPeriod;
// Provides restrictions on the object to be claimed
    string[] merchandises; 
// Includes terms and definitions to be defined in a contract
    string[] definitions; 
// Provides any other applicable restrictions
    string[] conditions; 
    
// Functions with this modifier can only be executed by the legalEntity
     modifier onlyLegalEntity() {
         if (msg.sender != legalEntity) {
            revert();
         }
        _;
     }
     
// Functions with this modifier can only be executed during the validity period
     modifier onlyV() {
         if ((now < start) || (now > expiration)) {
            revert(); }
         _;
    }
  
// Functions with this modifier can only be executed during the validity period
    modifier onlySeller() {
         if (seller[msg.sender].member != true) {
            revert(); }
         _;
    }
       
    
// balance in tokens for each account for each period
// We use VTS for a voucher following the Voucher Trading System (VTS) conventions
    mapping(address => uint) public vts;

// Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint)) public allowed;

// structuring seller information   
    struct Seller{
// brandname, he name normally known in the street
        string bName;
        bool member;
        int[] debt;
    }    
    mapping (address => Seller) seller;

// Initializes contract 
     function commodityVoucher(            					
         ) public {
     		legalEntity = msg.sender;
            totalSupply = 0;
            totalDebt = 0;
            totalReserve = 0;
            numberSellers = 0;
		    seller[msg.sender].bName = brandname;
	    	seller[msg.sender].member = true;
            seller[msg.sender].debt[0] = 0;
            numberSellers += 1;
     		start = now;
     		expiration = now + duration;
     		// write as many as necessary
     		merchandises[0] = 'Provides restrictions on the object to be claimed';
     		definitions[0] = 'Includes terms and definitions to be defined in a contract';
     		conditions[0] = 'Provides any other applicable restrictions';
     		totalReserve = 0;
     		price = 100 / tax;
     }
     
// This generates public events on the blockchain that will notify clients
     
// Triggered when voucher are transferred.
     event Transfer(uint _amount, address indexed _from, uint _balanceFrom, address indexed _to, uint _balanceTo);
 
 // Triggered whenever approve(address _spender, uint256 _value) is called
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  
// Function get current period
    function getPeriod () public {
    currentPeriod = (now - start) / period;
    }
    
// ERC20 set of functions

// Transfer vouchers. Transfer the balance from sender's account to another account
    function transfer(address _to, uint _amount) public onlyV {
        // Check if the sender has enough
        if (vts[msg.sender] < _amount) revert();   
        // Check for overflows
        if (vts[_to] + _amount < vts[_to]) revert(); 	
        // Subtract from the sender
        vts[msg.sender] -= _amount;  
        // Add the same to the recipient
        vts[_to] += _amount;    
        // Notify anyone listening that this transfer took place
        Transfer(_amount, msg.sender, vts[msg.sender], _to, vts[_to] );                   
    }
    
// Allow _spender to withdraw from your account, multiple times, up to the _value amount.
// If this function is called again it overwrites the current allowance with _value.
     function approve(address _spender, uint _amount) public onlyV {
         allowed[msg.sender][_spender] = _amount;
         Approval(msg.sender, _spender, _amount);
    }
     
// Send an amount of tokens from other address _from to address _to
    function transferFrom(address _from, address _to, uint _amount) public onlyV returns (bool success) {
        // Check allowance
        require(_amount <= allowed[_from][msg.sender]);
        allowed[_from][msg.sender] -= _amount;
        // Check if the sender has enough
        if (vts[_from] < _amount) revert();   
        // Check for overflows
        if (vts[_to] + _amount < vts[_to]) revert();
        // Subtract from the sender
        vts[_from] -= _amount;  
        // Add the same to the recipient
        vts[_to] += _amount; 
        return true;
        Transfer(_amount, _from, vts[_from], _to, vts[_to] );
    }

// What is the balance of a particular account?
     function balanceOf(address _account) constant public returns (uint balance) {
         return vts[_account];
     }

// What is the allowance of a particular account?
    function allowance(address _account, address _spender) constant public returns (uint256 remaining) {
	    return allowed[_account][_spender];
	}

// MEMBER MANAGEMENT

// Register as seller
    function register (string _brandname) public onlyV()  {
        	seller[msg.sender].bName = _brandname;
	    	seller[msg.sender].member = true;
            seller[msg.sender].debt[0] = 0;
            numberSellers += 1;
    }
        

// Throw seller
// Warning, all his debt remains. That is, thre is an excess of tokens, monatary mass in excess of goods that nobody will deliver
    function expulsion (address _seller) public onlyV() onlyLegalEntity() {
	    	seller[_seller].member = true;
            numberSellers -= 1;
    }

// Get seller information

// Get global variables
	
// ISSUING AND REDEEMING PROMISES

// A producer promises to produce and sell, isues tokens and aquires a seller.debt
    function issueTokens (uint _amount, uint _periodNumber) public onlyV {
        // promises cannot be beyond valid period
        if ((now + (_periodNumber * period)) > expiration) revert();

        // Calculate the amount of Ξ to deposit
        uint deposit = _amount / price;
        // Calculate the new price
        price = (totalReserve + deposit)/ (totalSupply + _amount) * (CRR / 100);
        // Deposit the tax reserve in Ξ
        // Calculate the due reserve, according Bancor formula
        // The Legal Entity acts as Bancor Relay
        // Isue the tokens
            vts[msg.sender] += _amount;
            // Update total supply
            totalSupply += _amount;
            int _debt = int(_amount);
            // Carry over the last period debt
            seller[msg.sender].debt[_periodNumber] += seller[msg.sender].debt[_periodNumber - 1];
            seller[msg.sender].debt[_periodNumber - 1];
            // Register new debt
            seller[msg.sender].debt[_periodNumber] += _debt;
            // Update total debt
            totalDebt += _debt;
            // put the tax reserve at the Legal Entity
    }
    
// Buy a product to a producer by redeeming tokens
        function buy (address _seller, uint _price) public onlyV {
            // get the current period _periodNumber
            getPeriod ();
            // Check if the buyer has enough
            if (vts[msg.sender] < _price) revert(); 
            //  Redeem the tokens
            vts[msg.sender] -= _price;
            // the seller cancels debt for that period
            int _debt = int(_price);
            seller[_seller].debt[currentPeriod] -= _debt;
        }
    
// What is the debt of a particular account due to a certain period?
     function debtOf(address _account, uint _periodNumber) constant public returns (int _debt) {
         return seller[_account].debt[_periodNumber];
     }
     


// LIQUIDITY


// This unnamed function is called whenever someone tries to send ether to it */
    function () public {
        revert();     // Prevents accidental sending of ether
    }
}
