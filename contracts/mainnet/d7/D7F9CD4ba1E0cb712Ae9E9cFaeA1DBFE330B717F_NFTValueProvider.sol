// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "../interfaces/IAggregatorV3Interface.sol";
import "../interfaces/IUniswapV2Oracle.sol";
import "../interfaces/IJPEGOraclesAggregator.sol";
import "../interfaces/IJPEGCardsCigStaking.sol";

contract NFTValueProvider is ReentrancyGuardUpgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    error InvalidNFTType(bytes32 nftType);
    error InvalidRate(Rate rate);
    error InvalidUnlockTime(uint256 unlockTime);
    error ExistingLock(uint256 index);
    error InvalidAmount(uint256 amount);
    error InvalidOracleResults();
    error Unauthorized();
    error ZeroAddress();
    error InvalidLength();

    event DaoFloorChanged(uint256 newFloor);

    event JPEGLocked(
        address indexed owner,
        uint256 indexed index,
        uint256 amount,
        uint256 unlockTime,
        bool isTraitBoost
    );
    event JPEGUnlocked(
        address indexed owner,
        uint256 indexed index,
        uint256 amount,
        bool isTraitBoost
    );

    struct Rate {
        uint128 numerator;
        uint128 denominator;
    }

    struct JPEGLock {
        address owner;
        uint256 unlockAt;
        uint256 lockedValue;
    }

    /// @notice The JPEG floor oracles aggregator
    IJPEGOraclesAggregator public aggregator;
    /// @notice If true, the floor price won't be fetched using the Chainlink oracle but
    /// a value set by the DAO will be used instead
    bool public daoFloorOverride;
    /// @notice Value of floor set by the DAO. Only used if `daoFloorOverride` is true
    uint256 private overriddenFloorValueETH;

    /// @notice The JPEG token
    IERC20Upgradeable public jpeg;
    /// @notice Value of the JPEG to lock for trait boost based on the NFT value increase
    /// @custom:oz-renamed-from valueIncreaseLockRate
    Rate public traitBoostLockRate;
    /// @notice Minimum amount of JPEG to lock for trait boost
    uint256 public minJPEGToLock;

    mapping(uint256 => bytes32) public nftTypes;
    mapping(bytes32 => Rate) public nftTypeValueMultiplier;
    /// @custom:oz-renamed-from lockPositions
    mapping(uint256 => JPEGLock) public traitBoostPositions;
    mapping(uint256 => JPEGLock) public ltvBoostPositions;

    Rate public baseCreditLimitRate;
    Rate public baseLiquidationLimitRate;
    Rate public cigStakedRateIncrease;
    Rate public jpegLockedRateIncrease;

    /// @notice Value of the JPEG to lock for ltv boost based on the NFT ltv increase
    Rate public ltvBoostLockRate;

    /// @notice JPEGCardsCigStaking, cig stakers get an higher credit limit rate and liquidation limit rate.
    /// Immediately reverts to normal rates if the cig is unstaked.
    IJPEGCardsCigStaking public cigStaking;

    /// @notice This function is only called once during deployment of the proxy contract. It's not called after upgrades.
    /// @param _jpeg The JPEG token
    /// @param _aggregator The JPEG floor oracles aggregator
    /// @param _cigStaking The cig staking address
    /// @param _baseCreditLimitRate The base credit limit rate
    /// @param _baseLiquidationLimitRate The base liquidation limit rate
    /// @param _cigStakedRateIncrease The liquidation and credit limit rate increases for users staking a cig in the cigStaking contract
    /// @param _jpegLockedRateIncrease The liquidation and credit limit rate increases for users that locked JPEG for LTV boost
    /// @param _traitBoostLockRate The rate used to calculate the amount of JPEG to lock for trait boost based on the NFT's value increase
    /// @param _ltvBoostLockRate The rate used to calculate the amount of JPEG to lock for LTV boost based on the NFT's credit limit increase
    /// @param _minJPEGToLock Minimum amount of JPEG to lock to apply the trait boost
    function initialize(
        IERC20Upgradeable _jpeg,
        IJPEGOraclesAggregator _aggregator,
        IJPEGCardsCigStaking _cigStaking,
        Rate calldata _baseCreditLimitRate,
        Rate calldata _baseLiquidationLimitRate,
        Rate calldata _cigStakedRateIncrease,
        Rate calldata _jpegLockedRateIncrease,
        Rate calldata _traitBoostLockRate,
        Rate calldata _ltvBoostLockRate,
        uint256 _minJPEGToLock
    ) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();

        if (address(_jpeg) == address(0)) revert ZeroAddress();
        if (address(_aggregator) == address(0)) revert ZeroAddress();
        if (address(_cigStaking) == address(0)) revert ZeroAddress();

        _validateRateBelowOne(_baseCreditLimitRate);
        _validateRateBelowOne(_baseLiquidationLimitRate);
        _validateRateBelowOne(_cigStakedRateIncrease);
        _validateRateBelowOne(_jpegLockedRateIncrease);
        _validateRateBelowOne(_traitBoostLockRate);
        _validateRateBelowOne(_ltvBoostLockRate);

        if (!_greaterThan(_baseLiquidationLimitRate, _baseCreditLimitRate))
            revert InvalidRate(_baseLiquidationLimitRate);

        _validateRateBelowOne(
            _rateSum(
                _rateSum(_baseLiquidationLimitRate, _cigStakedRateIncrease),
                _jpegLockedRateIncrease
            )
        );

        jpeg = _jpeg;
        aggregator = _aggregator;
        cigStaking = _cigStaking;
        baseCreditLimitRate = _baseCreditLimitRate;
        baseLiquidationLimitRate = _baseLiquidationLimitRate;
        cigStakedRateIncrease = _cigStakedRateIncrease;
        jpegLockedRateIncrease = _jpegLockedRateIncrease;
        traitBoostLockRate = _traitBoostLockRate;
        ltvBoostLockRate = _ltvBoostLockRate;
        minJPEGToLock = _minJPEGToLock;
    }

    /// @notice This function is only called once during the upgrade process by the {ProxyAdmin} contract.
    function finalizeUpgrade(
        IJPEGCardsCigStaking _cigStaking,
        Rate calldata _baseCreditLimitRate,
        Rate calldata _baseLiquidationLimitRate,
        Rate calldata _cigStakedRateIncrease,
        Rate calldata _jpegLockedRateIncrease,
        Rate calldata _ltvBoostLockRate
    ) external {
        if (address(cigStaking) != address(0)) revert Unauthorized();

        if (address(_cigStaking) == address(0)) revert ZeroAddress();

        _validateRateBelowOne(_baseCreditLimitRate);
        _validateRateBelowOne(_baseLiquidationLimitRate);
        _validateRateBelowOne(_cigStakedRateIncrease);
        _validateRateBelowOne(_jpegLockedRateIncrease);
        _validateRateBelowOne(_ltvBoostLockRate);

        if (!_greaterThan(_baseLiquidationLimitRate, _baseCreditLimitRate))
            revert InvalidRate(_baseLiquidationLimitRate);

        _validateRateBelowOne(
            _rateSum(
                _rateSum(_baseLiquidationLimitRate, _cigStakedRateIncrease),
                _jpegLockedRateIncrease
            )
        );

        cigStaking = _cigStaking;
        baseCreditLimitRate = _baseCreditLimitRate;
        baseLiquidationLimitRate = _baseLiquidationLimitRate;
        cigStakedRateIncrease = _cigStakedRateIncrease;
        jpegLockedRateIncrease = _jpegLockedRateIncrease;
        ltvBoostLockRate = _ltvBoostLockRate;
    }

    /// @param _owner The owner of the NFT at index `_nftIndex` (or the owner of the associated position in the vault)
    /// @param _nftIndex The index of the NFT to return the credit limit rate for
    /// @return The credit limit rate for the NFT with index `_nftIndex`
    function getCreditLimitRate(address _owner, uint256 _nftIndex)
        public
        view
        returns (Rate memory)
    {
        return _rateAfterBoosts(baseCreditLimitRate, _owner, _nftIndex);
    }

    /// @param _owner The owner of the NFT at index `_nftIndex` (or the owner of the associated position in the vault)
    /// @param _nftIndex The index of the NFT to return the liquidation limit rate for
    /// @return The liquidation limit rate for the NFT with index `_nftIndex`
    function getLiquidationLimitRate(address _owner, uint256 _nftIndex)
        public
        view
        returns (Rate memory)
    {
        return _rateAfterBoosts(baseLiquidationLimitRate, _owner, _nftIndex);
    }

    /// @param _owner The owner of the NFT at index `_nftIndex` (or the owner of the associated position in the vault)
    /// @param _nftIndex The index of the NFT to return the credit limit for
    /// @return The credit limit for the NFT with index `_nftIndex`, in ETH
    function getCreditLimitETH(address _owner, uint256 _nftIndex)
        external
        view
        returns (uint256)
    {
        Rate memory creditLimitRate = getCreditLimitRate(_owner, _nftIndex);
        return
            (getNFTValueETH(_nftIndex) * creditLimitRate.numerator) /
            creditLimitRate.denominator;
    }

    /// @param _owner The owner of the NFT at index `_nftIndex` (or the owner of the associated position in the vault)
    /// @param _nftIndex The index of the NFT to return the liquidation limit for
    /// @return The liquidation limit for the NFT with index `_nftIndex`, in ETH
    function getLiquidationLimitETH(address _owner, uint256 _nftIndex)
        external
        view
        returns (uint256)
    {
        Rate memory liquidationLimitRate = getLiquidationLimitRate(
            _owner,
            _nftIndex
        );
        return
            (getNFTValueETH(_nftIndex) * liquidationLimitRate.numerator) /
            liquidationLimitRate.denominator;
    }

    /// @param _nftType The NFT type to calculate the JPEG lock amount for
    /// @param _jpegPrice The JPEG price in ETH (18 decimals)
    /// @return The JPEG to lock for the specified `_nftType`
    function calculateTraitBoostLock(bytes32 _nftType, uint256 _jpegPrice)
        public
        view
        returns (uint256)
    {
        return
            _calculateTraitBoostLock(
                traitBoostLockRate,
                _nftType,
                getFloorETH(),
                _jpegPrice
            );
    }

    /// @param _nftIndex The index of the NFT to calculate the JPEG lock amount for
    /// @param _jpegPrice The JPEG price in ETH (18 decimals)
    /// @return The JPEG to lock for the specified `_nftIndex`
    function calculateLTVBoostLock(uint256 _nftIndex, uint256 _jpegPrice)
        external
        view
        returns (uint256)
    {
        uint256 nftValue = getNFTValueETH(_nftIndex);

        Rate memory creditLimitRate = baseCreditLimitRate;
        return
            _calculateLTVBoostLock(
                creditLimitRate,
                _rateSum(creditLimitRate, jpegLockedRateIncrease),
                ltvBoostLockRate,
                nftValue,
                _jpegPrice
            );
    }

    /// @return The floor value for the collection, in ETH.
    function getFloorETH() public view returns (uint256) {
        if (daoFloorOverride) return overriddenFloorValueETH;
        else return aggregator.getFloorETH();
    }

    /// @param _nftIndex The NFT to return the value of
    /// @return The value in ETH of the NFT at index `_nftIndex`, with 18 decimals.
    function getNFTValueETH(uint256 _nftIndex) public view returns (uint256) {
        uint256 floor = getFloorETH();

        bytes32 nftType = nftTypes[_nftIndex];
        if (
            nftType != bytes32(0) &&
            traitBoostPositions[_nftIndex].unlockAt > block.timestamp
        ) {
            Rate memory multiplier = nftTypeValueMultiplier[nftType];
            return (floor * multiplier.numerator) / multiplier.denominator;
        } else return floor;
    }

    /// @notice Allows users to lock JPEG tokens to unlock the trait boost for a single non floor NFT.
    /// The trait boost is a multiplicative value increase relative to the collection's floor.
    /// The value increase depends on the NFT's traits and it's set by the DAO.
    /// The ETH value of the JPEG to lock is calculated by applying the `traitBoostLockRate` rate to the NFT's new credit limit.
    /// The unlock time is set by the user and has to be greater than `block.timestamp` and the previous unlock time.
    /// After the lock expires, the boost is revoked and the NFT's value goes back to floor.
    /// If a boosted position is closed or liquidated, the JPEG remains locked and the boost will still be applied in case the NFT
    /// is deposited again, even in case of a different owner. The locked JPEG will only be claimable by the original lock creator
    /// once the lock expires. If the lock is renewed by the new owner, the JPEG from the previous lock will be sent back to the original
    /// lock creator.
    /// @dev emits multiple {JPEGLocked} events
    /// @param _nftIndexes The indexes of the non floor NFTs to boost
    /// @param _unlocks The locks expiration times
    function applyTraitBoost(
        uint256[] calldata _nftIndexes,
        uint256[] calldata _unlocks
    ) external nonReentrant {
        _lockJPEG(_nftIndexes, _unlocks, true);
    }

    /// @notice Allows users to lock JPEG tokens to unlock the LTV boost for a single NFT.
    /// The LTV boost is an increase of an NFT's credit and liquidation limit rates.
    /// The ETH value of the JPEG to lock is calculated by applying the `ltvBoostLockRate` rate to the difference between the new and the old credit limits.
    /// See {applyTraitBoost} for details on the locking and unlocking mechanism.
    /// @dev emits multiple {JPEGLocked} events
    /// @param _nftIndexes The indexes of the NFTs to boost
    /// @param _unlocks The locks expiration times
    function applyLTVBoost(
        uint256[] calldata _nftIndexes,
        uint256[] calldata _unlocks
    ) external nonReentrant {
        _lockJPEG(_nftIndexes, _unlocks, false);
    }

    /// @notice Allows trait boost lock creators to unlock the JPEG associated to the NFT at index `_nftIndex`, provided the lock expired.
    /// @dev emits a {JPEGUnlocked} event
    /// @param _nftIndexes The indexes of the NFTs holding the locks.
    function withdrawTraitBoost(uint256[] calldata _nftIndexes)
        external
        nonReentrant
    {
        _unlockJPEG(traitBoostPositions, _nftIndexes, true);
    }

    /// @notice Allows ltv boost lock creators to unlock the JPEG associated to the NFT at index `_nftIndex`, provided the lock expired.
    /// @dev emits a {JPEGUnlocked} event
    /// @param _nftIndexes The indexes of the NFTs holding the locks.
    function withdrawLTVBoost(uint256[] calldata _nftIndexes)
        external
        nonReentrant
    {
        _unlockJPEG(ltvBoostPositions, _nftIndexes, false);
    }

    function addLocks(
        uint256[] calldata _nftIndexes,
        JPEGLock[] calldata _locks
    ) external onlyOwner {
        if (_nftIndexes.length != _locks.length || _nftIndexes.length == 0)
            revert InvalidLength();

        for (uint256 i; i < _nftIndexes.length; ++i) {
            if (traitBoostPositions[_nftIndexes[i]].owner != address(0))
                revert ExistingLock(_nftIndexes[i]);
            traitBoostPositions[_nftIndexes[i]] = _locks[i];
        }
    }

    /// @notice Allows the DAO to bypass the floor oracle and override the NFT floor value
    /// @param _newFloor The new floor
    function overrideFloor(uint256 _newFloor) external onlyOwner {
        if (_newFloor == 0) revert InvalidAmount(_newFloor);
        overriddenFloorValueETH = _newFloor;
        daoFloorOverride = true;

        emit DaoFloorChanged(_newFloor);
    }

    /// @notice Allows the DAO to stop overriding floor
    function disableFloorOverride() external onlyOwner {
        daoFloorOverride = false;
    }

    /// @notice Allows the DAO to change the multiplier of an NFT category
    /// @param _type The category hash
    /// @param _multiplier The new multiplier
    function setNFTTypeMultiplier(bytes32 _type, Rate calldata _multiplier)
        external
        onlyOwner
    {
        if (_type == bytes32(0)) revert InvalidNFTType(_type);
        _validateRateAboveOne(_multiplier);
        nftTypeValueMultiplier[_type] = _multiplier;
    }

    /// @notice Allows the DAO to add an NFT to a specific price category
    /// @param _nftIndexes The indexes to add to the category
    /// @param _type The category hash
    function setNFTType(uint256[] calldata _nftIndexes, bytes32 _type)
        external
        onlyOwner
    {
        if (_type != bytes32(0) && nftTypeValueMultiplier[_type].numerator == 0)
            revert InvalidNFTType(_type);

        for (uint256 i; i < _nftIndexes.length; ++i) {
            nftTypes[_nftIndexes[i]] = _type;
        }
    }

    function setBaseCreditLimitRate(Rate memory _baseCreditLimitRate)
        external
        onlyOwner
    {
        _validateRateBelowOne(_baseCreditLimitRate);
        if (!_greaterThan(baseLiquidationLimitRate, _baseCreditLimitRate))
            revert InvalidRate(_baseCreditLimitRate);

        baseCreditLimitRate = _baseCreditLimitRate;
    }

    function setBaseLiquidationLimitRate(Rate memory _liquidationLimitRate)
        external
        onlyOwner
    {
        _validateRateBelowOne(_liquidationLimitRate);

        if (!_greaterThan(_liquidationLimitRate, baseCreditLimitRate))
            revert InvalidRate(_liquidationLimitRate);

        _validateRateBelowOne(
            _rateSum(
                _rateSum(_liquidationLimitRate, cigStakedRateIncrease),
                jpegLockedRateIncrease
            )
        );

        baseLiquidationLimitRate = _liquidationLimitRate;
    }

    function setCigStakedRateIncrease(Rate memory _cigStakedRateIncrease)
        external
        onlyOwner
    {
        _validateRateBelowOne(_cigStakedRateIncrease);
        _validateRateBelowOne(
            _rateSum(
                _rateSum(baseLiquidationLimitRate, _cigStakedRateIncrease),
                jpegLockedRateIncrease
            )
        );

        cigStakedRateIncrease = _cigStakedRateIncrease;
    }

    function setJPEGLockedRateIncrease(Rate memory _jpegLockedRateIncrease)
        external
        onlyOwner
    {
        _validateRateBelowOne(_jpegLockedRateIncrease);
        _validateRateBelowOne(
            _rateSum(
                _rateSum(baseLiquidationLimitRate, cigStakedRateIncrease),
                _jpegLockedRateIncrease
            )
        );

        jpegLockedRateIncrease = _jpegLockedRateIncrease;
    }

    function setTraitBoostLockRate(Rate memory _traitBoostLockRate)
        external
        onlyOwner
    {
        _validateRateBelowOne(_traitBoostLockRate);
        traitBoostLockRate = _traitBoostLockRate;
    }

    function setLTVBoostLockRate(Rate memory _ltvBoostLockRate)
        external
        onlyOwner
    {
        _validateRateBelowOne(_ltvBoostLockRate);
        ltvBoostLockRate = _ltvBoostLockRate;
    }

    /// @dev see {applyTraitBoost} and {applyLTVBoost}
    function _lockJPEG(
        uint256[] memory _nftIndexes,
        uint256[] memory _unlocks,
        bool _isTraitBoost
    ) internal {
        if (_nftIndexes.length != _unlocks.length) revert InvalidLength();

        Rate memory creditLimitRate;
        Rate memory boostedCreditLimitRate;
        Rate memory lockRate;

        if (_isTraitBoost) {
            lockRate = traitBoostLockRate;
        } else {
            creditLimitRate = baseCreditLimitRate;
            boostedCreditLimitRate = _rateSum(
                creditLimitRate,
                jpegLockedRateIncrease
            );
            lockRate = ltvBoostLockRate;
        }

        IERC20Upgradeable _jpeg = jpeg;
        uint256 floor = getFloorETH();
        uint256 minJPEG = minJPEGToLock;
        uint256 jpegPrice = _jpegPriceETH();
        uint256 requiredJpeg;
        uint256 jpegToRefund;
        for (uint256 i; i < _nftIndexes.length; ++i) {
            uint256 index = _nftIndexes[i];
            uint256 unlockAt = _unlocks[i];

            uint256 jpegToLock;

            JPEGLock storage jpegLock;
            if (_isTraitBoost) {
                jpegLock = traitBoostPositions[index];
                bytes32 nftType = nftTypes[index];
                if (nftType == bytes32(0)) revert InvalidNFTType(nftType);
                jpegToLock = _calculateTraitBoostLock(
                    lockRate,
                    nftType,
                    floor,
                    jpegPrice
                );

                if (minJPEG > jpegToLock) revert InvalidNFTType(nftType);

                //dirty workaround to prevent stack too deep errors
                _emitJPEGLockedTraitBoost(index, jpegToLock, unlockAt);
            } else {
                jpegLock = ltvBoostPositions[index];
                jpegToLock = _calculateLTVBoostLock(
                    creditLimitRate,
                    boostedCreditLimitRate,
                    lockRate,
                    floor,
                    jpegPrice
                );
                if (minJPEG > jpegToLock) jpegToLock = minJPEG;

                //dirty workaround to prevent stack too deep errors
                _emitJPEGLockedLTVBoost(index, jpegToLock, unlockAt);
            }

            if (block.timestamp >= unlockAt || jpegLock.unlockAt >= unlockAt)
                revert InvalidUnlockTime(unlockAt);

            uint256 previousLockValue = jpegLock.lockedValue;
            address previousOwner = jpegLock.owner;

            jpegLock.lockedValue = jpegToLock;
            jpegLock.unlockAt = unlockAt;
            jpegLock.owner = msg.sender;

            requiredJpeg += jpegToLock;

            if (previousOwner == msg.sender) jpegToRefund += previousLockValue;
            else if (previousLockValue > 0)
                _jpeg.safeTransfer(previousOwner, previousLockValue);
        }

        if (requiredJpeg > jpegToRefund)
            _jpeg.safeTransferFrom(
                msg.sender,
                address(this),
                requiredJpeg - jpegToRefund
            );
        else if (requiredJpeg < jpegToRefund)
            _jpeg.safeTransfer(msg.sender, jpegToRefund - requiredJpeg);
    }

    /// @dev This function is used in {_lockJPEG} to prevent stack too deep errors
    function _emitJPEGLockedTraitBoost(
        uint256 _nftIndex,
        uint256 _jpegToLock,
        uint256 _unlockAt
    ) internal {
        emit JPEGLocked(msg.sender, _nftIndex, _jpegToLock, _unlockAt, true);
    }

    /// @dev This function is used in {_lockJPEG} to prevent stack too deep errors
    function _emitJPEGLockedLTVBoost(
        uint256 _nftIndex,
        uint256 _jpegToLock,
        uint256 _unlockAt
    ) internal {
        emit JPEGLocked(msg.sender, _nftIndex, _jpegToLock, _unlockAt, false);
    }

    /// @dev See {withdrawTraitBoost} and {withdrawLTVBoost}
    function _unlockJPEG(
        mapping(uint256 => JPEGLock) storage _locks,
        uint256[] calldata _nftIndexes,
        bool _isTraitBoost
    ) internal {
        uint256 length = _nftIndexes.length;
        if (length == 0) revert InvalidLength();

        uint256 jpegToSend;
        for (uint256 i; i < length; ++i) {
            uint256 index = _nftIndexes[i];
            JPEGLock memory jpegLock = _locks[index];
            if (jpegLock.owner != msg.sender) revert Unauthorized();

            if (block.timestamp < jpegLock.unlockAt) revert Unauthorized();

            jpegToSend += jpegLock.lockedValue;

            delete _locks[index];

            emit JPEGUnlocked(
                msg.sender,
                index,
                jpegLock.lockedValue,
                _isTraitBoost
            );
        }

        jpeg.safeTransfer(msg.sender, jpegToSend);
    }

    function _calculateTraitBoostLock(
        Rate memory _lockRate,
        bytes32 _nftType,
        uint256 _floor,
        uint256 _jpegPrice
    ) internal view returns (uint256) {
        Rate memory multiplier = nftTypeValueMultiplier[_nftType];

        if (multiplier.numerator == 0 || multiplier.denominator == 0) return 0;

        return
            (((_floor * multiplier.numerator) /
                multiplier.denominator -
                _floor) *
                1 ether *
                _lockRate.numerator) /
            _lockRate.denominator /
            _jpegPrice;
    }

    function _calculateLTVBoostLock(
        Rate memory _creditLimitRate,
        Rate memory _boostedCreditLimitRate,
        Rate memory _lockRate,
        uint256 _floor,
        uint256 _jpegPrice
    ) internal pure returns (uint256) {
        uint256 baseCreditLimit = (_floor * _creditLimitRate.numerator) /
            _creditLimitRate.denominator;
        uint256 boostedCreditLimit = (_floor *
            _boostedCreditLimitRate.numerator) /
            _boostedCreditLimitRate.denominator;

        return
            ((((boostedCreditLimit - baseCreditLimit) * _lockRate.numerator) /
                _lockRate.denominator) * 1 ether) / _jpegPrice;
    }

    function _rateAfterBoosts(
        Rate memory _baseRate,
        address _owner,
        uint256 _nftIndex
    ) internal view returns (Rate memory) {
        if (cigStaking.isUserStaking(_owner)) {
            _baseRate = _rateSum(_baseRate, cigStakedRateIncrease);
        }
        if (ltvBoostPositions[_nftIndex].unlockAt > block.timestamp) {
            _baseRate = _rateSum(_baseRate, jpegLockedRateIncrease);
        }

        return _baseRate;
    }

    /// @dev Returns the current JPEG price in ETH
    /// @return result The current JPEG price, 18 decimals
    function _jpegPriceETH() internal returns (uint256) {
        return aggregator.consultJPEGPriceETH(address(jpeg));
    }

    /// @dev Validates a rate. The denominator must be greater than zero and less than or equal to the numerator.
    /// @param _rate The rate to validate
    function _validateRateAboveOne(Rate memory _rate) internal pure {
        if (_rate.denominator == 0 || _rate.numerator < _rate.denominator)
            revert InvalidRate(_rate);
    }

    /// @dev Validates a rate. The denominator must be greater than zero and greater than or equal to the numerator.
    /// @param _rate The rate to validate
    function _validateRateBelowOne(Rate memory _rate) internal pure {
        if (_rate.denominator == 0 || _rate.denominator < _rate.numerator)
            revert InvalidRate(_rate);
    }

    /// @dev Checks if `r1` is greater than `r2`.
    function _greaterThan(Rate memory _r1, Rate memory _r2)
        internal
        pure
        returns (bool)
    {
        return
            _r1.numerator * _r2.denominator > _r2.numerator * _r1.denominator;
    }

    function _rateSum(Rate memory _r1, Rate memory _r2)
        internal
        pure
        returns (Rate memory)
    {
        return
            Rate({
                numerator: _r1.numerator *
                    _r2.denominator +
                    _r1.denominator *
                    _r2.numerator,
                denominator: _r1.denominator * _r2.denominator
            });
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

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
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface IAggregatorV3Interface {
    function decimals() external view returns (uint8);

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface IUniswapV2Oracle {
    function consultAndUpdateIfNecessary(address token, uint256 amountIn)
        external
        returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface IJPEGOraclesAggregator {
    function getFloorETH() external view returns (uint256);
    function consultJPEGPriceETH(address _token) external returns (uint256 result);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface IJPEGCardsCigStaking {
    function isUserStaking(address _user) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

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