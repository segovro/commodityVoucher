pragma solidity ^0.4.18;

contract commodityVoucher {

//References
// Generic Voucher Language https://tools.ietf.org/html/draft-ietf-trade-voucher-lang-07
//  Voucher Trading System (vtsToken) conventions, Language (RFC 4153) – IETF https://tools.ietf.org/html/rfc4153 
// The Ricardian Financial Instrument Contract http://www.systemics.com/docs/ricardo/issuer/contract.html
// Bancor white paper https://www.bancor.network/Whitepaper
// ERC20 Token Standard https://theethereum.wiki/w/index.php/ERC20_Token_Standard

  
// Public variables of the ERC20 token 
    string public standard = 'Token 0.1';
    string public name = 'vtsToken';
    string public symbol = 'vts';
    uint public decimals = 2;
    uint public totalSupply;
    
// Owner of this smart contract, the legal entity signing the Ricardian Contract
    address public legalEntity ;

// Public variables of the sellers associaton
// total Debt in vtsToken 
    int public totalDebt;
    uint public numberSellers;

// Public variables of the Bancor protocol
// Constant Reserve Ratio (CRR) is not used. Always 100%
// Tax, VAT in % + any crowdfunding of the Legal Entity.For tax = 20%, price is 5
// Relay related
    uint public totalReserve; // reserve in Ξ
    uint public vtsTokenPrice = 5; // vtsToken per Ξ

// A Ricardian contract is a document which is legible to both a court of law and to a software application
// Ricardian Contract legal entity operating the token
    string brandname = 'BRANDNAME'; //the name normally known in the street
    string shortname = 'ABCDEFGH'; // short name is displayed by trading software, 8 chars
    string longname = 'The Legal Entity Association of Producers'; // full legal name
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
     
// Functions with this modifier can only be executed by sellers
    modifier onlySeller() {
         if (seller[msg.sender].member != true) {
            revert(); }
         _;
    }
       
    
// balance in tokens for each account for each period
// We use vtsToken for a voucher following the Voucher Trading System (vtsToken) conventions
    mapping(address => uint) public vtsToken;

// Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint)) public allowed;

// structuring seller information   
    struct Seller{
// brandname, he name normally known in the street
        string bName;
        bool member;
        int[] debt; //due det for a period
        uint[] sales; // sales made in a period
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
      }
     
// This generates public events on the blockchain that will notify clients
     
// Triggered when voucher are transferred.
    event Transfer(uint _amount, address indexed _from, uint _balanceFrom, address indexed _to, uint _balanceTo);
 
// Triggered whenever approve is called
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

// Triggered at a sell
    event Sell(address indexed _seller, string _bName, address indexed _buyer, uint _price);
     
// Triggered when vouchers are issued
    event Issue(address indexed _seller, string _bName, uint _amount);
  
// Function get current period
    function getPeriod () public {
    currentPeriod = (now - start) / period;
    }
    
// ERC20 SET OF FUNCTIONS

// Transfer vouchers. Transfer the balance from sender's account to another account
    function transfer(address _to, uint _amount) public {
        // Check if the sender has enough
        if (vtsToken[msg.sender] < _amount) revert();   
        // Check for overflows
        if (vtsToken[_to] + _amount < vtsToken[_to]) revert(); 	
        // Subtract from the sender
        vtsToken[msg.sender] -= _amount;  
        // Add the same to the recipient
        vtsToken[_to] += _amount;    
        // Notify anyone listening that this transfer took place
        Transfer(_amount, msg.sender, vtsToken[msg.sender], _to, vtsToken[_to] );                   
    }
    
// Allow _spender to withdraw from your account, multiple times, up to the _value amount.
// If this function is called again it overwrites the current allowance with _value.
     function approve(address _spender, uint _amount) public {
         allowed[msg.sender][_spender] = _amount;
         Approval(msg.sender, _spender, _amount);
    }
     
// Send an amount of tokens from other address _from to address _to
    function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
        // Check allowance
        require(_amount <= allowed[_from][msg.sender]);
        allowed[_from][msg.sender] -= _amount;
        // Check if the sender has enough
        if (vtsToken[_from] < _amount) revert();   
        // Check for overflows
        if (vtsToken[_to] + _amount < vtsToken[_to]) revert();
        // Subtract from the sender
        vtsToken[_from] -= _amount;  
        // Add the same to the recipient
        vtsToken[_to] += _amount; 
        return true;
        Transfer(_amount, _from, vtsToken[_from], _to, vtsToken[_to] );
    }

// SELLER MANAGEMENT

// Register as seller
    function signingasSeller (string _brandname) public onlyV() {
        	seller[msg.sender].bName = _brandname;
	    	seller[msg.sender].member = true;
            seller[msg.sender].debt[0] = 0;
            numberSellers += 1;
    }
        

// Throw seller
// Warning, all his debt remains. That is, there is an excess of tokens, monetary mass of vtsToken in excess representing goods that nobody will deliver
    function expulsion (address _seller) public onlyLegalEntity() onlyV() {
	    	seller[_seller].member = true;
            numberSellers -= 1;
    }

// SALES
	
// Buy a product to a producer or seller by redeeming tokens
        function buy (address _seller, uint _price) public onlyV() {
            // get the current period _periodNumber
            getPeriod ();
            // Check if the buyer has enough
            if (vtsToken[msg.sender] < _price) revert(); 
            //  Redeem the tokens
            vtsToken[msg.sender] -= _price;
            // the seller adds to sales
            seller[_seller].sales[currentPeriod] += _price;
            // the seller cancels debt for that period
            int _debt = int(_price);
            seller[_seller].debt[currentPeriod] -= _debt;
            // Free total reserve. The Legal Entity may now dispose of this monetary
            uint _freeR;
            _freeR = (1 ether) * _price /vtsTokenPrice;
            totalReserve = totalReserve - _freeR;
            Sell(_seller, seller[_seller].bName, msg.sender, _price);

        }
        
// ISSUING AND REDEEMING PROMISES

// A producer promises to produce and sell, issues tokens and aquires a seller.debt
    function issueTokens (uint _amount, uint _periodNumber) public onlySeller onlyV() {
        // promises cannot be beyond valid period
        if ((now + (_periodNumber * period)) > expiration) revert();
        // Calculate the amount of Ξ to deposit, according Bancor formula. Convert to wei. 
        uint _deposit;
        _deposit = (1 ether) * _amount / vtsTokenPrice;
        // The Legal Entity acts as Bancor Relay
        // Deposit the tax reserve in Ξ at the Legal Entity
        if (msg.sender.balance > _deposit) {legalEntity.transfer(_deposit);} else revert();
            totalReserve += _deposit / (1 ether);
        // Isue the tokens
            vtsToken[msg.sender] += _amount;
            // Update total supply
            totalSupply += _amount;
            int _debt = int(_amount);
            // Register new debt
            seller[msg.sender].debt[_periodNumber] += _debt;
            // Update total debt
            totalDebt += _debt;
            Issue(msg.sender, seller[msg.sender].bName, _amount);
    }
    
// What is the balance of a particular account?
     function balanceOf(address _account) constant public returns (uint balance) {
         return vtsToken[_account];
     }

// What is the allowance of a particular account?
    function allowance(address _account, address _spender) constant public returns (uint256 remaining) {
	    return allowed[_account][_spender];
	}
    
// What are sales and of a particular seller at a certain period?
     function debtOf(address _seller, uint _periodNumber) constant public returns (uint _sales, int _debt) {
         if (seller[_seller].member != true) revert();
         return (seller[_seller].sales[_periodNumber], seller[_seller].debt[_periodNumber]);
     }
     
// Get seller information
      function sellerDetails(address _seller) constant public returns (bool _member, string _bName)
      {
         if (seller[_seller].member != true) revert();
         return (seller[_seller].member, seller[_seller].bName);
      }

// Get global variables
        function globalariables() constant public returns (uint _numberSellers, uint _totalSupply, int _totalDebt, uint _totalReserve)
        {
        return (numberSellers, totalSupply, totalDebt,totalReserve);
        }

// This unnamed function is called whenever someone tries to send ether to it */
    function () public {
        revert();     // Prevents accidental sending of ether
    }
    
}
