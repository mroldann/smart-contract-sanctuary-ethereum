// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "../clever/interfaces/IMetaCLever.sol";
import "../concentrator/interfaces/IAladdinCRVConvexVault.sol";
import "../interfaces/IBalancerPool.sol";
import "../interfaces/IBalancerVault.sol";
import "../zap/TokenZapLogic.sol";
import "./ZapGatewayBase.sol";

interface IGauge {
  // solhint-disable-next-line func-name-mixedcase
  function lp_token() external view returns (address);

  function deposit(
    uint256 _value,
    address _recipient,
    // solhint-disable-next-line var-name-mixedcase
    bool _claim_rewards
  ) external;
}

interface IMetaCLeverDetailed is IMetaCLever {
  function yieldStrategies(uint256 _strategyIndex)
    external
    view
    returns (
      // Whether the strategy is active.
      bool isActive,
      // The address of yield strategy contract.
      address strategy,
      // The address of underlying token.
      address underlyingToken,
      // The address of yield token.
      address yieldToken,
      // The total share of yield token of this strategy.
      uint256 totalShare,
      // The total amount of active yield tokens in CLever.
      uint256 activeYieldTokenAmount,
      // The total amount of yield token could be harvested.
      uint256 harvestableYieldTokenAmount,
      // The expected amount of underlying token should be deposited to this strategy.
      uint256 expectedUnderlyingTokenAmount
    );
}

contract AllInOneGateway is ZapGatewayBase {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  /// @notice The version of the gateway.
  string public constant VERSION = "1.0.0";

  /// @dev The address of Balancer V2 Vault.
  address private constant BALANCER_VAULT = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

  constructor(address _logic) {
    logic = _logic;
  }

  /// @notice Deposit `_srcToken` into CLeverCRV with zapping to yield token first.
  /// @param _clever The address of MetaCLever.
  /// @param _srcToken The address of start token. Use zero address, if you want deposit with ETH.
  /// @param _amountIn The amount of `_srcToken` to deposit.
  /// @param _dstToken The address of destination token.
  /// @param _routes The routes used to do zap.
  /// @param _minShareOut The minimum amount of pool shares should receive.
  /// @return The amount of pool shares received.
  function depositCLever(
    address _clever,
    uint256 _strategyIndex,
    address _srcToken,
    uint256 _amountIn,
    address _dstToken,
    uint256[] calldata _routes,
    uint256 _minShareOut
  ) external payable returns (uint256) {
    require(_amountIn > 0, "deposit zero amount");
    bool _isUnderlying;
    {
      (, , address _underlyingToken, address _yieldToken, , , , ) = IMetaCLeverDetailed(_clever).yieldStrategies(
        _strategyIndex
      );
      if (_dstToken == _underlyingToken) _isUnderlying = true;
      else if (_dstToken == _yieldToken) _isUnderlying = false;
      else revert("invalid destination token");
    }

    // 1. transfer srcToken into this contract
    _amountIn = _transferTokenIn(_srcToken, _amountIn);

    // 2. zap srcToken to yieldToken
    uint256 _amountToken = _zap(_routes, _amountIn);
    require(IERC20(_dstToken).balanceOf(address(this)) >= _amountToken, "zap to dst token failed");

    // 3. deposit into Concentrator vault
    IERC20(_dstToken).safeApprove(_clever, 0);
    IERC20(_dstToken).safeApprove(_clever, _amountToken);
    uint256 _sharesOut = IMetaCLever(_clever).deposit(
      _strategyIndex,
      msg.sender,
      _amountToken,
      _minShareOut,
      _isUnderlying
    );

    require(_sharesOut >= _minShareOut, "insufficient share");
    return _sharesOut;
  }

  /// @notice Deposit `_srcToken` into Concentrator vault with zap.
  /// @param _vault The address of vault.
  /// @param _pid The pool id to deposit.
  /// @param _srcToken The address of start token. Use zero address, if you want deposit with ETH.
  /// @param _lpToken The address of lp token of corresponding pool.
  /// @param _amountIn The amount of `_srcToken` to deposit.
  /// @param _routes The routes used to do zap.
  /// @param _minShareOut The minimum amount of pool shares should receive.
  /// @return The amount of pool shares received.
  function depositConcentrator(
    address _vault,
    uint256 _pid,
    address _srcToken,
    address _lpToken,
    uint256 _amountIn,
    uint256[] calldata _routes,
    uint256 _minShareOut
  ) external payable returns (uint256) {
    require(_amountIn > 0, "deposit zero amount");

    // 1. transfer srcToken into this contract
    _amountIn = _transferTokenIn(_srcToken, _amountIn);

    // 2. zap srcToken to lp
    uint256 _amountLP = _zap(_routes, _amountIn);
    require(IERC20(_lpToken).balanceOf(address(this)) >= _amountLP, "zap to lp token failed");

    // 3. deposit into Concentrator vault
    IERC20(_lpToken).safeApprove(_vault, 0);
    IERC20(_lpToken).safeApprove(_vault, _amountLP);
    uint256 _sharesOut = IAladdinCRVConvexVault(_vault).deposit(_pid, msg.sender, _amountLP);

    require(_sharesOut >= _minShareOut, "insufficient share");
    return _sharesOut;
  }

  /// @notice Deposit `_srcToken` into Gauge with curve lp.
  /// @param _gauge The address of gauge.
  /// @param _srcToken The address of start token. Use zero address, if you want deposit with ETH.
  /// @param _amountIn The amount of `_srcToken` to deposit.
  /// @param _routes The routes used to do zap.
  /// @param _minLPOut The minimum amount of lp token should receive.
  /// @return The amount of lp token received.
  function depositGaugeWithCurveLP(
    address _gauge,
    address _srcToken,
    uint256 _amountIn,
    uint256[] calldata _routes,
    uint256 _minLPOut
  ) external payable returns (uint256) {
    require(_amountIn > 0, "deposit zero amount");

    // 1. transfer srcToken into this contract
    _amountIn = _transferTokenIn(_srcToken, _amountIn);

    // 2. zap srcToken to lp
    address _lpToken = IGauge(_gauge).lp_token();
    uint256 _amountLP = _zap(_routes, _amountIn);
    require(IERC20(_lpToken).balanceOf(address(this)) >= _amountLP, "zap to lp token failed");
    require(_amountLP >= _minLPOut, "insufficient share");

    // 3. deposit into gauge
    IERC20(_lpToken).safeApprove(_gauge, 0);
    IERC20(_lpToken).safeApprove(_gauge, _amountLP);
    IGauge(_gauge).deposit(_amountLP, msg.sender, false);
    return _amountLP;
  }

  /// @notice Deposit `_srcToken` into Gauge with balancer lp.
  /// @param _gauge The address of gauge.
  /// @param _srcToken The address of start token. Use zero address, if you want deposit with ETH.
  /// @param _amountIn The amount of `_srcToken` to deposit.
  /// @param _routes The routes used to do zap.
  /// @param _minLPOut The minimum amount of lp token should receive.
  /// @return The amount of lp token received.
  function depositGaugeWithBalancerLP(
    address _gauge,
    address _srcToken,
    uint256 _amountIn,
    uint256[] calldata _routes,
    uint256 _minLPOut
  ) external payable returns (uint256) {
    require(_amountIn > 0, "deposit zero amount");

    // 1. transfer srcToken into this contract
    _amountIn = _transferTokenIn(_srcToken, _amountIn);

    // 2. zap srcToken to some token
    _zap(_routes, _amountIn);

    // 3. join as Balancer LP
    address _lpToken = IGauge(_gauge).lp_token();
    uint256 _amountLP = _joinBalancerPool(_lpToken, _minLPOut);

    // 4. deposit into gauge
    IERC20(_lpToken).safeApprove(_gauge, 0);
    IERC20(_lpToken).safeApprove(_gauge, _amountLP);
    IGauge(_gauge).deposit(_amountLP, msg.sender, false);
    return _amountLP;
  }

  /// @notice Deposit `_srcToken` into Compounder with zap.
  /// @param _compounder The address of Compounder.
  /// @param _srcToken The address of start token. Use zero address, if you want deposit with ETH.
  /// @param _amountIn The amount of `_srcToken` to deposit.
  /// @param _routes The routes used to do zap.
  /// @param _minShareOut The minimum amount of pool shares should receive.
  /// @return The amount of pool shares received.
  function depositCompounder(
    address _compounder,
    address _srcToken,
    uint256 _amountIn,
    uint256[] calldata _routes,
    uint256 _minShareOut
  ) external payable returns (uint256) {
    require(_amountIn > 0, "deposit zero amount");
    address _lpToken = IAladdinCompounder(_compounder).asset();

    // 1. transfer srcToken into this contract
    _amountIn = _transferTokenIn(_srcToken, _amountIn);

    // 2. zap srcToken to lp
    uint256 _amountLP = _zap(_routes, _amountIn);
    require(IERC20(_lpToken).balanceOf(address(this)) >= _amountLP, "zap to lp token failed");

    // 3. deposit into Concentrator vault
    IERC20(_lpToken).safeApprove(_compounder, 0);
    IERC20(_lpToken).safeApprove(_compounder, _amountLP);
    uint256 _sharesOut = IAladdinCompounder(_compounder).deposit(_amountLP, msg.sender);

    require(_sharesOut >= _minShareOut, "insufficient share");
    return _sharesOut;
  }

  /// @notice Withdraw asset from Compounder and zap to `_dstToken`.
  /// @param _compounder The address of Compounder.
  /// @param _dstToken The address of destination token. Use zero address, if you want withdraw as ETH.
  /// @param _sharesIn The amount of pool share to withdraw.
  /// @param _routes The routes used to do zap.
  /// @param _minAmountOut The minimum amount of assets should receive.
  /// @return The amount of assets received.
  function withdrawCompounder(
    address _compounder,
    address _dstToken,
    uint256 _sharesIn,
    uint256[] calldata _routes,
    uint256 _minAmountOut
  ) external returns (uint256) {
    if (_sharesIn == uint256(-1)) {
      _sharesIn = IERC20(_compounder).balanceOf(msg.sender);
    }

    require(_sharesIn > 0, "withdraw zero amount");

    // 1. withdraw from Compounder
    uint256 _amountLP = IAladdinCompounder(_compounder).redeem(_sharesIn, address(this), msg.sender);

    // 2. zap to dstToken
    uint256 _amountOut = _zap(_routes, _amountLP);
    require(_amountOut >= _minAmountOut, "insufficient output");

    // 3. transfer to caller.
    _transferTokenOut(_dstToken, _amountOut);

    return _amountOut;
  }

  /// @dev Internal function to join as Balance Pool LP.
  /// @param _lpToken The address of Balancer LP.
  /// @param _minLPOut The minimum amount of LP token to receive.
  /// @return The amount of Balancer LP received.
  function _joinBalancerPool(address _lpToken, uint256 _minLPOut) internal returns (uint256) {
    bytes32 _poolId = IBalancerPool(_lpToken).getPoolId();
    IBalancerVault.JoinPoolRequest memory _request;
    (_request.assets, , ) = IBalancerVault(BALANCER_VAULT).getPoolTokens(_poolId);
    _request.maxAmountsIn = new uint256[](_request.assets.length);
    uint256[] memory _amountsIn = new uint256[](_request.assets.length);
    for (uint256 i = 0; i < _amountsIn.length; i++) {
      address _token = _request.assets[i];
      _amountsIn[i] = IERC20(_token).balanceOf(address(this));
      _request.maxAmountsIn[i] = uint256(-1);
      if (_amountsIn[i] > 0) {
        IERC20(_token).safeApprove(BALANCER_VAULT, 0);
        IERC20(_token).safeApprove(BALANCER_VAULT, _amountsIn[i]);
      }
    }
    _request.userData = abi.encode(IBalancerVault.JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT, _amountsIn, _minLPOut);

    uint256 _balance = IERC20(_lpToken).balanceOf(address(this));
    IBalancerVault(BALANCER_VAULT).joinPool(_poolId, address(this), address(this), _request);
    return IERC20(_lpToken).balanceOf(address(this)).sub(_balance);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;
pragma abicoder v2;

interface IBalancerVault {
  enum JoinKind {
    INIT,
    EXACT_TOKENS_IN_FOR_BPT_OUT,
    TOKEN_IN_FOR_EXACT_BPT_OUT,
    ALL_TOKENS_IN_FOR_EXACT_BPT_OUT
  }

  enum SwapKind {
    GIVEN_IN,
    GIVEN_OUT
  }

  struct SingleSwap {
    bytes32 poolId;
    SwapKind kind;
    address assetIn;
    address assetOut;
    uint256 amount;
    bytes userData;
  }

  struct FundManagement {
    address sender;
    bool fromInternalBalance;
    address payable recipient;
    bool toInternalBalance;
  }

  function getPoolTokens(bytes32 poolId)
    external
    view
    returns (
      address[] memory tokens,
      uint256[] memory balances,
      uint256 lastChangeBlock
    );

  function swap(
    SingleSwap memory singleSwap,
    FundManagement memory funds,
    uint256 limit,
    uint256 deadline
  ) external payable returns (uint256 amountCalculated);

  struct JoinPoolRequest {
    address[] assets;
    uint256[] maxAmountsIn;
    bytes userData;
    bool fromInternalBalance;
  }

  function joinPool(
    bytes32 poolId,
    address sender,
    address recipient,
    JoinPoolRequest memory request
  ) external payable;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";

import "../concentrator/interfaces/IAladdinCompounder.sol";
import "../concentrator/interfaces/IAladdinCRV.sol";
import "../interfaces/IBalancerVault.sol";
import "../interfaces/IBalancerPool.sol";
import "../interfaces/IConvexCRVDepositor.sol";
import "../interfaces/ICurveAPool.sol";
import "../interfaces/ICurveBasePool.sol";
import "../interfaces/ICurveCryptoPool.sol";
import "../interfaces/ICurveETHPool.sol";
import "../interfaces/ICurveFactoryMetaPool.sol";
import "../interfaces/ICurveFactoryPlainPool.sol";
import "../interfaces/ICurveMetaPool.sol";
import "../interfaces/ICurvePoolRegistry.sol";
import "../interfaces/ICurveYPool.sol";
import "../interfaces/ILidoStETH.sol";
import "../interfaces/ILidoWstETH.sol";
import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IUniswapV3Pool.sol";
import "../interfaces/IUniswapV3Router.sol";
import "../interfaces/IWETH.sol";

// solhint-disable reason-string, const-name-snakecase

contract TokenZapLogic {
  using SafeERC20Upgradeable for IERC20Upgradeable;
  using SafeMathUpgradeable for uint256;

  /// @notice The version of the zap
  string public constant version = "AladdinZap 1.1.0";

  /// @dev The address of Curve Pool Registry contract.
  address private constant CURVE_POOL_REGISTRY = 0x90E00ACe148ca3b23Ac1bC8C240C2a7Dd9c2d7f5;

  /// @dev The address of ETH which is commonly used.
  address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  /// @dev The address of WETH token.
  address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  /// @dev The address of Uniswap V3 Router
  address private constant UNISWAP_V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

  /// @dev The address of Balancer V2 Vault
  address private constant BALANCER_VAULT = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

  /// @dev The address of Curve 3pool Deposit Zap
  address private constant CURVE_3POOL_DEPOSIT_ZAP = 0xA79828DF1850E8a3A3064576f380D90aECDD3359;

  /// @dev The address of base tokens for 3pool: DAI, USDC, USDT in increasing order.
  address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address private constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

  /// @dev The address of Curve sBTC Deposit Zap
  address private constant CURVE_SBTC_DEPOSIT_ZAP = 0x7AbDBAf29929e7F8621B757D2a7c04d78d633834;

  /// @dev The address of base tokens for crvRenWsBTC: renBTC, WBTC, sBTC in increasing order.
  address private constant renBTC = 0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D;
  address private constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
  address private constant sBTC = 0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6;

  /// @dev The address of Curve FraxBP Deposit Zap
  address private constant CURVE_FRAXBP_DEPOSIT_ZAP = 0x08780fb7E580e492c1935bEe4fA5920b94AA95Da;
  address private constant FRAX = 0x853d955aCEf822Db058eb8505911ED77F175b99e;

  /// @dev The address of Lido's stETH token.
  address private constant stETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;

  /// @dev The address of Lido's wstETH token.
  address private constant wstETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;

  /// @dev The address of Aladdin CRV
  address private constant aCRV = 0x2b95A1Dcc3D405535f9ed33c219ab38E8d7e0884;

  /// @dev The address of cvxCRV token.
  address private constant cvxCRV = 0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7;

  /// @dev The pool type used in this zap contract, a maximum of 256 items
  enum PoolType {
    UniswapV2, // with fee 0.3%, add/remove liquidity not supported
    UniswapV3, // add/remove liquidity not supported
    BalancerV2, // add/remove liquidity not supported
    CurveETHPool, // including Factory Pool
    CurveCryptoPool, // including Factory Pool
    CurveMetaCryptoPool,
    CurveTriCryptoPool,
    CurveBasePool,
    CurveAPool,
    CurveAPoolUnderlying,
    CurveYPool,
    CurveYPoolUnderlying,
    CurveMetaPool,
    CurveMetaPoolUnderlying,
    CurveFactoryPlainPool,
    CurveFactoryMetaPool,
    CurveFactoryUSDMetaPoolUnderlying,
    CurveFactoryBTCMetaPoolUnderlying,
    LidoStake, // eth to stETH
    LidoWrap, // stETH to wstETH or wstETH to stETH
    CurveFactoryFraxBPMetaPoolUnderlying,
    AladdinCompounder // wrap/unrwap as aCRV/aFXS/...
  }

  /// @dev Only the following pool will call this function
  /// + CurveCryptoPool => use `ICurveCryptoPool.token()`
  //  + CurveMetaCryptoPool => use `ICurveCryptoPool.token()`
  /// + CurveTriCryptoPool => use `ICurveCryptoPool.token()`
  /// + CurveYPool => covered by `CurvePoolRegistry`
  /// + CurveYPoolUnderlying => covered by `CurvePoolRegistry`
  /// + CurveMetaPool => covered by `CurvePoolRegistry`
  /// + CurveMetaPoolUnderlying => covered by `CurvePoolRegistry`
  /// + CurveFactoryPlainPool
  /// + CurveFactoryMetaPool
  /// + CurveFactoryUSDMetaPoolUnderlying
  /// + CurveFactoryBTCMetaPoolUnderlying
  function getCurvePoolToken(PoolType _type, address _pool) public view virtual returns (address) {
    if (_type == PoolType.CurveYPoolUnderlying) {
      _pool = ICurveYPoolDeposit(_pool).curve();
    } else if (_type == PoolType.CurveMetaPoolUnderlying) {
      _pool = ICurveMetaPoolDeposit(_pool).pool();
    } else if (_type == PoolType.CurveMetaCryptoPool) {
      _pool = ICurveMetaPoolDeposit(_pool).pool();
    }
    address _token = ICurvePoolRegistry(CURVE_POOL_REGISTRY).get_lp_token(_pool);
    if (_token != address(0)) {
      return _token;
    } else if (uint256(_type) >= 4 && uint256(_type) <= 6) {
      return ICurveCryptoPool(_pool).token();
    } else {
      return _pool;
    }
  }

  /// @dev encoding for single route
  /// |   160 bits   |   8 bits  | 2 bits |  2 bits  |   2 bits  | 2 bits |
  /// | pool address | pool type | tokens | index in | index out | action |
  ///
  /// If poolType is PoolType.CurveMetaCryptoPool, pool address is zap contract
  /// If poolType is PoolType.CurveYPoolUnderlying: pool address is deposit contract
  /// If poolType is PoolType.CurveMetaPoolUnderlying: pool address is deposit contract
  /// If poolType is PoolType.LidoStake: only action = 1 is valid
  /// If poolType is PoolType.LidoWrap: only action = 1 or is valid
  /// Otherwise, pool address is swap contract
  ///
  /// tokens + 1 is the number of tokens of the pool
  ///
  /// action = 0: swap, index_in != index_out
  /// action = 1: add liquidity, index_in == index_out
  /// action = 2: remove liquidity, index_in == index_out
  function swap(uint256 _route, uint256 _amountIn) public payable returns (uint256) {
    address _pool = address(_route & uint256(1461501637330902918203684832716283019655932542975));
    PoolType _poolType = PoolType((_route >> 160) & 255);
    uint256 _indexIn = (_route >> 170) & 3;
    uint256 _indexOut = (_route >> 172) & 3;
    uint256 _action = (_route >> 174) & 3;
    if (_poolType == PoolType.UniswapV2) {
      return _swapUniswapV2Pair(_pool, _indexIn, _indexOut, _amountIn);
    } else if (_poolType == PoolType.UniswapV3) {
      return _swapUniswapV3Pool(_pool, _indexIn, _indexOut, _amountIn);
    } else if (_poolType == PoolType.BalancerV2) {
      return _swapBalancerPool(_pool, _indexIn, _indexOut, _amountIn);
    } else if (_poolType == PoolType.LidoStake) {
      require(_pool == stETH, "AladdinZap: pool not stETH");
      return _wrapLidoSTETH(_amountIn, _action);
    } else if (_poolType == PoolType.LidoWrap) {
      require(_pool == wstETH, "AladdinZap: pool not wstETH");
      return _wrapLidoWSTETH(_amountIn, _action);
    } else if (_poolType == PoolType.AladdinCompounder) {
      return _wrapAsAladdinCompounder(_pool, _amountIn, _action);
    } else {
      // all other is curve pool
      if (_action == 0) {
        return _swapCurvePool(_poolType, _pool, _indexIn, _indexOut, _amountIn);
      } else if (_action == 1) {
        uint256 _tokens = ((_route >> 168) & 3) + 1;
        return _addCurvePool(_poolType, _pool, _tokens, _indexIn, _amountIn);
      } else if (_action == 2) {
        return _removeCurvePool(_poolType, _pool, _indexOut, _amountIn);
      } else {
        revert("AladdinZap: invalid action");
      }
    }
  }

  function _swapUniswapV2Pair(
    address _pool,
    uint256 _indexIn,
    uint256 _indexOut,
    uint256 _amountIn
  ) private returns (uint256) {
    uint256 _rIn;
    uint256 _rOut;
    address _tokenIn;
    if (_indexIn < _indexOut) {
      (_rIn, _rOut, ) = IUniswapV2Pair(_pool).getReserves();
      _tokenIn = IUniswapV2Pair(_pool).token0();
    } else {
      (_rOut, _rIn, ) = IUniswapV2Pair(_pool).getReserves();
      _tokenIn = IUniswapV2Pair(_pool).token1();
    }
    // TODO: handle fee on transfer token
    uint256 _amountOut = _amountIn * 997;
    _amountOut = (_amountOut * _rOut) / (_rIn * 1000 + _amountOut);

    _wrapTokenIfNeeded(_tokenIn, _amountIn);
    IERC20Upgradeable(_tokenIn).safeTransfer(_pool, _amountIn);
    if (_indexIn < _indexOut) {
      IUniswapV2Pair(_pool).swap(0, _amountOut, address(this), new bytes(0));
    } else {
      IUniswapV2Pair(_pool).swap(_amountOut, 0, address(this), new bytes(0));
    }
    return _amountOut;
  }

  function _swapUniswapV3Pool(
    address _pool,
    uint256 _indexIn,
    uint256 _indexOut,
    uint256 _amountIn
  ) private returns (uint256) {
    address _tokenIn;
    address _tokenOut;
    uint24 _fee = IUniswapV3Pool(_pool).fee();
    if (_indexIn < _indexOut) {
      _tokenIn = IUniswapV3Pool(_pool).token0();
      _tokenOut = IUniswapV3Pool(_pool).token1();
    } else {
      _tokenIn = IUniswapV3Pool(_pool).token1();
      _tokenOut = IUniswapV3Pool(_pool).token0();
    }
    _wrapTokenIfNeeded(_tokenIn, _amountIn);
    _approve(_tokenIn, UNISWAP_V3_ROUTER, _amountIn);
    IUniswapV3Router.ExactInputSingleParams memory _params = IUniswapV3Router.ExactInputSingleParams(
      _tokenIn,
      _tokenOut,
      _fee,
      address(this),
      // solhint-disable-next-line not-rely-on-time
      block.timestamp + 1,
      _amountIn,
      1,
      0
    );
    return IUniswapV3Router(UNISWAP_V3_ROUTER).exactInputSingle(_params);
  }

  function _swapBalancerPool(
    address _pool,
    uint256 _indexIn,
    uint256 _indexOut,
    uint256 _amountIn
  ) private returns (uint256) {
    bytes32 _poolId = IBalancerPool(_pool).getPoolId();
    address _tokenIn;
    address _tokenOut;
    {
      (address[] memory _tokens, , ) = IBalancerVault(BALANCER_VAULT).getPoolTokens(_poolId);
      _tokenIn = _tokens[_indexIn];
      _tokenOut = _tokens[_indexOut];
    }
    _wrapTokenIfNeeded(_tokenIn, _amountIn);
    _approve(_tokenIn, BALANCER_VAULT, _amountIn);

    return
      IBalancerVault(BALANCER_VAULT).swap(
        IBalancerVault.SingleSwap({
          poolId: _poolId,
          kind: IBalancerVault.SwapKind.GIVEN_IN,
          assetIn: _tokenIn,
          assetOut: _tokenOut,
          amount: _amountIn,
          userData: new bytes(0)
        }),
        IBalancerVault.FundManagement({
          sender: address(this),
          fromInternalBalance: false,
          recipient: payable(address(this)),
          toInternalBalance: false
        }),
        0,
        // solhint-disable-next-line not-rely-on-time
        block.timestamp
      );
  }

  function _swapCurvePool(
    PoolType _poolType,
    address _pool,
    uint256 _indexIn,
    uint256 _indexOut,
    uint256 _amountIn
  ) private returns (uint256) {
    address _tokenIn = _getPoolTokenByIndex(_poolType, _pool, _indexIn);
    address _tokenOut = _getPoolTokenByIndex(_poolType, _pool, _indexOut);

    _wrapTokenIfNeeded(_tokenIn, _amountIn);
    if (_poolType == PoolType.CurveYPoolUnderlying) {
      _approve(_tokenIn, ICurveYPoolDeposit(_pool).curve(), _amountIn);
    } else if (_poolType == PoolType.CurveMetaPoolUnderlying) {
      _approve(_tokenIn, ICurveMetaPoolDeposit(_pool).pool(), _amountIn);
    } else {
      _approve(_tokenIn, _pool, _amountIn);
    }

    uint256 _before = _getBalance(_tokenOut);
    if (_poolType == PoolType.CurveETHPool) {
      if (_isETH(_tokenIn)) {
        _unwrapIfNeeded(_amountIn);
        ICurveETHPool(_pool).exchange{ value: _amountIn }(int128(_indexIn), int128(_indexOut), _amountIn, 0);
      } else {
        ICurveETHPool(_pool).exchange(int128(_indexIn), int128(_indexOut), _amountIn, 0);
      }
    } else if (_poolType == PoolType.CurveCryptoPool) {
      ICurveCryptoPool(_pool).exchange(_indexIn, _indexOut, _amountIn, 0);
    } else if (_poolType == PoolType.CurveMetaCryptoPool) {
      IZapCurveMetaCryptoPool(_pool).exchange_underlying(_indexIn, _indexOut, _amountIn, 0);
    } else if (_poolType == PoolType.CurveTriCryptoPool) {
      ICurveTriCryptoPool(_pool).exchange(_indexIn, _indexOut, _amountIn, 0, false);
    } else if (_poolType == PoolType.CurveBasePool) {
      ICurveBasePool(_pool).exchange(int128(_indexIn), int128(_indexOut), _amountIn, 0);
    } else if (_poolType == PoolType.CurveAPool) {
      ICurveAPool(_pool).exchange(int128(_indexIn), int128(_indexOut), _amountIn, 0);
    } else if (_poolType == PoolType.CurveAPoolUnderlying) {
      ICurveAPool(_pool).exchange_underlying(int128(_indexIn), int128(_indexOut), _amountIn, 0);
    } else if (_poolType == PoolType.CurveYPool) {
      ICurveYPoolSwap(_pool).exchange(int128(_indexIn), int128(_indexOut), _amountIn, 0);
    } else if (_poolType == PoolType.CurveYPoolUnderlying) {
      _pool = ICurveYPoolDeposit(_pool).curve();
      ICurveYPoolSwap(_pool).exchange_underlying(int128(_indexIn), int128(_indexOut), _amountIn, 0);
    } else if (_poolType == PoolType.CurveMetaPool) {
      ICurveMetaPoolSwap(_pool).exchange(int128(_indexIn), int128(_indexOut), _amountIn, 0);
    } else if (_poolType == PoolType.CurveMetaPoolUnderlying) {
      _pool = ICurveMetaPoolDeposit(_pool).pool();
      ICurveMetaPoolSwap(_pool).exchange_underlying(int128(_indexIn), int128(_indexOut), _amountIn, 0);
    } else if (_poolType == PoolType.CurveFactoryPlainPool) {
      ICurveFactoryPlainPool(_pool).exchange(int128(_indexIn), int128(_indexOut), _amountIn, 0, address(this));
    } else if (_poolType == PoolType.CurveFactoryMetaPool) {
      ICurveMetaPoolSwap(_pool).exchange(int128(_indexIn), int128(_indexOut), _amountIn, 0);
    } else if (_poolType == PoolType.CurveFactoryUSDMetaPoolUnderlying) {
      ICurveMetaPoolSwap(_pool).exchange_underlying(int128(_indexIn), int128(_indexOut), _amountIn, 0);
    } else if (_poolType == PoolType.CurveFactoryBTCMetaPoolUnderlying) {
      ICurveMetaPoolSwap(_pool).exchange_underlying(int128(_indexIn), int128(_indexOut), _amountIn, 0);
    } else if (_poolType == PoolType.CurveFactoryFraxBPMetaPoolUnderlying) {
      ICurveMetaPoolSwap(_pool).exchange_underlying(int128(_indexIn), int128(_indexOut), _amountIn, 0);
    } else {
      revert("AladdinZap: invalid poolType");
    }
    return _getBalance(_tokenOut) - _before;
  }

  function _addCurvePool(
    PoolType _poolType,
    address _pool,
    uint256 _tokens,
    uint256 _indexIn,
    uint256 _amountIn
  ) private returns (uint256) {
    address _tokenIn = _getPoolTokenByIndex(_poolType, _pool, _indexIn);

    _wrapTokenIfNeeded(_tokenIn, _amountIn);
    if (_poolType == PoolType.CurveFactoryUSDMetaPoolUnderlying) {
      _approve(_tokenIn, CURVE_3POOL_DEPOSIT_ZAP, _amountIn);
    } else if (_poolType == PoolType.CurveFactoryBTCMetaPoolUnderlying) {
      _approve(_tokenIn, CURVE_SBTC_DEPOSIT_ZAP, _amountIn);
    } else if (_poolType == PoolType.CurveFactoryFraxBPMetaPoolUnderlying) {
      _approve(_tokenIn, CURVE_FRAXBP_DEPOSIT_ZAP, _amountIn);
    } else {
      _approve(_tokenIn, _pool, _amountIn);
    }

    if (_poolType == PoolType.CurveAPool || _poolType == PoolType.CurveAPoolUnderlying) {
      // CurveAPool has different interface
      bool _useUnderlying = _poolType == PoolType.CurveAPoolUnderlying;
      if (_tokens == 2) {
        uint256[2] memory _amounts;
        _amounts[_indexIn] = _amountIn;
        return ICurveA2Pool(_pool).add_liquidity(_amounts, 0, _useUnderlying);
      } else if (_tokens == 3) {
        uint256[3] memory _amounts;
        _amounts[_indexIn] = _amountIn;
        return ICurveA3Pool(_pool).add_liquidity(_amounts, 0, _useUnderlying);
      } else {
        uint256[4] memory _amounts;
        _amounts[_indexIn] = _amountIn;
        return ICurveA4Pool(_pool).add_liquidity(_amounts, 0, _useUnderlying);
      }
    } else if (_poolType == PoolType.CurveFactoryUSDMetaPoolUnderlying) {
      uint256[4] memory _amounts;
      _amounts[_indexIn] = _amountIn;
      return ICurveDepositZap4Pool(CURVE_3POOL_DEPOSIT_ZAP).add_liquidity(_pool, _amounts, 0);
    } else if (_poolType == PoolType.CurveFactoryBTCMetaPoolUnderlying) {
      uint256[4] memory _amounts;
      _amounts[_indexIn] = _amountIn;
      return ICurveDepositZap4Pool(CURVE_SBTC_DEPOSIT_ZAP).add_liquidity(_pool, _amounts, 0);
    } else if (_poolType == PoolType.CurveFactoryFraxBPMetaPoolUnderlying) {
      uint256[3] memory _amounts;
      _amounts[_indexIn] = _amountIn;
      return ICurveDepositZap3Pool(CURVE_FRAXBP_DEPOSIT_ZAP).add_liquidity(_pool, _amounts, 0);
    } else if (_poolType == PoolType.CurveETHPool) {
      if (_isETH(_tokenIn)) {
        _unwrapIfNeeded(_amountIn);
      }
      uint256[2] memory _amounts;
      _amounts[_indexIn] = _amountIn;
      return ICurveETHPool(_pool).add_liquidity{ value: _amounts[0] }(_amounts, 0);
    } else {
      address _tokenOut = getCurvePoolToken(_poolType, _pool);
      uint256 _before = IERC20Upgradeable(_tokenOut).balanceOf(address(this));
      if (_tokens == 2) {
        uint256[2] memory _amounts;
        _amounts[_indexIn] = _amountIn;
        ICurveBase2Pool(_pool).add_liquidity(_amounts, 0);
      } else if (_tokens == 3) {
        uint256[3] memory _amounts;
        _amounts[_indexIn] = _amountIn;
        ICurveBase3Pool(_pool).add_liquidity(_amounts, 0);
      } else {
        uint256[4] memory _amounts;
        _amounts[_indexIn] = _amountIn;
        ICurveBase4Pool(_pool).add_liquidity(_amounts, 0);
      }
      return IERC20Upgradeable(_tokenOut).balanceOf(address(this)) - _before;
    }
  }

  function _removeCurvePool(
    PoolType _poolType,
    address _pool,
    uint256 _indexOut,
    uint256 _amountIn
  ) private returns (uint256) {
    address _tokenOut = _getPoolTokenByIndex(_poolType, _pool, _indexOut);
    address _tokenIn = getCurvePoolToken(_poolType, _pool);

    uint256 _before = _getBalance(_tokenOut);
    if (_poolType == PoolType.CurveAPool || _poolType == PoolType.CurveAPoolUnderlying) {
      // CurveAPool has different interface
      bool _useUnderlying = _poolType == PoolType.CurveAPoolUnderlying;
      ICurveAPool(_pool).remove_liquidity_one_coin(_amountIn, int128(_indexOut), 0, _useUnderlying);
    } else if (_poolType == PoolType.CurveCryptoPool) {
      // CurveCryptoPool use uint256 as index
      ICurveCryptoPool(_pool).remove_liquidity_one_coin(_amountIn, _indexOut, 0);
    } else if (_poolType == PoolType.CurveMetaCryptoPool) {
      // CurveMetaCryptoPool use uint256 as index
      _approve(_tokenIn, _pool, _amountIn);
      IZapCurveMetaCryptoPool(_pool).remove_liquidity_one_coin(_amountIn, _indexOut, 0);
    } else if (_poolType == PoolType.CurveTriCryptoPool) {
      // CurveTriCryptoPool use uint256 as index
      ICurveTriCryptoPool(_pool).remove_liquidity_one_coin(_amountIn, _indexOut, 0);
    } else if (_poolType == PoolType.CurveFactoryUSDMetaPoolUnderlying) {
      _approve(_tokenIn, CURVE_3POOL_DEPOSIT_ZAP, _amountIn);
      ICurveDepositZap4Pool(CURVE_3POOL_DEPOSIT_ZAP).remove_liquidity_one_coin(_pool, _amountIn, int128(_indexOut), 0);
    } else if (_poolType == PoolType.CurveFactoryBTCMetaPoolUnderlying) {
      _approve(_tokenIn, CURVE_SBTC_DEPOSIT_ZAP, _amountIn);
      ICurveDepositZap4Pool(CURVE_SBTC_DEPOSIT_ZAP).remove_liquidity_one_coin(_pool, _amountIn, int128(_indexOut), 0);
    } else if (_poolType == PoolType.CurveFactoryFraxBPMetaPoolUnderlying) {
      _approve(_tokenIn, CURVE_FRAXBP_DEPOSIT_ZAP, _amountIn);
      ICurveDepositZap3Pool(CURVE_FRAXBP_DEPOSIT_ZAP).remove_liquidity_one_coin(_pool, _amountIn, int128(_indexOut), 0);
    } else if (_poolType == PoolType.CurveMetaPoolUnderlying) {
      _approve(_tokenIn, _pool, _amountIn);
      ICurveMetaPoolDeposit(_pool).remove_liquidity_one_coin(_amountIn, int128(_indexOut), 0);
    } else if (_poolType == PoolType.CurveYPoolUnderlying) {
      _approve(_tokenIn, _pool, _amountIn);
      ICurveYPoolDeposit(_pool).remove_liquidity_one_coin(_amountIn, int128(_indexOut), 0, true);
    } else {
      ICurveBasePool(_pool).remove_liquidity_one_coin(_amountIn, int128(_indexOut), 0);
    }
    return _getBalance(_tokenOut) - _before;
  }

  function _wrapLidoSTETH(uint256 _amountIn, uint256 _action) private returns (uint256) {
    require(_action == 1, "AladdinZap: not wrap action");
    _unwrapIfNeeded(_amountIn);
    uint256 _before = IERC20Upgradeable(stETH).balanceOf(address(this));
    ILidoStETH(stETH).submit{ value: _amountIn }(address(0));
    return IERC20Upgradeable(stETH).balanceOf(address(this)).sub(_before);
  }

  function _wrapLidoWSTETH(uint256 _amountIn, uint256 _action) private returns (uint256) {
    if (_action == 1) {
      _approve(stETH, wstETH, _amountIn);
      return ILidoWstETH(wstETH).wrap(_amountIn);
    } else if (_action == 2) {
      return ILidoWstETH(wstETH).unwrap(_amountIn);
    } else {
      revert("AladdinZap: invalid action");
    }
  }

  function _wrapAsAladdinCompounder(
    address _pool,
    uint256 _amountIn,
    uint256 _action
  ) private returns (uint256) {
    address _token = _pool == aCRV ? cvxCRV : IAladdinCompounder(_pool).asset();
    if (_action == 1) {
      _approve(_token, _pool, _amountIn);
      if (_pool == aCRV) {
        return IAladdinCRV(_pool).deposit(address(this), _amountIn);
      } else {
        return IAladdinCompounder(_pool).deposit(_amountIn, address(this));
      }
    } else if (_action == 2) {
      if (_pool == aCRV) {
        return IAladdinCRV(_pool).withdraw(address(this), _amountIn, 0, IAladdinCRV.WithdrawOption.Withdraw);
      } else {
        return IAladdinCompounder(_pool).redeem(_amountIn, address(this), address(this));
      }
    } else {
      revert("AladdinZap: invalid action");
    }
  }

  function _getBalance(address _token) private view returns (uint256) {
    if (_isETH(_token)) return address(this).balance;
    else return IERC20Upgradeable(_token).balanceOf(address(this));
  }

  function _getPoolTokenByIndex(
    PoolType _type,
    address _pool,
    uint256 _index
  ) private view returns (address) {
    if (_type == PoolType.CurveMetaCryptoPool) {
      return IZapCurveMetaCryptoPool(_pool).underlying_coins(_index);
    } else if (_type == PoolType.CurveAPoolUnderlying) {
      return ICurveAPool(_pool).underlying_coins(_index);
    } else if (_type == PoolType.CurveYPoolUnderlying) {
      return ICurveYPoolDeposit(_pool).underlying_coins(int128(_index));
    } else if (_type == PoolType.CurveMetaPoolUnderlying) {
      if (_index == 0) return ICurveMetaPoolDeposit(_pool).coins(_index);
      else return ICurveMetaPoolDeposit(_pool).base_coins(_index - 1);
    } else if (_type == PoolType.CurveFactoryUSDMetaPoolUnderlying) {
      if (_index == 0) return ICurveBasePool(_pool).coins(_index);
      else return _get3PoolTokenByIndex(_index - 1);
    } else if (_type == PoolType.CurveFactoryBTCMetaPoolUnderlying) {
      if (_index == 0) return ICurveBasePool(_pool).coins(_index);
      else return _getsBTCTokenByIndex(_index - 1);
    } else if (_type == PoolType.CurveFactoryFraxBPMetaPoolUnderlying) {
      if (_index == 0) return ICurveBasePool(_pool).coins(_index);
      else return _getFraxBPTokenByIndex(_index - 1);
    } else {
      // vyper is weird, some use `int128`
      try ICurveBasePool(_pool).coins(_index) returns (address _token) {
        return _token;
      } catch {
        return ICurveBasePool(_pool).coins(int128(_index));
      }
    }
  }

  function _get3PoolTokenByIndex(uint256 _index) private pure returns (address) {
    if (_index == 0) return DAI;
    else if (_index == 1) return USDC;
    else if (_index == 2) return USDT;
    else return address(0);
  }

  function _getFraxBPTokenByIndex(uint256 _index) private pure returns (address) {
    if (_index == 0) return FRAX;
    else if (_index == 1) return USDC;
    else return address(0);
  }

  function _getsBTCTokenByIndex(uint256 _index) private pure returns (address) {
    if (_index == 0) return renBTC;
    else if (_index == 1) return WBTC;
    else if (_index == 2) return sBTC;
    else return address(0);
  }

  function _isETH(address _token) internal pure returns (bool) {
    return _token == ETH || _token == address(0);
  }

  function _wrapTokenIfNeeded(address _token, uint256 _amount) internal {
    if (_token == WETH && IERC20Upgradeable(_token).balanceOf(address(this)) < _amount) {
      IWETH(_token).deposit{ value: _amount }();
    }
  }

  function _unwrapIfNeeded(uint256 _amount) internal {
    if (address(this).balance < _amount) {
      IWETH(WETH).withdraw(_amount);
    }
  }

  function _approve(
    address _token,
    address _spender,
    uint256 _amount
  ) private {
    if (!_isETH(_token) && IERC20Upgradeable(_token).allowance(address(this), _spender) < _amount) {
      // hBTC cannot approve 0
      if (_token != 0x0316EB71485b0Ab14103307bf65a021042c6d380) {
        IERC20Upgradeable(_token).safeApprove(_spender, 0);
      }
      IERC20Upgradeable(_token).safeApprove(_spender, _amount);
    }
  }

  // solhint-disable-next-line no-empty-blocks
  receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

interface IBalancerPool {
  function getPoolId() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "../zap/TokenZapLogic.sol";
import "../interfaces/IWETH.sol";

abstract contract ZapGatewayBase is Ownable {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  /// @notice Emitted when the zap logic contract is updated.
  /// @param _oldLogic The old logic address.
  /// @param _newLogic The new logic address.
  event UpdateLogic(address _oldLogic, address _newLogic);

  /// @dev The address of WETH token.
  address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  /// @notice The address of zap logic contract.
  address public logic;

  /// @dev Internal function to transfer token into this contract.
  /// @param _token The address of token to transfer.
  /// @param _amount The amount of token to transfer.
  function _transferTokenIn(address _token, uint256 _amount) internal returns (uint256) {
    if (_token == address(0)) {
      require(msg.value == _amount, "msg.value mismatch");
    } else {
      require(msg.value == 0, "msg.value not zero");
      uint256 _balance = IERC20(_token).balanceOf(address(this));
      IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
      _amount = IERC20(_token).balanceOf(address(this)).sub(_balance);
    }

    return _amount;
  }

  function _transferTokenOut(address _token, uint256 _amount) internal {
    if (_token == address(0)) {
      uint256 _balance = address(this).balance;
      if (_balance < _amount) {
        IWETH(WETH).withdraw(_amount);
      }
      // solhint-disable-next-line avoid-low-level-calls
      (bool _success, ) = msg.sender.call{ value: _amount }("");
      require(_success, "transfer ETH failed");
    } else {
      uint256 _balance = IERC20(_token).balanceOf(address(this));
      if (_balance < _amount) {
        IWETH(WETH).deposit{ value: _amount }();
      }
      IERC20(_token).safeTransfer(msg.sender, _amount);
    }
  }

  /// @dev Internal function to do zap.
  /// @param _routes The routes to do zap. See comments in `TokenZapLogic` for more details.
  /// @param _amountIn The amount of input token.
  function _zap(uint256[] memory _routes, uint256 _amountIn) internal returns (uint256) {
    address _logic = logic;
    for (uint256 i = 0; i < _routes.length; i++) {
      // solhint-disable-next-line avoid-low-level-calls
      (bool _success, bytes memory _result) = _logic.delegatecall(
        abi.encodeWithSelector(TokenZapLogic.swap.selector, _routes[i], _amountIn)
      );
      // below lines will propagate inner error up
      if (!_success) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
          let ptr := mload(0x40)
          let size := returndatasize()
          returndatacopy(ptr, 0, size)
          revert(ptr, size)
        }
      }
      _amountIn = abi.decode(_result, (uint256));
    }
    return _amountIn;
  }

  /// @notice Update zap logic contract.
  /// @param _newLogic The address to update.
  function updateLogic(address _newLogic) external onlyOwner {
    address _oldLogic = logic;
    logic = _newLogic;

    emit UpdateLogic(_oldLogic, _newLogic);
  }

  // solhint-disable-next-line no-empty-blocks
  receive() external payable {}

  /// @notice Emergency function
  function execute(
    address _to,
    uint256 _value,
    bytes calldata _data
  ) external payable onlyOwner returns (bool, bytes memory) {
    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory result) = _to.call{ value: _value }(_data);
    return (success, result);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

interface IAladdinCRVConvexVault {
  enum ClaimOption {
    None,
    Claim,
    ClaimAsCvxCRV,
    ClaimAsCRV,
    ClaimAsCVX,
    ClaimAsETH
  }

  event Deposit(uint256 indexed _pid, address indexed _sender, uint256 _amount);
  event Withdraw(uint256 indexed _pid, address indexed _sender, uint256 _shares);
  event Claim(address indexed _sender, uint256 _reward, ClaimOption _option);
  event Harvest(address indexed _caller, uint256 _reward, uint256 _platformFee, uint256 _harvestBounty);

  event UpdateWithdrawalFeePercentage(uint256 indexed _pid, uint256 _feePercentage);
  event UpdatePlatformFeePercentage(uint256 indexed _pid, uint256 _feePercentage);
  event UpdateHarvestBountyPercentage(uint256 indexed _pid, uint256 _percentage);
  event UpdatePlatform(address indexed _platform);
  event UpdateZap(address indexed _zap);
  event UpdatePoolRewardTokens(uint256 indexed _pid, address[] _rewardTokens);
  event AddPool(uint256 indexed _pid, uint256 _convexPid, address[] _rewardTokens);
  event PausePoolDeposit(uint256 indexed _pid, bool _status);
  event PausePoolWithdraw(uint256 indexed _pid, bool _status);

  /// @notice Return the amount of pending AladdinCRV rewards for specific pool.
  /// @param _pid - The pool id.
  /// @param _account - The address of user.
  function pendingReward(uint256 _pid, address _account) external view returns (uint256);

  /// @notice Return the amount of pending AladdinCRV rewards for all pool.
  /// @param _account - The address of user.
  function pendingRewardAll(address _account) external view returns (uint256);

  /// @notice Return the user share for specific user.
  /// @param _pid The pool id to query.
  /// @param _account The address of user.
  function getUserShare(uint256 _pid, address _account) external view returns (uint256);

  /// @notice Return the total underlying token deposited.
  /// @param _pid The pool id to query.
  function getTotalUnderlying(uint256 _pid) external view returns (uint256);

  /// @notice Return the total pool share deposited.
  /// @param _pid The pool id to query.
  function getTotalShare(uint256 _pid) external view returns (uint256);

  /// @notice Deposit some token to specific pool.
  /// @dev This function is deprecated.
  /// @param _pid The pool id to query
  /// @param _amount The amount of token to deposit.
  /// @return share The amount of share after deposit.
  function deposit(uint256 _pid, uint256 _amount) external returns (uint256 share);

  /// @notice Deposit some token to specific pool for someone.
  /// @param _pid The pool id.
  /// @param _recipient The address of recipient who will recieve the token.
  /// @param _amount The amount of token to deposit.
  /// @return share The amount of share after deposit.
  function deposit(
    uint256 _pid,
    address _recipient,
    uint256 _amount
  ) external returns (uint256 share);

  /// @notice Deposit all token of the caller to specific pool.
  /// @dev This function is deprecated.
  /// @param _pid The pool id.
  /// @return share The amount of share after deposit.
  function depositAll(uint256 _pid) external returns (uint256 share);

  /// @notice Deposit all token of the caller to specific pool for someone.
  /// @param _pid The pool id.
  /// @param _recipient The address of recipient who will recieve the token.
  /// @return share The amount of share after deposit.
  function depositAll(uint256 _pid, address _recipient) external returns (uint256 share);

  /// @notice Deposit some token to specific pool with zap.
  /// @dev This function is deprecated.
  /// @param _pid The pool id.
  /// @param _token The address of token to deposit.
  /// @param _amount The amount of token to deposit.
  /// @param _minAmount The minimum amount of share to deposit.
  /// @return share The amount of share after deposit.
  function zapAndDeposit(
    uint256 _pid,
    address _token,
    uint256 _amount,
    uint256 _minAmount
  ) external payable returns (uint256 share);

  /// @notice Deposit some token to specific pool with zap for someone.
  /// @param _pid The pool id.
  /// @param _recipient The address of recipient who will recieve the token.
  /// @param _token The address of token to deposit.
  /// @param _amount The amount of token to deposit.
  /// @param _minAmount The minimum amount of share to deposit.
  /// @return share The amount of share after deposit.
  function zapAndDeposit(
    uint256 _pid,
    address _recipient,
    address _token,
    uint256 _amount,
    uint256 _minAmount
  ) external payable returns (uint256 share);

  /// @notice Deposit all token to specific pool with zap.
  /// @dev This function is deprecated.
  /// @param _pid The pool id.
  /// @param _token The address of token to deposit.
  /// @param _minAmount The minimum amount of share to deposit.
  /// @return share The amount of share after deposit.
  function zapAllAndDeposit(
    uint256 _pid,
    address _token,
    uint256 _minAmount
  ) external payable returns (uint256);

  /// @notice Deposit all token to specific pool with zap for someone.
  /// @param _pid The pool id.
  /// @param _recipient The address of recipient who will recieve the token.
  /// @param _token The address of token to deposit.
  /// @param _minAmount The minimum amount of share to deposit.
  /// @return share The amount of share after deposit.
  function zapAllAndDeposit(
    uint256 _pid,
    address _recipient,
    address _token,
    uint256 _minAmount
  ) external payable returns (uint256);

  /// @notice Withdraw some token from specific pool and zap to token.
  /// @param _pid - The pool id.
  /// @param _shares - The share of token want to withdraw.
  /// @param _token - The address of token zapping to.
  /// @param _minOut - The minimum amount of token to receive.
  /// @return withdrawn - The amount of token sent to caller.
  function withdrawAndZap(
    uint256 _pid,
    uint256 _shares,
    address _token,
    uint256 _minOut
  ) external returns (uint256);

  /// @notice Withdraw all token from specific pool and zap to token.
  /// @param _pid - The pool id.
  /// @param _token - The address of token zapping to.
  /// @param _minOut - The minimum amount of token to receive.
  /// @return withdrawn - The amount of token sent to caller.
  function withdrawAllAndZap(
    uint256 _pid,
    address _token,
    uint256 _minOut
  ) external returns (uint256);

  /// @notice Withdraw some token from specific pool and claim pending rewards.
  /// @param _pid - The pool id.
  /// @param _shares - The share of token want to withdraw.
  /// @param _minOut - The minimum amount of pending reward to receive.
  /// @param _option - The claim option (don't claim, as aCRV, cvxCRV, CRV, CVX, or ETH)
  /// @return withdrawn - The amount of token sent to caller.
  /// @return claimed - The amount of reward sent to caller.
  function withdrawAndClaim(
    uint256 _pid,
    uint256 _shares,
    uint256 _minOut,
    ClaimOption _option
  ) external returns (uint256, uint256);

  /// @notice Withdraw all share of token from specific pool and claim pending rewards.
  /// @param _pid - The pool id.
  /// @param _minOut - The minimum amount of pending reward to receive.
  /// @param _option - The claim option (as aCRV, cvxCRV, CRV, CVX, or ETH)
  /// @return withdrawn - The amount of token sent to caller.
  /// @return claimed - The amount of reward sent to caller.
  function withdrawAllAndClaim(
    uint256 _pid,
    uint256 _minOut,
    ClaimOption _option
  ) external returns (uint256, uint256);

  /// @notice claim pending rewards from specific pool.
  /// @param _pid - The pool id.
  /// @param _minOut - The minimum amount of pending reward to receive.
  /// @param _option - The claim option (as aCRV, cvxCRV, CRV, CVX, or ETH)
  /// @return claimed - The amount of reward sent to caller.
  function claim(
    uint256 _pid,
    uint256 _minOut,
    ClaimOption _option
  ) external returns (uint256);

  /// @notice claim pending rewards from all pools.
  /// @param _minOut - The minimum amount of pending reward to receive.
  /// @param _option - The claim option (as aCRV, cvxCRV, CRV, CVX, or ETH)
  /// @return claimed - The amount of reward sent to caller.
  function claimAll(uint256 _minOut, ClaimOption _option) external returns (uint256);

  /// @notice Harvest the pending reward and convert to aCRV.
  /// @param _pid - The pool id.
  /// @param _recipient - The address of account to receive harvest bounty.
  /// @param _minimumOut - The minimum amount of cvxCRV should get.
  /// @return harvested - The amount of cvxCRV harvested after zapping all other tokens to it.
  function harvest(
    uint256 _pid,
    address _recipient,
    uint256 _minimumOut
  ) external returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

interface IMetaCLever {
  event Deposit(uint256 indexed _strategyIndex, address indexed _account, uint256 _share, uint256 _amount);
  event Withdraw(uint256 indexed _strategyIndex, address indexed _account, uint256 _share, uint256 _amount);
  event Repay(address indexed _account, address indexed _underlyingToken, uint256 _amount);
  event Mint(address indexed _account, address indexed _recipient, uint256 _amount);
  event Burn(address indexed _account, address indexed _recipient, uint256 _amount);
  event Claim(uint256 indexed _strategyIndex, address indexed _rewardToken, uint256 _rewardAmount);
  event Harvest(uint256 indexed _strategyIndex, uint256 _reward, uint256 _platformFee, uint256 _harvestBounty);

  /// @notice Deposit underlying token or yield token as credit to this contract.
  ///
  /// @param _strategyIndex The yield strategy to deposit.
  /// @param _recipient The address of recipient who will receive the credit.
  /// @param _amount The number of token to deposit.
  /// @param _minShareOut The minimum share of yield token should be received.
  /// @param _isUnderlying Whether it is underlying token or yield token.
  ///
  /// @return _shares Return the amount of yield token shares received.
  function deposit(
    uint256 _strategyIndex,
    address _recipient,
    uint256 _amount,
    uint256 _minShareOut,
    bool _isUnderlying
  ) external returns (uint256 _shares);

  /// @notice Withdraw underlying token or yield token from this contract.
  ///
  /// @param _strategyIndex The yield strategy to withdraw.
  /// @param _recipient The address of recipient who will receive the token.
  /// @param _share The number of yield token share to withdraw.
  /// @param _minAmountOut The minimum amount of token should be receive.
  /// @param _asUnderlying Whether to receive underlying token or yield token.
  ///
  /// @return The amount of token sent to `_recipient`.
  function withdraw(
    uint256 _strategyIndex,
    address _recipient,
    uint256 _share,
    uint256 _minAmountOut,
    bool _asUnderlying
  ) external returns (uint256);

  /// @notice Repay debt with underlying token.
  ///
  /// @dev If the repay exceed current debt amount, a refund will be executed and only
  /// sufficient amount for debt plus fee will be taken.
  ///
  /// @param _underlyingToken The address of underlying token.
  /// @param _recipient The address of the recipient who will receive credit.
  /// @param _amount The amount of underlying token to repay.
  function repay(
    address _underlyingToken,
    address _recipient,
    uint256 _amount
  ) external;

  /// @notice Mint certern amount of debt tokens from caller's account.
  ///
  /// @param _recipient The address of the recipient who will receive the debt tokens.
  /// @param _amount The amount of debt token to mint.
  /// @param _depositToFurnace Whether to deposit the debt tokens to Furnace contract.
  function mint(
    address _recipient,
    uint256 _amount,
    bool _depositToFurnace
  ) external;

  /// @notice Burn certern amount of debt tokens from caller's balance to pay debt for someone.
  ///
  /// @dev If the repay exceed current debt amount, a refund will be executed and only
  /// sufficient amount for debt plus fee will be burned.
  ///
  /// @param _recipient The address of the recipient.
  /// @param _amount The amount of debt token to burn.
  function burn(address _recipient, uint256 _amount) external;

  /// @notice Claim extra rewards from strategy.
  ///
  /// @param _strategyIndex The yield strategy to claim.
  /// @param _recipient The address of recipient who will receive the rewards.
  function claim(uint256 _strategyIndex, address _recipient) external;

  /// @notice Claim extra rewards from all deposited strategies.
  ///
  /// @param _recipient The address of recipient who will receive the rewards.
  function claimAll(address _recipient) external;

  /// @notice Harvest rewards from corresponding yield strategy.
  ///
  /// @param _strategyIndex The yield strategy to harvest.
  /// @param _recipient The address of recipient who will receive the harvest bounty.
  /// @param _minimumOut The miminim amount of rewards harvested.
  ///
  /// @return The actual amount of reward tokens harvested.
  function harvest(
    uint256 _strategyIndex,
    address _recipient,
    uint256 _minimumOut
  ) external returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function allowance(address owner, address spender) external view returns (uint256);

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

// solhint-disable var-name-mixedcase, func-name-mixedcase

interface ICurveAPool {
  function remove_liquidity_one_coin(
    uint256 _token_amount,
    int128 i,
    uint256 _min_amount,
    bool _use_underlying
  ) external returns (uint256);

  function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);

  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external returns (uint256);

  function exchange_underlying(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external returns (uint256);

  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function get_dy_underlying(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function coins(uint256 index) external view returns (address);

  function underlying_coins(uint256 index) external view returns (address);

  function lp_token() external view returns (address);
}

/// @dev This is the interface of Curve aave-style Pool with 2 tokens, examples:
/// + saave: https://curve.fi/saave
interface ICurveA2Pool is ICurveAPool {
  function add_liquidity(
    uint256[2] memory _amounts,
    uint256 _min_mint_amount,
    bool _use_underlying
  ) external returns (uint256);

  function calc_token_amount(uint256[2] memory amounts, bool is_deposit) external view returns (uint256);
}

/// @dev This is the interface of Curve aave-style Pool with 3 tokens, examples:
/// aave: https://curve.fi/aave
/// ironbank: https://curve.fi/ib
interface ICurveA3Pool is ICurveAPool {
  function add_liquidity(
    uint256[3] memory _amounts,
    uint256 _min_mint_amount,
    bool _use_underlying
  ) external returns (uint256);

  function calc_token_amount(uint256[3] memory amounts, bool is_deposit) external view returns (uint256);
}

/// @dev This is the interface of Curve aave-style Pool with 3 tokens, examples:
interface ICurveA4Pool is ICurveAPool {
  function add_liquidity(
    uint256[4] memory _amounts,
    uint256 _min_mint_amount,
    bool _use_underlying
  ) external returns (uint256);

  function calc_token_amount(uint256[4] memory amounts, bool is_deposit) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

// solhint-disable func-name-mixedcase, var-name-mixedcase

/// @dev This is the interface of Curve Crypto Pools (including Factory Pool), examples:
/// + cvxeth: https://curve.fi/cvxeth
/// + crveth: https://curve.fi/crveth
/// + eursusd: https://curve.fi/eursusd
/// + teth: https://curve.fi/teth
/// + spelleth: https://curve.fi/spelleth

/// + FXS/ETH: https://curve.fi/factory-crypto/3
/// + YFI/ETH: https://curve.fi/factory-crypto/8
/// + AAVE/palStkAAVE: https://curve.fi/factory-crypto/9
/// + DYDX/ETH: https://curve.fi/factory-crypto/10
/// + SDT/ETH: https://curve.fi/factory-crypto/11
/// + BTRFLY/ETH: https://curve.fi/factory-crypto/17
/// + cvxFXS/FXS: https://curve.fi/factory-crypto/18
interface ICurveCryptoPool {
  function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount) external payable returns (uint256);

  function calc_token_amount(uint256[2] memory amounts) external view returns (uint256);

  function remove_liquidity_one_coin(
    uint256 token_amount,
    uint256 i,
    uint256 min_amount
  ) external returns (uint256);

  function calc_withdraw_one_coin(uint256 token_amount, uint256 i) external view returns (uint256);

  function exchange(
    uint256 i,
    uint256 j,
    uint256 dx,
    uint256 min_dy
  ) external payable returns (uint256);

  function exchange_underlying(
    uint256 i,
    uint256 j,
    uint256 dx,
    uint256 min_dy
  ) external payable returns (uint256);

  function get_dy(
    uint256 i,
    uint256 j,
    uint256 dx
  ) external view returns (uint256);

  function coins(uint256 index) external view returns (address);

  function token() external view returns (address);
}

/// @dev This is the interface of Zap Contract for Curve Meta Crypto Pools, examples:
/// + eurtusd: https://curve.fi/eurtusd
/// + xautusd: https://curve.fi/xautusd
interface IZapCurveMetaCryptoPool {
  function add_liquidity(uint256[4] memory amounts, uint256 min_mint_amount) external returns (uint256);

  function calc_token_amount(uint256[4] memory amounts) external view returns (uint256);

  function remove_liquidity_one_coin(
    uint256 token_amount,
    uint256 i,
    uint256 min_amount
  ) external;

  function calc_withdraw_one_coin(uint256 token_amount, uint256 i) external view returns (uint256);

  function exchange_underlying(
    uint256 i,
    uint256 j,
    uint256 dx,
    uint256 min_dy
  ) external returns (uint256);

  function get_dy_underlying(
    uint256 i,
    uint256 j,
    uint256 dx
  ) external view returns (uint256);

  function coins(uint256 index) external view returns (address);

  function underlying_coins(uint256 index) external view returns (address);

  function token() external view returns (address);

  function base_pool() external view returns (address);

  function pool() external view returns (address);
}

/// @dev This is the interface of Curve Tri Crypto Pools, examples:
/// + tricrypto2: https://curve.fi/tricrypto2
/// + tricrypto: https://curve.fi/tricrypto
interface ICurveTriCryptoPool {
  function add_liquidity(uint256[3] memory amounts, uint256 min_mint_amount) external;

  function calc_token_amount(uint256[3] memory amounts, bool deposit) external view returns (uint256);

  function remove_liquidity_one_coin(
    uint256 token_amount,
    uint256 i,
    uint256 min_amount
  ) external;

  function calc_withdraw_one_coin(uint256 token_amount, uint256 i) external view returns (uint256);

  function exchange(
    uint256 i,
    uint256 j,
    uint256 dx,
    uint256 min_dy,
    bool use_eth
  ) external;

  function get_dy(
    uint256 i,
    uint256 j,
    uint256 dx
  ) external view returns (uint256);

  function token() external view returns (address);

  function coins(uint256 index) external returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

interface IConvexCRVDepositor {
  function deposit(
    uint256 _amount,
    bool _lock,
    address _stakeAddress
  ) external;

  function deposit(uint256 _amount, bool _lock) external;

  function lockIncentive() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

// solhint-disable var-name-mixedcase, func-name-mixedcase

interface ICurveBasePool {
  function remove_liquidity_one_coin(
    uint256 _token_amount,
    int128 i,
    uint256 min_amount
  ) external;

  function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);

  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external;

  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function get_dy_underlying(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function coins(uint256 index) external view returns (address);

  function balances(uint256 index) external view returns (uint256);

  // ren and sbtc pool
  function coins(int128 index) external view returns (address);

  // ren and sbtc pool
  function balances(int128 index) external view returns (uint256);
}

/// @dev This is the interface of Curve base-style Pool with 2 tokens, examples:
/// hbtc: https://curve.fi/hbtc
/// ren: https://curve.fi/ren
/// eurs: https://www.curve.fi/eurs
interface ICurveBase2Pool {
  function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount) external;

  function calc_token_amount(uint256[2] memory amounts, bool deposit) external view returns (uint256);
}

/// @dev This is the interface of Curve base-style Pool with 3 tokens, examples:
/// sbtc: https://curve.fi/sbtc
/// 3pool: https://curve.fi/3pool
interface ICurveBase3Pool {
  function add_liquidity(uint256[3] memory amounts, uint256 min_mint_amount) external;

  function calc_token_amount(uint256[3] memory amounts, bool deposit) external view returns (uint256);
}

/// @dev This is the interface of Curve base-style Pool with 4 tokens, examples:
interface ICurveBase4Pool {
  function add_liquidity(uint256[4] memory amounts, uint256 min_mint_amount) external;

  function calc_token_amount(uint256[4] memory amounts, bool deposit) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

// solhint-disable func-name-mixedcase, var-name-mixedcase

/// @dev This is the interface of Curve ETH Pools (including Factory Pool), examples:
/// + steth: https://curve.fi/steth
/// + seth: https://curve.fi/seth
/// + reth: https://curve.fi/reth
/// + ankreth: https://curve.fi/ankreth
/// + alETH [Factory]: https://curve.fi/factory/38
/// + Ankr Reward-Earning Staked ETH [Factory]: https://curve.fi/factory/56
interface ICurveETHPool {
  function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount) external payable returns (uint256);

  function calc_token_amount(uint256[2] memory amounts, bool is_deposit) external view returns (uint256);

  function remove_liquidity_one_coin(
    uint256 _token_amount,
    int128 i,
    uint256 _min_amount
  ) external returns (uint256);

  function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);

  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external payable returns (uint256);

  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function coins(uint256 index) external view returns (address);

  function lp_token() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

// solhint-disable var-name-mixedcase, func-name-mixedcase

/// @dev This is the interface of Curve Factory Meta Pool (with 3pool or sbtc), examples:
/// + mim: https://curve.fi/mim
/// + frax: https://curve.fi/frax
/// + tusd: https://curve.fi/tusd
/// + ousd + 3crv: https://curve.fi/factory/9
/// + fei + 3crv: https://curve.fi/factory/11
/// + dola + 3crv: https://curve.fi/factory/27
/// + ust + 3crv: https://curve.fi/factory/53
/// + usdp + 3crv: https://curve.fi/factory/59
/// + wibBTC + crvRenWSBTC: https://curve.fi/factory/60
/// + bean + 3crv: https://curve.fi/factory/81
/// + usdv + 3crv: https://curve.fi/factory/82
interface ICurveFactoryMetaPool {
  function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount) external returns (uint256);

  function calc_token_amount(uint256[2] memory amounts, bool is_deposit) external view returns (uint256);

  function remove_liquidity_one_coin(
    uint256 token_amount,
    int128 i,
    uint256 min_amount
  ) external returns (uint256);

  function calc_withdraw_one_coin(uint256 token_amount, int128 i) external view returns (uint256);

  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external returns (uint256);

  function exchange_underlying(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external returns (uint256);

  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function get_dy_underlying(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function coins(uint256 index) external view returns (address);
}

interface ICurveDepositZap {
  function remove_liquidity_one_coin(
    address _pool,
    uint256 _burn_amount,
    int128 i,
    uint256 _min_amount
  ) external returns (uint256);

  function calc_withdraw_one_coin(
    address _pool,
    uint256 _token_amount,
    int128 i
  ) external view returns (uint256);
}

interface ICurveDepositZap3Pool is ICurveDepositZap {
  function add_liquidity(
    address _pool,
    uint256[3] memory _deposit_amounts,
    uint256 _min_mint_amount
  ) external returns (uint256);

  function calc_token_amount(
    address _pool,
    uint256[3] memory _amounts,
    bool _is_deposit
  ) external view returns (uint256);
}

interface ICurveDepositZap4Pool is ICurveDepositZap {
  function add_liquidity(
    address _pool,
    uint256[4] memory _deposit_amounts,
    uint256 _min_mint_amount
  ) external returns (uint256);

  function calc_token_amount(
    address _pool,
    uint256[4] memory _amounts,
    bool _is_deposit
  ) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

// solhint-disable var-name-mixedcase, func-name-mixedcase

/// @dev This is the interface of Curve Meta Pool with (3pool or sbtc), examples:
/// + ust: https://curve.fi/ust
/// + dusd: https://www.curve.fi/dusd
/// + gusd: https://curve.fi/gusd
/// + husd: https://curve.fi/husd
/// + rai: https://curve.fi/rai
/// + musd: https://curve.fi/musd
///
/// + bbtc: https://curve.fi/bbtc
/// + obtc: https://www.curve.fi/obtc
/// + pbtc: https://www.curve.fi/pbtc
/// + tbtc: https://www.curve.fi/tbtc
interface ICurveMetaPoolSwap {
  function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount) external returns (uint256);

  function calc_token_amount(uint256[2] memory amounts, bool is_deposit) external view returns (uint256);

  function remove_liquidity_one_coin(
    uint256 token_amount,
    int128 i,
    uint256 min_amount
  ) external returns (uint256);

  function calc_withdraw_one_coin(uint256 token_amount, int128 i) external view returns (uint256);

  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external returns (uint256);

  function exchange_underlying(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external returns (uint256);

  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function get_dy_underlying(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function base_pool() external view returns (address);

  function base_coins(uint256 index) external view returns (address);

  function coins(uint256 index) external view returns (address);

  function token() external view returns (address);
}

interface ICurveMetaPoolDeposit {
  function add_liquidity(uint256[4] memory amounts, uint256 min_mint_amount) external returns (uint256);

  function calc_token_amount(uint256[4] memory amounts, bool is_deposit) external view returns (uint256);

  function remove_liquidity_one_coin(
    uint256 token_amount,
    int128 i,
    uint256 min_amount
  ) external returns (uint256);

  function calc_withdraw_one_coin(uint256 token_amount, int128 i) external view returns (uint256);

  function token() external view returns (address);

  function base_pool() external view returns (address);

  function pool() external view returns (address);

  function coins(uint256 index) external view returns (address);

  function base_coins(uint256 index) external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

interface ILidoWstETH {
  function wrap(uint256 _stETHAmount) external returns (uint256);

  function unwrap(uint256 _wstETHAmount) external returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

// solhint-disable func-name-mixedcase

interface ICurvePoolRegistry {
  function get_lp_token(address _pool) external view returns (address);

  function get_pool_from_lp_token(address _token) external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

interface ILidoStETH {
  function submit(address _referral) external payable returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

// solhint-disable var-name-mixedcase, func-name-mixedcase
interface ICurveFactoryPlainPool {
  function remove_liquidity_one_coin(
    uint256 token_amount,
    int128 i,
    uint256 min_amount
  ) external returns (uint256);

  function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);

  function exchange(
    int128 i,
    int128 j,
    uint256 _dx,
    uint256 _min_dy,
    address _receiver
  ) external returns (uint256);

  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function coins(uint256 index) external view returns (address);
}

/// @dev This is the interface of Curve Factory Plain Pool with 2 tokens, examples:
interface ICurveFactoryPlain2Pool is ICurveFactoryPlainPool {
  function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount) external returns (uint256);

  function calc_token_amount(uint256[2] memory amounts, bool _is_deposit) external view returns (uint256);
}

/// @dev This is the interface of Curve Factory Plain Pool with 3 tokens, examples:
interface ICurveFactoryPlain3Pool is ICurveFactoryPlainPool {
  function add_liquidity(uint256[3] memory amounts, uint256 min_mint_amount) external returns (uint256);

  function calc_token_amount(uint256[3] memory amounts, bool _is_deposit) external view returns (uint256);
}

/// @dev This is the interface of Curve Factory Plain Pool with 4 tokens, examples:
interface ICurveFactoryPlain4Pool is ICurveFactoryPlainPool {
  function add_liquidity(uint256[4] memory amounts, uint256 min_mint_amount) external returns (uint256);

  function calc_token_amount(uint256[4] memory amounts, bool _is_deposit) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

// solhint-disable var-name-mixedcase, func-name-mixedcase

interface ICurveYPoolSwap {
  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external;

  function exchange_underlying(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external;

  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function get_dy_underlying(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);

  function coins(uint256 index) external view returns (address);

  function underlying_coins(uint256 index) external view returns (address);
}

interface ICurveYPoolDeposit {
  function remove_liquidity_one_coin(
    uint256 _token_amount,
    int128 i,
    uint256 _min_amount,
    bool donate_dust
  ) external;

  function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);

  function token() external view returns (address);

  function curve() external view returns (address);

  function coins(uint256 index) external view returns (address);

  function underlying_coins(uint256 index) external view returns (address);

  function coins(int128 index) external view returns (address);

  function underlying_coins(int128 index) external view returns (address);
}

// solhint-disable var-name-mixedcase, func-name-mixedcase
/// @dev This is the interface of Curve yearn-style Pool with 2 tokens, examples:
/// + compound: https://curve.fi/compound
interface ICurveY2PoolDeposit is ICurveYPoolDeposit {
  function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount) external;
}

interface ICurveY2PoolSwap is ICurveYPoolSwap {
  function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount) external;
}

/// @dev This is the interface of Curve yearn-style Pool with 3 tokens, examples:
/// usdt: https://curve.fi/usdt
interface ICurveY3PoolDeposit is ICurveYPoolDeposit {
  function add_liquidity(uint256[3] memory _amounts, uint256 _min_mint_amount) external;
}

interface ICurveY3PoolSwap is ICurveYPoolSwap {
  function add_liquidity(uint256[3] memory _amounts, uint256 _min_mint_amount) external;
}

/// @dev This is the interface of Curve yearn-style Pool with 4 tokens, examples:
/// + pax: https://curve.fi/pax
/// + y: https://curve.fi/iearn
/// + busd: https://curve.fi/busd
/// + susd v2: https://curve.fi/susdv2
interface ICurveY4PoolDeposit is ICurveYPoolDeposit {
  function add_liquidity(uint256[4] memory _amounts, uint256 _min_mint_amount) external;
}

interface ICurveY4PoolSwap is ICurveYPoolSwap {
  function add_liquidity(uint256[4] memory _amounts, uint256 _min_mint_amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

interface IUniswapV2Pair {
  function token0() external returns (address);

  function token1() external returns (address);

  function getReserves()
    external
    view
    returns (
      uint112 _reserve0,
      uint112 _reserve1,
      uint32 _blockTimestampLast
    );

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;
pragma abicoder v2;

interface IUniswapV3Router {
  struct ExactInputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
    uint160 sqrtPriceLimitX96;
  }

  function exactInputSingle(ExactInputSingleParams calldata params) external returns (uint256 amountOut);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

interface IWETH {
  function deposit() external payable;

  function withdraw(uint256 wad) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

interface IUniswapV3Pool {
  function token0() external returns (address);

  function token1() external returns (address);

  function fee() external returns (uint24);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

/// @title IAladdinCompounder
/// @notice The interface for AladdinCompounder like aCRV, aFXS, and is also EIP4646 compatible.
interface IAladdinCompounder {
  /// @notice Emitted when someone deposits asset into this contract.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  /// @param sender The address who sends underlying asset.
  /// @param owner The address who will receive the pool shares.
  /// @param assets The amount of asset deposited.
  /// @param shares The amounf of pool shares received.
  event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

  /// @notice Emitted when someone withdraws asset from this contract.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  /// @param sender The address who call the function.
  /// @param receiver The address who will receive the assets.
  /// @param owner The address who owns the assets.
  /// @param assets The amount of asset withdrawn.
  /// @param shares The amounf of pool shares to withdraw.
  event Withdraw(
    address indexed sender,
    address indexed receiver,
    address indexed owner,
    uint256 assets,
    uint256 shares
  );

  /// @notice Emitted when someone harvests rewards.
  /// @param caller The address who call the function.
  /// @param recipient The address of account to recieve the harvest bounty.
  /// @param assets The total amount of underlying asset harvested.
  /// @param platformFee The amount of harvested assets as platform fee.
  /// @param harvestBounty The amount of harvested assets as harvest bounty.
  event Harvest(
    address indexed caller,
    address indexed recipient,
    uint256 assets,
    uint256 platformFee,
    uint256 harvestBounty
  );

  /// @notice Return the address of underlying assert.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  function asset() external view returns (address assetTokenAddress);

  /// @notice Return the total amount of underlying assert mananged by the contract.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  function totalAssets() external view returns (uint256 totalManagedAssets);

  /// @notice Return the amount of pool shares given the amount of asset.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  /// @param assets The amount of asset to convert.
  function convertToShares(uint256 assets) external view returns (uint256 shares);

  /// @notice Return the amount of asset given the amount of pool share.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  /// @param assets The amount of pool shares to convert.
  function convertToAssets(uint256 shares) external view returns (uint256 assets);

  /// @notice Return the maximum amount of asset that the user can deposit.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  /// @param receiver The address of user to receive the pool share.
  function maxDeposit(address receiver) external view returns (uint256 maxAssets);

  /// @notice Return the amount of pool shares will receive, if perform a deposit.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  /// @param assets The amount of asset to deposit.
  function previewDeposit(uint256 assets) external view returns (uint256 shares);

  /// @notice Deposit assets into this contract.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  /// @param assets The amount of asset to deposit.
  /// @param receiver The address of account who will receive the pool share.
  /// @return shares The amount of pool shares received.
  function deposit(uint256 assets, address receiver) external returns (uint256 shares);

  /// @notice Return the maximum amount of pool shares that the user can mint.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  /// @param receiver The address of user to receive the pool share.
  function maxMint(address receiver) external view returns (uint256 maxShares);

  /// @notice Return the amount of assets needed, if perform a mint.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  /// @param shares The amount of pool shares to mint.
  function previewMint(uint256 shares) external view returns (uint256 assets);

  /// @notice Mint pool shares from this contract.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  /// @param shares The amount of pool shares to mint.
  /// @param receiver The address of account who will receive the pool share.
  /// @return assets The amount of assets deposited to the contract.
  function mint(uint256 shares, address receiver) external returns (uint256 assets);

  /// @notice Return the maximum amount of assets that the user can withdraw.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  /// @param owner The address of user to withdraw from.
  function maxWithdraw(address owner) external view returns (uint256 maxAssets);

  /// @notice Return the amount of shares needed, if perform a withdraw.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  /// @param assets The amount of assets to withdraw.
  function previewWithdraw(uint256 assets) external view returns (uint256 shares);

  /// @notice Withdraw assets from this contract.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  /// @param assets The amount of assets to withdraw.
  /// @param receiver The address of account who will receive the assets.
  /// @param owner The address of user to withdraw from.
  /// @return shares The amount of pool shares burned.
  function withdraw(
    uint256 assets,
    address receiver,
    address owner
  ) external returns (uint256 shares);

  /// @notice Return the maximum amount of pool shares that the user can redeem.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  /// @param owner The address of user to redeem from.
  function maxRedeem(address owner) external view returns (uint256 maxShares);

  /// @notice Return the amount of assets to be received, if perform a redeem.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  /// @param shares The amount of pool shares to redeem.
  function previewRedeem(uint256 shares) external view returns (uint256 assets);

  /// @notice Redeem assets from this contract.
  /// @dev See https://eips.ethereum.org/EIPS/eip-4626
  /// @param shares The amount of pool shares to burn.
  /// @param receiver The address of account who will receive the assets.
  /// @param owner The address of user to withdraw from.
  /// @return assets The amount of assets withdrawn.
  function redeem(
    uint256 shares,
    address receiver,
    address owner
  ) external returns (uint256 assets);

  /// @notice Harvest rewards and convert to underlying asset.
  /// @param recipient The address of account to recieve the harvest bounty.
  /// @param minAssets The minimum amount of underlying asset harvested.
  /// @return assets The total amount of underlying asset harvested.
  function harvest(address recipient, uint256 minAssets) external returns (uint256 assets);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IAladdinCRV is IERC20Upgradeable {
  event Harvest(address indexed _caller, uint256 _amount);
  event Deposit(address indexed _sender, address indexed _recipient, uint256 _amount);
  event Withdraw(
    address indexed _sender,
    address indexed _recipient,
    uint256 _shares,
    IAladdinCRV.WithdrawOption _option
  );

  event UpdateWithdrawalFeePercentage(uint256 _feePercentage);
  event UpdatePlatformFeePercentage(uint256 _feePercentage);
  event UpdateHarvestBountyPercentage(uint256 _percentage);
  event UpdatePlatform(address indexed _platform);
  event UpdateZap(address indexed _zap);

  enum WithdrawOption {
    Withdraw,
    WithdrawAndStake,
    WithdrawAsCRV,
    WithdrawAsCVX,
    WithdrawAsETH
  }

  /// @dev return the total amount of cvxCRV staked.
  function totalUnderlying() external view returns (uint256);

  /// @dev return the amount of cvxCRV staked for user
  function balanceOfUnderlying(address _user) external view returns (uint256);

  function deposit(address _recipient, uint256 _amount) external returns (uint256);

  function depositAll(address _recipient) external returns (uint256);

  function depositWithCRV(address _recipient, uint256 _amount) external returns (uint256);

  function depositAllWithCRV(address _recipient) external returns (uint256);

  function withdraw(
    address _recipient,
    uint256 _shares,
    uint256 _minimumOut,
    WithdrawOption _option
  ) external returns (uint256);

  function withdrawAll(
    address _recipient,
    uint256 _minimumOut,
    WithdrawOption _option
  ) external returns (uint256);

  function harvest(address _recipient, uint256 _minimumOut) external returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./IERC20Upgradeable.sol";
import "../../math/SafeMathUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function allowance(address owner, address spender) external view returns (uint256);

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../utils/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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