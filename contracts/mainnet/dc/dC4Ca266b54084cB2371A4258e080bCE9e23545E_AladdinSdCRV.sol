// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;
pragma abicoder v2;

import "./interfaces/IStakeDAOCRVVault.sol";
import "../../interfaces/IZap.sol";

import "./SdCRVLocker.sol";
import "../AladdinCompounder.sol";

// solhint-disable reason-string

contract AladdinSdCRV is AladdinCompounder, SdCRVLocker {
  using SafeMathUpgradeable for uint256;
  using SafeERC20Upgradeable for IERC20Upgradeable;

  /// @notice Emitted when the zap contract is updated.
  /// @param _zap The address of the zap contract.
  event UpdateZap(address _zap);

  /// @dev The type for withdraw fee in StakeDAOVaultBase
  bytes32 private constant VAULT_WITHDRAW_FEE_TYPE = keccak256("StakeDAOVaultBase.WithdrawFee");

  /// @dev The address of CRV Token.
  address private constant CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;

  /// @dev The address of SDT Token.
  address private constant SDT = 0x73968b9a57c6E53d41345FD57a6E6ae27d6CDB2F;

  // The address of 3CRV token.
  address private constant THREE_CRV = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;

  /// @dev The address of legacy sdveCRV Token.
  address private constant SD_VE_CRV = 0x478bBC744811eE8310B461514BDc29D03739084D;

  /// @dev The address of sdCRV Token.
  // solhint-disable-next-line const-name-snakecase
  address private constant sdCRV = 0xD1b5651E55D4CeeD36251c61c50C889B36F6abB5;

  /// @dev The address of StakeDAOCRVVault contract.
  address private immutable vault;

  /// @dev The address of ZAP contract, will be used to swap tokens.
  address public zap;

  /********************************** Constructor **********************************/

  constructor(address _vault) {
    vault = _vault;
  }

  function initialize(address _zap) external initializer {
    OwnableUpgradeable.__Ownable_init();
    ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
    ERC20Upgradeable.__ERC20_init("Aladdin sdCRV", "asdCRV");

    require(_zap != address(0), "zero zap address");
    zap = _zap;

    IERC20Upgradeable(CRV).safeApprove(vault, uint256(-1));
    IERC20Upgradeable(SD_VE_CRV).safeApprove(vault, uint256(-1));
    IERC20Upgradeable(sdCRV).safeApprove(vault, uint256(-1));
  }

  // receive ETH from zap
  receive() external payable {}

  /********************************** View Functions **********************************/

  /// @inheritdoc IAladdinCompounder
  function asset() public pure override returns (address) {
    return sdCRV;
  }

  /// @inheritdoc SdCRVLocker
  function withdrawLockTime() public view override returns (uint256) {
    return SdCRVLocker(vault).withdrawLockTime();
  }

  /********************************** Mutated Functions **********************************/

  /// @notice Deposit CRV into the contract.
  /// @dev Use `_assets=uint256(-1)` if you want to deposit all CRV.
  /// @param _assets The amount of CRV to desposit.
  /// @param _receiver The address of account who will receive the pool share.
  /// @param _minShareOut The minimum amount of share to receive.
  /// @return _shares The amount of pool shares received.
  function depositWithCRV(
    uint256 _assets,
    address _receiver,
    uint256 _minShareOut
  ) external nonReentrant returns (uint256 _shares) {
    _distributePendingReward();

    if (_assets == uint256(-1)) {
      _assets = IERC20Upgradeable(CRV).balanceOf(msg.sender);
    }
    IERC20Upgradeable(CRV).safeTransferFrom(msg.sender, address(this), _assets);

    _assets = IStakeDAOCRVVault(vault).depositWithCRV(_assets, address(this), 0);

    _shares = _mintShare(_assets, _receiver);
    require(_shares >= _minShareOut, "asdCRV: insufficient share received");
  }

  /// @notice Deposit sdveCRV into the contract.
  /// @dev Use `_assets=uint256(-1)` if you want to deposit all sdveCRV.
  /// @param _assets The amount of sdveCRV to desposit.
  /// @param _receiver The address of account who will receive the pool share.
  /// @return _shares The amount of pool shares received.
  function depositWithSdVeCRV(uint256 _assets, address _receiver) external nonReentrant returns (uint256 _shares) {
    _distributePendingReward();

    if (_assets == uint256(-1)) {
      _assets = IERC20Upgradeable(SD_VE_CRV).balanceOf(msg.sender);
    }
    IERC20Upgradeable(SD_VE_CRV).safeTransferFrom(msg.sender, address(this), _assets);

    IStakeDAOCRVVault(vault).depositWithSdVeCRV(_assets, address(this));

    _shares = _mintShare(_assets, _receiver);
  }

  /// @inheritdoc IAladdinCompounder
  function harvest(address _recipient, uint256 _minAssets) external override nonReentrant returns (uint256 assets) {
    _distributePendingReward();

    // 1. claim rewards and sell to sdCRV
    {
      // 1.1 claim SDT/CRV/3CRV rewards
      uint256 _amountSDT = IERC20Upgradeable(SDT).balanceOf(address(this));
      uint256 _amountCRV = IERC20Upgradeable(CRV).balanceOf(address(this));
      uint256 _amount3CRV = IERC20Upgradeable(THREE_CRV).balanceOf(address(this));
      IStakeDAOCRVVault(vault).claim(address(this), address(this));
      _amountSDT = IERC20Upgradeable(SDT).balanceOf(address(this)) - _amountSDT;
      _amountCRV = IERC20Upgradeable(CRV).balanceOf(address(this)) - _amountCRV;
      _amount3CRV = IERC20Upgradeable(THREE_CRV).balanceOf(address(this)) - _amount3CRV;

      // 1.2 sell SDT/3CRV to ETH

      uint256 _amountETH;
      address _zap = zap;
      if (_amountSDT > 0) {
        IERC20Upgradeable(SDT).safeTransfer(_zap, _amountSDT);
        _amountETH += IZap(_zap).zap(SDT, _amountSDT, address(0), 0);
      }
      if (_amount3CRV > 0) {
        IERC20Upgradeable(THREE_CRV).safeTransfer(_zap, _amount3CRV);
        _amountETH += IZap(_zap).zap(THREE_CRV, _amount3CRV, address(0), 0);
      }

      // 1.3 sell ETH to CRV
      if (_amountETH > 0) {
        _amountCRV += IZap(_zap).zap{ value: _amountETH }(address(0), _amountETH, CRV, 0);
      }

      // 1.4 deposit CRV as sdCRV
      assets = IStakeDAOCRVVault(vault).depositWithCRV(_amountCRV, address(this), 0);
      require(assets >= _minAssets, "asdCRV: insufficient harvested sdCRV");
    }

    // 2. calculate fee and distribute
    FeeInfo memory _fee = feeInfo;
    uint256 _totalAssets = totalAssetsStored; // the value is correct
    uint256 _totalShare = totalSupply();
    uint256 _platformFee = _fee.platformPercentage;
    if (_platformFee > 0) {
      _platformFee = (_platformFee * assets) / FEE_PRECISION;
      // share will be a little more than the actual percentage since minted before distribute rewards
      _mint(_fee.platform, _platformFee.mul(_totalShare) / _totalAssets);
    }
    uint256 _harvestBounty = _fee.bountyPercentage;
    if (_harvestBounty > 0) {
      _harvestBounty = (_harvestBounty * assets) / FEE_PRECISION;
      // share will be a little more than the actual percentage since minted before distribute rewards
      _mint(_recipient, _harvestBounty.mul(_totalShare) / _totalAssets);
    }
    totalAssetsStored = _totalAssets.add(_platformFee).add(_harvestBounty);

    emit Harvest(msg.sender, _recipient, assets, _platformFee, _harvestBounty);

    _notifyHarvestedReward(assets - _platformFee - _harvestBounty);
  }

  /********************************** Restricted Functions **********************************/

  /// @dev Update the zap contract
  /// @param _zap The address of the zap contract.
  function updateZap(address _zap) external onlyOwner {
    require(_zap != address(0), "asdCRV: zero zap address");
    zap = _zap;

    emit UpdateZap(_zap);
  }

  /********************************** Internal Functions **********************************/

  /// @inheritdoc AladdinCompounder
  function _deposit(uint256 _assets, address _receiver) internal override returns (uint256) {
    IStakeDAOCRVVault(vault).deposit(_assets, address(this));

    return _mintShare(_assets, _receiver);
  }

  /// @dev Internal function to mint share to user.
  /// @param _assets The amount of asset to deposit.
  /// @param _receiver The address of account who will receive the pool share.
  /// @return Return the amount of pool shares to be received.
  function _mintShare(uint256 _assets, address _receiver) internal returns (uint256) {
    require(_assets > 0, "asdCRV: deposit zero amount");

    uint256 _totalAssets = totalAssetsStored; // the value is correct
    uint256 _totalShare = totalSupply();
    uint256 _shares;
    if (_totalAssets == 0) _shares = _assets;
    else _shares = _assets.mul(_totalShare) / _totalAssets;

    _mint(_receiver, _shares);

    totalAssetsStored = _totalAssets + _assets;

    emit Deposit(msg.sender, _receiver, _assets, _shares);

    return _shares;
  }

  /// @inheritdoc AladdinCompounder
  function _withdraw(
    uint256 _shares,
    address _receiver,
    address _owner
  ) internal override returns (uint256) {
    require(_shares > 0, "asdCRV: withdraw zero share");
    require(_shares <= balanceOf(_owner), "asdCRV: insufficient owner shares");
    uint256 _totalAssets = totalAssetsStored; // the value is correct
    uint256 _totalShare = totalSupply();
    uint256 _amount = _shares.mul(_totalAssets) / _totalShare;
    _burn(_owner, _shares);

    if (_totalShare != _shares) {
      // take withdraw fee if it is not the last user.
      uint256 _withdrawPercentage = getFeeRate(WITHDRAW_FEE_TYPE, _owner);
      uint256 _withdrawFee = (_amount * _withdrawPercentage) / FEE_PRECISION;
      _amount = _amount - _withdrawFee; // never overflow here
    } else {
      // @note If it is the last user, some extra rewards still pending.
      // We just ignore it for now.
    }

    totalAssetsStored = _totalAssets - _amount; // never overflow here

    // vault has withdraw fee, we need to subtract from it
    IStakeDAOCRVVault(vault).withdraw(_amount, address(this));
    uint256 _vaultWithdrawFee = FeeCustomization(vault).getFeeRate(VAULT_WITHDRAW_FEE_TYPE, address(this));
    if (_vaultWithdrawFee > 0) {
      _vaultWithdrawFee = (_amount * _vaultWithdrawFee) / FEE_PRECISION;
      _amount = _amount - _vaultWithdrawFee;
    }

    _lockToken(_amount, _receiver);

    emit Withdraw(msg.sender, _receiver, _owner, _amount, _shares);

    return _amount;
  }

  /// @inheritdoc SdCRVLocker
  function _unlockToken(uint256 _amount, address _recipient) internal override {
    SdCRVLocker(vault).withdrawExpired(address(this), address(this));
    IERC20Upgradeable(sdCRV).safeTransfer(_recipient, _amount);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import "./interfaces/IAladdinCompounder.sol";

import "../common/FeeCustomization.sol";

// solhint-disable no-empty-blocks
// solhint-disable reason-string
// solhint-disable not-rely-on-time

abstract contract AladdinCompounder is
  OwnableUpgradeable,
  ReentrancyGuardUpgradeable,
  ERC20Upgradeable,
  FeeCustomization,
  IAladdinCompounder
{
  using SafeMathUpgradeable for uint256;
  using SafeERC20Upgradeable for IERC20Upgradeable;

  /// @notice Emitted when the fee information is updated.
  /// @param _platform The platform address to be updated.
  /// @param _platformPercentage The platform fee percentage to be updated.
  /// @param _bountyPercentage The harvest bounty percentage to be updated.
  /// @param _repayPercentage The repay fee percentage to be updated.
  event UpdateFeeInfo(
    address indexed _platform,
    uint32 _platformPercentage,
    uint32 _bountyPercentage,
    uint32 _repayPercentage
  );

  /// @notice Emitted when the reward period is updated.
  event UpdateRewardPeriodLength(uint256 _length);

  /// @dev The type for withdraw fee, used in FeeCustomization.
  bytes32 internal constant WITHDRAW_FEE_TYPE = keccak256("AladdinCompounder.WithdrawFee");

  /// @dev The maximum percentage of withdraw fee.
  uint256 internal constant MAX_WITHDRAW_FEE = 1e8; // 10%

  /// @dev The maximum percentage of platform fee.
  uint256 internal constant MAX_PLATFORM_FEE = 2e8; // 20%

  /// @dev The maximum percentage of harvest bounty.
  uint256 internal constant MAX_HARVEST_BOUNTY = 1e8; // 10%

  /// @dev Compiler will pack this into single `uint256`.
  struct FeeInfo {
    // The address of recipient of platform fee
    address platform;
    // The percentage of rewards to take for platform on harvest, multipled by 1e9.
    uint32 platformPercentage;
    // The percentage of rewards to take for caller on harvest, multipled by 1e9.
    uint32 bountyPercentage;
    // The percentage of withdraw fee, multipled by 1e9.
    uint32 withdrawPercentage;
  }

  /// @dev Compiler will pack this into single `uint256`.
  struct RewardInfo {
    // The current reward rate per second.
    uint128 rate;
    // The length of reward period in seconds.
    // If the value is zero, the reward will be distributed immediately.
    uint32 periodLength;
    uint48 lastUpdate;
    uint48 finishAt;
  }

  /// @notice The fee information, including platform fee, bounty fee and repay fee.
  FeeInfo public feeInfo;

  /// @notice The reward information, including reward rate,
  RewardInfo public rewardInfo;

  /// @dev The amount of underlying asset recorded.
  uint256 internal totalAssetsStored;

  function _initialize(string memory _name, string memory _symbol) internal {
    OwnableUpgradeable.__Ownable_init();
    ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
    ERC20Upgradeable.__ERC20_init(_name, _symbol);
  }

  /// @inheritdoc IAladdinCompounder
  function asset() public view virtual override returns (address);

  /// @inheritdoc IAladdinCompounder
  function totalAssets() public view virtual override returns (uint256) {
    RewardInfo memory _info = rewardInfo;
    uint256 _period;
    if (block.timestamp > _info.finishAt) {
      // finishAt >= lastUpdate will happen, if `_notifyHarvestedReward` is not called during current period.
      _period = _info.finishAt >= _info.lastUpdate ? _info.finishAt - _info.lastUpdate : 0;
    } else {
      _period = block.timestamp - _info.lastUpdate; // never overflow
    }
    return totalAssetsStored + _period * _info.rate;
  }

  /// @inheritdoc IAladdinCompounder
  function convertToShares(uint256 _assets) public view override returns (uint256) {
    uint256 _totalAssets = totalAssets();
    if (_totalAssets == 0) return _assets;

    uint256 _totalShares = totalSupply();
    return _totalShares.mul(_assets) / _totalAssets;
  }

  /// @inheritdoc IAladdinCompounder
  function convertToAssets(uint256 _shares) public view override returns (uint256) {
    uint256 _totalShares = totalSupply();
    if (_totalShares == 0) return _shares;

    uint256 _totalAssets = totalAssets();
    return _totalAssets.mul(_shares) / _totalShares;
  }

  /// @inheritdoc IAladdinCompounder
  function maxDeposit(address) external pure override returns (uint256) {
    return uint256(-1);
  }

  /// @inheritdoc IAladdinCompounder
  function previewDeposit(uint256 _assets) external view override returns (uint256) {
    return convertToShares(_assets);
  }

  /// @inheritdoc IAladdinCompounder
  function maxMint(address) external pure override returns (uint256) {
    return uint256(-1);
  }

  /// @inheritdoc IAladdinCompounder
  function previewMint(uint256 _shares) external view override returns (uint256) {
    return convertToAssets(_shares);
  }

  /// @inheritdoc IAladdinCompounder
  function maxWithdraw(address) external pure override returns (uint256) {
    return uint256(-1);
  }

  /// @inheritdoc IAladdinCompounder
  function previewWithdraw(uint256 _assets) external view override returns (uint256) {
    uint256 _totalAssets = totalAssets();
    require(_assets <= _totalAssets, "exceed total assets");
    uint256 _shares = convertToShares(_assets);
    if (_assets == _totalAssets) {
      return _shares;
    } else {
      FeeInfo memory _fees = feeInfo;
      return _shares.mul(FEE_PRECISION).div(FEE_PRECISION - _fees.withdrawPercentage);
    }
  }

  /// @inheritdoc IAladdinCompounder
  function maxRedeem(address) external pure override returns (uint256) {
    return uint256(-1);
  }

  /// @inheritdoc IAladdinCompounder
  function previewRedeem(uint256 _shares) external view override returns (uint256) {
    uint256 _totalSupply = totalSupply();
    require(_shares <= _totalSupply, "exceed total supply");

    uint256 _assets = convertToAssets(_shares);
    if (_shares == totalSupply()) {
      return _assets;
    } else {
      FeeInfo memory _fees = feeInfo;
      uint256 _withdrawFee = _assets.mul(_fees.withdrawPercentage) / FEE_PRECISION;
      return _assets - _withdrawFee;
    }
  }

  /********************************** Mutated Functions **********************************/

  /// @inheritdoc IAladdinCompounder
  function deposit(uint256 _assets, address _receiver) public override nonReentrant returns (uint256) {
    if (_assets == uint256(-1)) {
      _assets = IERC20Upgradeable(asset()).balanceOf(msg.sender);
    }

    _distributePendingReward();

    IERC20Upgradeable(asset()).safeTransferFrom(msg.sender, address(this), _assets);

    return _deposit(_assets, _receiver);
  }

  /// @inheritdoc IAladdinCompounder
  function mint(uint256 _shares, address _receiver) external override nonReentrant returns (uint256) {
    _distributePendingReward();

    uint256 _assets = convertToAssets(_shares);
    IERC20Upgradeable(asset()).safeTransferFrom(msg.sender, address(this), _assets);

    _deposit(_assets, _receiver);
    return _assets;
  }

  /// @inheritdoc IAladdinCompounder
  function withdraw(
    uint256 _assets,
    address _receiver,
    address _owner
  ) external override nonReentrant returns (uint256) {
    _distributePendingReward();
    if (_assets == uint256(-1)) {
      _assets = convertToAssets(balanceOf(_owner));
    }

    uint256 _totalAssets = totalAssets();
    require(_assets <= _totalAssets, "exceed total assets");

    uint256 _shares = convertToShares(_assets);
    if (_assets < _totalAssets) {
      uint256 _withdrawPercentage = getFeeRate(WITHDRAW_FEE_TYPE, _owner);
      _shares = _shares.mul(FEE_PRECISION).div(FEE_PRECISION - _withdrawPercentage);
    }

    if (msg.sender != _owner) {
      uint256 _allowance = allowance(_owner, msg.sender);
      require(_allowance >= _shares, "withdraw exceeds allowance");
      if (_allowance != uint256(-1)) {
        // decrease allowance if it is not max
        _approve(_owner, msg.sender, _allowance - _shares);
      }
    }

    _withdraw(_shares, _receiver, _owner);
    return _shares;
  }

  /// @inheritdoc IAladdinCompounder
  function redeem(
    uint256 _shares,
    address _receiver,
    address _owner
  ) public override nonReentrant returns (uint256) {
    if (_shares == uint256(-1)) {
      _shares = balanceOf(_owner);
    }
    _distributePendingReward();

    if (msg.sender != _owner) {
      uint256 _allowance = allowance(_owner, msg.sender);
      require(_allowance >= _shares, "redeem exceeds allowance");
      if (_allowance != uint256(-1)) {
        // decrease allowance if it is not max
        _approve(_owner, msg.sender, _allowance - _shares);
      }
    }

    return _withdraw(_shares, _receiver, _owner);
  }

  /// @notice External function to force update pending reward.
  function checkpoint() external {
    _distributePendingReward();
  }

  /********************************** Restricted Functions **********************************/

  /// @notice Update the fee information.
  /// @param _platform The platform address to be updated.
  /// @param _platformPercentage The platform fee percentage to be updated, multipled by 1e9.
  /// @param _bountyPercentage The harvest bounty percentage to be updated, multipled by 1e9.
  /// @param _withdrawPercentage The withdraw fee percentage to be updated, multipled by 1e9.
  function updateFeeInfo(
    address _platform,
    uint32 _platformPercentage,
    uint32 _bountyPercentage,
    uint32 _withdrawPercentage
  ) external onlyOwner {
    require(_platform != address(0), "zero platform address");
    require(_platformPercentage <= MAX_PLATFORM_FEE, "platform fee too large");
    require(_bountyPercentage <= MAX_HARVEST_BOUNTY, "bounty fee too large");
    require(_withdrawPercentage <= MAX_WITHDRAW_FEE, "withdraw fee too large");

    feeInfo = FeeInfo(_platform, _platformPercentage, _bountyPercentage, _withdrawPercentage);

    emit UpdateFeeInfo(_platform, _platformPercentage, _bountyPercentage, _withdrawPercentage);
  }

  /// @notice Update the reward period length
  /// @param _length The length of the reward period.
  function updateRewardPeriodLength(uint32 _length) external onlyOwner {
    rewardInfo.periodLength = _length;

    emit UpdateRewardPeriodLength(_length);
  }

  /// @notice Update withdraw fee for certain user.
  /// @param _user The address of user to update.
  /// @param _percentage The withdraw fee percentage to be updated, multipled by 1e9.
  function setWithdrawFeeForUser(address _user, uint32 _percentage) external onlyOwner {
    require(_percentage <= MAX_WITHDRAW_FEE, "withdraw fee too large");

    _setFeeCustomization(WITHDRAW_FEE_TYPE, _user, _percentage);
  }

  /********************************** Internal Functions **********************************/

  /// @dev Internal function to deposit assets and transfer to `_receiver`.
  /// @param _assets The amount of asset to deposit.
  /// @param _receiver The address of account who will receive the pool share.
  /// @return Return the amount of pool shares to be received.
  function _deposit(uint256 _assets, address _receiver) internal virtual returns (uint256);

  /// @dev Internal function to withdraw assets from `_owner` and transfer to `_receiver`.
  /// @param _shares The amount of pool share to burn.
  /// @param _receiver The address of account who will receive the assets.
  /// @param _owner The address of user to withdraw from.
  /// @return Return the amount of underlying assets to be received.
  function _withdraw(
    uint256 _shares,
    address _receiver,
    address _owner
  ) internal virtual returns (uint256);

  /// @dev Internal function to distribute pending rewards.
  function _distributePendingReward() internal virtual {
    RewardInfo memory _info = rewardInfo;
    if (_info.periodLength == 0) return;

    uint256 _period;
    if (block.timestamp > _info.finishAt) {
      // finishAt >= lastUpdate will happen, if `_notifyHarvestedReward` is not called during current period.
      _period = _info.finishAt >= _info.lastUpdate ? _info.finishAt - _info.lastUpdate : 0;
    } else {
      _period = block.timestamp - _info.lastUpdate; // never overflow
    }

    uint256 _totalAssetsStored = totalAssetsStored;
    if (_totalAssetsStored == 0) {
      // If the pool is empty, we just do nothing.
      // And if the someone deposit again, the pending rewards will be
      // accumulated into the compounder index.
      // This may have some problems if the pool share is very small.
      // If this happens, we can just redploy the contract.
    } else {
      totalAssetsStored = _totalAssetsStored + _period * _info.rate;
      rewardInfo.lastUpdate = uint48(block.timestamp);
    }
  }

  /// @dev Internal function to notify harvested rewards.
  /// @dev The caller should make sure `_distributePendingReward` is called before.
  /// @param _amount The amount of harvested rewards.
  function _notifyHarvestedReward(uint256 _amount) internal virtual {
    RewardInfo memory _info = rewardInfo;
    if (_info.periodLength == 0) {
      totalAssetsStored = totalAssetsStored.add(_amount);
    } else {
      require(_amount < uint128(-1), "amount overflow");

      if (block.timestamp >= _info.finishAt) {
        _info.rate = uint128(_amount / _info.periodLength);
      } else {
        uint256 _remaining = _info.finishAt - block.timestamp;
        uint256 _leftover = _remaining * _info.rate;
        _info.rate = uint128((_amount + _leftover) / _info.periodLength);
      }

      _info.lastUpdate = uint48(block.timestamp);
      _info.finishAt = uint48(block.timestamp + _info.periodLength);

      rewardInfo = _info;
    }
  }

  /// @inheritdoc FeeCustomization
  function _defaultFeeRate(bytes32) internal view override returns (uint256) {
    return feeInfo.withdrawPercentage;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

interface IZap {
  function zap(
    address _fromToken,
    uint256 _amountIn,
    address _toToken,
    uint256 _minOut
  ) external payable returns (uint256);

  function zapWithRoutes(
    address _fromToken,
    uint256 _amountIn,
    address _toToken,
    uint256[] calldata _routes,
    uint256 _minOut
  ) external payable returns (uint256);

  function zapFrom(
    address _fromToken,
    uint256 _amountIn,
    address _toToken,
    uint256 _minOut
  ) external payable returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;
pragma abicoder v2;

// solhint-disable not-rely-on-time

abstract contract SdCRVLocker {
  /// @notice Emmited when someone withdraw staking token from contract.
  /// @param _owner The address of the owner of the staking token.
  /// @param _recipient The address of the recipient of the locked staking token.
  /// @param _amount The amount of staking token withdrawn.
  /// @param _expiredAt The timestamp in second then the lock expired
  event Lock(address indexed _owner, address indexed _recipient, uint256 _amount, uint256 _expiredAt);

  /// @notice Emitted when someone withdraw expired locked staking token.
  /// @param _owner The address of the owner of the locked staking token.
  /// @param _recipient The address of the recipient of the staking token.
  /// @param _amount The amount of staking token withdrawn.
  event WithdrawExpired(address indexed _owner, address indexed _recipient, uint256 _amount);

  /// @dev Compiler will pack this into single `uint256`.
  struct LockedBalance {
    // The amount of staking token locked.
    uint128 amount;
    // The timestamp in seconds when the lock expired.
    uint128 expireAt;
  }

  /// @dev The number of seconds in 1 day.
  uint256 private constant DAYS = 86400;

  /// @dev Mapping from user address to list of locked staking tokens.
  mapping(address => LockedBalance[]) private locks;

  /// @dev Mapping from user address to next index in `LockedBalance` lists.
  mapping(address => uint256) private nextLockIndex;

  /// @notice The number of seconds to lock for withdrawing assets from the contract.
  function withdrawLockTime() public view virtual returns (uint256);

  /// @notice Return the list of locked staking token in the contract.
  /// @param _user The address of user to query.
  /// @return _locks The list of `LockedBalance` of the user.
  function getUserLocks(address _user) external view returns (LockedBalance[] memory _locks) {
    uint256 _nextIndex = nextLockIndex[_user];
    uint256 _length = locks[_user].length;
    _locks = new LockedBalance[](_length - _nextIndex);
    for (uint256 i = _nextIndex; i < _length; i++) {
      _locks[i - _nextIndex] = locks[_user][i];
    }
  }

  /// @notice Withdraw all expired locks from contract.
  /// @param _user The address of user to withdraw.
  /// @param _recipient The address of recipient who will receive the token.
  /// @return _amount The amount of staking token withdrawn.
  function withdrawExpired(address _user, address _recipient) external returns (uint256 _amount) {
    if (_user != msg.sender) {
      require(_recipient == _user, "withdraw from others to others");
    }

    LockedBalance[] storage _locks = locks[_user];
    uint256 _nextIndex = nextLockIndex[_user];
    uint256 _length = _locks.length;
    while (_nextIndex < _length) {
      LockedBalance memory _lock = _locks[_nextIndex];
      // The list may not be ordered by expireAt, since `withdrawLockTime` could be changed.
      // However, we will still wait the first one to expire just for the sake of simplicity.
      if (_lock.expireAt > block.timestamp) break;
      _amount += _lock.amount;

      delete _locks[_nextIndex]; // clear to refund gas
      _nextIndex += 1;
    }
    nextLockIndex[_user] = _nextIndex;

    _unlockToken(_amount, _recipient);

    emit WithdrawExpired(_user, _recipient, _amount);
  }

  /// @dev Internal function to lock staking token.
  /// @param _amount The amount of staking token to lock.
  /// @param _recipient The address of recipient who will receive the locked token.
  function _lockToken(uint256 _amount, address _recipient) internal {
    uint256 _expiredAt = block.timestamp + withdrawLockTime();
    // ceil up to 86400 seconds
    _expiredAt = ((_expiredAt + DAYS - 1) / DAYS) * DAYS;

    uint256 _length = locks[_recipient].length;
    if (_length == 0 || locks[_recipient][_length - 1].expireAt != _expiredAt) {
      locks[_recipient].push(LockedBalance({ amount: uint128(_amount), expireAt: uint128(_expiredAt) }));
    } else {
      locks[_recipient][_length - 1].amount += uint128(_amount);
    }

    emit Lock(msg.sender, _recipient, _amount, _expiredAt);
  }

  /// @dev Internal function to unlock staking token.
  /// @param _amount The amount of staking token to unlock.
  /// @param _recipient The address of recipient who will receive the unlocked token.
  function _unlockToken(uint256 _amount, address _recipient) internal virtual;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;
pragma abicoder v2;

import "./IStakeDAOMultiMerkleStash.sol";
import "./IStakeDAOVault.sol";

interface IStakeDAOCRVVault is IStakeDAOVault {
  /// @notice Emitted when the withdraw lock time is updated.
  /// @param _withdrawLockTime The new withdraw lock time in seconds.
  event UpdateWithdrawLockTime(uint256 _withdrawLockTime);

  /// @notice Emitted when someone harvest pending sdCRV bribe rewards.
  /// @param _token The address of the reward token.
  /// @param _reward The amount of harvested rewards.
  /// @param _platformFee The amount of platform fee taken.
  /// @param _boostFee The amount SDT for veSDT boost delegation fee.
  event HarvestBribe(address _token, uint256 _reward, uint256 _platformFee, uint256 _boostFee);

  /// @notice Deposit some CRV to the contract.
  /// @dev use `_amount=-1` to deposit all tokens.
  /// @param _amount The amount of staking token to deposit.
  /// @param _recipient The address of recipient who will receive the deposited staking token.
  /// @param _minOut The minimum amount of sdCRV should received.
  /// @return _amountOut The amount of sdCRV received.
  function depositWithCRV(
    uint256 _amount,
    address _recipient,
    uint256 _minOut
  ) external returns (uint256 _amountOut);

  /// @notice Deposit some CRV to the contract.
  /// @dev use `_amount=-1` to deposit all tokens.
  /// @param _amount The amount of staking token to deposit.
  /// @param _recipient The address of recipient who will receive the deposited staking token.
  function depositWithSdVeCRV(uint256 _amount, address _recipient) external;

  /// @notice Harvest sdCRV bribes.
  /// @dev No harvest bounty when others call this function.
  /// @param _claims The claim parameters passing to StakeDAOMultiMerkleStash contract.
  function harvestBribes(IStakeDAOMultiMerkleStash.claimParam[] memory _claims) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

// solhint-disable no-inline-assembly

abstract contract FeeCustomization {
  /// @notice Emitted when a fee customization is set.
  /// @param _feeType The type of fee to set.
  /// @param _user The address of user to set.
  /// @param _rate The fee rate for the user.
  event CustomizeFee(bytes32 _feeType, address _user, uint256 _rate);

  /// @notice Emitted when a fee customization is cancled.
  /// @param _feeType The type of fee to cancle.
  /// @param _user The address of user to cancle.
  event CancleCustomizeFee(bytes32 _feeType, address _user);

  /// @dev The fee denominator used for rate calculation.
  uint256 internal constant FEE_PRECISION = 1e9;

  /// @dev The salt used to compute storage slot.
  bytes32 private constant SALT = keccak256("FeeCustomization");

  /// @notice Return the fee rate for the user
  /// @param _feeType The type of fee to query.
  /// @param _user The address of user to query.
  /// @return rate The rate of fee for the user, multiplied by 1e9
  function getFeeRate(bytes32 _feeType, address _user) public view returns (uint256 rate) {
    rate = _defaultFeeRate(_feeType);

    (uint8 _customized, uint32 _rate) = _loadFeeCustomization(_feeType, _user);
    if (_customized == 1) {
      rate = _rate;
    }
  }

  /// @dev Internal function to set customized fee for user.
  /// @param _feeType The type of fee to update.
  /// @param _user The address of user to update.
  /// @param _rate The fee rate to update.
  function _setFeeCustomization(
    bytes32 _feeType,
    address _user,
    uint32 _rate
  ) internal {
    require(_rate <= FEE_PRECISION, "rate too large");

    uint256 _slot = _computeStorageSlot(_feeType, _user);
    uint256 _encoded = _encode(1, _rate);
    assembly {
      sstore(_slot, _encoded)
    }

    emit CustomizeFee(_feeType, _user, _rate);
  }

  /// @dev Internal function to cancel fee customization.
  /// @param _feeType The type of fee to update.
  /// @param _user The address of user to update.
  function _cancleFeeCustomization(bytes32 _feeType, address _user) internal {
    uint256 _slot = _computeStorageSlot(_feeType, _user);
    assembly {
      sstore(_slot, 0)
    }

    emit CancleCustomizeFee(_feeType, _user);
  }

  /// @dev Return the default fee rate for certain type.
  /// @param _feeType The type of fee to query.
  /// @return rate The default rate of fee, multiplied by 1e9
  function _defaultFeeRate(bytes32 _feeType) internal view virtual returns (uint256 rate);

  /// @dev Internal function to load fee customization from storage.
  /// @param _feeType The type of fee to query.
  /// @param _user The address of user to query.
  /// @return customized Whether there is a customization.
  /// @return rate The customized fee rate, multiplied by 1e9.
  function _loadFeeCustomization(bytes32 _feeType, address _user) private view returns (uint8 customized, uint32 rate) {
    uint256 _slot = _computeStorageSlot(_feeType, _user);
    uint256 _encoded;
    assembly {
      _encoded := sload(_slot)
    }
    (customized, rate) = _decode(_encoded);
  }

  /// @dev Internal function to compute storage slot for fee storage.
  /// @param _feeType The type of fee.
  /// @param _user The address of user.
  /// @return slot The destination storage slot.
  function _computeStorageSlot(bytes32 _feeType, address _user) private pure returns (uint256 slot) {
    bytes32 salt = SALT;
    assembly {
      mstore(0x00, _feeType)
      mstore(0x20, xor(_user, salt))
      slot := keccak256(0x00, 0x40)
    }
  }

  /// @dev Internal function to encode customized fee data. The encoding is
  /// low ---------------------> high
  /// |   8 bits   | 32 bits | 216 bits |
  /// | customized |   rate  | reserved |
  ///
  /// @param customized If it is 0, there is no customization; if it is 1, there is customization.
  /// @param rate The customized fee rate, multiplied by 1e9.
  function _encode(uint8 customized, uint32 rate) private pure returns (uint256 encoded) {
    encoded = (uint256(rate) << 8) | uint256(customized);
  }

  /// @dev Internal function to decode data.
  /// @param _encoded The data to decode.
  /// @return customized Whether there is a customization.
  /// @return rate The customized fee rate, multiplied by 1e9.
  function _decode(uint256 _encoded) private pure returns (uint8 customized, uint32 rate) {
    customized = uint8(_encoded & 0xff);
    rate = uint32((_encoded >> 8) & 0xffffffff);
  }
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

pragma solidity ^0.7.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../../utils/ContextUpgradeable.sol";
import "./IERC20Upgradeable.sol";
import "../../math/SafeMathUpgradeable.sol";
import "../../proxy/Initializable.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {
    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    uint256[44] private __gap;
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
import "../proxy/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
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

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
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

pragma solidity ^0.7.6;
pragma abicoder v2;

interface IStakeDAOMultiMerkleStash {
  // solhint-disable-next-line contract-name-camelcase
  struct claimParam {
    address token;
    uint256 index;
    uint256 amount;
    bytes32[] merkleProof;
  }

  function isClaimed(address token, uint256 index) external view returns (bool);

  function merkleRoot(address token) external returns (address);

  function claim(
    address token,
    uint256 index,
    address account,
    uint256 amount,
    bytes32[] calldata merkleProof
  ) external;

  function claimMulti(address account, claimParam[] calldata claims) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

interface IStakeDAOVault {
  /// @notice Emitted when user deposit staking token to the contract.
  /// @param _owner The address of the owner of the staking token.
  /// @param _recipient The address of the recipient of the staking token.
  /// @param _amount The amount of staking token deposited.
  event Deposit(address indexed _owner, address indexed _recipient, uint256 _amount);

  /// @notice Emitted when user withdraw staking token from the contract.
  /// @param _owner The address of the owner of the staking token.
  /// @param _recipient The address of the recipient of the staking token.
  /// @param _amount The amount of staking token withdrawn.
  /// @param _fee The amount of withdraw fee.
  event Withdraw(address indexed _owner, address indexed _recipient, uint256 _amount, uint256 _fee);

  /// @notice Emitted when user claim pending rewards from the contract.
  /// @param _owner The address of the owner of the staking token.
  /// @param _recipient The address of the recipient of the pending rewards.
  /// @param _amounts The list of pending reward amounts.
  event Claim(address indexed _owner, address indexed _recipient, uint256[] _amounts);

  /// @notice Emitted when someone harvest pending rewards.
  /// @param _caller The address of the caller.
  /// @param _rewards The list of harvested rewards.
  /// @param _bounties The list of harvest bounty given to caller.
  /// @param _platformFees The list of platform fee taken.
  /// @param _boostFee The amount SDT for veSDT boost delegation fee.
  event Harvest(
    address indexed _caller,
    uint256[] _rewards,
    uint256[] _bounties,
    uint256[] _platformFees,
    uint256 _boostFee
  );

  /// @notice Return the amount of staking token staked in the contract.
  function totalSupply() external view returns (uint256);

  /// @notice Return the amount of staking token staked in the contract for some user.
  /// @param _user The address of user to query.
  function balanceOf(address _user) external view returns (uint256);

  /// @notice Deposit some staking token to the contract.
  /// @dev use `_amount=-1` to deposit all tokens.
  /// @param _amount The amount of staking token to deposit.
  /// @param _recipient The address of recipient who will receive the deposited staking token.
  function deposit(uint256 _amount, address _recipient) external;

  /// @notice Withdraw some staking token from the contract.
  /// @dev use `_amount=-1` to withdraw all tokens.
  /// @param _amount The amount of staking token to withdraw.
  /// @param _recipient The address of recipient who will receive the withdrawn staking token.
  function withdraw(uint256 _amount, address _recipient) external;

  /// @notice Claim all pending rewards from some user.
  /// @param _user The address of user to claim.
  /// @param _recipient The address of recipient who will receive the rewards.
  /// @return _amounts The list of amount of rewards claimed.
  function claim(address _user, address _recipient) external returns (uint256[] memory _amounts);

  /// @notice Harvest pending reward from the contract.
  /// @param _recipient The address of recipient who will receive the harvest bounty.
  function harvest(address _recipient) external;

  /// @notice Update the user information.
  /// @param _user The address of user to update.
  function checkpoint(address _user) external;
}