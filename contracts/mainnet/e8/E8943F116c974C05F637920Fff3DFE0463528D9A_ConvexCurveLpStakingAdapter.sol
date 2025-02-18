// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

import "../../utils/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

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
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

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
    constructor (string memory name_, string memory symbol_) public {
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
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor () internal {
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
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    /**
     * @dev Converts a `uint256` to its ASCII `string` representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

/// @title IDispatcher Interface
/// @author Enzyme Council <[email protected]>
interface IDispatcher {
    function cancelMigration(address _vaultProxy, bool _bypassFailure) external;

    function claimOwnership() external;

    function deployVaultProxy(
        address _vaultLib,
        address _owner,
        address _vaultAccessor,
        string calldata _fundName
    ) external returns (address vaultProxy_);

    function executeMigration(address _vaultProxy, bool _bypassFailure) external;

    function getCurrentFundDeployer() external view returns (address currentFundDeployer_);

    function getFundDeployerForVaultProxy(address _vaultProxy)
        external
        view
        returns (address fundDeployer_);

    function getMigrationRequestDetailsForVaultProxy(address _vaultProxy)
        external
        view
        returns (
            address nextFundDeployer_,
            address nextVaultAccessor_,
            address nextVaultLib_,
            uint256 executableTimestamp_
        );

    function getMigrationTimelock() external view returns (uint256 migrationTimelock_);

    function getNominatedOwner() external view returns (address nominatedOwner_);

    function getOwner() external view returns (address owner_);

    function getSharesTokenSymbol() external view returns (string memory sharesTokenSymbol_);

    function getTimelockRemainingForMigrationRequest(address _vaultProxy)
        external
        view
        returns (uint256 secondsRemaining_);

    function hasExecutableMigrationRequest(address _vaultProxy)
        external
        view
        returns (bool hasExecutableRequest_);

    function hasMigrationRequest(address _vaultProxy)
        external
        view
        returns (bool hasMigrationRequest_);

    function removeNominatedOwner() external;

    function setCurrentFundDeployer(address _nextFundDeployer) external;

    function setMigrationTimelock(uint256 _nextTimelock) external;

    function setNominatedOwner(address _nextNominatedOwner) external;

    function setSharesTokenSymbol(string calldata _nextSymbol) external;

    function signalMigration(
        address _vaultProxy,
        address _nextVaultAccessor,
        address _nextVaultLib,
        bool _bypassFailure
    ) external;
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

/// @title IFundDeployer Interface
/// @author Enzyme Council <[email protected]>
interface IFundDeployer {
    function getOwner() external view returns (address);

    function hasReconfigurationRequest(address) external view returns (bool);

    function isAllowedBuySharesOnBehalfCaller(address) external view returns (bool);

    function isAllowedVaultCall(
        address,
        bytes4,
        bytes32
    ) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

/// @title IIntegrationManager interface
/// @author Enzyme Council <[email protected]>
/// @notice Interface for the IntegrationManager
interface IIntegrationManager {
    enum SpendAssetsHandleType {None, Approve, Transfer}
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

import "../IIntegrationManager.sol";

/// @title Integration Adapter interface
/// @author Enzyme Council <[email protected]>
/// @notice Interface for all integration adapters
interface IIntegrationAdapter {
    function parseAssetsForAction(
        address _vaultProxy,
        bytes4 _selector,
        bytes calldata _encodedCallArgs
    )
        external
        view
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        );
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.12;

import "../../../../infrastructure/price-feeds/derivatives/feeds/CurvePriceFeed.sol";
import "../../../../infrastructure/staking-wrappers/convex-curve-lp/ConvexCurveLpStakingWrapperFactory.sol";
import "../utils/actions/StakingWrapperActionsMixin.sol";
import "../utils/bases/CurveLiquidityAdapterBase.sol";

/// @title ConvexCurveLpStakingAdapter Contract
/// @author Enzyme Council <[email protected]>
/// @notice Adapter for staking Curve LP tokens via Convex,
/// with optional combined end-to-end liquidity provision via Curve
/// @dev Rewards tokens are not included as incoming assets for claimRewards()
/// Rationale:
/// - rewards tokens can be claimed to the vault outside of the IntegrationManager, so no need
/// to enforce policy management or emit an event
/// - rewards tokens can be outside of the asset universe, in which case they cannot be tracked
contract ConvexCurveLpStakingAdapter is CurveLiquidityAdapterBase, StakingWrapperActionsMixin {
    ConvexCurveLpStakingWrapperFactory private immutable STAKING_WRAPPER_FACTORY_CONTRACT;
    CurvePriceFeed private immutable CURVE_PRICE_FEED_CONTRACT;

    constructor(
        address _integrationManager,
        address _curvePriceFeed,
        address _wrappedNativeAsset,
        address _stakingWrapperFactory,
        address _nativeAssetAddress
    )
        public
        CurveLiquidityAdapterBase(_integrationManager, _wrappedNativeAsset, _nativeAssetAddress)
    {
        CURVE_PRICE_FEED_CONTRACT = CurvePriceFeed(_curvePriceFeed);
        STAKING_WRAPPER_FACTORY_CONTRACT = ConvexCurveLpStakingWrapperFactory(
            _stakingWrapperFactory
        );
    }

    // EXTERNAL FUNCTIONS

    /// @notice Claims all rewards for a given staking token
    /// @param _vaultProxy The VaultProxy of the calling fund
    /// @param _actionData Data specific to this action
    function claimRewards(
        address _vaultProxy,
        bytes calldata _actionData,
        bytes calldata
    ) external onlyIntegrationManager {
        __stakingWrapperClaimRewardsFor(__decodeClaimRewardsCallArgs(_actionData), _vaultProxy);
    }

    /// @notice Lends assets for LP tokens, then stakes the received LP tokens
    /// @param _vaultProxy The VaultProxy of the calling fund
    /// @param _actionData Data specific to this action
    /// @param _assetData Parsed spend assets and incoming assets data for this action
    function lendAndStake(
        address _vaultProxy,
        bytes calldata _actionData,
        bytes calldata _assetData
    ) external onlyIntegrationManager {
        (
            address pool,
            uint256[] memory orderedOutgoingAssetAmounts,
            address incomingStakingToken,
            uint256 minIncomingStakingTokenAmount,
            bool useUnderlyings
        ) = __decodeLendAndStakeCallArgs(_actionData);
        (address[] memory spendAssets, , ) = __decodeAssetData(_assetData);

        address lpToken = CURVE_PRICE_FEED_CONTRACT.getLpTokenForPool(pool);

        __curveAddLiquidity(
            pool,
            spendAssets,
            orderedOutgoingAssetAmounts,
            minIncomingStakingTokenAmount,
            useUnderlyings
        );

        __stakingWrapperStake(
            incomingStakingToken,
            _vaultProxy,
            ERC20(lpToken).balanceOf(address(this)),
            lpToken
        );
    }

    /// @notice Stakes LP tokens
    /// @param _vaultProxy The VaultProxy of the calling fund
    /// @param _actionData Data specific to this action
    /// @param _assetData Parsed spend assets and incoming assets data for this action
    function stake(
        address _vaultProxy,
        bytes calldata _actionData,
        bytes calldata _assetData
    ) external onlyIntegrationManager {
        (, address incomingStakingToken, uint256 amount) = __decodeStakeCallArgs(_actionData);

        (address[] memory spendAssets, , ) = __decodeAssetData(_assetData);

        __stakingWrapperStake(incomingStakingToken, _vaultProxy, amount, spendAssets[0]);
    }

    /// @notice Unstakes LP tokens
    /// @param _vaultProxy The VaultProxy of the calling fund
    /// @param _actionData Data specific to this action
    function unstake(
        address _vaultProxy,
        bytes calldata _actionData,
        bytes calldata
    ) external onlyIntegrationManager {
        (, address outgoingStakingToken, uint256 amount) = __decodeUnstakeCallArgs(_actionData);

        __stakingWrapperUnstake(outgoingStakingToken, _vaultProxy, _vaultProxy, amount, false);
    }

    /// @notice Unstakes LP tokens, then redeems them
    /// @param _vaultProxy The VaultProxy of the calling fund
    /// @param _actionData Data specific to this action
    /// @param _assetData Parsed spend assets and incoming assets data for this action
    function unstakeAndRedeem(
        address _vaultProxy,
        bytes calldata _actionData,
        bytes calldata _assetData
    )
        external
        onlyIntegrationManager
        postActionIncomingAssetsTransferHandler(_vaultProxy, _assetData)
    {
        (
            address pool,
            address outgoingStakingToken,
            uint256 outgoingStakingTokenAmount,
            bool useUnderlyings,
            RedeemType redeemType,
            bytes memory incomingAssetsData
        ) = __decodeUnstakeAndRedeemCallArgs(_actionData);

        __stakingWrapperUnstake(
            outgoingStakingToken,
            _vaultProxy,
            address(this),
            outgoingStakingTokenAmount,
            false
        );

        __curveRedeem(
            pool,
            outgoingStakingTokenAmount,
            useUnderlyings,
            redeemType,
            incomingAssetsData
        );
    }

    /////////////////////////////
    // PARSE ASSETS FOR METHOD //
    /////////////////////////////

    /// @notice Parses the expected assets in a particular action
    /// @param _selector The function selector for the callOnIntegration
    /// @param _actionData Data specific to this action
    /// @return spendAssetsHandleType_ A type that dictates how to handle granting
    /// the adapter access to spend assets (`None` by default)
    /// @return spendAssets_ The assets to spend in the call
    /// @return spendAssetAmounts_ The max asset amounts to spend in the call
    /// @return incomingAssets_ The assets to receive in the call
    /// @return minIncomingAssetAmounts_ The min asset amounts to receive in the call
    function parseAssetsForAction(
        address,
        bytes4 _selector,
        bytes calldata _actionData
    )
        external
        view
        override
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        if (_selector == CLAIM_REWARDS_SELECTOR) {
            return __parseAssetsForClaimRewards();
        } else if (_selector == LEND_AND_STAKE_SELECTOR) {
            return __parseAssetsForLendAndStake(_actionData);
        } else if (_selector == STAKE_SELECTOR) {
            return __parseAssetsForStake(_actionData);
        } else if (_selector == UNSTAKE_SELECTOR) {
            return __parseAssetsForUnstake(_actionData);
        } else if (_selector == UNSTAKE_AND_REDEEM_SELECTOR) {
            return __parseAssetsForUnstakeAndRedeem(_actionData);
        }

        revert("parseAssetsForAction: _selector invalid");
    }

    /// @dev Helper function to parse spend and incoming assets from encoded call args
    /// during claimRewards() calls.
    /// No action required, all values empty.
    function __parseAssetsForClaimRewards()
        private
        pure
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        return (
            IIntegrationManager.SpendAssetsHandleType.None,
            new address[](0),
            new uint256[](0),
            new address[](0),
            new uint256[](0)
        );
    }

    /// @dev Helper function to parse spend and incoming assets from encoded call args
    /// during lendAndStake() calls
    function __parseAssetsForLendAndStake(bytes calldata _actionData)
        private
        view
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        (
            address pool,
            uint256[] memory orderedOutgoingAssetAmounts,
            address incomingStakingToken,
            uint256 minIncomingStakingTokenAmount,
            bool useUnderlyings
        ) = __decodeLendAndStakeCallArgs(_actionData);

        __validatePoolForWrapper(pool, incomingStakingToken);

        (spendAssets_, spendAssetAmounts_) = __parseSpendAssetsForLendingCalls(
            pool,
            orderedOutgoingAssetAmounts,
            useUnderlyings
        );

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = incomingStakingToken;

        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = minIncomingStakingTokenAmount;

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    /// @dev Helper function to parse spend and incoming assets from encoded call args
    /// during stake() calls
    function __parseAssetsForStake(bytes calldata _actionData)
        private
        view
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        (, address incomingStakingToken, uint256 amount) = __decodeStakeCallArgs(_actionData);

        spendAssets_ = new address[](1);
        spendAssets_[0] = STAKING_WRAPPER_FACTORY_CONTRACT.getCurveLpTokenForWrapper(
            incomingStakingToken
        );

        spendAssetAmounts_ = new uint256[](1);
        spendAssetAmounts_[0] = amount;

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = incomingStakingToken;

        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = amount;

        return (
            IIntegrationManager.SpendAssetsHandleType.Transfer,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    /// @dev Helper function to parse spend and incoming assets from encoded call args
    /// during unstake() calls
    function __parseAssetsForUnstake(bytes calldata _actionData)
        private
        view
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        (, address outgoingStakingToken, uint256 amount) = __decodeUnstakeCallArgs(_actionData);

        spendAssets_ = new address[](1);
        spendAssets_[0] = outgoingStakingToken;

        spendAssetAmounts_ = new uint256[](1);
        spendAssetAmounts_[0] = amount;

        incomingAssets_ = new address[](1);
        incomingAssets_[0] = STAKING_WRAPPER_FACTORY_CONTRACT.getCurveLpTokenForWrapper(
            outgoingStakingToken
        );

        minIncomingAssetAmounts_ = new uint256[](1);
        minIncomingAssetAmounts_[0] = amount;

        // SpendAssetsHandleType is `Approve`, since staking wrapper allows unstaking on behalf
        return (
            IIntegrationManager.SpendAssetsHandleType.Approve,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    /// @dev Helper function to parse spend and incoming assets from encoded call args
    /// during unstakeAndRedeem() calls
    function __parseAssetsForUnstakeAndRedeem(bytes calldata _actionData)
        private
        view
        returns (
            IIntegrationManager.SpendAssetsHandleType spendAssetsHandleType_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_,
            uint256[] memory minIncomingAssetAmounts_
        )
    {
        (
            address pool,
            address outgoingStakingToken,
            uint256 outgoingStakingTokenAmount,
            bool useUnderlyings,
            RedeemType redeemType,
            bytes memory incomingAssetsData
        ) = __decodeUnstakeAndRedeemCallArgs(_actionData);

        __validatePoolForWrapper(pool, outgoingStakingToken);

        spendAssets_ = new address[](1);
        spendAssets_[0] = outgoingStakingToken;

        spendAssetAmounts_ = new uint256[](1);
        spendAssetAmounts_[0] = outgoingStakingTokenAmount;

        (incomingAssets_, minIncomingAssetAmounts_) = __parseIncomingAssetsForRedemptionCalls(
            pool,
            useUnderlyings,
            redeemType,
            incomingAssetsData
        );

        // SpendAssetsHandleType is `Approve`, since staking wrapper allows unstaking on behalf
        return (
            IIntegrationManager.SpendAssetsHandleType.Approve,
            spendAssets_,
            spendAssetAmounts_,
            incomingAssets_,
            minIncomingAssetAmounts_
        );
    }

    /// @dev Helper to validate a given Curve `pool` for a given convex staking wrapper
    function __validatePoolForWrapper(address _pool, address _wrapper) private view {
        address lpToken = STAKING_WRAPPER_FACTORY_CONTRACT.getCurveLpTokenForWrapper(_wrapper);
        require(
            lpToken == CURVE_PRICE_FEED_CONTRACT.getLpTokenForPool(_pool),
            "__validatePoolForWrapper: Invalid"
        );
    }
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "../../../../utils/AssetHelpers.sol";
import "../IIntegrationAdapter.sol";
import "./IntegrationSelectors.sol";

/// @title AdapterBase Contract
/// @author Enzyme Council <[email protected]>
/// @notice A base contract for integration adapters
abstract contract AdapterBase is IIntegrationAdapter, IntegrationSelectors, AssetHelpers {
    using SafeERC20 for ERC20;

    address internal immutable INTEGRATION_MANAGER;

    /// @dev Provides a standard implementation for transferring incoming assets
    /// from an adapter to a VaultProxy at the end of an adapter action
    modifier postActionIncomingAssetsTransferHandler(
        address _vaultProxy,
        bytes memory _assetData
    ) {
        _;

        (, , address[] memory incomingAssets) = __decodeAssetData(_assetData);

        __pushFullAssetBalances(_vaultProxy, incomingAssets);
    }

    /// @dev Provides a standard implementation for transferring unspent spend assets
    /// from an adapter to a VaultProxy at the end of an adapter action
    modifier postActionSpendAssetsTransferHandler(address _vaultProxy, bytes memory _assetData) {
        _;

        (address[] memory spendAssets, , ) = __decodeAssetData(_assetData);

        __pushFullAssetBalances(_vaultProxy, spendAssets);
    }

    modifier onlyIntegrationManager {
        require(
            msg.sender == INTEGRATION_MANAGER,
            "Only the IntegrationManager can call this function"
        );
        _;
    }

    constructor(address _integrationManager) public {
        INTEGRATION_MANAGER = _integrationManager;
    }

    // INTERNAL FUNCTIONS

    /// @dev Helper to decode the _assetData param passed to adapter call
    function __decodeAssetData(bytes memory _assetData)
        internal
        pure
        returns (
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_,
            address[] memory incomingAssets_
        )
    {
        return abi.decode(_assetData, (address[], uint256[], address[]));
    }

    ///////////////////
    // STATE GETTERS //
    ///////////////////

    /// @notice Gets the `INTEGRATION_MANAGER` variable
    /// @return integrationManager_ The `INTEGRATION_MANAGER` variable value
    function getIntegrationManager() external view returns (address integrationManager_) {
        return INTEGRATION_MANAGER;
    }
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

/// @title IntegrationSelectors Contract
/// @author Enzyme Council <[email protected]>
/// @notice Selectors for integration actions
/// @dev Selectors are created from their signatures rather than hardcoded for easy verification
abstract contract IntegrationSelectors {
    // Trading
    bytes4 public constant TAKE_ORDER_SELECTOR = bytes4(
        keccak256("takeOrder(address,bytes,bytes)")
    );

    // Lending
    bytes4 public constant LEND_SELECTOR = bytes4(keccak256("lend(address,bytes,bytes)"));
    bytes4 public constant REDEEM_SELECTOR = bytes4(keccak256("redeem(address,bytes,bytes)"));

    // Staking
    bytes4 public constant STAKE_SELECTOR = bytes4(keccak256("stake(address,bytes,bytes)"));
    bytes4 public constant UNSTAKE_SELECTOR = bytes4(keccak256("unstake(address,bytes,bytes)"));

    // Rewards
    bytes4 public constant CLAIM_REWARDS_SELECTOR = bytes4(
        keccak256("claimRewards(address,bytes,bytes)")
    );

    // Combined
    bytes4 public constant LEND_AND_STAKE_SELECTOR = bytes4(
        keccak256("lendAndStake(address,bytes,bytes)")
    );
    bytes4 public constant UNSTAKE_AND_REDEEM_SELECTOR = bytes4(
        keccak256("unstakeAndRedeem(address,bytes,bytes)")
    );
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../../../../../interfaces/IWETH.sol";
import "../../../../../utils/AssetHelpers.sol";

/// @title CurveLiquidityActionsMixin Contract
/// @author Enzyme Council <[email protected]>
/// @notice Mixin contract for interacting with the Curve pool liquidity functions
/// @dev Inheriting contract must have a receive() function if lending or redeeming for the native asset
abstract contract CurveLiquidityActionsMixin is AssetHelpers {
    using Strings for uint256;

    uint256 private constant ASSET_APPROVAL_TOP_UP_THRESHOLD = 1e76; // Arbitrary, slightly less than 1/11 of max uint256

    bytes4 private constant CURVE_REMOVE_LIQUIDITY_ONE_COIN_SELECTOR = 0x1a4d01d2;
    bytes4 private constant CURVE_REMOVE_LIQUIDITY_ONE_COIN_USE_UNDERLYINGS_SELECTOR = 0x517a55a3;

    address private immutable CURVE_LIQUIDITY_WRAPPED_NATIVE_ASSET;

    constructor(address _wrappedNativeAsset) public {
        CURVE_LIQUIDITY_WRAPPED_NATIVE_ASSET = _wrappedNativeAsset;
    }

    /// @dev Helper to add liquidity to the pool.
    /// _squashedOutgoingAssets are only those pool assets that are actually used to add liquidity,
    /// which can be verbose and ordered, but it is more gas-efficient to only include non-0 amounts.
    function __curveAddLiquidity(
        address _pool,
        address[] memory _squashedOutgoingAssets,
        uint256[] memory _orderedOutgoingAssetAmounts,
        uint256 _minIncomingLpTokenAmount,
        bool _useUnderlyings
    ) internal {
        // Approve and/or unwrap native asset as necessary.
        // Rather than using exact amounts for approvals,
        // this tops up to max approval if 1/2 max is reached.
        uint256 outgoingNativeAssetAmount;
        for (uint256 i; i < _squashedOutgoingAssets.length; i++) {
            if (_squashedOutgoingAssets[i] == getCurveLiquidityWrappedNativeAsset()) {
                // It is never the case that a pool has multiple slots for the same native asset,
                // so this is not additive
                outgoingNativeAssetAmount = ERC20(getCurveLiquidityWrappedNativeAsset()).balanceOf(
                    address(this)
                );
                IWETH(getCurveLiquidityWrappedNativeAsset()).withdraw(outgoingNativeAssetAmount);
            } else {
                // Once an asset it approved for a given pool, it will almost definitely
                // never need approval again, but it is topped up to max once an arbitrary
                // threshold is reached
                __approveAssetMaxAsNeeded(
                    _squashedOutgoingAssets[i],
                    _pool,
                    ASSET_APPROVAL_TOP_UP_THRESHOLD
                );
            }
        }

        // Dynamically call the appropriate selector
        (bool success, bytes memory returnData) = _pool.call{value: outgoingNativeAssetAmount}(
            __curveAddLiquidityEncodeCalldata(
                _orderedOutgoingAssetAmounts,
                _minIncomingLpTokenAmount,
                _useUnderlyings
            )
        );
        require(success, string(returnData));
    }

    /// @dev Helper to remove liquidity from the pool.
    /// if using _redeemSingleAsset, must pre-validate that one - and only one - asset
    /// has a non-zero _orderedMinIncomingAssetAmounts value.
    function __curveRemoveLiquidity(
        address _pool,
        uint256 _outgoingLpTokenAmount,
        uint256[] memory _orderedMinIncomingAssetAmounts,
        bool _useUnderlyings
    ) internal {
        // Dynamically call the appropriate selector
        (bool success, bytes memory returnData) = _pool.call(
            __curveRemoveLiquidityEncodeCalldata(
                _outgoingLpTokenAmount,
                _orderedMinIncomingAssetAmounts,
                _useUnderlyings
            )
        );
        require(success, string(returnData));

        // Wrap native asset
        __curveLiquidityWrapNativeAssetBalance();
    }

    /// @dev Helper to remove liquidity from the pool and receive all value owed in one specified token
    function __curveRemoveLiquidityOneCoin(
        address _pool,
        uint256 _outgoingLpTokenAmount,
        int128 _incomingAssetPoolIndex,
        uint256 _minIncomingAssetAmount,
        bool _useUnderlyings
    ) internal {
        bytes memory callData;
        if (_useUnderlyings) {
            callData = abi.encodeWithSelector(
                CURVE_REMOVE_LIQUIDITY_ONE_COIN_USE_UNDERLYINGS_SELECTOR,
                _outgoingLpTokenAmount,
                _incomingAssetPoolIndex,
                _minIncomingAssetAmount,
                true
            );
        } else {
            callData = abi.encodeWithSelector(
                CURVE_REMOVE_LIQUIDITY_ONE_COIN_SELECTOR,
                _outgoingLpTokenAmount,
                _incomingAssetPoolIndex,
                _minIncomingAssetAmount
            );
        }

        // Dynamically call the appropriate selector
        (bool success, bytes memory returnData) = _pool.call(callData);
        require(success, string(returnData));

        // Wrap native asset
        __curveLiquidityWrapNativeAssetBalance();
    }

    // PRIVATE FUNCTIONS

    /// @dev Helper to encode calldata for a call to add liquidity on Curve
    function __curveAddLiquidityEncodeCalldata(
        uint256[] memory _orderedOutgoingAssetAmounts,
        uint256 _minIncomingLpTokenAmount,
        bool _useUnderlyings
    ) private pure returns (bytes memory callData_) {
        bytes memory finalEncodedArgOrEmpty;
        if (_useUnderlyings) {
            finalEncodedArgOrEmpty = abi.encode(true);
        }

        return
            abi.encodePacked(
                __curveAddLiquidityEncodeSelector(
                    _orderedOutgoingAssetAmounts.length,
                    _useUnderlyings
                ),
                abi.encodePacked(_orderedOutgoingAssetAmounts),
                _minIncomingLpTokenAmount,
                finalEncodedArgOrEmpty
            );
    }

    /// @dev Helper to encode selector for a call to add liquidity on Curve
    function __curveAddLiquidityEncodeSelector(uint256 _numberOfCoins, bool _useUnderlyings)
        private
        pure
        returns (bytes4 selector_)
    {
        string memory finalArgOrEmpty;
        if (_useUnderlyings) {
            finalArgOrEmpty = ",bool";
        }

        return
            bytes4(
                keccak256(
                    abi.encodePacked(
                        "add_liquidity(uint256[",
                        _numberOfCoins.toString(),
                        "],",
                        "uint256",
                        finalArgOrEmpty,
                        ")"
                    )
                )
            );
    }

    /// @dev Helper to wrap the full native asset balance of the current contract
    function __curveLiquidityWrapNativeAssetBalance() private {
        uint256 nativeAssetBalance = payable(address(this)).balance;
        if (nativeAssetBalance > 0) {
            IWETH(payable(getCurveLiquidityWrappedNativeAsset())).deposit{
                value: nativeAssetBalance
            }();
        }
    }

    /// @dev Helper to encode calldata for a call to remove liquidity from Curve
    function __curveRemoveLiquidityEncodeCalldata(
        uint256 _outgoingLpTokenAmount,
        uint256[] memory _orderedMinIncomingAssetAmounts,
        bool _useUnderlyings
    ) private pure returns (bytes memory callData_) {
        bytes memory finalEncodedArgOrEmpty;
        if (_useUnderlyings) {
            finalEncodedArgOrEmpty = abi.encode(true);
        }

        return
            abi.encodePacked(
                __curveRemoveLiquidityEncodeSelector(
                    _orderedMinIncomingAssetAmounts.length,
                    _useUnderlyings
                ),
                _outgoingLpTokenAmount,
                abi.encodePacked(_orderedMinIncomingAssetAmounts),
                finalEncodedArgOrEmpty
            );
    }

    /// @dev Helper to encode selector for a call to remove liquidity on Curve
    function __curveRemoveLiquidityEncodeSelector(uint256 _numberOfCoins, bool _useUnderlyings)
        private
        pure
        returns (bytes4 selector_)
    {
        string memory finalArgOrEmpty;
        if (_useUnderlyings) {
            finalArgOrEmpty = ",bool";
        }

        return
            bytes4(
                keccak256(
                    abi.encodePacked(
                        "remove_liquidity(uint256,",
                        "uint256[",
                        _numberOfCoins.toString(),
                        "]",
                        finalArgOrEmpty,
                        ")"
                    )
                )
            );
    }

    ///////////////////
    // STATE GETTERS //
    ///////////////////

    /// @notice Gets the `CURVE_LIQUIDITY_WRAPPED_NATIVE_ASSET` variable
    /// @return addressProvider_ The `CURVE_LIQUIDITY_WRAPPED_NATIVE_ASSET` variable value
    function getCurveLiquidityWrappedNativeAsset() public view returns (address addressProvider_) {
        return CURVE_LIQUIDITY_WRAPPED_NATIVE_ASSET;
    }
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

import "../../../../../infrastructure/staking-wrappers/IStakingWrapper.sol";
import "../../../../../utils/AssetHelpers.sol";

/// @title StakingWrapperActionsMixin Contract
/// @author Enzyme Council <[email protected]>
/// @notice Mixin contract for interacting with IStakingWrapper implementations
abstract contract StakingWrapperActionsMixin is AssetHelpers {
    /// @dev Helper to claim rewards via a IStakingWrapper implementation
    function __stakingWrapperClaimRewardsFor(address _wrapper, address _for) internal {
        IStakingWrapper(_wrapper).claimRewardsFor(_for);
    }

    /// @dev Helper to stake via a IStakingWrapper implementation
    function __stakingWrapperStake(
        address _wrapper,
        address _to,
        uint256 _amount,
        address _outgoingAsset
    ) internal {
        __approveAssetMaxAsNeeded(_outgoingAsset, _wrapper, _amount);
        IStakingWrapper(_wrapper).depositTo(_to, _amount);
    }

    /// @dev Helper to unstake via a IStakingWrapper implementation
    function __stakingWrapperUnstake(
        address _wrapper,
        address _from,
        address _to,
        uint256 _amount,
        bool _claimRewards
    ) internal {
        IStakingWrapper(_wrapper).withdrawToOnBehalf(_from, _to, _amount, _claimRewards);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.12;

import "../../../../../interfaces/ICurveLiquidityPool.sol";
import "../actions/CurveLiquidityActionsMixin.sol";
import "../AdapterBase.sol";

/// @title CurveLiquidityAdapterBase Contract
/// @author Enzyme Council <[email protected]>
/// @notice Base adapter for liquidity provision in Curve pools that adhere to pool templates,
/// as well as some old pools that have almost the same required interface (e.g., 3pool).
/// Implementing contracts can allow staking via Curve gauges, Convex, etc.
abstract contract CurveLiquidityAdapterBase is AdapterBase, CurveLiquidityActionsMixin {
    enum RedeemType {Standard, OneCoin}

    address private immutable CURVE_LIQUIDITY_NATIVE_ASSET_ADDRESS;

    constructor(
        address _integrationManager,
        address _wrappedNativeAsset,
        address _nativeAssetAddress
    ) public AdapterBase(_integrationManager) CurveLiquidityActionsMixin(_wrappedNativeAsset) {
        CURVE_LIQUIDITY_NATIVE_ASSET_ADDRESS = _nativeAssetAddress;
    }

    /// @dev Needed to unwrap and receive the native asset
    receive() external payable {}

    // INTERNAL FUNCTIONS

    /// @dev Helper to return the wrappedNativeAsset if the input is the native asset
    function __castWrappedIfNativeAsset(address _tokenOrNativeAsset)
        internal
        view
        returns (address token_)
    {
        if (_tokenOrNativeAsset == CURVE_LIQUIDITY_NATIVE_ASSET_ADDRESS) {
            return getCurveLiquidityWrappedNativeAsset();
        }

        return _tokenOrNativeAsset;
    }

    /// @dev Helper to correctly call the relevant redeem function based on RedeemType
    function __curveRedeem(
        address _pool,
        uint256 _outgoingLpTokenAmount,
        bool _useUnderlyings,
        RedeemType _redeemType,
        bytes memory _incomingAssetsData
    ) internal {
        if (_redeemType == RedeemType.OneCoin) {
            (
                uint256 incomingAssetPoolIndex,
                uint256 minIncomingAssetAmount
            ) = __decodeIncomingAssetsDataRedeemOneCoin(_incomingAssetsData);

            __curveRemoveLiquidityOneCoin(
                _pool,
                _outgoingLpTokenAmount,
                int128(incomingAssetPoolIndex),
                minIncomingAssetAmount,
                _useUnderlyings
            );
        } else {
            __curveRemoveLiquidity(
                _pool,
                _outgoingLpTokenAmount,
                __decodeIncomingAssetsDataRedeemStandard(_incomingAssetsData),
                _useUnderlyings
            );
        }
    }

    /// @dev Helper function to parse spend assets for redeem() and unstakeAndRedeem() calls
    function __parseIncomingAssetsForRedemptionCalls(
        address _pool,
        bool _useUnderlyings,
        RedeemType _redeemType,
        bytes memory _incomingAssetsData
    )
        internal
        view
        returns (address[] memory incomingAssets_, uint256[] memory minIncomingAssetAmounts_)
    {
        if (_redeemType == RedeemType.OneCoin) {
            (
                uint256 incomingAssetPoolIndex,
                uint256 minIncomingAssetAmount
            ) = __decodeIncomingAssetsDataRedeemOneCoin(_incomingAssetsData);

            // No need to validate incomingAssetPoolIndex,
            // as an out-of-bounds index will fail in the call to Curve
            incomingAssets_ = new address[](1);
            incomingAssets_[0] = __getPoolAsset(_pool, incomingAssetPoolIndex, _useUnderlyings);

            minIncomingAssetAmounts_ = new uint256[](1);
            minIncomingAssetAmounts_[0] = minIncomingAssetAmount;
        } else {
            minIncomingAssetAmounts_ = __decodeIncomingAssetsDataRedeemStandard(
                _incomingAssetsData
            );

            // No need to validate minIncomingAssetAmounts_.length,
            // as an incorrect length will fail with the wrong n_tokens in the call to Curve
            incomingAssets_ = new address[](minIncomingAssetAmounts_.length);
            for (uint256 i; i < incomingAssets_.length; i++) {
                incomingAssets_[i] = __getPoolAsset(_pool, i, _useUnderlyings);
            }
        }

        return (incomingAssets_, minIncomingAssetAmounts_);
    }

    /// @dev Helper function to parse spend assets for lend() and lendAndStake() calls
    function __parseSpendAssetsForLendingCalls(
        address _pool,
        uint256[] memory _orderedOutgoingAssetAmounts,
        bool _useUnderlyings
    ) internal view returns (address[] memory spendAssets_, uint256[] memory spendAssetAmounts_) {
        uint256 spendAssetsCount;
        for (uint256 i; i < _orderedOutgoingAssetAmounts.length; i++) {
            if (_orderedOutgoingAssetAmounts[i] > 0) {
                spendAssetsCount++;
            }
        }

        spendAssets_ = new address[](spendAssetsCount);
        spendAssetAmounts_ = new uint256[](spendAssetsCount);
        uint256 spendAssetsIndex;
        for (uint256 i; i < _orderedOutgoingAssetAmounts.length; i++) {
            if (_orderedOutgoingAssetAmounts[i] > 0) {
                spendAssets_[spendAssetsIndex] = __getPoolAsset(_pool, i, _useUnderlyings);
                spendAssetAmounts_[spendAssetsIndex] = _orderedOutgoingAssetAmounts[i];
                spendAssetsIndex++;

                if (spendAssetsIndex == spendAssetsCount) {
                    break;
                }
            }
        }

        return (spendAssets_, spendAssetAmounts_);
    }

    /// @dev Helper to get a pool asset at a given index
    function __getPoolAsset(
        address _pool,
        uint256 _index,
        bool _useUnderlying
    ) internal view returns (address asset_) {
        if (_useUnderlying) {
            try ICurveLiquidityPool(_pool).underlying_coins(_index) returns (
                address underlyingCoin
            ) {
                asset_ = underlyingCoin;
            } catch {
                asset_ = ICurveLiquidityPool(_pool).underlying_coins(int128(_index));
            }
        } else {
            try ICurveLiquidityPool(_pool).coins(_index) returns (address coin) {
                asset_ = coin;
            } catch {
                asset_ = ICurveLiquidityPool(_pool).coins(int128(_index));
            }
        }

        return __castWrappedIfNativeAsset(asset_);
    }

    ///////////////////////
    // ENCODED CALL ARGS //
    ///////////////////////

    // Some of these decodings are not relevant to inheriting contracts,
    // and some parameters will be ignored, but this keeps the payloads
    // consistent for all inheriting adapters.

    /// @dev Helper to decode the encoded call arguments for claiming rewards
    function __decodeClaimRewardsCallArgs(bytes memory _actionData)
        internal
        pure
        returns (address stakingToken_)
    {
        return abi.decode(_actionData, (address));
    }

    /// @dev Helper to decode the encoded call arguments for lending and then staking
    function __decodeLendAndStakeCallArgs(bytes memory _actionData)
        internal
        pure
        returns (
            address pool_,
            uint256[] memory orderedOutgoingAssetAmounts_,
            address incomingStakingToken_,
            uint256 minIncomingStakingTokenAmount_,
            bool useUnderlyings_
        )
    {
        return abi.decode(_actionData, (address, uint256[], address, uint256, bool));
    }

    /// @dev Helper to decode the encoded call arguments for lending
    function __decodeLendCallArgs(bytes memory _actionData)
        internal
        pure
        returns (
            address pool_,
            uint256[] memory orderedOutgoingAssetAmounts_,
            uint256 minIncomingLpTokenAmount_,
            bool useUnderlyings_
        )
    {
        return abi.decode(_actionData, (address, uint256[], uint256, bool));
    }

    /// @dev Helper to decode the encoded call arguments for redeeming
    function __decodeRedeemCallArgs(bytes memory _actionData)
        internal
        pure
        returns (
            address pool_,
            uint256 outgoingLpTokenAmount_,
            bool useUnderlyings_,
            RedeemType redeemType_,
            bytes memory incomingAssetsData_
        )
    {
        return abi.decode(_actionData, (address, uint256, bool, RedeemType, bytes));
    }

    /// @dev Helper to decode the encoded incoming assets arguments for RedeemType.OneCoin
    function __decodeIncomingAssetsDataRedeemOneCoin(bytes memory _incomingAssetsData)
        internal
        pure
        returns (uint256 incomingAssetPoolIndex_, uint256 minIncomingAssetAmount_)
    {
        return abi.decode(_incomingAssetsData, (uint256, uint256));
    }

    /// @dev Helper to decode the encoded incoming assets arguments for RedeemType.Standard
    function __decodeIncomingAssetsDataRedeemStandard(bytes memory _incomingAssetsData)
        internal
        pure
        returns (uint256[] memory orderedMinIncomingAssetAmounts_)
    {
        return abi.decode(_incomingAssetsData, (uint256[]));
    }

    /// @dev Helper to decode the encoded call arguments for staking
    function __decodeStakeCallArgs(bytes memory _actionData)
        internal
        pure
        returns (
            address pool_,
            address incomingStakingToken_,
            uint256 amount_
        )
    {
        return abi.decode(_actionData, (address, address, uint256));
    }

    /// @dev Helper to decode the encoded call arguments for unstaking and then redeeming
    function __decodeUnstakeAndRedeemCallArgs(bytes memory _actionData)
        internal
        pure
        returns (
            address pool_,
            address outgoingStakingToken_,
            uint256 outgoingStakingTokenAmount_,
            bool useUnderlyings_,
            RedeemType redeemType_,
            bytes memory incomingAssetsData_
        )
    {
        return abi.decode(_actionData, (address, address, uint256, bool, RedeemType, bytes));
    }

    /// @dev Helper to decode the encoded call arguments for unstaking
    function __decodeUnstakeCallArgs(bytes memory _actionData)
        internal
        pure
        returns (
            address pool_,
            address outgoingStakingToken_,
            uint256 amount_
        )
    {
        return abi.decode(_actionData, (address, address, uint256));
    }
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

/// @title IDerivativePriceFeed Interface
/// @author Enzyme Council <[email protected]>
/// @notice Simple interface for derivative price source oracle implementations
interface IDerivativePriceFeed {
    function calcUnderlyingValues(address, uint256)
        external
        returns (address[] memory, uint256[] memory);

    function isSupportedAsset(address) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../../../../interfaces/ICurveAddressProvider.sol";
import "../../../../interfaces/ICurveLiquidityPool.sol";
import "../../../../interfaces/ICurvePoolOwner.sol";
import "../../../../interfaces/ICurveRegistryMain.sol";
import "../../../../interfaces/ICurveRegistryMetapoolFactory.sol";
import "../../../../utils/FundDeployerOwnerMixin.sol";
import "../IDerivativePriceFeed.sol";

/// @title CurvePriceFeed Contract
/// @author Enzyme Council <[email protected]>
/// @notice Price feed for Curve pool tokens
contract CurvePriceFeed is IDerivativePriceFeed, FundDeployerOwnerMixin {
    using SafeMath for uint256;

    event CurvePoolOwnerSet(address poolOwner);

    event DerivativeAdded(address indexed derivative, address indexed pool);

    event DerivativeRemoved(address indexed derivative);

    event InvariantProxyAssetForPoolSet(address indexed pool, address indexed invariantProxyAsset);

    event PoolRemoved(address indexed pool);

    event ValidatedVirtualPriceForPoolUpdated(address indexed pool, uint256 virtualPrice);

    uint256 private constant ADDRESS_PROVIDER_METAPOOL_FACTORY_ID = 3;
    uint256 private constant VIRTUAL_PRICE_DEVIATION_DIVISOR = 10000;
    uint256 private constant VIRTUAL_PRICE_UNIT = 10**18;

    ICurveAddressProvider private immutable ADDRESS_PROVIDER_CONTRACT;
    uint256 private immutable VIRTUAL_PRICE_DEVIATION_THRESHOLD;

    // We take one asset as representative of the pool's invariant, e.g., WETH for ETH-based pools.
    // Caching invariantProxyAssetDecimals in a packed storage slot
    // removes an additional external call and cold SLOAD operation during value lookups.
    struct PoolInfo {
        address invariantProxyAsset; // 20 bytes
        uint8 invariantProxyAssetDecimals; // 1 byte
        uint88 lastValidatedVirtualPrice; // 11 bytes (could safely be 8-10 bytes)
    }

    address private curvePoolOwner;

    // Pool tokens and liquidity gauge tokens are treated the same for pricing purposes
    mapping(address => address) private derivativeToPool;
    mapping(address => PoolInfo) private poolToPoolInfo;

    // Not necessary for this contract, but used by Curve liquidity adapters
    mapping(address => address) private poolToLpToken;

    constructor(
        address _fundDeployer,
        address _addressProvider,
        address _poolOwner,
        uint256 _virtualPriceDeviationThreshold
    ) public FundDeployerOwnerMixin(_fundDeployer) {
        ADDRESS_PROVIDER_CONTRACT = ICurveAddressProvider(_addressProvider);
        VIRTUAL_PRICE_DEVIATION_THRESHOLD = _virtualPriceDeviationThreshold;

        __setCurvePoolOwner(_poolOwner);
    }

    /// @notice Converts a given amount of a derivative to its underlying asset values
    /// @param _derivative The derivative to convert
    /// @param _derivativeAmount The amount of the derivative to convert
    /// @return underlyings_ The underlying assets for the _derivative
    /// @return underlyingAmounts_ The amount of each underlying asset for the equivalent derivative amount
    function calcUnderlyingValues(address _derivative, uint256 _derivativeAmount)
        external
        override
        returns (address[] memory underlyings_, uint256[] memory underlyingAmounts_)
    {
        address pool = getPoolForDerivative(_derivative);
        require(pool != address(0), "calcUnderlyingValues: _derivative is not supported");

        PoolInfo memory poolInfo = getPoolInfo(pool);

        uint256 virtualPrice = ICurveLiquidityPool(pool).get_virtual_price();

        // Validate and update the cached lastValidatedVirtualPrice if:
        /// 1. a pool requires virtual price validation, and
        /// 2. the unvalidated `virtualPrice` deviates from the PoolInfo.lastValidatedVirtualPrice value
        /// by more than the tolerated "deviation threshold" (e.g., 1%).
        /// This is an optimization to save gas on validating non-reentrancy during the virtual price query,
        /// since the virtual price increases relatively slowly as the pool accrues fees over time.
        if (
            poolInfo.lastValidatedVirtualPrice > 0 &&
            __virtualPriceDiffExceedsThreshold(
                virtualPrice,
                uint256(poolInfo.lastValidatedVirtualPrice)
            )
        ) {
            __updateValidatedVirtualPrice(pool, virtualPrice);
        }

        underlyings_ = new address[](1);
        underlyings_[0] = poolInfo.invariantProxyAsset;

        underlyingAmounts_ = new uint256[](1);
        if (poolInfo.invariantProxyAssetDecimals == 18) {
            underlyingAmounts_[0] = _derivativeAmount.mul(virtualPrice).div(VIRTUAL_PRICE_UNIT);
        } else {
            underlyingAmounts_[0] = _derivativeAmount
                .mul(virtualPrice)
                .mul(10**uint256(poolInfo.invariantProxyAssetDecimals))
                .div(VIRTUAL_PRICE_UNIT)
                .div(VIRTUAL_PRICE_UNIT);
        }

        return (underlyings_, underlyingAmounts_);
    }

    /// @notice Checks if an asset is supported by the price feed
    /// @param _asset The asset to check
    /// @return isSupported_ True if the asset is supported
    function isSupportedAsset(address _asset) external view override returns (bool isSupported_) {
        return getPoolForDerivative(_asset) != address(0);
    }

    //////////////////////////
    // DERIVATIVES REGISTRY //
    //////////////////////////

    // addPools() is the primary action to add validated lpTokens and gaugeTokens as derivatives.
    // addGaugeTokens() can be used to add validated gauge tokens for an already-registered pool.
    // addPoolsWithoutValidation() and addGaugeTokensWithoutValidation() can be used as overrides.
    // It is possible to remove all pool data and derivatives (separately).
    // It is possible to update the invariant proxy asset for any pool.
    // It is possible to update whether the pool's virtual price is reenterable.

    /// @notice Adds validated gaugeTokens to the price feed
    /// @param _gaugeTokens The ordered gauge tokens
    /// @param _pools The ordered pools corresponding to _gaugeTokens
    /// @dev All params are corresponding, equal length arrays.
    /// _pools must already have been added via an addPools~() function
    function addGaugeTokens(address[] calldata _gaugeTokens, address[] calldata _pools)
        external
        onlyFundDeployerOwner
    {
        ICurveRegistryMain registryContract = __getRegistryMainContract();
        ICurveRegistryMetapoolFactory factoryContract = __getRegistryMetapoolFactoryContract();

        for (uint256 i; i < _gaugeTokens.length; i++) {
            if (factoryContract.get_gauge(_pools[i]) != _gaugeTokens[i]) {
                __validateGaugeMainRegistry(_gaugeTokens[i], _pools[i], registryContract);
            }
        }

        __addGaugeTokens(_gaugeTokens, _pools);
    }

    /// @notice Adds unvalidated gaugeTokens to the price feed
    /// @param _gaugeTokens The ordered gauge tokens
    /// @param _pools The ordered pools corresponding to _gaugeTokens
    /// @dev Should only be used if something is incorrectly failing in the registry validation,
    /// or if gauge tokens exist outside of the registries supported by this price feed,
    /// e.g., a wrapper for non-tokenized gauges.
    /// All params are corresponding, equal length arrays.
    /// _pools must already have been added via an addPools~() function.
    function addGaugeTokensWithoutValidation(
        address[] calldata _gaugeTokens,
        address[] calldata _pools
    ) external onlyFundDeployerOwner {
        __addGaugeTokens(_gaugeTokens, _pools);
    }

    /// @notice Adds validated Curve pool info, lpTokens, and gaugeTokens to the price feed
    /// @param _pools The ordered Curve pools
    /// @param _invariantProxyAssets The ordered invariant proxy assets corresponding to _pools,
    /// e.g., WETH for ETH-based pools
    /// @param _reentrantVirtualPrices The ordered flags corresponding to _pools,
    /// true if the get_virtual_price() function is potentially reenterable
    /// @param _lpTokens The ordered lpToken corresponding to _pools
    /// @param _gaugeTokens The ordered gauge token corresponding to _pools
    /// @dev All params are corresponding, equal length arrays.
    /// address(0) can be used for any _gaugeTokens index to omit the gauge (e.g., no gauge token exists).
    /// _lpTokens is not technically necessary since it is knowable from a Curve registry,
    /// but it's better to use Curve's upgradable contracts as an input validation rather than fully-trusted.
    function addPools(
        address[] calldata _pools,
        address[] calldata _invariantProxyAssets,
        bool[] calldata _reentrantVirtualPrices,
        address[] calldata _lpTokens,
        address[] calldata _gaugeTokens
    ) external onlyFundDeployerOwner {
        ICurveRegistryMain registryContract = __getRegistryMainContract();
        ICurveRegistryMetapoolFactory factoryContract = __getRegistryMetapoolFactoryContract();

        for (uint256 i; i < _pools.length; i++) {
            // Validate the lpToken and gauge token based on registry
            if (_lpTokens[i] == registryContract.get_lp_token(_pools[i])) {
                // Main registry

                if (_gaugeTokens[i] != address(0)) {
                    __validateGaugeMainRegistry(_gaugeTokens[i], _pools[i], registryContract);
                }
            } else if (_lpTokens[i] == _pools[i] && factoryContract.get_n_coins(_pools[i]) > 0) {
                // Metapool factory registry
                // lpToken and pool are the same address
                // get_n_coins() is arbitrarily used to validate the pool is on this registry

                if (_gaugeTokens[i] != address(0)) {
                    __validateGaugeMetapoolFactoryRegistry(
                        _gaugeTokens[i],
                        _pools[i],
                        factoryContract
                    );
                }
            } else {
                revert("addPools: Invalid inputs");
            }
        }

        __addPools(
            _pools,
            _invariantProxyAssets,
            _reentrantVirtualPrices,
            _lpTokens,
            _gaugeTokens
        );
    }

    /// @notice Adds unvalidated Curve pool info, lpTokens, and gaugeTokens to the price feed
    /// @param _pools The ordered Curve pools
    /// @param _invariantProxyAssets The ordered invariant proxy assets corresponding to _pools,
    /// e.g., WETH for ETH-based pools
    /// @param _reentrantVirtualPrices The ordered flags corresponding to _pools,
    /// true if the get_virtual_price() function is potentially reenterable
    /// @param _lpTokens The ordered lpToken corresponding to _pools
    /// @param _gaugeTokens The ordered gauge token corresponding to _pools
    /// @dev Should only be used if something is incorrectly failing in the registry validation,
    /// or if pools exist outside of the registries supported by this price feed.
    /// All params are corresponding, equal length arrays.
    /// address(0) can be used for any _gaugeTokens index to omit the gauge (e.g., no gauge token exists).
    function addPoolsWithoutValidation(
        address[] calldata _pools,
        address[] calldata _invariantProxyAssets,
        bool[] calldata _reentrantVirtualPrices,
        address[] calldata _lpTokens,
        address[] calldata _gaugeTokens
    ) external onlyFundDeployerOwner {
        __addPools(
            _pools,
            _invariantProxyAssets,
            _reentrantVirtualPrices,
            _lpTokens,
            _gaugeTokens
        );
    }

    /// @notice Removes derivatives from the price feed
    /// @param _derivatives The derivatives to remove
    /// @dev Unlikely to be needed, just in case of bad storage entry.
    /// Can remove both lpToken and gaugeToken from derivatives list,
    /// but does not remove lpToken from pool info cache.
    function removeDerivatives(address[] calldata _derivatives) external onlyFundDeployerOwner {
        for (uint256 i; i < _derivatives.length; i++) {
            delete derivativeToPool[_derivatives[i]];

            emit DerivativeRemoved(_derivatives[i]);
        }
    }

    /// @notice Removes pools from the price feed
    /// @param _pools The pools to remove
    /// @dev Unlikely to be needed, just in case of bad storage entry.
    /// Does not remove lpToken nor gauge tokens from derivatives list.
    function removePools(address[] calldata _pools) external onlyFundDeployerOwner {
        for (uint256 i; i < _pools.length; i++) {
            delete poolToPoolInfo[_pools[i]];
            delete poolToLpToken[_pools[i]];

            emit PoolRemoved(_pools[i]);
        }
    }

    /// @notice Sets the Curve pool owner
    /// @param _nextPoolOwner The next pool owner value
    function setCurvePoolOwner(address _nextPoolOwner) external onlyFundDeployerOwner {
        __setCurvePoolOwner(_nextPoolOwner);
    }

    /// @notice Updates the PoolInfo for the given pools
    /// @param _pools The ordered pools
    /// @param _invariantProxyAssets The ordered invariant asset proxy assets
    /// @param _reentrantVirtualPrices The ordered flags corresponding to _pools,
    /// true if the get_virtual_price() function is potentially reenterable
    function updatePoolInfo(
        address[] calldata _pools,
        address[] calldata _invariantProxyAssets,
        bool[] calldata _reentrantVirtualPrices
    ) external onlyFundDeployerOwner {
        require(
            _pools.length == _invariantProxyAssets.length &&
                _pools.length == _reentrantVirtualPrices.length,
            "updatePoolInfo: Unequal arrays"
        );

        for (uint256 i; i < _pools.length; i++) {
            __setPoolInfo(_pools[i], _invariantProxyAssets[i], _reentrantVirtualPrices[i]);
        }
    }

    // PRIVATE FUNCTIONS

    /// @dev Helper to add a derivative to the price feed
    function __addDerivative(address _derivative, address _pool) private {
        require(
            getPoolForDerivative(_derivative) == address(0),
            "__addDerivative: Already exists"
        );

        // Assert that the assumption that all Curve pool tokens are 18 decimals
        require(ERC20(_derivative).decimals() == 18, "__addDerivative: Not 18-decimal");

        derivativeToPool[_derivative] = _pool;

        emit DerivativeAdded(_derivative, _pool);
    }

    /// @dev Helper for common logic in addGauges~() functions
    function __addGaugeTokens(address[] calldata _gaugeTokens, address[] calldata _pools) private {
        require(_gaugeTokens.length == _pools.length, "__addGaugeTokens: Unequal arrays");

        for (uint256 i; i < _gaugeTokens.length; i++) {
            require(
                getLpTokenForPool(_pools[i]) != address(0),
                "__addGaugeTokens: Pool not registered"
            );
            // Not-yet-registered _gaugeTokens[i] tested in __addDerivative()

            __addDerivative(_gaugeTokens[i], _pools[i]);
        }
    }

    /// @dev Helper for common logic in addPools~() functions
    function __addPools(
        address[] calldata _pools,
        address[] calldata _invariantProxyAssets,
        bool[] calldata _reentrantVirtualPrices,
        address[] calldata _lpTokens,
        address[] calldata _gaugeTokens
    ) private {
        require(
            _pools.length == _invariantProxyAssets.length &&
                _pools.length == _reentrantVirtualPrices.length &&
                _pools.length == _lpTokens.length &&
                _pools.length == _gaugeTokens.length,
            "__addPools: Unequal arrays"
        );

        for (uint256 i; i < _pools.length; i++) {
            // Redundant for validated addPools()
            require(_lpTokens[i] != address(0), "__addPools: Empty lpToken");
            // Empty _pools[i] reverts during __validatePoolCompatibility
            // Empty _invariantProxyAssets[i] reverts during __setPoolInfo

            // Validate new pool's compatibility with price feed
            require(getLpTokenForPool(_pools[i]) == address(0), "__addPools: Already registered");
            __validatePoolCompatibility(_pools[i]);

            // Register pool info
            __setPoolInfo(_pools[i], _invariantProxyAssets[i], _reentrantVirtualPrices[i]);
            poolToLpToken[_pools[i]] = _lpTokens[i];

            // Add lpToken and gauge token as derivatives
            __addDerivative(_lpTokens[i], _pools[i]);
            if (_gaugeTokens[i] != address(0)) {
                __addDerivative(_gaugeTokens[i], _pools[i]);
            }
        }
    }

    /// @dev Helper to get the main Curve registry contract
    function __getRegistryMainContract() private view returns (ICurveRegistryMain contract_) {
        return ICurveRegistryMain(ADDRESS_PROVIDER_CONTRACT.get_registry());
    }

    /// @dev Helper to get the Curve metapool factory registry contract
    function __getRegistryMetapoolFactoryContract()
        private
        view
        returns (ICurveRegistryMetapoolFactory contract_)
    {
        return
            ICurveRegistryMetapoolFactory(
                ADDRESS_PROVIDER_CONTRACT.get_address(ADDRESS_PROVIDER_METAPOOL_FACTORY_ID)
            );
    }

    /// @dev Helper to call a known non-reenterable pool function
    function __makeNonReentrantPoolCall(address _pool) private {
        ICurvePoolOwner(getCurvePoolOwner()).withdraw_admin_fees(_pool);
    }

    /// @dev Helper to set the Curve pool owner
    function __setCurvePoolOwner(address _nextPoolOwner) private {
        curvePoolOwner = _nextPoolOwner;

        emit CurvePoolOwnerSet(_nextPoolOwner);
    }

    /// @dev Helper to set the PoolInfo for a given pool
    function __setPoolInfo(
        address _pool,
        address _invariantProxyAsset,
        bool _reentrantVirtualPrice
    ) private {
        uint256 lastValidatedVirtualPrice;
        if (_reentrantVirtualPrice) {
            // Validate the virtual price by calling a non-reentrant pool function
            __makeNonReentrantPoolCall(_pool);

            lastValidatedVirtualPrice = ICurveLiquidityPool(_pool).get_virtual_price();

            emit ValidatedVirtualPriceForPoolUpdated(_pool, lastValidatedVirtualPrice);
        }

        poolToPoolInfo[_pool] = PoolInfo({
            invariantProxyAsset: _invariantProxyAsset,
            invariantProxyAssetDecimals: ERC20(_invariantProxyAsset).decimals(),
            lastValidatedVirtualPrice: uint88(lastValidatedVirtualPrice)
        });

        emit InvariantProxyAssetForPoolSet(_pool, _invariantProxyAsset);
    }

    /// @dev Helper to update the last validated virtual price for a given pool
    function __updateValidatedVirtualPrice(address _pool, uint256 _virtualPrice) private {
        // Validate the virtual price by calling a non-reentrant pool function
        __makeNonReentrantPoolCall(_pool);

        // _virtualPrice is now considered valid
        poolToPoolInfo[_pool].lastValidatedVirtualPrice = uint88(_virtualPrice);

        emit ValidatedVirtualPriceForPoolUpdated(_pool, _virtualPrice);
    }

    /// @dev Helper to validate a gauge on the main Curve registry
    function __validateGaugeMainRegistry(
        address _gauge,
        address _pool,
        ICurveRegistryMain _mainRegistryContract
    ) private view {
        (address[10] memory gauges, ) = _mainRegistryContract.get_gauges(_pool);
        for (uint256 i; i < gauges.length; i++) {
            if (_gauge == gauges[i]) {
                return;
            }
        }

        revert("__validateGaugeMainRegistry: Invalid gauge");
    }

    /// @dev Helper to validate a gauge on the Curve metapool factory registry
    function __validateGaugeMetapoolFactoryRegistry(
        address _gauge,
        address _pool,
        ICurveRegistryMetapoolFactory _metapoolFactoryRegistryContract
    ) private view {
        require(
            _gauge == _metapoolFactoryRegistryContract.get_gauge(_pool),
            "__validateGaugeMetapoolFactoryRegistry: Invalid gauge"
        );
    }

    /// @dev Helper to validate a pool's compatibility with the price feed.
    /// Pool must implement expected get_virtual_price() function.
    function __validatePoolCompatibility(address _pool) private view {
        require(
            ICurveLiquidityPool(_pool).get_virtual_price() > 0,
            "__validatePoolCompatibility: Incompatible"
        );
    }

    /// @dev Helper to check if the difference between lastValidatedVirtualPrice and the current virtual price
    /// exceeds the allowed threshold before the current virtual price must be validated and stored
    function __virtualPriceDiffExceedsThreshold(
        uint256 _currentVirtualPrice,
        uint256 _lastValidatedVirtualPrice
    ) private view returns (bool exceedsThreshold_) {
        // Uses the absolute delta between current and last validated virtual prices for the rare
        // case where a virtual price might have decreased (e.g., rounding, slashing, yet unknown
        // manipulation vector, etc)
        uint256 absDiff;
        if (_currentVirtualPrice > _lastValidatedVirtualPrice) {
            absDiff = _currentVirtualPrice.sub(_lastValidatedVirtualPrice);
        } else {
            absDiff = _lastValidatedVirtualPrice.sub(_currentVirtualPrice);
        }

        return
            absDiff >
            _lastValidatedVirtualPrice.mul(VIRTUAL_PRICE_DEVIATION_THRESHOLD).div(
                VIRTUAL_PRICE_DEVIATION_DIVISOR
            );
    }

    ///////////////////
    // STATE GETTERS //
    ///////////////////

    /// @notice Gets the Curve pool owner
    /// @return poolOwner_ The Curve pool owner
    function getCurvePoolOwner() public view returns (address poolOwner_) {
        return curvePoolOwner;
    }

    /// @notice Gets the lpToken for a given pool
    /// @param _pool The pool
    /// @return lpToken_ The lpToken
    function getLpTokenForPool(address _pool) public view returns (address lpToken_) {
        return poolToLpToken[_pool];
    }

    /// @notice Gets the stored PoolInfo for a given pool
    /// @param _pool The pool
    /// @return poolInfo_ The PoolInfo
    function getPoolInfo(address _pool) public view returns (PoolInfo memory poolInfo_) {
        return poolToPoolInfo[_pool];
    }

    /// @notice Gets the pool for a given derivative
    /// @param _derivative The derivative
    /// @return pool_ The pool
    function getPoolForDerivative(address _derivative) public view returns (address pool_) {
        return derivativeToPool[_derivative];
    }
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

/// @title IStakingWrapper interface
/// @author Enzyme Council <[email protected]>
interface IStakingWrapper {
    struct TotalHarvestData {
        uint128 integral;
        uint128 lastCheckpointBalance;
    }

    struct UserHarvestData {
        uint128 integral;
        uint128 claimableReward;
    }

    function claimRewardsFor(address _for)
        external
        returns (address[] memory rewardTokens_, uint256[] memory claimedAmounts_);

    function deposit(uint256 _amount) external;

    function depositTo(address _to, uint256 _amount) external;

    function withdraw(uint256 _amount, bool _claimRewards)
        external
        returns (address[] memory rewardTokens_, uint256[] memory claimedAmounts_);

    function withdrawTo(
        address _to,
        uint256 _amount,
        bool _claimRewardsToHolder
    ) external;

    function withdrawToOnBehalf(
        address _onBehalf,
        address _to,
        uint256 _amount,
        bool _claimRewardsToHolder
    ) external;

    // STATE GETTERS

    function getRewardTokenAtIndex(uint256 _index) external view returns (address rewardToken_);

    function getRewardTokenCount() external view returns (uint256 count_);

    function getRewardTokens() external view returns (address[] memory rewardTokens_);

    function getTotalHarvestDataForRewardToken(address _rewardToken)
        external
        view
        returns (TotalHarvestData memory totalHarvestData_);

    function getUserHarvestDataForRewardToken(address _user, address _rewardToken)
        external
        view
        returns (UserHarvestData memory userHarvestData_);

    function isPaused() external view returns (bool isPaused_);
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../../utils/AddressArrayLib.sol";
import "./IStakingWrapper.sol";

/// @title StakingWrapperBase Contract
/// @author Enzyme Council <[email protected]>
/// @notice A base contract for staking wrappers
/// @dev Can be used as a base for both standard deployments and proxy targets.
/// Draws on Convex's ConvexStakingWrapper implementation (https://github.com/convex-eth/platform/blob/main/contracts/contracts/wrappers/ConvexStakingWrapper.sol),
/// which is based on Curve.fi gauge wrappers (https://github.com/curvefi/curve-dao-contracts/tree/master/contracts/gauges/wrappers)
abstract contract StakingWrapperBase is IStakingWrapper, ERC20, ReentrancyGuard {
    using AddressArrayLib for address[];
    using SafeERC20 for ERC20;
    using SafeMath for uint256;

    event Deposited(address indexed from, address indexed to, uint256 amount);

    event PauseToggled(bool isPaused);

    event RewardsClaimed(
        address caller,
        address indexed user,
        address[] rewardTokens,
        uint256[] claimedAmounts
    );

    event RewardTokenAdded(address token);

    event TotalHarvestIntegralUpdated(address indexed rewardToken, uint256 integral);

    event TotalHarvestLastCheckpointBalanceUpdated(
        address indexed rewardToken,
        uint256 lastCheckpointBalance
    );

    event UserHarvestUpdated(
        address indexed user,
        address indexed rewardToken,
        uint256 integral,
        uint256 claimableReward
    );

    event Withdrawn(
        address indexed caller,
        address indexed from,
        address indexed to,
        uint256 amount
    );

    uint8 private constant DEFAULT_DECIMALS = 18;
    uint256 private constant INTEGRAL_PRECISION = 1e18;
    address internal immutable OWNER;

    // Paused stops new deposits and checkpoints
    bool private paused;
    address[] private rewardTokens;
    mapping(address => TotalHarvestData) private rewardTokenToTotalHarvestData;
    mapping(address => mapping(address => UserHarvestData)) private rewardTokenToUserToHarvestData;

    modifier onlyOwner() {
        require(msg.sender == OWNER, "Only owner callable");
        _;
    }

    constructor(
        address _owner,
        string memory _tokenName,
        string memory _tokenSymbol
    ) public ERC20(_tokenName, _tokenSymbol) {
        OWNER = _owner;
    }

    /// @notice Toggles pause for deposit and harvesting new rewards
    /// @param _isPaused True if next state is paused, false if unpaused
    function togglePause(bool _isPaused) external onlyOwner {
        paused = _isPaused;

        emit PauseToggled(_isPaused);
    }

    ////////////////////////////
    // DEPOSITOR INTERACTIONS //
    ////////////////////////////

    // CLAIM REWARDS

    /// @notice Claims all rewards for a given account
    /// @param _for The account for which to claim rewards
    /// @return rewardTokens_ The reward tokens
    /// @return claimedAmounts_ The reward token amounts claimed
    /// @dev Can be called off-chain to simulate the total harvestable rewards for a particular user
    function claimRewardsFor(address _for)
        external
        override
        nonReentrant
        returns (address[] memory rewardTokens_, uint256[] memory claimedAmounts_)
    {
        return __checkpointAndClaim(_for);
    }

    // DEPOSIT

    /// @notice Deposits tokens to be staked, minting staking token to sender
    /// @param _amount The amount of tokens to deposit
    function deposit(uint256 _amount) external override {
        __deposit(msg.sender, msg.sender, _amount);
    }

    /// @notice Deposits tokens to be staked, minting staking token to a specified account
    /// @param _to The account to receive staking tokens
    /// @param _amount The amount of tokens to deposit
    function depositTo(address _to, uint256 _amount) external override {
        __deposit(msg.sender, _to, _amount);
    }

    /// @dev Helper to deposit tokens to be staked
    function __deposit(
        address _from,
        address _to,
        uint256 _amount
    ) private nonReentrant {
        require(!isPaused(), "__deposit: Paused");

        // Checkpoint before minting
        __checkpoint([_to, address(0)]);
        _mint(_to, _amount);

        __depositLogic(_from, _amount);

        emit Deposited(_from, _to, _amount);
    }

    // WITHDRAWAL

    /// @notice Withdraws staked tokens, returning tokens to the sender, and optionally claiming rewards
    /// @param _amount The amount of tokens to withdraw
    /// @param _claimRewards True if accrued rewards should be claimed
    /// @return rewardTokens_ The reward tokens
    /// @return claimedAmounts_ The reward token amounts claimed
    /// @dev Setting `_claimRewards` to true will save gas over separate calls to withdraw + claim
    function withdraw(uint256 _amount, bool _claimRewards)
        external
        override
        returns (address[] memory rewardTokens_, uint256[] memory claimedAmounts_)
    {
        return __withdraw(msg.sender, msg.sender, _amount, _claimRewards);
    }

    /// @notice Withdraws staked tokens, returning tokens to a specified account,
    /// and optionally claims rewards to the staked token holder
    /// @param _to The account to receive tokens
    /// @param _amount The amount of tokens to withdraw
    function withdrawTo(
        address _to,
        uint256 _amount,
        bool _claimRewardsToHolder
    ) external override {
        __withdraw(msg.sender, _to, _amount, _claimRewardsToHolder);
    }

    /// @notice Withdraws staked tokens on behalf of AccountA, returning tokens to a specified AccountB,
    /// and optionally claims rewards to the staked token holder
    /// @param _onBehalf The account on behalf to withdraw
    /// @param _to The account to receive tokens
    /// @param _amount The amount of tokens to withdraw
    /// @dev The caller must have an adequate ERC20.allowance() for _onBehalf
    function withdrawToOnBehalf(
        address _onBehalf,
        address _to,
        uint256 _amount,
        bool _claimRewardsToHolder
    ) external override {
        // Validate and reduce sender approval
        _approve(_onBehalf, msg.sender, allowance(_onBehalf, msg.sender).sub(_amount));

        __withdraw(_onBehalf, _to, _amount, _claimRewardsToHolder);
    }

    /// @dev Helper to withdraw staked tokens
    function __withdraw(
        address _from,
        address _to,
        uint256 _amount,
        bool _claimRewards
    )
        private
        nonReentrant
        returns (address[] memory rewardTokens_, uint256[] memory claimedAmounts_)
    {
        // Checkpoint before burning
        if (_claimRewards) {
            (rewardTokens_, claimedAmounts_) = __checkpointAndClaim(_from);
        } else {
            __checkpoint([_from, address(0)]);
        }

        _burn(_from, _amount);

        __withdrawLogic(_to, _amount);

        emit Withdrawn(msg.sender, _from, _to, _amount);

        return (rewardTokens_, claimedAmounts_);
    }

    /////////////
    // REWARDS //
    /////////////

    // Rewards tokens are added by the inheriting contract. Rewards tokens should be added, but not removed.
    // If new rewards tokens need to be added over time, that logic must be handled by the inheriting contract,
    // and can make use of __harvestRewardsLogic() if necessary

    // INTERNAL FUNCTIONS

    /// @dev Helper to add new reward tokens. Silently ignores duplicates.
    function __addRewardToken(address _rewardToken) internal {
        if (!rewardTokens.contains(_rewardToken)) {
            rewardTokens.push(_rewardToken);

            emit RewardTokenAdded(_rewardToken);
        }
    }

    // PRIVATE FUNCTIONS

    /// @dev Helper to calculate an unaccounted for reward amount due to a user based on integral values
    function __calcClaimableRewardForIntegralDiff(
        address _account,
        uint256 _totalHarvestIntegral,
        uint256 _userHarvestIntegral
    ) private view returns (uint256 claimableReward_) {
        return
            balanceOf(_account).mul(_totalHarvestIntegral.sub(_userHarvestIntegral)).div(
                INTEGRAL_PRECISION
            );
    }

    /// @dev Helper to calculate an unaccounted for integral amount based on checkpoint balance diff
    function __calcIntegralForBalDiff(
        uint256 _supply,
        uint256 _currentBalance,
        uint256 _lastCheckpointBalance
    ) private pure returns (uint256 integral_) {
        if (_supply > 0) {
            uint256 balDiff = _currentBalance.sub(_lastCheckpointBalance);
            if (balDiff > 0) {
                return balDiff.mul(INTEGRAL_PRECISION).div(_supply);
            }
        }

        return 0;
    }

    /// @dev Helper to checkpoint harvest data for specified accounts.
    /// Harvests all rewards prior to checkpoint.
    function __checkpoint(address[2] memory _accounts) private {
        // If paused, continue to checkpoint, but don't attempt to get new rewards
        if (!isPaused()) {
            __harvestRewardsLogic();
        }

        uint256 supply = totalSupply();

        uint256 rewardTokensLength = rewardTokens.length;
        for (uint256 i; i < rewardTokensLength; i++) {
            __updateHarvest(rewardTokens[i], _accounts, supply);
        }
    }

    /// @dev Helper to checkpoint harvest data for specified accounts.
    /// Harvests all rewards prior to checkpoint.
    function __checkpointAndClaim(address _account)
        private
        returns (address[] memory rewardTokens_, uint256[] memory claimedAmounts_)
    {
        // If paused, continue to checkpoint, but don't attempt to get new rewards
        if (!isPaused()) {
            __harvestRewardsLogic();
        }

        uint256 supply = totalSupply();

        rewardTokens_ = rewardTokens;
        claimedAmounts_ = new uint256[](rewardTokens_.length);
        for (uint256 i; i < rewardTokens_.length; i++) {
            claimedAmounts_[i] = __updateHarvestAndClaim(rewardTokens_[i], _account, supply);
        }

        emit RewardsClaimed(msg.sender, _account, rewardTokens_, claimedAmounts_);

        return (rewardTokens_, claimedAmounts_);
    }

    /// @dev Helper to update harvest data
    function __updateHarvest(
        address _rewardToken,
        address[2] memory _accounts,
        uint256 _supply
    ) private {
        TotalHarvestData storage totalHarvestData = rewardTokenToTotalHarvestData[_rewardToken];

        uint256 totalIntegral = totalHarvestData.integral;
        uint256 bal = ERC20(_rewardToken).balanceOf(address(this));
        uint256 integralToAdd = __calcIntegralForBalDiff(
            _supply,
            bal,
            totalHarvestData.lastCheckpointBalance
        );
        if (integralToAdd > 0) {
            totalIntegral = totalIntegral.add(integralToAdd);
            totalHarvestData.integral = uint128(totalIntegral);
            emit TotalHarvestIntegralUpdated(_rewardToken, totalIntegral);

            totalHarvestData.lastCheckpointBalance = uint128(bal);
            emit TotalHarvestLastCheckpointBalanceUpdated(_rewardToken, bal);
        }

        for (uint256 i; i < _accounts.length; i++) {
            // skip address(0), passed in upon mint and burn
            if (_accounts[i] == address(0)) continue;


                UserHarvestData storage userHarvestData
             = rewardTokenToUserToHarvestData[_rewardToken][_accounts[i]];

            uint256 userIntegral = userHarvestData.integral;
            if (userIntegral < totalIntegral) {
                uint256 claimableReward = uint256(userHarvestData.claimableReward).add(
                    __calcClaimableRewardForIntegralDiff(_accounts[i], totalIntegral, userIntegral)
                );

                userHarvestData.claimableReward = uint128(claimableReward);
                userHarvestData.integral = uint128(totalIntegral);

                emit UserHarvestUpdated(
                    _accounts[i],
                    _rewardToken,
                    totalIntegral,
                    claimableReward
                );
            }
        }
    }

    /// @dev Helper to update harvest data and claim all rewards to holder
    function __updateHarvestAndClaim(
        address _rewardToken,
        address _account,
        uint256 _supply
    ) private returns (uint256 claimedAmount_) {
        TotalHarvestData storage totalHarvestData = rewardTokenToTotalHarvestData[_rewardToken];

        uint256 totalIntegral = totalHarvestData.integral;
        uint256 integralToAdd = __calcIntegralForBalDiff(
            _supply,
            ERC20(_rewardToken).balanceOf(address(this)),
            totalHarvestData.lastCheckpointBalance
        );
        if (integralToAdd > 0) {
            totalIntegral = totalIntegral.add(integralToAdd);
            totalHarvestData.integral = uint128(totalIntegral);

            emit TotalHarvestIntegralUpdated(_rewardToken, totalIntegral);
        }


            UserHarvestData storage userHarvestData
         = rewardTokenToUserToHarvestData[_rewardToken][_account];

        uint256 userIntegral = userHarvestData.integral;
        claimedAmount_ = userHarvestData.claimableReward;
        if (userIntegral < totalIntegral) {
            userHarvestData.integral = uint128(totalIntegral);
            claimedAmount_ = claimedAmount_.add(
                __calcClaimableRewardForIntegralDiff(_account, totalIntegral, userIntegral)
            );

            emit UserHarvestUpdated(_account, _rewardToken, totalIntegral, claimedAmount_);
        }

        if (claimedAmount_ > 0) {
            userHarvestData.claimableReward = 0;
            ERC20(_rewardToken).safeTransfer(_account, claimedAmount_);

            emit UserHarvestUpdated(_account, _rewardToken, totalIntegral, 0);
        }

        // Repeat balance lookup since the reward token could have irregular transfer behavior
        uint256 finalBal = ERC20(_rewardToken).balanceOf(address(this));
        if (finalBal < totalHarvestData.lastCheckpointBalance) {
            totalHarvestData.lastCheckpointBalance = uint128(finalBal);

            emit TotalHarvestLastCheckpointBalanceUpdated(_rewardToken, finalBal);
        }

        return claimedAmount_;
    }

    ////////////////////////////////
    // REQUIRED VIRTUAL FUNCTIONS //
    ////////////////////////////////

    /// @dev Logic to be run during a deposit, specific to the integrated protocol.
    /// Do not mint staking tokens, which already happens during __deposit().
    function __depositLogic(address _onBehalf, uint256 _amount) internal virtual;

    /// @dev Logic to be run during a checkpoint to harvest new rewards, specific to the integrated protocol.
    /// Can also be used to add new rewards tokens dynamically.
    /// Do not checkpoint, only harvest the rewards.
    function __harvestRewardsLogic() internal virtual;

    /// @dev Logic to be run during a withdrawal, specific to the integrated protocol.
    /// Do not burn staking tokens, which already happens during __withdraw().
    function __withdrawLogic(address _to, uint256 _amount) internal virtual;

    /////////////////////
    // ERC20 OVERRIDES //
    /////////////////////

    /// @notice Gets the token decimals
    /// @return decimals_ The token decimals
    /// @dev Implementing contracts should override to set different decimals
    function decimals() public view virtual override returns (uint8 decimals_) {
        return DEFAULT_DECIMALS;
    }

    /// @dev Overrides ERC20._transfer() in order to checkpoint sender and recipient pre-transfer rewards
    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal override nonReentrant {
        __checkpoint([_from, _to]);
        super._transfer(_from, _to, _amount);
    }

    ///////////////////
    // STATE GETTERS //
    ///////////////////

    /// @notice Gets the reward token at a particular index
    /// @return rewardToken_ The reward token address
    function getRewardTokenAtIndex(uint256 _index)
        public
        view
        override
        returns (address rewardToken_)
    {
        return rewardTokens[_index];
    }

    /// @notice Gets the count of reward tokens being harvested
    /// @return count_ The count
    function getRewardTokenCount() public view override returns (uint256 count_) {
        return rewardTokens.length;
    }

    /// @notice Gets all reward tokens being harvested
    /// @return rewardTokens_ The reward tokens
    function getRewardTokens() public view override returns (address[] memory rewardTokens_) {
        return rewardTokens;
    }

    /// @notice Gets the TotalHarvestData for a specified reward token
    /// @param _rewardToken The reward token
    /// @return totalHarvestData_ The TotalHarvestData
    function getTotalHarvestDataForRewardToken(address _rewardToken)
        public
        view
        override
        returns (TotalHarvestData memory totalHarvestData_)
    {
        return rewardTokenToTotalHarvestData[_rewardToken];
    }

    /// @notice Gets the UserHarvestData for a specified account and reward token
    /// @param _user The account
    /// @param _rewardToken The reward token
    /// @return userHarvestData_ The UserHarvestData
    function getUserHarvestDataForRewardToken(address _user, address _rewardToken)
        public
        view
        override
        returns (UserHarvestData memory userHarvestData_)
    {
        return rewardTokenToUserToHarvestData[_rewardToken][_user];
    }

    /// @notice Checks if deposits and new reward harvesting are paused
    /// @return isPaused_ True if paused
    function isPaused() public view override returns (bool isPaused_) {
        return paused;
    }
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

import "./StakingWrapperBase.sol";

/// @title StakingWrapperLibBase Contract
/// @author Enzyme Council <[email protected]>
/// @notice A staking wrapper base for proxy targets, extending StakingWrapperBase
abstract contract StakingWrapperLibBase is StakingWrapperBase {
    event TokenNameSet(string name);

    event TokenSymbolSet(string symbol);

    string private tokenName;
    string private tokenSymbol;

    /// @dev Helper function to set token name
    function __setTokenName(string memory _name) internal {
        tokenName = _name;

        emit TokenNameSet(_name);
    }

    /// @dev Helper function to set token symbol
    function __setTokenSymbol(string memory _symbol) internal {
        tokenSymbol = _symbol;

        emit TokenSymbolSet(_symbol);
    }

    /////////////////////
    // ERC20 OVERRIDES //
    /////////////////////

    /// @notice Gets the token name
    /// @return name_ The token name
    /// @dev Overrides the constructor-set storage for use in proxies
    function name() public view override returns (string memory name_) {
        return tokenName;
    }

    /// @notice Gets the token symbol
    /// @return symbol_ The token symbol
    /// @dev Overrides the constructor-set storage for use in proxies
    function symbol() public view override returns (string memory symbol_) {
        return tokenSymbol;
    }
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.
    (c) Enzyme Council <[email protected]>
    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "../../../../persistent/dispatcher/IDispatcher.sol";
import "../../../utils/beacon-proxy/BeaconProxyFactory.sol";
import "./ConvexCurveLpStakingWrapperLib.sol";

/// @title ConvexCurveLpStakingWrapperFactory Contract
/// @author Enzyme Council <[email protected]>
/// @notice A contract factory for ConvexCurveLpStakingWrapper instances
contract ConvexCurveLpStakingWrapperFactory is BeaconProxyFactory {
    event WrapperDeployed(uint256 indexed pid, address wrapperProxy, address curveLpToken);

    IDispatcher private immutable DISPATCHER_CONTRACT;

    mapping(uint256 => address) private pidToWrapper;
    // Handy cache for interacting contracts
    mapping(address => address) private wrapperToCurveLpToken;

    modifier onlyOwner {
        require(msg.sender == getOwner(), "Only the owner can call this function");
        _;
    }

    constructor(
        address _dispatcher,
        address _convexBooster,
        address _crvToken,
        address _cvxToken
    ) public BeaconProxyFactory(address(0)) {
        DISPATCHER_CONTRACT = IDispatcher(_dispatcher);

        __setCanonicalLib(
            address(
                new ConvexCurveLpStakingWrapperLib(
                    address(this),
                    _convexBooster,
                    _crvToken,
                    _cvxToken
                )
            )
        );
    }

    /// @notice Deploys a staking wrapper for a given Convex pool
    /// @param _pid The Convex Curve pool id
    /// @return wrapperProxy_ The staking wrapper proxy contract address
    function deploy(uint256 _pid) external returns (address wrapperProxy_) {
        require(getWrapperForConvexPool(_pid) == address(0), "deploy: Wrapper already exists");

        bytes memory constructData = abi.encodeWithSelector(
            ConvexCurveLpStakingWrapperLib.init.selector,
            _pid
        );

        wrapperProxy_ = deployProxy(constructData);

        pidToWrapper[_pid] = wrapperProxy_;

        address lpToken = ConvexCurveLpStakingWrapperLib(wrapperProxy_).getCurveLpToken();
        wrapperToCurveLpToken[wrapperProxy_] = lpToken;

        emit WrapperDeployed(_pid, wrapperProxy_, lpToken);

        return wrapperProxy_;
    }

    /// @notice Pause deposits and harvesting new rewards for the given wrappers
    /// @param _wrappers The wrappers to pause
    function pauseWrappers(address[] calldata _wrappers) external onlyOwner {
        for (uint256 i; i < _wrappers.length; i++) {
            ConvexCurveLpStakingWrapperLib(_wrappers[i]).togglePause(true);
        }
    }

    /// @notice Unpauses deposits and harvesting new rewards for the given wrappers
    /// @param _wrappers The wrappers to unpause
    function unpauseWrappers(address[] calldata _wrappers) external onlyOwner {
        for (uint256 i; i < _wrappers.length; i++) {
            ConvexCurveLpStakingWrapperLib(_wrappers[i]).togglePause(false);
        }
    }

    ////////////////////////////////////
    // BEACON PROXY FACTORY OVERRIDES //
    ////////////////////////////////////

    /// @notice Gets the contract owner
    /// @return owner_ The contract owner
    function getOwner() public view override returns (address owner_) {
        return DISPATCHER_CONTRACT.getOwner();
    }

    ///////////////////
    // STATE GETTERS //
    ///////////////////

    // EXTERNAL FUNCTIONS

    /// @notice Gets the Curve LP token address for a given wrapper
    /// @param _wrapper The wrapper proxy address
    /// @return lpToken_ The Curve LP token address
    function getCurveLpTokenForWrapper(address _wrapper) external view returns (address lpToken_) {
        return wrapperToCurveLpToken[_wrapper];
    }

    // PUBLIC FUNCTIONS

    /// @notice Gets the wrapper address for a given Convex pool
    /// @param _pid The Convex pool id
    /// @return wrapper_ The wrapper proxy address
    function getWrapperForConvexPool(uint256 _pid) public view returns (address wrapper_) {
        return pidToWrapper[_pid];
    }
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "../../../interfaces/IConvexBaseRewardPool.sol";
import "../../../interfaces/IConvexBooster.sol";
import "../../../interfaces/IConvexVirtualBalanceRewardPool.sol";
import "../StakingWrapperLibBase.sol";

/// @title ConvexCurveLpStakingWrapperLib Contract
/// @author Enzyme Council <[email protected]>
/// @notice A library contract for ConvexCurveLpStakingWrapper instances
contract ConvexCurveLpStakingWrapperLib is StakingWrapperLibBase {
    IConvexBooster private immutable CONVEX_BOOSTER_CONTRACT;
    address private immutable CRV_TOKEN;
    address private immutable CVX_TOKEN;

    address private convexPool;
    uint256 private convexPoolId;
    address private curveLPToken;

    constructor(
        address _owner,
        address _convexBooster,
        address _crvToken,
        address _cvxToken
    ) public StakingWrapperBase(_owner, "", "") {
        CONVEX_BOOSTER_CONTRACT = IConvexBooster(_convexBooster);
        CRV_TOKEN = _crvToken;
        CVX_TOKEN = _cvxToken;
    }

    /// @notice Initializes the proxy
    /// @param _pid The Convex pool id for which to use the proxy
    function init(uint256 _pid) external {
        // Can validate with any variable set here
        require(getCurveLpToken() == address(0), "init: Initialized");

        IConvexBooster.PoolInfo memory poolInfo = CONVEX_BOOSTER_CONTRACT.poolInfo(_pid);

        // Set ERC20 info on proxy
        __setTokenName(string(abi.encodePacked("Enzyme Staked: ", ERC20(poolInfo.token).name())));
        __setTokenSymbol(string(abi.encodePacked("stk", ERC20(poolInfo.token).symbol())));

        curveLPToken = poolInfo.lptoken;
        convexPool = poolInfo.crvRewards;
        convexPoolId = _pid;

        __addRewardToken(CRV_TOKEN);
        __addRewardToken(CVX_TOKEN);
        addExtraRewards();

        setApprovals();
    }

    /// @notice Adds rewards tokens that have not yet been added to the wrapper
    /// @dev Anybody can call, in case more pool tokens are added.
    /// Is called prior to every new harvest.
    function addExtraRewards() public {
        IConvexBaseRewardPool convexPoolContract = IConvexBaseRewardPool(getConvexPool());
        // Could probably exit early after validating that extraRewardsCount + 2 <= rewardsTokens.length,
        // but this protects against a reward token being removed that still needs to be paid out
        uint256 extraRewardsCount = convexPoolContract.extraRewardsLength();
        for (uint256 i; i < extraRewardsCount; i++) {
            // __addRewardToken silently ignores duplicates
            __addRewardToken(
                IConvexVirtualBalanceRewardPool(convexPoolContract.extraRewards(i)).rewardToken()
            );
        }
    }

    /// @notice Sets necessary ERC20 approvals, as-needed
    function setApprovals() public {
        ERC20(getCurveLpToken()).safeApprove(address(CONVEX_BOOSTER_CONTRACT), type(uint256).max);
    }

    ////////////////////////////////
    // STAKING WRAPPER BASE LOGIC //
    ////////////////////////////////

    /// @dev Logic to be run during a deposit, specific to the integrated protocol.
    /// Do not mint staking tokens, which already happens during __deposit().
    function __depositLogic(address _from, uint256 _amount) internal override {
        ERC20(getCurveLpToken()).safeTransferFrom(_from, address(this), _amount);
        CONVEX_BOOSTER_CONTRACT.deposit(convexPoolId, _amount, true);
    }

    /// @dev Logic to be run during a checkpoint to harvest new rewards, specific to the integrated protocol.
    /// Can also be used to add new rewards tokens dynamically.
    /// Do not checkpoint, only harvest the rewards.
    function __harvestRewardsLogic() internal override {
        // It's probably overly-cautious to check rewards on every call,
        // but even when the pool has 1 extra reward token (most have 0) it only adds ~10-15k gas units,
        // so more convenient to always check than to monitor for rewards changes.
        addExtraRewards();
        IConvexBaseRewardPool(getConvexPool()).getReward();
    }

    /// @dev Logic to be run during a withdrawal, specific to the integrated protocol.
    /// Do not burn staking tokens, which already happens during __withdraw().
    function __withdrawLogic(address _to, uint256 _amount) internal override {
        IConvexBaseRewardPool(getConvexPool()).withdrawAndUnwrap(_amount, false);
        ERC20(getCurveLpToken()).safeTransfer(_to, _amount);
    }

    ///////////////////
    // STATE GETTERS //
    ///////////////////

    /// @notice Gets the associated Convex reward pool address
    /// @return convexPool_ The reward pool
    function getConvexPool() public view returns (address convexPool_) {
        return convexPool;
    }

    /// @notice Gets the associated Convex reward pool id (pid)
    /// @return convexPoolId_ The pid
    function getConvexPoolId() public view returns (uint256 convexPoolId_) {
        return convexPoolId;
    }

    /// @notice Gets the associated Curve LP token
    /// @return curveLPToken_ The Curve LP token
    function getCurveLpToken() public view returns (address curveLPToken_) {
        return curveLPToken;
    }
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.
    (c) Enzyme Council <[email protected]>
    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

/// @title IConvexBaseRewardPool Interface
/// @author Enzyme Council <[email protected]>
interface IConvexBaseRewardPool {
    function balanceOf(address) external view returns (uint256);

    function extraRewards(uint256) external view returns (address);

    function extraRewardsLength() external view returns (uint256);

    function getReward() external returns (bool);

    function withdraw(uint256, bool) external;

    function withdrawAndUnwrap(uint256, bool) external returns (bool);
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.
    (c) Enzyme Council <[email protected]>
    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

/// @title IConvexBooster Interface
/// @author Enzyme Council <[email protected]>
interface IConvexBooster {
    struct PoolInfo {
        address lptoken;
        address token;
        address gauge;
        address crvRewards;
        address stash;
        bool shutdown;
    }

    function deposit(
        uint256,
        uint256,
        bool
    ) external returns (bool);

    function poolInfo(uint256) external view returns (PoolInfo memory);
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.
    (c) Enzyme Council <[email protected]>
    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

/// @title IConvexVirtualBalanceRewardPool Interface
/// @author Enzyme Council <[email protected]>
interface IConvexVirtualBalanceRewardPool {
    function rewardToken() external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

/// @title ICurveAddressProvider interface
/// @author Enzyme Council <[email protected]>
interface ICurveAddressProvider {
    function get_address(uint256) external view returns (address);

    function get_registry() external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

/// @title ICurveLiquidityPool interface
/// @author Enzyme Council <[email protected]>
interface ICurveLiquidityPool {
    function coins(int128) external view returns (address);

    function coins(uint256) external view returns (address);

    function get_virtual_price() external view returns (uint256);

    function underlying_coins(int128) external view returns (address);

    function underlying_coins(uint256) external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

/// @title ICurvePoolOwner interface
/// @author Enzyme Council <[email protected]>
interface ICurvePoolOwner {
    function withdraw_admin_fees(address) external;
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

/// @title ICurveRegistryMain interface
/// @author Enzyme Council <[email protected]>
/// @notice Limited interface for the Curve Registry contract at ICurveAddressProvider.get_address(0)
interface ICurveRegistryMain {
    function get_gauges(address) external view returns (address[10] memory, int128[10] memory);

    function get_lp_token(address) external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

/// @title ICurveRegistryMetapoolFactory interface
/// @author Enzyme Council <[email protected]>
/// @notice Limited interface for the Curve Registry contract at ICurveAddressProvider.get_address(3)
interface ICurveRegistryMetapoolFactory {
    function get_gauge(address) external view returns (address);

    function get_n_coins(address) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

/// @title WETH Interface
/// @author Enzyme Council <[email protected]>
interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

/// @title AddressArray Library
/// @author Enzyme Council <[email protected]>
/// @notice A library to extend the address array data type
library AddressArrayLib {
    /////////////
    // STORAGE //
    /////////////

    /// @dev Helper to remove an item from a storage array
    function removeStorageItem(address[] storage _self, address _itemToRemove)
        internal
        returns (bool removed_)
    {
        uint256 itemCount = _self.length;
        for (uint256 i; i < itemCount; i++) {
            if (_self[i] == _itemToRemove) {
                if (i < itemCount - 1) {
                    _self[i] = _self[itemCount - 1];
                }
                _self.pop();
                removed_ = true;
                break;
            }
        }

        return removed_;
    }

    ////////////
    // MEMORY //
    ////////////

    /// @dev Helper to add an item to an array. Does not assert uniqueness of the new item.
    function addItem(address[] memory _self, address _itemToAdd)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        nextArray_ = new address[](_self.length + 1);
        for (uint256 i; i < _self.length; i++) {
            nextArray_[i] = _self[i];
        }
        nextArray_[_self.length] = _itemToAdd;

        return nextArray_;
    }

    /// @dev Helper to add an item to an array, only if it is not already in the array.
    function addUniqueItem(address[] memory _self, address _itemToAdd)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        if (contains(_self, _itemToAdd)) {
            return _self;
        }

        return addItem(_self, _itemToAdd);
    }

    /// @dev Helper to verify if an array contains a particular value
    function contains(address[] memory _self, address _target)
        internal
        pure
        returns (bool doesContain_)
    {
        for (uint256 i; i < _self.length; i++) {
            if (_target == _self[i]) {
                return true;
            }
        }
        return false;
    }

    /// @dev Helper to merge the unique items of a second array.
    /// Does not consider uniqueness of either array, only relative uniqueness.
    /// Preserves ordering.
    function mergeArray(address[] memory _self, address[] memory _arrayToMerge)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        uint256 newUniqueItemCount;
        for (uint256 i; i < _arrayToMerge.length; i++) {
            if (!contains(_self, _arrayToMerge[i])) {
                newUniqueItemCount++;
            }
        }

        if (newUniqueItemCount == 0) {
            return _self;
        }

        nextArray_ = new address[](_self.length + newUniqueItemCount);
        for (uint256 i; i < _self.length; i++) {
            nextArray_[i] = _self[i];
        }
        uint256 nextArrayIndex = _self.length;
        for (uint256 i; i < _arrayToMerge.length; i++) {
            if (!contains(_self, _arrayToMerge[i])) {
                nextArray_[nextArrayIndex] = _arrayToMerge[i];
                nextArrayIndex++;
            }
        }

        return nextArray_;
    }

    /// @dev Helper to verify if array is a set of unique values.
    /// Does not assert length > 0.
    function isUniqueSet(address[] memory _self) internal pure returns (bool isUnique_) {
        if (_self.length <= 1) {
            return true;
        }

        uint256 arrayLength = _self.length;
        for (uint256 i; i < arrayLength; i++) {
            for (uint256 j = i + 1; j < arrayLength; j++) {
                if (_self[i] == _self[j]) {
                    return false;
                }
            }
        }

        return true;
    }

    /// @dev Helper to remove items from an array. Removes all matching occurrences of each item.
    /// Does not assert uniqueness of either array.
    function removeItems(address[] memory _self, address[] memory _itemsToRemove)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        if (_itemsToRemove.length == 0) {
            return _self;
        }

        bool[] memory indexesToRemove = new bool[](_self.length);
        uint256 remainingItemsCount = _self.length;
        for (uint256 i; i < _self.length; i++) {
            if (contains(_itemsToRemove, _self[i])) {
                indexesToRemove[i] = true;
                remainingItemsCount--;
            }
        }

        if (remainingItemsCount == _self.length) {
            nextArray_ = _self;
        } else if (remainingItemsCount > 0) {
            nextArray_ = new address[](remainingItemsCount);
            uint256 nextArrayIndex;
            for (uint256 i; i < _self.length; i++) {
                if (!indexesToRemove[i]) {
                    nextArray_[nextArrayIndex] = _self[i];
                    nextArrayIndex++;
                }
            }
        }

        return nextArray_;
    }
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

/// @title AssetHelpers Contract
/// @author Enzyme Council <[email protected]>
/// @notice A util contract for common token actions
abstract contract AssetHelpers {
    using SafeERC20 for ERC20;
    using SafeMath for uint256;

    /// @dev Helper to aggregate amounts of the same assets
    function __aggregateAssetAmounts(address[] memory _rawAssets, uint256[] memory _rawAmounts)
        internal
        pure
        returns (address[] memory aggregatedAssets_, uint256[] memory aggregatedAmounts_)
    {
        if (_rawAssets.length == 0) {
            return (aggregatedAssets_, aggregatedAmounts_);
        }

        uint256 aggregatedAssetCount = 1;
        for (uint256 i = 1; i < _rawAssets.length; i++) {
            bool contains;
            for (uint256 j; j < i; j++) {
                if (_rawAssets[i] == _rawAssets[j]) {
                    contains = true;
                    break;
                }
            }
            if (!contains) {
                aggregatedAssetCount++;
            }
        }

        aggregatedAssets_ = new address[](aggregatedAssetCount);
        aggregatedAmounts_ = new uint256[](aggregatedAssetCount);
        uint256 aggregatedAssetIndex;
        for (uint256 i; i < _rawAssets.length; i++) {
            bool contains;
            for (uint256 j; j < aggregatedAssetIndex; j++) {
                if (_rawAssets[i] == aggregatedAssets_[j]) {
                    contains = true;

                    aggregatedAmounts_[j] += _rawAmounts[i];

                    break;
                }
            }
            if (!contains) {
                aggregatedAssets_[aggregatedAssetIndex] = _rawAssets[i];
                aggregatedAmounts_[aggregatedAssetIndex] = _rawAmounts[i];
                aggregatedAssetIndex++;
            }
        }

        return (aggregatedAssets_, aggregatedAmounts_);
    }

    /// @dev Helper to approve a target account with the max amount of an asset.
    /// This is helpful for fully trusted contracts, such as adapters that
    /// interact with external protocol like Uniswap, Compound, etc.
    function __approveAssetMaxAsNeeded(
        address _asset,
        address _target,
        uint256 _neededAmount
    ) internal {
        uint256 allowance = ERC20(_asset).allowance(address(this), _target);
        if (allowance < _neededAmount) {
            if (allowance > 0) {
                ERC20(_asset).safeApprove(_target, 0);
            }
            ERC20(_asset).safeApprove(_target, type(uint256).max);
        }
    }

    /// @dev Helper to transfer full asset balances from the current contract to a target
    function __pushFullAssetBalances(address _target, address[] memory _assets)
        internal
        returns (uint256[] memory amountsTransferred_)
    {
        amountsTransferred_ = new uint256[](_assets.length);
        for (uint256 i; i < _assets.length; i++) {
            ERC20 assetContract = ERC20(_assets[i]);
            amountsTransferred_[i] = assetContract.balanceOf(address(this));
            if (amountsTransferred_[i] > 0) {
                assetContract.safeTransfer(_target, amountsTransferred_[i]);
            }
        }

        return amountsTransferred_;
    }
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

import "../core/fund-deployer/IFundDeployer.sol";

/// @title FundDeployerOwnerMixin Contract
/// @author Enzyme Council <[email protected]>
/// @notice A mixin contract that defers ownership to the owner of FundDeployer
abstract contract FundDeployerOwnerMixin {
    address internal immutable FUND_DEPLOYER;

    modifier onlyFundDeployerOwner() {
        require(
            msg.sender == getOwner(),
            "onlyFundDeployerOwner: Only the FundDeployer owner can call this function"
        );
        _;
    }

    constructor(address _fundDeployer) public {
        FUND_DEPLOYER = _fundDeployer;
    }

    /// @notice Gets the owner of this contract
    /// @return owner_ The owner
    /// @dev Ownership is deferred to the owner of the FundDeployer contract
    function getOwner() public view returns (address owner_) {
        return IFundDeployer(FUND_DEPLOYER).getOwner();
    }

    ///////////////////
    // STATE GETTERS //
    ///////////////////

    /// @notice Gets the `FUND_DEPLOYER` variable
    /// @return fundDeployer_ The `FUND_DEPLOYER` variable value
    function getFundDeployer() public view returns (address fundDeployer_) {
        return FUND_DEPLOYER;
    }
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

import "./IBeacon.sol";

/// @title BeaconProxy Contract
/// @author Enzyme Council <[email protected]>
/// @notice A proxy contract that uses the beacon pattern for instant upgrades
contract BeaconProxy {
    address private immutable BEACON;

    constructor(bytes memory _constructData, address _beacon) public {
        BEACON = _beacon;

        (bool success, bytes memory returnData) = IBeacon(_beacon).getCanonicalLib().delegatecall(
            _constructData
        );
        require(success, string(returnData));
    }

    // solhint-disable-next-line no-complex-fallback
    fallback() external payable {
        address contractLogic = IBeacon(BEACON).getCanonicalLib();
        assembly {
            calldatacopy(0x0, 0x0, calldatasize())
            let success := delegatecall(
                sub(gas(), 10000),
                contractLogic,
                0x0,
                calldatasize(),
                0,
                0
            )
            let retSz := returndatasize()
            returndatacopy(0, 0, retSz)
            switch success
                case 0 {
                    revert(0, retSz)
                }
                default {
                    return(0, retSz)
                }
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

import "./BeaconProxy.sol";
import "./IBeaconProxyFactory.sol";

/// @title BeaconProxyFactory Contract
/// @author Enzyme Council <[email protected]>
/// @notice Factory contract that deploys beacon proxies
abstract contract BeaconProxyFactory is IBeaconProxyFactory {
    event CanonicalLibSet(address nextCanonicalLib);

    event ProxyDeployed(address indexed caller, address proxy, bytes constructData);

    address private canonicalLib;

    constructor(address _canonicalLib) public {
        __setCanonicalLib(_canonicalLib);
    }

    /// @notice Deploys a new proxy instance
    /// @param _constructData The constructor data with which to call `init()` on the deployed proxy
    /// @return proxy_ The proxy address
    function deployProxy(bytes memory _constructData) public override returns (address proxy_) {
        proxy_ = address(new BeaconProxy(_constructData, address(this)));

        emit ProxyDeployed(msg.sender, proxy_, _constructData);

        return proxy_;
    }

    /// @notice Gets the canonical lib used by all proxies
    /// @return canonicalLib_ The canonical lib
    function getCanonicalLib() public view override returns (address canonicalLib_) {
        return canonicalLib;
    }

    /// @notice Gets the contract owner
    /// @return owner_ The contract owner
    function getOwner() public view virtual returns (address owner_);

    /// @notice Sets the next canonical lib used by all proxies
    /// @param _nextCanonicalLib The next canonical lib
    function setCanonicalLib(address _nextCanonicalLib) public override {
        require(
            msg.sender == getOwner(),
            "setCanonicalLib: Only the owner can call this function"
        );

        __setCanonicalLib(_nextCanonicalLib);
    }

    /// @dev Helper to set the next canonical lib
    function __setCanonicalLib(address _nextCanonicalLib) internal {
        canonicalLib = _nextCanonicalLib;

        emit CanonicalLibSet(_nextCanonicalLib);
    }
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity 0.6.12;

/// @title IBeacon interface
/// @author Enzyme Council <[email protected]>
interface IBeacon {
    function getCanonicalLib() external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <[email protected]>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

import "./IBeacon.sol";

pragma solidity 0.6.12;

/// @title IBeaconProxyFactory interface
/// @author Enzyme Council <[email protected]>
interface IBeaconProxyFactory is IBeacon {
    function deployProxy(bytes memory _constructData) external returns (address proxy_);

    function setCanonicalLib(address _canonicalLib) external;
}