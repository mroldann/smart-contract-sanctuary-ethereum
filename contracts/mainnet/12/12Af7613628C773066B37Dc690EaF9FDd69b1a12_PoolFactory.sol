/**
 *Submitted for verification at Etherscan.io on 2022-08-12
*/

// SPDX-License-Identifier: GPL-3.0-or-later
// Sources flattened with hardhat v2.6.1 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;


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
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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


// File @openzeppelin/contracts/proxy/[email protected]

// OpenZeppelin Contracts v4.4.1 (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}


// File interfaces/IStakerVault.sol

pragma solidity 0.8.10;

interface IStakerVault {
    event Staked(address indexed account, uint256 amount);
    event Unstaked(address indexed account, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function initialize(address _token) external;

    function initializeLpGauge(address _lpGauge) external;

    function stake(uint256 amount) external;

    function stakeFor(address account, uint256 amount) external;

    function unstake(uint256 amount) external;

    function unstakeFor(
        address src,
        address dst,
        uint256 amount
    ) external;

    function approve(address spender, uint256 amount) external;

    function transfer(address account, uint256 amount) external;

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external;

    function increaseActionLockedBalance(address account, uint256 amount) external;

    function decreaseActionLockedBalance(address account, uint256 amount) external;

    function updateLpGauge(address _lpGauge) external;

    function poolCheckpoint() external returns (bool);

    function poolCheckpoint(uint256 updateEndTime) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function getToken() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function stakedAndActionLockedBalanceOf(address account) external view returns (uint256);

    function actionLockedBalanceOf(address account) external view returns (uint256);

    function getStakedByActions() external view returns (uint256);

    function getPoolTotalStaked() external view returns (uint256);

    function decimals() external view returns (uint8);

    function lpGauge() external view returns (address);
}


// File interfaces/strategies/IStrategy.sol

pragma solidity 0.8.10;

interface IStrategy {
    function deposit() external payable returns (bool);

    function withdraw(uint256 amount) external returns (bool);

    function withdrawAll() external returns (uint256);

    function harvest() external returns (uint256);

    function shutdown() external;

    function setCommunityReserve(address _communityReserve) external;

    function setStrategist(address strategist_) external;

    function name() external view returns (string memory);

    function balance() external view returns (uint256);

    function harvestable() external view returns (uint256);

    function strategist() external view returns (address);

    function hasPendingFunds() external view returns (bool);
}


// File interfaces/IVault.sol

pragma solidity 0.8.10;

/**
 * @title Interface for a Vault
 */

interface IVault {
    event StrategyActivated(address indexed strategy);

    event StrategyDeactivated(address indexed strategy);

    /**
     * @dev 'netProfit' is the profit after all fees have been deducted
     */
    event Harvest(uint256 indexed netProfit, uint256 indexed loss);

    function initialize(
        address _pool,
        uint256 _debtLimit,
        uint256 _targetAllocation,
        uint256 _bound
    ) external;

    function withdrawFromStrategyWaitingForRemoval(address strategy) external returns (uint256);

    function deposit() external payable;

    function withdraw(uint256 amount) external returns (bool);

    function withdrawAvailableToPool() external;

    function initializeStrategy(address strategy_) external;

    function shutdownStrategy() external;

    function withdrawFromReserve(uint256 amount) external;

    function updateStrategy(address newStrategy) external;

    function activateStrategy() external returns (bool);

    function deactivateStrategy() external returns (bool);

    function updatePerformanceFee(uint256 newPerformanceFee) external;

    function updateStrategistFee(uint256 newStrategistFee) external;

    function updateDebtLimit(uint256 newDebtLimit) external;

    function updateTargetAllocation(uint256 newTargetAllocation) external;

    function updateReserveFee(uint256 newReserveFee) external;

    function updateBound(uint256 newBound) external;

    function withdrawFromStrategy(uint256 amount) external returns (bool);

    function withdrawAllFromStrategy() external returns (bool);

    function harvest() external returns (bool);

    function getStrategiesWaitingForRemoval() external view returns (address[] memory);

    function getAllocatedToStrategyWaitingForRemoval(address strategy)
        external
        view
        returns (uint256);

    function getTotalUnderlying() external view returns (uint256);

    function getUnderlying() external view returns (address);

    function strategy() external view returns (IStrategy);
}


// File @openzeppelin/contracts-upgradeable/token/ERC20/[email protected]

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


// File interfaces/ILpToken.sol

pragma solidity 0.8.10;

interface ILpToken is IERC20Upgradeable {
    function mint(address account, uint256 lpTokens) external;

    function burn(address account, uint256 burnAmount) external returns (uint256);

    function burn(uint256 burnAmount) external;

    function minter() external view returns (address);

    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 _decimals,
        address _minter
    ) external returns (bool);
}


// File interfaces/IAdmin.sol

pragma solidity 0.8.10;

interface IAdmin {
    event NewAdminAdded(address newAdmin);
    event AdminRenounced(address oldAdmin);

    function admins() external view returns (address[] memory);

    function addAdmin(address newAdmin) external returns (bool);

    function renounceAdmin() external returns (bool);

    function isAdmin(address account) external view returns (bool);
}


// File interfaces/pool/ILiquidityPool.sol

pragma solidity 0.8.10;


interface ILiquidityPool {
    event Deposit(address indexed minter, uint256 depositAmount, uint256 mintedLpTokens);

    event DepositFor(
        address indexed minter,
        address indexed mintee,
        uint256 depositAmount,
        uint256 mintedLpTokens
    );

    event Redeem(address indexed redeemer, uint256 redeemAmount, uint256 redeemTokens);

    event LpTokenSet(address indexed lpToken);

    event StakerVaultSet(address indexed stakerVault);

    event Shutdown();

    function redeem(uint256 redeemTokens) external returns (uint256);

    function redeem(uint256 redeemTokens, uint256 minRedeemAmount) external returns (uint256);

    function calcRedeem(address account, uint256 underlyingAmount) external returns (uint256);

    function deposit(uint256 mintAmount) external payable returns (uint256);

    function deposit(uint256 mintAmount, uint256 minTokenAmount) external payable returns (uint256);

    function depositAndStake(uint256 depositAmount, uint256 minTokenAmount)
        external
        payable
        returns (uint256);

    function depositFor(address account, uint256 depositAmount) external payable returns (uint256);

    function depositFor(
        address account,
        uint256 depositAmount,
        uint256 minTokenAmount
    ) external payable returns (uint256);

    function unstakeAndRedeem(uint256 redeemLpTokens, uint256 minRedeemAmount)
        external
        returns (uint256);

    function handleLpTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) external;

    function updateVault(address _vault) external;

    function setLpToken(address _lpToken) external;

    function setStaker() external;

    function shutdownPool(bool shutdownStrategy) external;

    function shutdownStrategy() external;

    function updateRequiredReserves(uint256 _newRatio) external;

    function updateReserveDeviation(uint256 newRatio) external;

    function updateMinWithdrawalFee(uint256 newFee) external;

    function updateMaxWithdrawalFee(uint256 newFee) external;

    function updateWithdrawalFeeDecreasePeriod(uint256 newPeriod) external;

    function rebalanceVault() external;

    function getNewCurrentFees(
        uint256 timeToWait,
        uint256 lastActionTimestamp,
        uint256 feeRatio
    ) external view returns (uint256);

    function vault() external view returns (IVault);

    function staker() external view returns (IStakerVault);

    function getUnderlying() external view returns (address);

    function getLpToken() external view returns (address);

    function getWithdrawalFee(address account, uint256 amount) external view returns (uint256);

    function exchangeRate() external view returns (uint256);

    function totalUnderlying() external view returns (uint256);

    function name() external view returns (string memory);

    function isShutdown() external view returns (bool);
}


// File interfaces/IGasBank.sol

pragma solidity 0.8.10;

interface IGasBank {
    event Deposit(address indexed account, uint256 value);
    event Withdraw(address indexed account, address indexed receiver, uint256 value);

    function depositFor(address account) external payable;

    function withdrawUnused(address account) external;

    function withdrawFrom(address account, uint256 amount) external;

    function withdrawFrom(
        address account,
        address payable to,
        uint256 amount
    ) external;

    function balanceOf(address account) external view returns (uint256);
}


// File interfaces/oracles/IOracleProvider.sol

pragma solidity 0.8.10;

interface IOracleProvider {
    /// @notice Checks whether the asset is supported
    /// @param baseAsset the asset of which the price is to be quoted
    /// @return true if the asset is supported
    function isAssetSupported(address baseAsset) external view returns (bool);

    /// @notice Quotes the USD price of `baseAsset`
    /// @param baseAsset the asset of which the price is to be quoted
    /// @return the USD price of the asset
    function getPriceUSD(address baseAsset) external view returns (uint256);

    /// @notice Quotes the ETH price of `baseAsset`
    /// @param baseAsset the asset of which the price is to be quoted
    /// @return the ETH price of the asset
    function getPriceETH(address baseAsset) external view returns (uint256);
}


// File libraries/AddressProviderMeta.sol

pragma solidity 0.8.10;

library AddressProviderMeta {
    struct Meta {
        bool freezable;
        bool frozen;
    }

    function fromUInt(uint256 value) internal pure returns (Meta memory) {
        Meta memory meta;
        meta.freezable = (value & 1) == 1;
        meta.frozen = ((value >> 1) & 1) == 1;
        return meta;
    }

    function toUInt(Meta memory meta) internal pure returns (uint256) {
        uint256 value;
        value |= meta.freezable ? 1 : 0;
        value |= meta.frozen ? 1 << 1 : 0;
        return value;
    }
}


// File interfaces/IAddressProvider.sol

pragma solidity 0.8.10;




// solhint-disable ordering

interface IAddressProvider {
    event KnownAddressKeyAdded(bytes32 indexed key);
    event StakerVaultListed(address indexed stakerVault);
    event StakerVaultDelisted(address indexed stakerVault);
    event ActionListed(address indexed action);
    event ActionShutdown(address indexed action);
    event PoolListed(address indexed pool);
    event VaultUpdated(address indexed previousVault, address indexed newVault);
    event FeeHandlerAdded(address feeHandler);
    event FeeHandlerRemoved(address feeHandler);

    /** Key functions */
    function getKnownAddressKeys() external view returns (bytes32[] memory);

    function freezeAddress(bytes32 key) external;

    /** Pool functions */

    function allPools() external view returns (address[] memory);

    function addPool(address pool) external;

    function poolsCount() external view returns (uint256);

    function getPoolAtIndex(uint256 index) external view returns (address);

    function isPool(address pool) external view returns (bool);

    function getPoolForToken(address token) external view returns (ILiquidityPool);

    function safeGetPoolForToken(address token) external view returns (address);

    /** Vault functions  */

    function updateVault(address previousVault, address newVault) external;

    function allVaults() external view returns (address[] memory);

    function vaultsCount() external view returns (uint256);

    function getVaultAtIndex(uint256 index) external view returns (address);

    function isVault(address vault) external view returns (bool);

    /** Action functions */

    function allActions() external view returns (address[] memory);

    function actionsCount() external view returns (uint256);

    function getActionAtIndex(uint256 index) external view returns (address);

    function allActiveActions() external view returns (address[] memory);

    function addAction(address action) external returns (bool);

    function shutdownAction(address action) external;

    function isAction(address action) external view returns (bool);

    function isActiveAction(address action) external view returns (bool);

    /** Address functions */

    function initialize(address roleManager_, address treasury_) external;

    function initializeAddress(bytes32 key, address initialAddress) external;

    function initializeAddress(
        bytes32 key,
        address initialAddress,
        bool frezable
    ) external;

    function initializeAndFreezeAddress(bytes32 key, address initialAddress) external;

    function getAddress(bytes32 key) external view returns (address);

    function getAddress(bytes32 key, bool checkExists) external view returns (address);

    function getAddressMeta(bytes32 key) external view returns (AddressProviderMeta.Meta memory);

    function updateAddress(bytes32 key, address newAddress) external;

    function initializeInflationManager(address initialAddress) external;

    /** Staker vault functions */
    function allStakerVaults() external view returns (address[] memory);

    function tryGetStakerVault(address token) external view returns (bool, address);

    function getStakerVault(address token) external view returns (address);

    function addStakerVault(address stakerVault) external;

    function isStakerVault(address stakerVault, address token) external view returns (bool);

    function isStakerVaultRegistered(address stakerVault) external view returns (bool);

    function isWhiteListedFeeHandler(address feeHandler) external view returns (bool);

    /** Fee Handler function */
    function addFeeHandler(address feeHandler) external;

    function removeFeeHandler(address feeHandler) external;
}


// File interfaces/actions/IAction.sol

pragma solidity 0.8.10;

interface IAction {
    event UsableTokenAdded(address token);
    event UsableTokenRemoved(address token);
    event Paused();
    event Unpaused();
    event Shutdown();

    function addUsableToken(address token) external;

    function removeUsableToken(address token) external;

    function updateActionFee(uint256 actionFee) external;

    function updateFeeHandler(address feeHandler) external;

    function shutdownAction() external;

    function pause() external;

    function unpause() external;

    function getEthRequiredForGas(address payer) external view returns (uint256);

    function getUsableTokens() external view returns (address[] memory);

    function isUsable(address token) external view returns (bool);

    function feeHandler() external view returns (address);

    function isShutdown() external view returns (bool);

    function isPaused() external view returns (bool);
}


// File interfaces/tokenomics/IInflationManager.sol

pragma solidity 0.8.10;

interface IInflationManager {
    event KeeperGaugeListed(address indexed pool, address indexed keeperGauge);
    event AmmGaugeListed(address indexed token, address indexed ammGauge);
    event KeeperGaugeDelisted(address indexed pool, address indexed keeperGauge);
    event AmmGaugeDelisted(address indexed token, address indexed ammGauge);

    /** Pool functions */

    function setKeeperGauge(address pool, address _keeperGauge) external returns (bool);

    function setAmmGauge(address token, address _ammGauge) external returns (bool);

    function setMinter(address _minter) external;

    function advanceKeeperGaugeEpoch(address pool) external;

    function whitelistGauge(address gauge) external;

    function removeStakerVaultFromInflation(address lpToken) external;

    function removeAmmGauge(address token) external returns (bool);

    function addGaugeForVault(address lpToken) external;

    function checkpointAllGauges(uint256 updateEndTime) external;

    function mintRewards(address beneficiary, uint256 amount) external;

    function checkPointInflation() external;

    function removeKeeperGauge(address pool) external;

    function getAllAmmGauges() external view returns (address[] memory);

    function getLpRateForStakerVault(address stakerVault) external view returns (uint256);

    function getKeeperRateForPool(address pool) external view returns (uint256);

    function getAmmRateForToken(address token) external view returns (uint256);

    function getLpPoolWeight(address pool) external view returns (uint256);

    function getKeeperGaugeForPool(address pool) external view returns (address);

    function getAmmGaugeForToken(address token) external view returns (address);

    function gauges(address lpToken) external view returns (bool);

    function ammWeights(address gauge) external view returns (uint256);

    function lpPoolWeights(address gauge) external view returns (uint256);

    function keeperPoolWeights(address gauge) external view returns (uint256);

    function minter() external view returns (address);

    function weightBasedKeeperDistributionDeactivated() external view returns (bool);

    function totalKeeperPoolWeight() external view returns (uint256);

    function totalLpPoolWeight() external view returns (uint256);

    function totalAmmTokenWeight() external view returns (uint256);

    /** Weight setter functions **/

    function updateLpPoolWeight(address lpToken, uint256 newPoolWeight) external;

    function updateAmmTokenWeight(address token, uint256 newTokenWeight) external;

    function updateKeeperPoolWeight(address pool, uint256 newPoolWeight) external;

    function batchUpdateLpPoolWeights(address[] calldata lpTokens, uint256[] calldata weights)
        external;

    function batchUpdateAmmTokenWeights(address[] calldata tokens, uint256[] calldata weights)
        external;

    function batchUpdateKeeperPoolWeights(address[] calldata pools, uint256[] calldata weights)
        external;

    function deactivateWeightBasedKeeperDistribution() external;
}


// File interfaces/IController.sol

pragma solidity 0.8.10;





// solhint-disable ordering

interface IController {
    function addressProvider() external view returns (IAddressProvider);

    function addStakerVault(address stakerVault) external;

    function shutdownPool(ILiquidityPool pool, bool shutdownStrategy) external returns (bool);

    function shutdownAction(IAction action) external;

    /** Keeper functions */
    function updateKeeperRequiredStakedMERO(uint256 amount) external;

    function canKeeperExecuteAction(address keeper) external view returns (bool);

    function keeperRequireStakedMero() external view returns (uint256);

    /** Miscellaneous functions */

    function getTotalEthRequiredForGas(address payer) external view returns (uint256);
}


// File interfaces/pool/IErc20Pool.sol

pragma solidity 0.8.10;

interface IErc20Pool {
    function initialize(
        string calldata name_,
        address underlying_,
        address vault_,
        uint256 maxWithdrawalFee_,
        uint256 minWithdrawalFee_
    ) external;
}


// File interfaces/pool/IEthPool.sol

pragma solidity 0.8.10;

interface IEthPool {
    function initialize(
        string calldata name_,
        address vault_,
        uint256 maxWithdrawalFee_,
        uint256 minWithdrawalFee_
    ) external;
}


// File interfaces/pool/IPoolFactory.sol

pragma solidity 0.8.10;

interface IPoolFactory {
    struct Addresses {
        address pool;
        address vault;
        address lpToken;
        address stakerVault;
    }

    struct ImplementationNames {
        bytes32 pool;
        bytes32 vault;
        bytes32 lpToken;
        bytes32 stakerVault;
    }

    struct PoolArgs {
        string name;
        uint256 maxWithdrawalFee;
        uint256 minWithdrawalFee;
    }

    struct VaultArgs {
        uint256 debtLimit;
        uint256 targetAllocation;
        uint256 bound;
    }

    struct LpTokenArgs {
        string name;
        string symbol;
        uint8 decimals;
    }

    struct DeployPoolVars {
        address lpTokenImplementation;
        address poolImplementation;
        address stakerVaultImplementation;
        address vaultImplementation;
    }

    function addPoolImplementation(bytes32 name, address implementation) external returns (bool);

    function addLpTokenImplementation(
        bytes32 name,
        address implementation,
        bytes calldata initCode
    ) external returns (bool);

    function addVaultImplementation(bytes32 name, address implementation) external returns (bool);

    function addStakerVaultImplementation(bytes32 name, address implementation)
        external
        returns (bool);

    function deployPool(
        address underlying,
        PoolArgs calldata poolArgs,
        LpTokenArgs calldata lpTokenArgs,
        VaultArgs calldata vaultArgs,
        ImplementationNames calldata implementationNames
    ) external returns (Addresses memory addrs);
}


// File libraries/ScaledMath.sol

pragma solidity 0.8.10;

/*
 * @dev To use functions of this contract, at least one of the numbers must
 * be scaled to `DECIMAL_SCALE`. The result will scaled to `DECIMAL_SCALE`
 * if both numbers are scaled to `DECIMAL_SCALE`, otherwise to the scale
 * of the number not scaled by `DECIMAL_SCALE`
 */
library ScaledMath {
    // solhint-disable-next-line private-vars-leading-underscore
    uint256 internal constant DECIMAL_SCALE = 1e18;
    // solhint-disable-next-line private-vars-leading-underscore
    uint256 internal constant ONE = 1e18;

    /**
     * @notice Performs a multiplication between two scaled numbers
     */
    function scaledMul(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * b) / DECIMAL_SCALE;
    }

    /**
     * @notice Performs a division between two scaled numbers
     */
    function scaledDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * DECIMAL_SCALE) / b;
    }

    /**
     * @notice Performs a division between two numbers, rounding up the result
     */
    function scaledDivRoundUp(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * DECIMAL_SCALE + b - 1) / b;
    }

    /**
     * @notice Performs a division between two numbers, ignoring any scaling and rounding up the result
     */
    function divRoundUp(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a + b - 1) / b;
    }
}


// File interfaces/IVaultReserve.sol

pragma solidity 0.8.10;

interface IVaultReserve {
    event Deposit(address indexed vault, address indexed token, uint256 amount);
    event Withdraw(address indexed vault, address indexed token, uint256 amount);
    event VaultListed(address indexed vault);

    function deposit(address token, uint256 amount) external payable;

    function withdraw(address token, uint256 amount) external;

    function getBalance(address vault, address token) external view returns (uint256);

    function canWithdraw(address vault) external view returns (bool);
}


// File interfaces/IRoleManager.sol

pragma solidity 0.8.10;

interface IRoleManager {
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function initialize() external;

    function grantRole(bytes32 role, address account) external;

    function addGovernor(address newGovernor) external;

    function renounceGovernance() external;

    function addGaugeZap(address zap) external;

    function removeGaugeZap(address zap) external;

    function revokeRole(bytes32 role, address account) external;

    function hasRole(bytes32 role, address account) external view returns (bool);

    function hasAnyRole(bytes32[] memory roles, address account) external view returns (bool);

    function hasAnyRole(
        bytes32 role1,
        bytes32 role2,
        address account
    ) external view returns (bool);

    function hasAnyRole(
        bytes32 role1,
        bytes32 role2,
        bytes32 role3,
        address account
    ) external view returns (bool);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);
}


// File interfaces/IFeeBurner.sol

pragma solidity 0.8.10;

interface IFeeBurner {
    function burnToTarget(address[] memory tokens, address targetLpToken)
        external
        payable
        returns (uint256);
}


// File interfaces/tokenomics/IMeroToken.sol

pragma solidity 0.8.10;

interface IMeroToken is IERC20 {
    function mint(address account, uint256 amount) external;

    function cap() external view returns (uint256);
}


// File interfaces/ISwapperRouter.sol

pragma solidity 0.8.10;

interface ISwapperRouter {
    function swapAll(address fromToken, address toToken) external payable returns (uint256);

    function setSlippageTolerance(uint256 slippageTolerance_) external;

    function setCurvePool(address token_, address curvePool_) external;

    function swap(
        address fromToken,
        address toToken,
        uint256 amountIn
    ) external payable returns (uint256);

    function getAmountOut(
        address fromToken,
        address toToken,
        uint256 amountIn
    ) external view returns (uint256 amountOut);
}


// File libraries/AddressProviderKeys.sol

pragma solidity 0.8.10;

library AddressProviderKeys {
    bytes32 internal constant _TREASURY_KEY = "treasury";
    bytes32 internal constant _REWARD_HANDLER_KEY = "rewardHandler";
    bytes32 internal constant _GAS_BANK_KEY = "gasBank";
    bytes32 internal constant _VAULT_RESERVE_KEY = "vaultReserve";
    bytes32 internal constant _ORACLE_PROVIDER_KEY = "oracleProvider";
    bytes32 internal constant _POOL_FACTORY_KEY = "poolFactory";
    bytes32 internal constant _CONTROLLER_KEY = "controller";
    bytes32 internal constant _MERO_LOCKER_KEY = "meroLocker";
    bytes32 internal constant _INFLATION_MANAGER_KEY = "inflationManager";
    bytes32 internal constant _FEE_BURNER_KEY = "feeBurner";
    bytes32 internal constant _ROLE_MANAGER_KEY = "roleManager";
    bytes32 internal constant _SWAPPER_ROUTER_KEY = "swapperRouter";
}


// File libraries/AddressProviderHelpers.sol

pragma solidity 0.8.10;









library AddressProviderHelpers {
    /**
     * @return The address of the treasury.
     */
    function getTreasury(IAddressProvider provider) internal view returns (address) {
        return provider.getAddress(AddressProviderKeys._TREASURY_KEY);
    }

    /**
     * @return The address of the reward handler.
     */
    function getRewardHandler(IAddressProvider provider) internal view returns (address) {
        return provider.getAddress(AddressProviderKeys._REWARD_HANDLER_KEY);
    }

    /**
     * @dev Returns zero address if no reward handler is set.
     * @return The address of the reward handler.
     */
    function getSafeRewardHandler(IAddressProvider provider) internal view returns (address) {
        return provider.getAddress(AddressProviderKeys._REWARD_HANDLER_KEY, false);
    }

    /**
     * @return The address of the fee burner.
     */
    function getFeeBurner(IAddressProvider provider) internal view returns (IFeeBurner) {
        return IFeeBurner(provider.getAddress(AddressProviderKeys._FEE_BURNER_KEY));
    }

    /**
     * @return The gas bank.
     */
    function getGasBank(IAddressProvider provider) internal view returns (IGasBank) {
        return IGasBank(provider.getAddress(AddressProviderKeys._GAS_BANK_KEY));
    }

    /**
     * @return The address of the vault reserve.
     */
    function getVaultReserve(IAddressProvider provider) internal view returns (IVaultReserve) {
        return IVaultReserve(provider.getAddress(AddressProviderKeys._VAULT_RESERVE_KEY));
    }

    /**
     * @return The oracleProvider.
     */
    function getOracleProvider(IAddressProvider provider) internal view returns (IOracleProvider) {
        return IOracleProvider(provider.getAddress(AddressProviderKeys._ORACLE_PROVIDER_KEY));
    }

    /**
     * @return the address of the MERO locker
     */
    function getMEROLocker(IAddressProvider provider) internal view returns (address) {
        return provider.getAddress(AddressProviderKeys._MERO_LOCKER_KEY);
    }

    /**
     * @return the address of the MERO locker
     */
    function getRoleManager(IAddressProvider provider) internal view returns (IRoleManager) {
        return IRoleManager(provider.getAddress(AddressProviderKeys._ROLE_MANAGER_KEY));
    }

    /**
     * @return the controller
     */
    function getController(IAddressProvider provider) internal view returns (IController) {
        return IController(provider.getAddress(AddressProviderKeys._CONTROLLER_KEY));
    }

    /**
     * @return the inflation manager
     */
    function getInflationManager(IAddressProvider provider)
        internal
        view
        returns (IInflationManager)
    {
        return IInflationManager(provider.getAddress(AddressProviderKeys._INFLATION_MANAGER_KEY));
    }

    /**
     * @return the inflation manager or `address(0)` if it does not exist
     */
    function safeGetInflationManager(IAddressProvider provider)
        internal
        view
        returns (IInflationManager)
    {
        return
            IInflationManager(
                provider.getAddress(AddressProviderKeys._INFLATION_MANAGER_KEY, false)
            );
    }

    /**
     * @return the swapper router
     */
    function getSwapperRouter(IAddressProvider provider) internal view returns (ISwapperRouter) {
        return ISwapperRouter(provider.getAddress(AddressProviderKeys._SWAPPER_ROUTER_KEY));
    }
}


// File libraries/Errors.sol

pragma solidity 0.8.10;

// solhint-disable private-vars-leading-underscore

library Error {
    string internal constant ADDRESS_WHITELISTED = "address already whitelisted";
    string internal constant ADMIN_ALREADY_SET = "admin has already been set once";
    string internal constant ADDRESS_NOT_WHITELISTED = "address not whitelisted";
    string internal constant ADDRESS_NOT_FOUND = "address not found";
    string internal constant CONTRACT_INITIALIZED = "contract can only be initialized once";
    string internal constant CONTRACT_PAUSED = "contract is paused";
    string internal constant UNAUTHORIZED_PAUSE = "not authorized to pause";
    string internal constant INVALID_AMOUNT = "invalid amount";
    string internal constant INVALID_INDEX = "invalid index";
    string internal constant INVALID_VALUE = "invalid msg.value";
    string internal constant INVALID_SENDER = "invalid msg.sender";
    string internal constant INVALID_TOKEN = "token address does not match pool's LP token address";
    string internal constant INVALID_DECIMALS = "incorrect number of decimals";
    string internal constant INVALID_ARGUMENT = "invalid argument";
    string internal constant INVALID_PARAMETER_VALUE = "invalid parameter value attempted";
    string internal constant INVALID_IMPLEMENTATION = "invalid pool implementation for given coin";
    string internal constant INVALID_POOL_IMPLEMENTATION =
        "invalid pool implementation for given coin";
    string internal constant INVALID_LP_TOKEN_IMPLEMENTATION =
        "invalid LP Token implementation for given coin";
    string internal constant INVALID_VAULT_IMPLEMENTATION =
        "invalid vault implementation for given coin";
    string internal constant INVALID_STAKER_VAULT_IMPLEMENTATION =
        "invalid stakerVault implementation for given coin";
    string internal constant INSUFFICIENT_ALLOWANCE = "insufficient allowance";
    string internal constant INSUFFICIENT_BALANCE = "insufficient balance";
    string internal constant INSUFFICIENT_AMOUNT_OUT = "Amount received less than min amount";
    string internal constant PROXY_CALL_FAILED = "proxy call failed";
    string internal constant INSUFFICIENT_AMOUNT_IN = "Amount spent more than max amount";
    string internal constant ADDRESS_ALREADY_SET = "Address is already set";
    string internal constant INSUFFICIENT_STRATEGY_BALANCE = "insufficient strategy balance";
    string internal constant INSUFFICIENT_FUNDS_RECEIVED = "insufficient funds received";
    string internal constant ADDRESS_DOES_NOT_EXIST = "address does not exist";
    string internal constant ADDRESS_FROZEN = "address is frozen";
    string internal constant ROLE_EXISTS = "role already exists";
    string internal constant CANNOT_REVOKE_ROLE = "cannot revoke role";
    string internal constant UNAUTHORIZED_ACCESS = "unauthorized access";
    string internal constant SAME_ADDRESS_NOT_ALLOWED = "same address not allowed";
    string internal constant SELF_TRANSFER_NOT_ALLOWED = "self-transfer not allowed";
    string internal constant ZERO_ADDRESS_NOT_ALLOWED = "zero address not allowed";
    string internal constant ZERO_TRANSFER_NOT_ALLOWED = "zero transfer not allowed";
    string internal constant THRESHOLD_TOO_HIGH = "threshold is too high, must be under 10";
    string internal constant INSUFFICIENT_THRESHOLD = "insufficient threshold";
    string internal constant NO_POSITION_EXISTS = "no position exists";
    string internal constant POSITION_ALREADY_EXISTS = "position already exists";
    string internal constant CANNOT_EXECUTE_IN_SAME_BLOCK = "cannot execute action in same block";
    string internal constant PROTOCOL_NOT_FOUND = "protocol not found";
    string internal constant TOP_UP_FAILED = "top up failed";
    string internal constant SWAP_PATH_NOT_FOUND = "swap path not found";
    string internal constant UNDERLYING_NOT_SUPPORTED = "underlying token not supported";
    string internal constant NOT_ENOUGH_FUNDS_WITHDRAWN =
        "not enough funds were withdrawn from the pool";
    string internal constant FAILED_TRANSFER = "transfer failed";
    string internal constant FAILED_MINT = "mint failed";
    string internal constant FAILED_REPAY_BORROW = "repay borrow failed";
    string internal constant FAILED_METHOD_CALL = "method call failed";
    string internal constant NOTHING_TO_CLAIM = "there is no claimable balance";
    string internal constant ERC20_BALANCE_EXCEEDED = "ERC20: transfer amount exceeds balance";
    string internal constant INVALID_MINTER =
        "the minter address of the LP token and the pool address do not match";
    string internal constant STAKER_VAULT_EXISTS = "a staker vault already exists for the token";
    string internal constant DEADLINE_NOT_ZERO = "deadline must be 0";
    string internal constant NOTHING_PENDING = "no pending change to reset";
    string internal constant DEADLINE_NOT_SET = "deadline is 0";
    string internal constant DEADLINE_NOT_REACHED = "deadline has not been reached yet";
    string internal constant DELAY_TOO_SHORT = "delay must be at least 3 days";
    string internal constant INSUFFICIENT_UPDATE_BALANCE =
        "insufficient funds for updating the position";
    string internal constant SAME_AS_CURRENT = "value must be different to existing value";
    string internal constant NOT_CAPPED = "the pool is not currently capped";
    string internal constant ALREADY_CAPPED = "the pool is already capped";
    string internal constant ALREADY_SHUTDOWN = "already shutdown";
    string internal constant EXCEEDS_DEPOSIT_CAP = "deposit exceeds deposit cap";
    string internal constant VALUE_TOO_LOW_FOR_GAS = "value too low to cover gas";
    string internal constant NOT_ENOUGH_FUNDS = "not enough funds to withdraw";
    string internal constant ESTIMATED_GAS_TOO_HIGH = "too much ETH will be used for gas";
    string internal constant GAUGE_KILLED = "gauge killed";
    string internal constant INVALID_TARGET = "Invalid Target";
    string internal constant DEPOSIT_FAILED = "deposit failed";
    string internal constant GAS_TOO_HIGH = "too much ETH used for gas";
    string internal constant GAS_BANK_BALANCE_TOO_LOW = "not enough ETH in gas bank to cover gas";
    string internal constant INVALID_TOKEN_TO_ADD = "Invalid token to add";
    string internal constant INVALID_TOKEN_TO_REMOVE = "token can not be removed";
    string internal constant TIME_DELAY_NOT_EXPIRED = "time delay not expired yet";
    string internal constant UNDERLYING_NOT_WITHDRAWABLE =
        "pool does not support additional underlying coins to be withdrawn";
    string internal constant STRATEGY_SHUTDOWN = "Strategy is shutdown";
    string internal constant POOL_SHUTDOWN = "Pool is shutdown";
    string internal constant ACTION_SHUTDOWN = "Action is shutdown";
    string internal constant ACTION_PAUSED = "Action is paused";
    string internal constant STRATEGY_DOES_NOT_EXIST = "Strategy does not exist";
    string internal constant GAUGE_STILL_ACTIVE = "Gauge still active";
    string internal constant UNSUPPORTED_UNDERLYING = "Underlying not supported";
    string internal constant NO_DEX_SET = "no dex has been set for token";
    string internal constant INVALID_TOKEN_PAIR = "invalid token pair";
    string internal constant TOKEN_NOT_USABLE = "token not usable for the specific action";
    string internal constant ADDRESS_NOT_ACTION = "address is not registered action";
    string internal constant ACTION_NOT_ACTIVE = "address is not active action";
    string internal constant INVALID_SLIPPAGE_TOLERANCE = "Invalid slippage tolerance";
    string internal constant INVALID_MAX_FEE = "invalid max fee";
    string internal constant POOL_NOT_PAUSED = "Pool must be paused to withdraw from reserve";
    string internal constant INTERACTION_LIMIT = "Max of one deposit and withdraw per block";
    string internal constant GAUGE_EXISTS = "Gauge already exists";
    string internal constant GAUGE_DOES_NOT_EXIST = "Gauge does not exist";
    string internal constant EXCEEDS_MAX_BOOST = "Not allowed to exceed maximum boost on Convex";
    string internal constant PREPARED_WITHDRAWAL =
        "Cannot relock funds when withdrawal is being prepared";
    string internal constant ASSET_NOT_SUPPORTED = "Asset not supported";
    string internal constant STALE_PRICE = "Price is stale";
    string internal constant NEGATIVE_PRICE = "Price is negative";
    string internal constant ROUND_NOT_COMPLETE = "Round not complete";
    string internal constant NOT_ENOUGH_MERO_STAKED = "Not enough MERO tokens staked";
    string internal constant RESERVE_ACCESS_EXCEEDED = "Reserve access exceeded";
}


// File libraries/Roles.sol

pragma solidity 0.8.10;

// solhint-disable private-vars-leading-underscore

library Roles {
    bytes32 internal constant GOVERNANCE = "governance";
    bytes32 internal constant ADDRESS_PROVIDER = "address_provider";
    bytes32 internal constant POOL_FACTORY = "pool_factory";
    bytes32 internal constant CONTROLLER = "controller";
    bytes32 internal constant GAUGE_ZAP = "gauge_zap";
    bytes32 internal constant MAINTENANCE = "maintenance";
    bytes32 internal constant INFLATION_ADMIN = "inflation_admin";
    bytes32 internal constant INFLATION_MANAGER = "inflation_manager";
    bytes32 internal constant POOL = "pool";
    bytes32 internal constant VAULT = "vault";
    bytes32 internal constant ACTION = "action";
}


// File contracts/access/AuthorizationBase.sol

pragma solidity 0.8.10;


/**
 * @notice Provides modifiers for authorization
 */
abstract contract AuthorizationBase {
    /**
     * @notice Only allows a sender with `role` to perform the given action
     */
    modifier onlyRole(bytes32 role) {
        require(_roleManager().hasRole(role, msg.sender), Error.UNAUTHORIZED_ACCESS);
        _;
    }

    /**
     * @notice Only allows a sender with GOVERNANCE role to perform the given action
     */
    modifier onlyGovernance() {
        require(_roleManager().hasRole(Roles.GOVERNANCE, msg.sender), Error.UNAUTHORIZED_ACCESS);
        _;
    }

    /**
     * @notice Only allows a sender with any of `roles` to perform the given action
     */
    modifier onlyRoles2(bytes32 role1, bytes32 role2) {
        require(_roleManager().hasAnyRole(role1, role2, msg.sender), Error.UNAUTHORIZED_ACCESS);
        _;
    }

    /**
     * @notice Only allows a sender with any of `roles` to perform the given action
     */
    modifier onlyRoles3(
        bytes32 role1,
        bytes32 role2,
        bytes32 role3
    ) {
        require(
            _roleManager().hasAnyRole(role1, role2, role3, msg.sender),
            Error.UNAUTHORIZED_ACCESS
        );
        _;
    }

    function roleManager() external view virtual returns (IRoleManager) {
        return _roleManager();
    }

    function _roleManager() internal view virtual returns (IRoleManager);
}


// File contracts/access/Authorization.sol

pragma solidity 0.8.10;

contract Authorization is AuthorizationBase {
    IRoleManager internal immutable __roleManager;

    constructor(IRoleManager roleManager) {
        __roleManager = roleManager;
    }

    function _roleManager() internal view override returns (IRoleManager) {
        return __roleManager;
    }
}


// File @openzeppelin/contracts-upgradeable/token/ERC20/extensions/[email protected]

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


// File @openzeppelin/contracts-upgradeable/utils/[email protected]

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


// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts-upgradeable/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts-upgradeable/token/ERC20/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




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
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
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
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}


// File contracts/LpToken.sol

pragma solidity 0.8.10;





contract LpToken is ILpToken, ERC20Upgradeable {
    using ScaledMath for uint256;

    uint8 private _decimals;

    address public override minter;

    /**
     * @notice Make a function only callable by the minter contract.
     * @dev Fails if msg.sender is not the minter.
     */
    modifier onlyMinter() {
        require(msg.sender == minter, Error.UNAUTHORIZED_ACCESS);
        _;
    }

    function initialize(
        string calldata name_,
        string calldata symbol_,
        uint8 decimals_,
        address _minter
    ) external override initializer returns (bool) {
        require(_minter != address(0), Error.ZERO_ADDRESS_NOT_ALLOWED);
        __ERC20_init(name_, symbol_);
        _decimals = decimals_;
        minter = _minter;
        return true;
    }

    /**
     * @notice Mint tokens.
     * @param account Account from which tokens should be burned.
     * @param amount Amount of tokens to mint.
     */
    function mint(address account, uint256 amount) external override onlyMinter {
        _mint(account, amount);
    }

    /**
     * @notice Burns tokens of msg.sender.
     * @param amount Amount of tokens to burn.
     */
    function burn(uint256 amount) external override {
        _burn(msg.sender, amount);
    }

    /**
     * @notice Burn tokens.
     * @param owner Account from which tokens should be burned.
     * @param burnAmount Amount of tokens to burn.
     * @return Amount of tokens burned.
     */
    function burn(address owner, uint256 burnAmount)
        external
        override
        onlyMinter
        returns (uint256)
    {
        _burn(owner, burnAmount);
        return burnAmount;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev We notify that LP tokens have been transferred
     * this is currently used to keep track of the withdrawal fees
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (amount > 0) ILiquidityPool(minter).handleLpTokenTransfer(from, to, amount); // add check to not break 0 transfers
    }
}


// File contracts/pool/PoolFactory.sol

pragma solidity 0.8.10;













contract PoolFactory is IPoolFactory, Authorization {
    using AddressProviderHelpers for IAddressProvider;

    bytes32 internal constant _POOL_KEY = "pool";
    bytes32 internal constant _LP_TOKEN_KEY = "lp_token";
    bytes32 internal constant _STAKER_VAULT_KEY = "staker_vault";
    bytes32 internal constant _VAULT_KEY = "vault";

    IController public immutable controller;
    IAddressProvider public immutable addressProvider;

    /**
     * @dev maps a contract type (e.g. "pool" or "lp_token", as defined in constants above)
     * to a mapping from an implementation name to the actual implementation
     * The implementation name is decided when registering the implementation
     * and can be arbitrary (e.g. "ERC20PoolV1")
     */
    mapping(bytes32 => mapping(bytes32 => address)) public implementations;

    /**
     * @dev maps an LP token implementation to its creation code
     * this is only required for the LP token because they are deployed using `create`
     * rather than using a minimal proxy like the other contracts
     */
    mapping(address => bytes) public lpTokensInitCode;

    event NewPool(address pool, address vault, address lpToken, address stakerVault);
    event NewImplementation(bytes32 key, bytes32 name, address implementation);

    constructor(IController _controller)
        Authorization(_controller.addressProvider().getRoleManager())
    {
        controller = IController(_controller);
        addressProvider = IController(_controller).addressProvider();
    }

    /**
     * @notice Add a new pool implementation to the factory.
     * @param name of the pool implementation.
     * @param implementation of pool implementation to add.
     */
    function addPoolImplementation(bytes32 name, address implementation)
        external
        override
        onlyGovernance
        returns (bool)
    {
        return _addImplementation(_POOL_KEY, name, implementation);
    }

    /**
     * @notice Add a new LP token implementation to the factory.
     * @param name of the LP token implementation.
     * @param implementation of lp token implementation to add.
     */
    function addLpTokenImplementation(
        bytes32 name,
        address implementation,
        bytes calldata initCode
    ) external override onlyGovernance returns (bool) {
        lpTokensInitCode[implementation] = initCode;
        return _addImplementation(_LP_TOKEN_KEY, name, implementation);
    }

    /**
     * @notice Add a new vault implementation to the factory.
     * @param name of the vault implementation.
     * @param implementation of vault implementation to add.
     */
    function addVaultImplementation(bytes32 name, address implementation)
        external
        override
        onlyGovernance
        returns (bool)
    {
        return _addImplementation(_VAULT_KEY, name, implementation);
    }

    /**
     * @notice Add a new staker vault implementation to the factory.
     * @param name of the staker vault implementation.
     * @param implementation of staker vault implementation to add.
     */
    function addStakerVaultImplementation(bytes32 name, address implementation)
        external
        override
        onlyGovernance
        returns (bool)
    {
        return _addImplementation(_STAKER_VAULT_KEY, name, implementation);
    }

    /**
     * @notice Deploys a new pool and LP token.
     * @dev Decimals is an argument as not all ERC20 tokens implement the ERC20Detailed interface.
     *      An implementation where `getUnderlying()` returns the zero address is for ETH pools.
     * @param underlying Address of the pool's underlying.
     * @param poolArgs Arguments to initialize the pool.
     * @param lpTokenArgs Arguments to create the LP token for the pool.
     * @param vaultArgs Arguments to create the vault.
     * @param implementationNames Name of the implementations to use.
     * @return addrs Address of the deployed pool, address of the pool's deployed LP token.
     */
    function deployPool(
        address underlying,
        PoolArgs calldata poolArgs,
        LpTokenArgs calldata lpTokenArgs,
        VaultArgs calldata vaultArgs,
        ImplementationNames calldata implementationNames
    ) external override onlyGovernance returns (Addresses memory addrs) {
        DeployPoolVars memory vars;

        vars.poolImplementation = implementations[_POOL_KEY][implementationNames.pool];
        require(vars.poolImplementation != address(0), Error.INVALID_POOL_IMPLEMENTATION);

        vars.lpTokenImplementation = implementations[_LP_TOKEN_KEY][implementationNames.lpToken];
        require(vars.lpTokenImplementation != address(0), Error.INVALID_LP_TOKEN_IMPLEMENTATION);

        vars.vaultImplementation = implementations[_VAULT_KEY][implementationNames.vault];
        require(vars.vaultImplementation != address(0), Error.INVALID_VAULT_IMPLEMENTATION);

        vars.stakerVaultImplementation = implementations[_STAKER_VAULT_KEY][
            implementationNames.stakerVault
        ];
        require(
            vars.stakerVaultImplementation != address(0),
            Error.INVALID_STAKER_VAULT_IMPLEMENTATION
        );

        addrs.pool = Clones.clone(vars.poolImplementation);
        addrs.vault = Clones.clone(vars.vaultImplementation);

        if (underlying == address(0)) {
            // ETH pool
            require(
                ILiquidityPool(vars.poolImplementation).getUnderlying() == address(0),
                Error.INVALID_POOL_IMPLEMENTATION
            );
            require(lpTokenArgs.decimals == 18, Error.INVALID_DECIMALS);
            IEthPool(addrs.pool).initialize(
                poolArgs.name,
                addrs.vault,
                poolArgs.maxWithdrawalFee,
                poolArgs.minWithdrawalFee
            );
        } else {
            IErc20Pool(addrs.pool).initialize(
                poolArgs.name,
                underlying,
                addrs.vault,
                poolArgs.maxWithdrawalFee,
                poolArgs.minWithdrawalFee
            );
        }

        address lpTokenAddress;
        bytes memory lptokenCreationCode = bytes.concat(
            lpTokensInitCode[vars.lpTokenImplementation],
            vars.lpTokenImplementation.code
        );

        // solhint-disable-next-line no-inline-assembly
        assembly {
            lpTokenAddress := create(0, add(lptokenCreationCode, 32), mload(lptokenCreationCode))
        }

        addrs.lpToken = lpTokenAddress;

        ILpToken(addrs.lpToken).initialize(
            lpTokenArgs.name,
            lpTokenArgs.symbol,
            lpTokenArgs.decimals,
            addrs.pool
        );

        addrs.stakerVault = Clones.clone(vars.stakerVaultImplementation);
        IStakerVault(addrs.stakerVault).initialize(addrs.lpToken);
        controller.addStakerVault(addrs.stakerVault);

        ILiquidityPool(addrs.pool).setLpToken(addrs.lpToken);
        ILiquidityPool(addrs.pool).setStaker();

        IVault(addrs.vault).initialize(
            addrs.pool,
            vaultArgs.debtLimit,
            vaultArgs.targetAllocation,
            vaultArgs.bound
        );

        addressProvider.addPool(addrs.pool);

        emit NewPool(addrs.pool, addrs.vault, addrs.lpToken, addrs.stakerVault);
        return addrs;
    }

    /**
     * @notice Add a new implementation of type `name` to the factory.
     * @param key of the implementation to add.
     * @param name of the implementation to add.
     * @param implementation of lp token implementation to add.
     */
    function _addImplementation(
        bytes32 key,
        bytes32 name,
        address implementation
    ) internal returns (bool) {
        mapping(bytes32 => address) storage currentImplementations = implementations[key];
        if (currentImplementations[name] != address(0)) {
            return false;
        }
        currentImplementations[name] = implementation;
        emit NewImplementation(key, name, implementation);
        return true;
    }
}