// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./GovernorBravoInterfaces.sol";

// solhint-disable no-complex-fallback
// solhint-disable reason-string
// solhint-disable no-inline-assembly
// solhint-disable avoid-low-level-calls

contract GovernorBravoDelegator is
    GovernorBravoDelegatorStorage,
    GovernorBravoEvents
{
    constructor(
        address timelock_,
        address gvEase_,
        address admin_,
        address implementation_,
        uint256 votingPeriod_,
        uint256 votingDelay_, // solhint-disable func-name-mixedcase
        uint256 proposalThreshold_
    ) {
        // Admin set to msg.sender for initialization
        admin = msg.sender;

        delegateTo(
            implementation_,
            abi.encodeWithSignature(
                "initialize(address,address,uint256,uint256,uint256)",
                timelock_,
                gvEase_,
                votingPeriod_,
                votingDelay_,
                proposalThreshold_
            )
        );

        _setImplementation(implementation_);

        admin = admin_;
    }

    /**
     * @notice Called by the admin to update the implementation of the delegator
     * @param implementation_ The address of the new implementation for delegation
     */
    function _setImplementation(address implementation_) public {
        require(
            msg.sender == admin,
            "GovernorBravoDelegator::_setImplementation: admin only"
        );
        require(
            implementation_ != address(0),
            "GovernorBravoDelegator::_setImplementation: invalid implementation address"
        );

        address oldImplementation = implementation;
        implementation = implementation_;

        emit NewImplementation(oldImplementation, implementation);
    }

    /**
     * @notice Internal method to delegate execution to another contract
     * @dev It returns to the external caller whatever the implementation returns or forwards reverts
     * @param callee The contract to delegatecall
     * @param data The raw data to delegatecall
     */
    function delegateTo(address callee, bytes memory data) internal {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize())
            }
        }
    }

    /**
     * @dev Delegates execution to an implementation contract.
     * It returns to the external caller whatever the implementation returns
     * or forwards reverts.
     */
    fallback() external payable {
        // delegate all other functions to current implementation
        (bool success, ) = implementation.delegatecall(msg.data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())

            switch success
            case 0 {
                revert(free_mem_ptr, returndatasize())
            }
            default {
                return(free_mem_ptr, returndatasize())
            }
        }
    }
}

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.11;
import "../../core/GvToken.sol";

// solhint-disable func-name-mixedcase

contract GovernorBravoEvents {
    /// @notice An event emitted when a new proposal is created
    event ProposalCreated(
        uint256 id,
        address proposer,
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        uint256 startBlock,
        uint256 endBlock,
        string description
    );

    /// @notice An event emitted when a vote has been cast on a proposal
    /// @param voter The address which casted a vote
    /// @param proposalId The proposal id which was voted on
    /// @param support Support value for the vote. 0=against, 1=for, 2=abstain
    /// @param votes Number of votes which were cast by the voter
    /// @param reason The reason given for the vote by the voter
    event VoteCast(
        address indexed voter,
        uint256 proposalId,
        uint8 support,
        uint256 votes,
        string reason
    );

    /// @notice An event emitted when a proposal has been canceled
    event ProposalCanceled(uint256 id);

    /// @notice An event emitted when a proposal has been queued in the Timelock
    event ProposalQueued(uint256 id, uint256 eta);

    /// @notice An event emitted when a proposal has been executed in the Timelock
    event ProposalExecuted(uint256 id);

    /// @notice An event emitted when the voting delay is set
    event VotingDelaySet(uint256 oldVotingDelay, uint256 newVotingDelay);

    /// @notice An event emitted when the quorum vote amount is set
    event QuorumVotesSet(uint256 oldQuorumVotes, uint256 newQuorumVotes);

    /// @notice An event emitted when the voting period is set
    event VotingPeriodSet(uint256 oldVotingPeriod, uint256 newVotingPeriod);

    /// @notice Emitted when implementation is changed
    event NewImplementation(
        address oldImplementation,
        address newImplementation
    );

    /// @notice Emitted when proposal threshold is set
    event ProposalThresholdSet(
        uint256 oldProposalThreshold,
        uint256 newProposalThreshold
    );

    /// @notice Emitted when pendingAdmin is changed
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    /// @notice Emitted when pendingAdmin is accepted, which means admin is updated
    event NewAdmin(address oldAdmin, address newAdmin);

    /// @notice Emitted when whitelist account expiration is set
    event WhitelistAccountExpirationSet(address account, uint256 expiration);

    /// @notice Emitted when the whitelistGuardian is set
    event WhitelistGuardianSet(address oldGuardian, address newGuardian);
}

contract GovernorBravoDelegatorStorage {
    /// @notice Administrator for this contract
    address public admin;

    /// @notice Pending administrator for this contract
    address public pendingAdmin;

    /// @notice Active brains of Governor
    address public implementation;
}

/**
 * @title Storage for Governor Bravo Delegate
 * @notice For future upgrades, do not change GovernorBravoDelegateStorageV1. Create a new
 * contract which implements GovernorBravoDelegateStorageV1 and following the naming convention
 * GovernorBravoDelegateStorageVX.
 */
contract GovernorBravoDelegateStorageV1 is GovernorBravoDelegatorStorage {
    /// @notice The delay before voting on a proposal may take place, once proposed, in blocks
    uint256 public votingDelay;

    /// @notice The duration of voting on a proposal, in blocks
    uint256 public votingPeriod;

    /// @notice The number of votes required in order for a voter to become a proposer
    uint256 public proposalThreshold;

    /// @notice Initial proposal id set at become
    uint256 public initialProposalId;

    /// @notice The total number of proposals
    uint256 public proposalCount;

    /// @notice The address of the Ease Protocol Timelock
    TimelockInterface public timelock;

    /// @notice The address of the Ease governance token
    GvToken public gvEase;

    /// @notice The official record of all proposals ever proposed
    mapping(uint256 => Proposal) public proposals;

    /// @notice The latest proposal for each proposer
    mapping(address => uint256) public latestProposalIds;

    struct Proposal {
        /// @notice Unique id for looking up a proposal
        uint256 id;
        /// @notice Creator of the proposal
        address proposer;
        /// @notice The timestamp that the proposal will be available for execution, set once the vote succeeds
        uint256 eta;
        /// @notice the ordered list of target addresses for calls to be made
        address[] targets;
        /// @notice The ordered list of values (i.e. msg.value) to be passed to the calls to be made
        uint256[] values;
        /// @notice The ordered list of function signatures to be called
        string[] signatures;
        /// @notice The ordered list of calldata to be passed to each call
        bytes[] calldatas;
        /// @notice The block at which voting begins: holders must delegate their votes prior to this block
        uint256 startBlock;
        /// @notice The block at which voting ends: votes must be cast prior to this block
        uint256 endBlock;
        /// @notice Current number of votes in favor of this proposal
        uint256 forVotes;
        /// @notice Current number of votes in opposition to this proposal
        uint256 againstVotes;
        /// @notice Current number of votes for abstaining for this proposal
        uint256 abstainVotes;
        /// @notice Flag marking whether the proposal has been canceled
        bool canceled;
        /// @notice Flag marking whether the proposal has been executed
        bool executed;
        /// @notice Receipts of ballots for the entire set of voters
        mapping(address => Receipt) receipts;
    }

    /// @notice Ballot receipt record for a voter
    struct Receipt {
        /// @notice Whether or not a vote has been cast
        bool hasVoted;
        /// @notice Whether or not the voter supports the proposal or abstains
        uint8 support;
        /// @notice The number of votes the voter had, which were cast
        uint128 votes;
    }

    /// @notice Possible states that a proposal may be in
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }
}

contract GovernorBravoDelegateStorageV2 is GovernorBravoDelegateStorageV1 {
    /// @notice Stores the expiration of account whitelist status as a timestamp
    mapping(address => uint256) public whitelistAccountExpirations;

    /// @notice Address which manages whitelisted proposals and whitelist accounts
    address public whitelistGuardian;
}

interface TimelockInterface {
    function delay() external view returns (uint256);

    function GRACE_PERIOD() external view returns (uint256);

    function acceptAdmin() external;

    function queuedTransactions(bytes32 hash) external view returns (bool);

    function queueTransaction(
        address target,
        uint256 value,
        string calldata signature,
        bytes calldata data,
        uint256 eta
    ) external returns (bytes32);

    function cancelTransaction(
        address target,
        uint256 value,
        string calldata signature,
        bytes calldata data,
        uint256 eta
    ) external;

    function executeTransaction(
        address target,
        uint256 value,
        string calldata signature,
        bytes calldata data,
        uint256 eta
    ) external payable returns (bytes memory);
}

interface GovernorAlpha {
    /// @notice The total number of proposals
    function proposalCount() external returns (uint256);
}

/// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {IERC20Permit} from "../interfaces/IERC20.sol";
import "../interfaces/IGvToken.sol";
import "../interfaces/IBribePot.sol";
import "../interfaces/IRcaController.sol";
import "../interfaces/ITokenSwap.sol";
import "../library/MerkleProof.sol";
import "./Delegable.sol";

// solhint-disable not-rely-on-time
// solhint-disable reason-string
// solhint-disable max-states-count
// solhint-disable no-inline-assembly
// solhint-disable no-empty-blocks

contract GvToken is Delegable, UUPSUpgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Permit;

    /* ========== STRUCTS ========== */
    struct MetaData {
        string name;
        string symbol;
        uint256 decimals;
    }
    struct Deposit {
        uint128 amount;
        uint128 start;
    }
    struct PermitArgs {
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
    struct WithdrawRequest {
        uint128 amount;
        uint128 endTime;
    }
    struct SupplyPointer {
        uint128 amount;
        uint128 storedAt;
    }
    struct DelegateDetails {
        address reciever;
        uint256 amount;
    }

    /* ========== CONSTANTS ========== */
    uint64 public constant MAX_PERCENT = 100_000;
    uint32 public constant MAX_GROW = 52 weeks;
    uint32 public constant WEEK = 1 weeks;
    uint256 internal constant MULTIPLIER = 1e18;

    /* ========== STATE ========== */
    IBribePot public pot;
    IERC20Permit public stakingToken;
    IRcaController public rcaController;
    ITokenSwap public tokenSwap;
    /// @notice Timestamp rounded in weeks for earliest vArmor staker
    uint32 public genesis;
    /// @notice total amount of EASE deposited
    uint256 public totalDeposited;
    /// @notice Time delay for withdrawals which will be set by governance
    uint256 public withdrawalDelay;

    /// @notice total supply of gvToken
    uint256 private _totalSupply;
    /// @notice merkle root of vArmor stakers for giving them
    /// extra deposit start time
    bytes32 private _powerRoot;
    MetaData private metadata;
    /// @notice Request by users for withdrawals.
    mapping(address => WithdrawRequest) public withdrawRequests;
    /// @notice amount of gvToken leased to bribe Pot
    mapping(address => uint256) public leasedAmount;

    /// @notice User deposits of ease tokens
    mapping(address => Deposit[]) private _deposits;
    /// @notice total amount of ease deposited on user behalf
    mapping(address => uint256) private _totalDeposit;
    /// @notice Total percent of balance staked by user to different RCA-vaults

    /* ========== EVENTS ========== */
    event Deposited(address indexed user, uint256 amount);
    event RedeemRequest(address indexed user, uint256 amount, uint256 endTime);
    event RedeemFinalize(address indexed user, uint256 amount);

    event AdjustStakes(
        address indexed user,
        address[] vaults,
        uint256[] percents
    );

    /* ========== INITIALIZE ========== */
    /// @notice Initialize a new gvToken.
    /// @param _pot Address of a bribe pot.
    /// @param _stakingToken Address of a token to be deposited in exchange
    /// of Growing vote token.
    /// @param _rcaController Address of a RCA controller needed for verifying
    /// active rca vaults.
    /// @param _tokenSwap VArmor to EASE token swap address
    /// @param _genesis Deposit time of first vArmor holder.
    function initialize(
        address _pot,
        address _stakingToken,
        address _rcaController,
        address _tokenSwap,
        uint256 _genesis
    ) external initializer {
        __Ownable_init();
        pot = IBribePot(_pot);
        stakingToken = IERC20Permit(_stakingToken);
        rcaController = IRcaController(_rcaController);
        tokenSwap = ITokenSwap(_tokenSwap);
        genesis = uint32((_genesis / WEEK) * WEEK);
        metadata = MetaData("Growing Vote Ease", "gvEase", 18);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */
    /// @notice Deposit ease and recieve gvEASE
    /// @param amount Amount of ease to deposit.
    /// @param permit v,r,s and deadline for signed approvals (EIP-2612)
    function deposit(uint256 amount, PermitArgs memory permit) external {
        _deposit(msg.sender, amount, block.timestamp, permit, false);
    }

    /// @notice Deposit for vArmor holders to give them
    /// extra power when migrating
    /// @param amount Amount of EASE
    /// @param depositStart Extra time start for stakers of Armor Token
    /// as promised by EASE DAO when token migration from ARMOR to EASE
    /// @param proof Merkle proof of the vArmor staker
    /// @param permit v,r,s and deadline for signed approvals (EIP-2612)
    function deposit(
        uint256 amount,
        uint256 depositStart,
        bytes32[] memory proof,
        PermitArgs memory permit
    ) external {
        _depositForVArmorHolders(
            msg.sender,
            amount,
            depositStart,
            proof,
            permit
        );
    }

    /// @notice Deposit vArmor and recieve gvEASE with extra start time
    /// @param amount Amount of EASE
    /// @param vArmorAmt Amount in vArmor
    /// @param depositStart Extra time start for stakers of Armor Token
    /// as promised by EASE DAO when token migration from ARMOR to EASE
    /// @param proof Merkle proof of the vArmor staker
    /// @param permit v,r,s and deadline for signed approvals (EIP-2612)
    function depositWithVArmor(
        uint256 amount,
        uint256 vArmorAmt,
        uint256 depositStart,
        bytes32[] memory proof,
        PermitArgs memory permit
    ) external {
        address user = msg.sender;
        tokenSwap.swapVArmorFor(user, vArmorAmt);

        _depositForVArmorHolders(user, amount, depositStart, proof, permit);
    }

    /// @notice Deposit armor and recieve gvEASE
    /// @param amount Amount of armor to deposit.
    /// @param permit v,r,s and deadline for signed approvals (EIP-2612)
    function depositWithArmor(uint256 amount, PermitArgs memory permit)
        external
    {
        address user = msg.sender;
        tokenSwap.swapFor(user, amount);
        _deposit(user, amount, block.timestamp, permit, false);
    }

    /// @notice Request redemption of gvToken back to ease
    /// Has a withdrawal delay which will work in 2 parts(request and finalize)
    /// @param amount The amount of tokens in EASE to withdraw
    /// gvToken from bribe pot if true
    function withdrawRequest(uint256 amount) external {
        address user = msg.sender;
        require(amount <= _totalDeposit[user], "not enough deposit!");
        WithdrawRequest memory currRequest = withdrawRequests[user];

        (uint256 depositBalance, uint256 earnedPower) = _balanceOf(user);

        uint256 gvAmtToWithdraw = _gvTokenValue(
            amount,
            depositBalance,
            earnedPower
        );
        uint256 gvBalance = depositBalance + earnedPower;

        // withdraw form bribe pot if necessary
        _withdrawFromPot(user, gvAmtToWithdraw, gvBalance);

        _updateDeposits(user, amount);

        _updateTotalSupply(gvAmtToWithdraw);

        _updateDelegated(user, gvAmtToWithdraw, gvBalance);

        uint256 endTime = block.timestamp + withdrawalDelay;
        currRequest.endTime = uint32(endTime);
        currRequest.amount += uint128(amount);
        withdrawRequests[user] = currRequest;

        emit RedeemRequest(user, amount, endTime);
    }

    /// @notice Used to exchange gvToken back to ease token and transfers
    /// pending EASE withdrawal amount to the user if withdrawal delay is over
    function withdrawFinalize() external {
        // Finalize withdraw of a user
        address user = msg.sender;

        WithdrawRequest memory userReq = withdrawRequests[user];
        delete withdrawRequests[user];
        require(
            userReq.endTime <= block.timestamp,
            "withdrawal not yet allowed"
        );

        stakingToken.safeTransfer(user, userReq.amount);

        emit RedeemFinalize(user, userReq.amount);
    }

    /// @notice Adjusts stakes of a user to different RCA-vaults
    /// @param vaults Rca vaults user want's to stake
    /// @param percents Percentages of gvTokens user wants to stake
    /// in each RCA-vault
    function adjustStakes(address[] memory vaults, uint256[] memory percents)
        external
    {
        address user = msg.sender;
        uint256 length = vaults.length;
        require(percents.length == length, "length mismatch");
        uint256 totalPercent;
        for (uint256 i; i < length; i++) {
            require(rcaController.activeShields(vaults[i]), "vault not active");
            totalPercent += percents[i];
        }
        require(totalPercent <= MAX_PERCENT, "can't stake more than 100%");
        emit AdjustStakes(user, vaults, percents);
    }

    /// @notice Deposits gvToken of an account to bribe pot
    /// @param amount Amount of gvToken to bribe
    function depositToPot(uint256 amount) external {
        // deposits user gvToken to bribe pot and
        // get rewards against it
        address user = msg.sender;
        uint256 totalPower = balanceOf(user);
        uint256 leased = leasedAmount[user];

        require(totalPower >= (amount + leased), "not enough power");

        leasedAmount[user] += amount;

        pot.deposit(user, amount);
    }

    /// @notice Withdraws bribed gvToken from bribe pot
    /// @param amount Amount in gvToken to withdraw from bribe pot
    function withdrawFromPot(uint256 amount) external {
        // withdraws user gvToken from bribe pot
        leasedAmount[msg.sender] -= amount;
        pot.withdraw(msg.sender, amount);
    }

    /// @notice Allows user to collect rewards.
    function claimReward() external {
        pot.getReward(msg.sender, true);
    }

    /// @notice Allows account to claim rewards from Bribe pot and deposit
    /// to gain more gvToken
    function claimAndDepositReward() external {
        address user = msg.sender;
        // bribe rewards from the pot
        uint256 amount;

        PermitArgs memory permit;
        if (leasedAmount[user] > 0) {
            amount = pot.getReward(user, false);
        }
        if (amount > 0) {
            _deposit(user, amount, block.timestamp, permit, true);
        }
    }

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(metadata.name)),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry)
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );

        address signatory = ecrecover(digest, v, r, s);
        require(
            signatory != address(0),
            "gvEASE::delegateBySig: invalid signature"
        );
        require(
            nonce == nonces[signatory]++,
            "gvEASE::delegateBySig: invalid nonce"
        );
        require(
            block.timestamp <= expiry,
            "gvEASE::delegateBySig: signature expired"
        );
        return _delegate(signatory, delegatee);
    }

    /* ========== ONLY GOV ========== */

    /// @notice Set root for vArmor holders to get earlier deposit start time.
    /// @param root Merkle root of the vArmor holders.
    function setPower(bytes32 root) external onlyOwner {
        _powerRoot = root;
    }

    /// @notice Change withdrawal delay
    /// @param time Delay time in seconds
    function setDelay(uint256 time) external onlyOwner {
        time = (time / 1 weeks) * 1 weeks;
        require(time >= 1 weeks, "min delay 7 days");
        withdrawalDelay = time;
    }

    /// @notice Update total supply for ecosystem wide grown part
    /// @param newTotalSupply New total supply.(should be > existing supply)
    function setTotalSupply(uint256 newTotalSupply) external onlyOwner {
        uint256 totalEaseDeposit = totalDeposited;

        require(
            newTotalSupply >= totalEaseDeposit &&
                newTotalSupply <= (totalEaseDeposit * 2),
            "not in range"
        );
        // making sure governance can only update for the vote grown part
        require(newTotalSupply > _totalSupply, "existing > new amount");

        _totalSupply = newTotalSupply;
    }

    /* ========== VIEW FUNCTIONS ========== */

    /// @notice EIP-20 token name for this token
    function name() external view returns (string memory) {
        return metadata.name;
    }

    /// @notice EIP-20 token symbol for this token
    function symbol() external view returns (string memory) {
        return metadata.symbol;
    }

    /// @notice EIP-20 token decimals for this token
    function decimals() external view returns (uint8) {
        return uint8(metadata.decimals);
    }

    /// @notice Get total ease deposited by user
    /// @param user The address of the account to get total deposit
    /// @return total ease deposited by the user
    function totalDeposit(address user) external view returns (uint256) {
        return _totalDeposit[user];
    }

    /// @notice Get deposits of a user
    /// @param user The address of the account to get the deposits of
    /// @return Details of deposits in an array
    function getUserDeposits(address user)
        external
        view
        returns (Deposit[] memory)
    {
        return _deposits[user];
    }

    /// @notice Total number of tokens in circulation
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /// @notice Get the number of tokens held by the `account`
    /// @param user The address of the account to get the balance of
    /// @return The number of tokens held
    function balanceOf(address user) public view override returns (uint256) {
        (uint256 depositAmount, uint256 powerEarned) = _balanceOf(user);
        return depositAmount + powerEarned;
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function _authorizeUpgrade(address) internal override onlyOwner {}

    ///@notice Deposit EASE to obtain gvToken that grows upto
    ///twice the amount of ease being deposited.
    ///@param user Wallet address to deposit for
    ///@param amount Amount of EASE to deposit
    ///@param depositStart Start time of deposit(current timestamp
    /// for regular deposit and ahead timestart for vArmor holders)
    ///@param permit v,r,s and deadline for signed approvals (EIP-2612)
    ///@param fromBribePot boolean to represent if reward being deposited
    ///for compounding gvPower
    function _deposit(
        address user,
        uint256 amount,
        uint256 depositStart,
        PermitArgs memory permit,
        bool fromBribePot
    ) internal {
        require(amount > 0, "cannot deposit 0!");

        // we only transfer tokens from user if they are
        // depositing from their external wallet if this
        // function is called by claimAndDepositReward we don't
        // need to transfer EASE as it will already be transferred
        // to this contract address
        if (!fromBribePot) {
            _transferStakingToken(user, amount, permit);
        }

        _updateBalances(user, amount, depositStart);

        emit Deposited(user, amount);
    }

    function _depositForVArmorHolders(
        address user,
        uint256 amount,
        uint256 depositStart,
        bytes32[] memory proof,
        PermitArgs memory permit
    ) internal {
        bytes32 leaf = keccak256(abi.encodePacked(user, amount, depositStart));

        require(MerkleProof.verify(proof, _powerRoot, leaf), "invalid proof");
        require(depositStart >= genesis, "depositStart < genesis");

        _deposit(user, amount, depositStart, permit, false);
    }

    function _updateBalances(
        address user,
        uint256 amount,
        uint256 depositStart
    ) internal {
        Deposit memory newDeposit = Deposit(
            uint128(amount),
            uint32(depositStart)
        );

        totalDeposited += newDeposit.amount;
        _totalSupply += newDeposit.amount;
        _totalDeposit[user] += newDeposit.amount;
        _deposits[user].push(newDeposit);
    }

    function _transferStakingToken(
        address from,
        uint256 amount,
        PermitArgs memory permit
    ) internal {
        if (permit.r != "") {
            stakingToken.permit(
                from,
                address(this),
                amount,
                permit.deadline,
                permit.v,
                permit.r,
                permit.s
            );
        }
        stakingToken.safeTransferFrom(from, address(this), amount);
    }

    ///@notice Withraw from bribe pot if withdraw amount of gvToken exceeds
    ///(gvToken balance - bribed amount)
    function _withdrawFromPot(
        address user,
        uint256 gvAmountToWithdraw,
        uint256 userTotalGvBal
    ) internal {
        uint256 totalLeased = leasedAmount[user];
        uint256 gvAmtAvailableForBribe = userTotalGvBal - totalLeased;
        // whether user is willing to withdraw from bribe pot
        // we will not add reward amount to withdraw if user doesn't
        // want to withdraw from bribe pot
        if (totalLeased > 0 && gvAmountToWithdraw > gvAmtAvailableForBribe) {
            uint256 amtToWithdrawFromPot = gvAmountToWithdraw -
                gvAmtAvailableForBribe;
            pot.withdraw(user, amtToWithdrawFromPot);
            leasedAmount[user] -= amtToWithdrawFromPot;
        }
    }

    ///@notice Loops through deposits of user from last index and pop's off the
    ///ones that are included in withdraw amount
    function _updateDeposits(address user, uint256 withdrawAmount) internal {
        Deposit memory remainder;
        uint256 totalAmount;
        // current deposit details
        Deposit memory userDeposit;

        totalDeposited -= withdrawAmount;
        _totalDeposit[user] -= withdrawAmount;
        // index to loop from
        uint256 i = _deposits[user].length;
        for (i; i > 0; i--) {
            userDeposit = _deposits[user][i - 1];
            totalAmount += userDeposit.amount;
            // remove last deposit
            _deposits[user].pop();

            // Let's say user tries to withdraw 100 EASE and they have
            // multiple ease deposits [75, 30] EASE when our loop is
            // at index 0 total amount will be 105, that means we need
            // to push the remainder to deposits array
            if (totalAmount >= withdrawAmount) {
                remainder.amount = uint128(totalAmount - withdrawAmount);
                remainder.start = userDeposit.start;
                break;
            }
        }

        // If there is a remainder we need to update the index at which
        // we broke out of loop and push the withdrawan amount to user
        // _deposits withdraw 100 ease from [75, 30] EASE balance becomes
        // [5]
        if (remainder.amount != 0) {
            _deposits[user].push(remainder);
        }
    }

    ///@notice Updates total supply on withdraw request
    /// @param gvAmtToWithdraw Amount of gvToken to withdraw of a user
    function _updateTotalSupply(uint256 gvAmtToWithdraw) internal {
        // if _totalSupply is not in Sync with the grown votes of users
        // and if it's the last user wanting to get out of this contract
        // we need to take consideration of underflow and at the same time
        // set total supply to zero
        if (_totalSupply < gvAmtToWithdraw || totalDeposited == 0) {
            _totalSupply = 0;
        } else {
            _totalSupply -= gvAmtToWithdraw;
        }
    }

    /// @notice Updates delegated votes of a user on withdraw request.
    /// @param user Address of the user requesting withdraw.
    /// @param withdrawAmt Amount of gvToken being withdrawn.
    /// @param gvBalance Total gvToken balance of a user.
    function _updateDelegated(
        address user,
        uint256 withdrawAmt,
        uint256 gvBalance
    ) internal {
        uint256 remainingGvBal = gvBalance - withdrawAmt;
        uint256 delegatedAmt = _delegated[user];
        // this means we need to deduct delegated Amt
        if (remainingGvBal < delegatedAmt) {
            uint256 gvAmtToDeduct = delegatedAmt - remainingGvBal;
            _delegated[user] -= gvAmtToDeduct;
            _moveDelegates(
                _delegates[msg.sender],
                address(0),
                gvAmtToDeduct,
                0
            );
        }
    }

    function _balanceOf(address user)
        internal
        view
        returns (uint256 depositBalance, uint256 powerEarned)
    {
        uint256 timestamp = block.timestamp;
        depositBalance = _totalDeposit[user];

        uint256 i = _deposits[user].length;
        uint256 depositIncluded;
        for (i; i > 0; i--) {
            Deposit memory userDeposit = _deposits[user][i - 1];

            if ((timestamp - userDeposit.start) > MAX_GROW) {
                // if we reach here that means we have max_grow
                // has been achieved for earlier deposits
                break;
            }

            depositIncluded += userDeposit.amount;
            powerEarned += _powerEarned(userDeposit, timestamp);
        }
        // if we break out of the loop and the user has deposits
        // that have gained max power we need to add that deposit amount
        // to power earned because power can only grow upto deposit amount
        powerEarned += (depositBalance - depositIncluded);
    }

    function _powerEarned(Deposit memory userDeposit, uint256 timestamp)
        private
        pure
        returns (uint256 powerGrowth)
    {
        uint256 timeSinceDeposit = timestamp - userDeposit.start;

        if (timeSinceDeposit < MAX_GROW) {
            powerGrowth =
                (userDeposit.amount *
                    ((timeSinceDeposit * MULTIPLIER) / MAX_GROW)) /
                MULTIPLIER;
        } else {
            powerGrowth = userDeposit.amount;
        }
    }

    function _gvTokenValue(
        uint256 easeAmt,
        uint256 depositBalance,
        uint256 earnedPower
    ) internal pure returns (uint256 gvTokenValue) {
        uint256 conversionRate = (((depositBalance + earnedPower) *
            MULTIPLIER) / depositBalance);
        gvTokenValue = (easeAmt * conversionRate) / MULTIPLIER;
    }

    function _percentToGvPower(
        uint256 stakedPercent,
        uint256 gvBalance,
        uint256 bribed
    ) internal pure returns (uint256 stakedGvPower) {
        stakedGvPower = (stakedPercent * (gvBalance - bribed)) / MAX_PERCENT;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
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

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

/// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;
import {IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IERC20Permit is IERC20Upgradeable {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

/// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

interface IGvToken {
    /* ========== STRUCTS ========== */
    struct Deposit {
        uint128 amount;
        uint128 start;
    }
    struct PermitArgs {
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    /* ========== EVENTS ========== */
    event Deposited(address indexed user, uint256 amount);
    event RedeemRequest(address indexed user, uint256 amount, uint256 endTime);
    event RedeemFinalize(address indexed user, uint256 amount);
    event Stake(
        address indexed user,
        address indexed vault,
        uint256 percentage
    );

    event UnStake(
        address indexed user,
        address indexed vault,
        uint256 percentage
    );

    function deposit(uint256 amount, PermitArgs memory args) external;

    function deposit(
        uint256 amount,
        uint256 depositStart,
        bytes32[] memory proof,
        PermitArgs memory args
    ) external;

    function withdrawRequest(uint256 amount) external;

    function withdrawFinalize() external;

    function stake(uint256 balancePercent, address vault) external;

    function unStake(uint256 balancePercent, address vault) external;

    function depositToPot(uint256 amount) external;

    function withdrawFromPot(uint256 amount) external;

    function claimReward() external;

    function claimAndDepositReward() external;

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function setPower(bytes32 root) external;

    function setDelay(uint256 time) external;

    function setTotalSupply(uint256 newTotalSupply) external;

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function powerStaked(address user, address vault)
        external
        view
        returns (uint256);

    function powerAvailableForStake(address user)
        external
        view
        returns (uint256);

    function getUserDeposits(address user)
        external
        view
        returns (Deposit[] memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address user) external view returns (uint256);
}

/// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

interface IBribePot {
    /* ========== structs ========== */
    struct PermitArgs {
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    /* ========== EVENTS ========== */
    event Leased(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event BribeAdded(
        address indexed user,
        address indexed vault,
        uint256 bribePerWeek,
        uint256 startWeek,
        uint256 endWeek
    );
    event BribeCanceled(
        address indexed user,
        address indexed vault,
        uint256 bribePerWeek,
        uint256 expiryWeek, // this will always currentWeek + 1
        uint256 endWeek
    );

    function deposit(address from, uint256 amount) external;

    function withdraw(address to, uint256 amount) external;

    function bribe(
        uint256 bribeRate,
        address vault,
        uint256 numOfWeeks,
        PermitArgs memory permit
    ) external;

    function cancelBribe(address vault) external;

    function getReward(address user, bool toUser) external returns (uint256);

    function earned(address user) external view returns (uint256);

    function balanceOf(address user) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function bribePerWeek() external view returns (uint256);

    function earnable(address user) external view returns (uint256);
}

/// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

interface IRcaController {
    function activeShields(address shield) external view returns (bool);
}

/// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

interface ITokenSwap {
    function swap(uint256 amount) external;

    function swapFor(address user, uint256 amount) external;

    function swapVArmor(uint256 amount) external;

    function swapVArmorFor(address user, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == root;
    }
}

/// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

// solhint-disable not-rely-on-time
// solhint-disable reason-string
// solhint-disable no-inline-assembly

abstract contract Delegable {
    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint128 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping(address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,uint256 chainId,address verifyingContract)"
        );

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping(address => uint256) public nonces;

    /// @notice A record of each accounts delegate
    mapping(address => address) internal _delegates;
    /// @notice A record of delegated amount of a account
    mapping(address => uint256) internal _delegated;

    event DelegateVotesChanged(
        address indexed delegate,
        uint256 previousBalance,
        uint256 newBalance
    );
    event DelegateChanged(
        address indexed delegator,
        address indexed fromDelegate,
        address indexed toDelegate
    );

    /**
     * @notice Vote amount delegated by delegator
     * @param delegator The address to get amount of vote delegated
     * @return amount of vote delegated by delegator
     */
    function delegated(address delegator) external view returns (uint256) {
        return _delegated[delegator];
    }

    /**
     * @notice Delegates of delegator
     * @param delegator The address to get delegatee for
     * @return address of delegates
     */
    function delegates(address delegator) external view returns (address) {
        return _delegates[delegator];
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual;

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[account];
        return
            nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint256 blockNumber)
        external
        view
        returns (uint256)
    {
        require(
            blockNumber < block.number,
            "gvToken::getPriorVotes: not yet determined"
        );

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function balanceOf(address user) public view virtual returns (uint256);

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = _delegates[delegator];
        uint256 oldDelegatorBalance = _delegated[delegator];
        // additional amount that has grown by this time
        uint256 newDelegatorBalance = balanceOf(delegator);

        _delegates[delegator] = delegatee;
        _delegated[delegator] = newDelegatorBalance;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(
            currentDelegate,
            delegatee,
            oldDelegatorBalance,
            newDelegatorBalance
        );
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint256 oldAmount,
        uint256 newAmount
    ) internal {
        if (srcRep != address(0) && oldAmount != 0) {
            // decrease old representative
            uint32 srcRepNum = numCheckpoints[srcRep];
            uint256 srcRepOld = srcRepNum > 0
                ? checkpoints[srcRep][srcRepNum - 1].votes
                : 0;
            uint256 srcRepNew = srcRepOld - oldAmount;
            _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
        }
        if (dstRep != address(0) && newAmount != 0) {
            // increase new representative
            uint32 dstRepNum = numCheckpoints[dstRep];
            uint256 dstRepOld = dstRepNum > 0
                ? checkpoints[dstRep][dstRepNum - 1].votes
                : 0;
            uint256 dstRepNew = dstRepOld + newAmount;
            _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    ) internal {
        uint32 blockNumber = safe32(
            block.number,
            "gvToken::_writeCheckpoint: block number exceeds 32 bits"
        );

        if (
            nCheckpoints > 0 &&
            checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber
        ) {
            checkpoints[delegatee][nCheckpoints - 1].votes = uint128(newVotes);
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(
                blockNumber,
                uint128(newVotes)
            );
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }
        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint32)
    {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
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