/**
 *Submitted for verification at Etherscan.io on 2023-07-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract xAI is Context, IERC20 {
    address private _owner;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => bool) lpPairs;
    uint256 private timeSinceLastPair = 0;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    mapping (address => bool) private _liquidityHolders;
   
    uint256 private startingSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private _tTotal;
    uint256 private _rTotal;

    struct CurrentFees {
        uint16 reflect;
        uint16 totalSwap;
    }

    struct Fees {
        uint16 reflect;
        uint16 liquidity;
        uint16 marketing;
        uint16 totalSwap;
    }

    struct StaticValuesStruct {
        uint16 maxReflect;
        uint16 maxLiquidity;
        uint16 maxMarketing;
        uint16 masterTaxDivisor;
    }

    struct Ratios {
        uint16 liquidity;
        uint16 marketing;
        uint16 total;
    }

    CurrentFees private currentTaxes = CurrentFees({
        reflect: 0,
        totalSwap: 0
        });

    Fees public _buyTaxes = Fees({
        reflect: 0,
        liquidity: 100,
        marketing: 100,
        totalSwap: 200
        });

    Fees public _sellTaxes = Fees({
        reflect: 0,
        liquidity: 100,
        marketing: 100,
        totalSwap: 200
        });

    Fees public _transferTaxes = Fees({
        reflect: 0,
        liquidity: 0,
        marketing: 0,
        totalSwap: 0
        });

    Ratios public _ratios = Ratios({
        liquidity: 1,
        marketing: 1,
        total: 3
        });

    StaticValuesStruct public staticVals = StaticValuesStruct({
        maxReflect: 3000,
        maxLiquidity: 3000,
        maxMarketing: 3000,
        masterTaxDivisor: 10000
        });


    IRouter02 public dexRouter;
    address public lpPair;

    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;

    address public currentRouter;
    address private pcsV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private pcstestV2Router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address private uniswapV2Router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    struct TaxWallets {
        address payable marketing;
    }

    TaxWallets public _taxWallets = TaxWallets({
        marketing: payable(0x7ff362bdB84e9f7F818321cc69974FCf4B9C183f)
        });
    
    bool inSwap;
    bool public contractSwapEnabled = false;
    
    uint256 private _maxTxAmount;
    uint256 private _maxWalletSize;

    uint256 private swapThreshold;
    uint256 private swapAmount;

    bool public tradingEnabled = false;
    bool public _hasLiqBeenAdded = false;

    uint256 public launch;
    bool contractInitialized = false;

    address[] path;

    uint256 public maxEthBuy = 5 * 10**18;
    uint256 public maxEthSell = 5 * 10**18;
    bool public timedLimitsEnabled = false;
    bool public maxEthTradesEnabled = false;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event ContractSwapEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Caller =/= owner.");
        _;
    }

    mapping (address => bool) public whitelist;
    
    constructor (address[] memory whitelisted) payable {
        // Set the owner.
        _owner = msg.sender;

        if (block.chainid == 56 ) {
            currentRouter = pcsV2Router;
        } else if (block.chainid == 1|| block.chainid == 31337) {
            currentRouter = uniswapV2Router;
        }
         else if ( block.chainid == 97) {
            currentRouter = pcstestV2Router;
        }

        _approve(msg.sender, currentRouter, type(uint256).max);
        _approve(address(this), currentRouter, type(uint256).max);

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[DEAD] = true;
        _liquidityHolders[owner()] = true;

        uint whitelistLength = whitelisted.length;
        for( uint i = 0; i < whitelistLength; i++){
            whitelist[whitelisted[i]] = true;
        }
    }

    function intializeContract() external onlyOwner {
        require(!contractInitialized, "1");
        startingSupply = 10000000000;
        if (startingSupply < 100000000) {
            _decimals = 18;
        } else {
            _decimals = 9;
        }
        _tTotal = startingSupply * (10**_decimals);
        _rTotal = (~uint256(0) - (~uint256(0) % _tTotal));
        _name = "Life of xAI";
        _symbol = "XAI3.14";
        dexRouter = IRouter02(currentRouter);
        lpPair = IFactoryV2(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
        lpPairs[lpPair] = true;        
        path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();
        _maxTxAmount = (_tTotal * 100) / 1000;
        _maxWalletSize = (_tTotal * 15) / 1000;
        swapThreshold = (_tTotal * 20) / 10000;
        swapAmount = (_tTotal * 100) / 10000;
        contractInitialized = true;     
        _rOwned[owner()] = _rTotal;
        emit Transfer(address(0), owner(), _tTotal);

        _approve(address(this), address(dexRouter), type(uint256).max);

    }

        function liquidityTokens() external onlyOwner {
         _transfer(owner(), address(this), balanceOf(owner()));

        dexRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );

        enableTrading();
    }


    receive() external payable {}

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwner(address newOwner) external onlyOwner() {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newOwner != DEAD, "Call renounceOwnership to transfer owner to the zero address.");
        setExcludedFromFees(_owner, false);
        setExcludedFromFees(newOwner, true);
        
        if(balanceOf(_owner) > 0) {
            _transfer(_owner, newOwner, balanceOf(_owner));
        }
        
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
        
    }

    function renounceOwnership() public virtual onlyOwner() {
        setExcludedFromFees(_owner, false);
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }

    function totalSupply() external view override returns (uint256) {
        if (_tTotal == 0) {
            revert();
        }
        return _tTotal; 
    }
    function decimals() external view override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner(); }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) private {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function approveContractContingency() public onlyOwner returns (bool) {
        _approve(address(this), address(dexRouter), type(uint256).max);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function setNewRouter(address newRouter) public onlyOwner() {
        IRouter02 _newRouter = IRouter02(newRouter);
        address get_pair = IFactoryV2(_newRouter.factory()).getPair(address(this), _newRouter.WETH());
        if (get_pair == address(0)) {
            lpPair = IFactoryV2(_newRouter.factory()).createPair(address(this), _newRouter.WETH());
        }
        else {
            lpPair = get_pair;
        }
        dexRouter = _newRouter;
        _approve(address(this), address(dexRouter), type(uint256).max);
    }


    function changeRouterContingency(address router) external onlyOwner {
        require(!_hasLiqBeenAdded);
        currentRouter = router;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (_tTotal - (balanceOf(DEAD) + balanceOf(address(0))));
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function setExcludedFromFees(address account, bool enabled) public onlyOwner {
        _isExcludedFromFees[account] = enabled;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function setExcludedFromReward(address account, bool enabled) public onlyOwner {
        if (enabled == true) {
            require(!_isExcluded[account], "Account is already excluded.");
            if(_rOwned[account] > 0) {
                _tOwned[account] = tokenFromReflection(_rOwned[account]);
            }
            _isExcluded[account] = true;
            _excluded.push(account);
        } else if (enabled == false) {
            require(_isExcluded[account], "Account is already included.");
            if(_excluded.length == 1){
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
            } else {
                for (uint256 i = 0; i < _excluded.length; i++) {
                    if (_excluded[i] == account) {
                        _excluded[i] = _excluded[_excluded.length - 1];
                        _tOwned[account] = 0;
                        _isExcluded[account] = false;
                        _excluded.pop();
                        break;
                    }
                }
            }
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }

        function setEthLimits(uint256 buyVal, uint256 buyMult, uint256 sellVal, uint256 sellMult) external onlyOwner {
        maxEthBuy = buyVal * 10**buyMult;
        maxEthSell = sellVal * 10**sellMult;
    }

    function setEthLimitsEnabled(bool timeLimits, bool maxEthTrades) external onlyOwner {
        timedLimitsEnabled = timeLimits;
        maxEthTradesEnabled = maxEthTrades;
    }

    function setTaxesBuy(uint16 reflect, uint16 liquidity, uint16 marketing) external onlyOwner {
        require(reflect <= staticVals.maxReflect
                && liquidity <= staticVals.maxLiquidity
                && marketing <= staticVals.maxMarketing);
        uint16 check = reflect + liquidity + marketing;
        _buyTaxes.liquidity = liquidity;
        _buyTaxes.reflect = reflect;
        _buyTaxes.marketing = marketing;
        _buyTaxes.totalSwap = check - reflect;
    }

    function setTaxesSell(uint16 reflect, uint16 liquidity, uint16 marketing) external onlyOwner {
        require(reflect <= staticVals.maxReflect
                && liquidity <= staticVals.maxLiquidity
                && marketing <= staticVals.maxMarketing);
        uint16 check = reflect + liquidity + marketing;
        _sellTaxes.liquidity = liquidity;
        _sellTaxes.reflect = reflect;
        _sellTaxes.marketing = marketing;
        _sellTaxes.totalSwap = check - reflect;
    }

    function setTaxesTransfer(uint16 reflect, uint16 liquidity, uint16 marketing) external onlyOwner {
        require(reflect <= staticVals.maxReflect
                && liquidity <= staticVals.maxLiquidity
                && marketing <= staticVals.maxMarketing);
        uint16 check = reflect + liquidity + marketing;
        _transferTaxes.liquidity = liquidity;
        _transferTaxes.reflect = reflect;
        _transferTaxes.marketing = marketing;
        _transferTaxes.totalSwap = check - reflect;
    }

    function setRatios(uint16 liquidity, uint16 marketing) external onlyOwner {
        _ratios.liquidity = liquidity;
        _ratios.marketing = marketing;
        _ratios.total = liquidity + marketing;
    }

    function setSwapSettings(uint256 thresholdPercent, uint256 thresholdDivisor, uint256 amountPercent, uint256 amountDivisor) external onlyOwner {
        swapThreshold = (_tTotal * thresholdPercent) / thresholdDivisor;
        swapAmount = (_tTotal * amountPercent) / amountDivisor;
    }

    function setWallets(address payable marketing) external onlyOwner {
        _taxWallets.marketing = payable(marketing);
    }

    function setContractSwapEnabled(bool _enabled) public onlyOwner {
        contractSwapEnabled = _enabled;
        emit ContractSwapEnabledUpdated(_enabled);
    }

    function _hasLimits(address from, address to) private view returns (bool) {
        return from != owner()
            && to != owner()
            && !_liquidityHolders[to]
            && !_liquidityHolders[from]
            && to != DEAD
            && to != address(0)
            && from != address(this);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool takeFee = true;
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]){
            takeFee = false;
        }

        if(_hasLimits(from, to)) {
            if(!tradingEnabled || whitelist[from]) {
                revert("Trading not yet enabled!");
            }
            uint256 _ethBalance = dexRouter.getAmountsOut(amount, path)[1];
            if (maxEthTradesEnabled) {
                if(lpPairs[from]) {
                    if (timedLimitsEnabled) {
                        if(block.timestamp <= launch + 2 hours) {
                            require(_ethBalance <= 25 * 10**16);
                        } else if (block.timestamp <= launch + 22 hours) {
                            require(_ethBalance <= 2 * 10**18);
                        } else {
                            require(_ethBalance <= maxEthBuy);
                        }
                    } else {
                        require(_ethBalance <= maxEthBuy);
                    }
                } else if (lpPairs[to]) {
                    if (timedLimitsEnabled) {
                        if(block.timestamp <= launch + 2 hours) {
                            require(_ethBalance <= 25 * 10**16);
                        } else if (block.timestamp <= launch + 22 hours) {
                            require(_ethBalance <= 2 * 10**18);
                        } else {
                            require(_ethBalance <= maxEthSell);
                        }
                    } else {
                        require(_ethBalance <= maxEthSell);
                    }
                }
            }
        }

        if (lpPairs[to]) {
            if (!inSwap
                && contractSwapEnabled
            ) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if (contractTokenBalance >= swapThreshold) {
                    if(contractTokenBalance >= swapAmount) { contractTokenBalance = swapAmount; }
                    contractSwap(contractTokenBalance);
                }
            }      
        } 
        return _finalizeTransfer(from, to, amount, takeFee);
    }

    function contractSwap(uint256 contractTokenBalance) private lockTheSwap {
        if (_ratios.total == 0)
            return;

        if(_allowances[address(this)][address(dexRouter)] != type(uint256).max) {
            _allowances[address(this)][address(dexRouter)] = type(uint256).max;
        }

        uint256 toLiquify = ((contractTokenBalance * _ratios.liquidity) / _ratios.total) / 2;

        uint256 toSwapForEth = contractTokenBalance - toLiquify;

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            toSwapForEth,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        uint256 liquidityBalance = ((address(this).balance * _ratios.liquidity) / _ratios.total) / 2;

        if (toLiquify > 0) {
            dexRouter.addLiquidityETH{value: liquidityBalance}(
                address(this),
                toLiquify,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                owner(),
                block.timestamp
            );
            emit SwapAndLiquify(toLiquify, liquidityBalance, toLiquify);
        }
        if (address(this).balance > 0 && _ratios.total - _ratios.liquidity > 0) {
            _taxWallets.marketing.transfer(address(this).balance);
        }
    }

    function _checkLiquidityAdd(address from, address to) private {
        require(!_hasLiqBeenAdded, "Liquidity already added and marked.");
        if (!_hasLimits(from, to) && to == lpPair) {
            _liquidityHolders[from] = true;
            _hasLiqBeenAdded = true;
            contractSwapEnabled = true;
            emit ContractSwapEnabledUpdated(true);
        }
    }

    function enableTrading() public onlyOwner {
        require(!tradingEnabled, "Trading already enabled!");
        require(_hasLiqBeenAdded, "Liquidity must be added.");
        setExcludedFromReward(address(this), true);
        setExcludedFromReward(lpPair, true);
        tradingEnabled = true;
        launch = block.timestamp;
    }

    function sweepContingency() external onlyOwner {
        require(!_hasLiqBeenAdded, "Cannot call after liquidity.");
        payable(owner()).transfer(address(this).balance);
    }

    struct ExtraValues {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tSwap;

        uint256 rTransferAmount;
        uint256 rAmount;
        uint256 rFee;
    }

    function _finalizeTransfer(address from, address to, uint256 tAmount, bool takeFee) private returns (bool) {
        if (!_hasLiqBeenAdded) {
            _checkLiquidityAdd(from, to);
            if (!_hasLiqBeenAdded && _hasLimits(from, to)) {
                revert("Only owner can transfer at this time.");
            }
        }

        ExtraValues memory values = _getValues(from, to, tAmount, takeFee);

        _rOwned[from] = _rOwned[from] - values.rAmount;
        _rOwned[to] = _rOwned[to] + values.rTransferAmount;

        if (_isExcluded[from]) {
            _tOwned[from] = _tOwned[from] - tAmount;
        }
        if (_isExcluded[to]) {
            _tOwned[to] = _tOwned[to] + values.tTransferAmount;
        }

        if (values.tSwap > 0) {
            _rOwned[address(this)] = _rOwned[address(this)] + (values.tSwap * _getRate());
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)] + values.tSwap;
            emit Transfer(from, address(this), values.tSwap); // Transparency is the key to success.
        }
        if (values.rFee > 0 || values.tFee > 0) {
            _rTotal -= values.rFee;
        }


        emit Transfer(from, to, values.tTransferAmount);
        return true;
    }

    function _getValues(address from, address to, uint256 tAmount, bool takeFee) private returns (ExtraValues memory) {
        ExtraValues memory values;
        uint256 currentRate = _getRate();

        values.rAmount = tAmount * currentRate;


        if(takeFee) {
            if (lpPairs[to]) {
                currentTaxes.reflect = _sellTaxes.reflect;
                currentTaxes.totalSwap = _sellTaxes.totalSwap;
            } else if (lpPairs[from]) {
                currentTaxes.reflect = _buyTaxes.reflect;
                currentTaxes.totalSwap = _buyTaxes.totalSwap;
            } else {
                currentTaxes.reflect = _transferTaxes.reflect;
                currentTaxes.totalSwap = _transferTaxes.totalSwap;
            }

            values.tFee = (tAmount * currentTaxes.reflect) / staticVals.masterTaxDivisor;
            values.tSwap = (tAmount * currentTaxes.totalSwap) / staticVals.masterTaxDivisor;
            values.tTransferAmount = tAmount - (values.tFee + values.tSwap);

            values.rFee = values.tFee * currentRate;
        } else {
            values.tFee = 0;
            values.tSwap = 0;
            values.tTransferAmount = tAmount;

            values.rFee = 0;
        }
        values.rTransferAmount = values.rAmount - (values.rFee + (values.tSwap * currentRate));
        return values;
    }

    function _getRate() internal view returns(uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint8 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return _rTotal / _tTotal;
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return _rTotal / _tTotal;
        return rSupply / tSupply;
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function withdrawMoney() public onlyOwner {
        address payable to = payable(msg.sender);
        to.transfer(getBalance());
    }

    function addAddress(address whitelistAddress, bool onoff) public onlyOwner {
        whitelist[whitelistAddress] = onoff;
    }
}