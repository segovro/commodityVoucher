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
    uint8 public decimals = 2;
    uint256 public totalSupply = 0;
    
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
    
// balance in tokens for each account for each period
    mapping(address => uint) public voucherBalance;
// Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint) allowed;
// balance in debt for each account for each period
    mapping(address => uint[]) public debtBalance;

// Initializes contract 
     function commodityVoucher(            					
         ) public {
     		legalEntity = msg.sender;
     		voucherBalance[msg.sender] = totalSupply;  
     		debtBalance[msg.sender][1] = 0;  
     		start = now;
     		expiration = now + duration;
     		// write as many as necessary
     		merchandises[1] = 'Provides restrictions on the object to be claimed';
     		definitions[1] = 'Includes terms and definitions to be defined in a contract';
     		conditions[1] = 'Provides any other applicable restrictions';
     }
     
// This generates public events on the blockchain that will notify clients
     
// Triggered when voucher are transferred.
     event Transfer(address indexed _from, address indexed _to, uint256 _value);
 
 // Triggered whenever approve(address _spender, uint256 _value) is called
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  
// Function get current period
    function getPeriod () public {
    currentPeriod = (now - start) / period;
    }
    
// ERC20 set of functions

// Transfeer vouchers
// Transfer the balance from sender's account to another account
    function transfer(address _to, uint _amount) public {
        // Check if the sender has enough
        if (voucherBalance[msg.sender] < _amount) revert();   
        // Check for overflows
        if (voucherBalance[_to] + _amount < voucherBalance[_to]) revert(); 	
        // Subtract from the sender
        voucherBalance[msg.sender] -= _amount;  
        // Add the same to the recipient
        voucherBalance[_to] += _amount;    
        // Notify anyone listening that this transfer took place
        Transfer(_amount, msg.sender, voucherBalance[msg.sender], _to, voucherBalance[_to] );                   
    }
    
// Mint vouchers
    function mint (uint _amount) public legalEntity {
        voucherBalance[legalEntity] += _amount;
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
     function approve(address _spender, uint256 _amount) public {
         allowed[msg.sender][_spender] = _amount;
         Approval(msg.sender, _spender, _amount);
    }
     
     // Send _value amount of tokens from address _from to address _to
     // The transferFrom method is used for a withdraw workflow, allowing contracts to send
     // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
     // fees in sub-currencies; the command should fail unless the _from account has
     // deliberately authorized the sender of the message via some mechanism; we propose
     // these standardized APIs for approval:
     function transferFrom(
         address _from,
         address _to,
         uint256 _amount
     ) public {
     		int256 _ivalue = int256(_amount);   
     		if (balances[_from] < (_ivalue + negLim)) revert();   		// Check if the sender has enough
	        if (balances[_to] + _ivalue < balances[_to]) revert(); 	// Check for overflows
	        balances[_from] -= _ivalue;                     		// Subtract from the sender
	        balances[_to] += _ivalue;                            	// Add the same to the recipient
            Transfer(_from, _to, _amount);
     }

    // What is the balance of a particular account?
     function balanceOf(address _owner) constant public returns (int256 balance) {
         return balances[_owner];
     }

	function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
	    return allowed[_owner][_spender];
	}

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () public {
        revert();     // Prevents accidental sending of ether
    }

    
}
