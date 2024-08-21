// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract FIGStake is Context, ReentrancyGuard {

    enum StakeType {
        Days30,           // 0
        Days90,           // 1
        Days180,          // 2  
        Days360           // 3  
    }

    struct Stake {
        address staker;
        uint id;
        uint amount;
        uint start;
        uint startBounsId;
        uint withdrawn;             // already withdraw
        StakeType stakeType;
    }

    struct Bonus {
        uint id;
        uint amount;
        uint start;
        uint end;
    }

    struct Factor {
        uint duration;              // stake duration
        uint powerRate;             // stake power rate, user power equals to `amount * powerRate`
    }

    struct Stat {
        uint totalPower;            // total power of all stakes
        uint totalStake;            // total stake amount
        uint userTransferRest;      // user but not foundation transfer FIL to this contract, and the value will be part of next bonus
        uint userTotalTransfer;     // the sum of FIL transfered by user but not foundation
    }

    event BonusCreated(address indexed sender, uint bonusId, uint amount, uint start, uint end, uint totalPower);
    event StakeCreated(address indexed staker, uint stakeId, uint amount, uint stakeType, uint start, uint startBonusId);
    event StakeDropped(address indexed staker, uint stakeId, uint amount, uint stakeType, uint withdrawn, uint unWithdrawn);
    event Withdrawn(address indexed staker, uint amount);
    event Received(address indexed sender, uint amount);

    uint constant MIN_BONUS_AMOUNT = 1 ether;               // todo: update to 100 ether
    uint constant MIN_STAKE_AMOUNT = 100 ether;             // the minimum amount of user staking FIG
    uint constant BLOCKS_PER_DAY = 1; // 86400 / 32;              // blocks in one day
    uint constant MAX_USER_STAKE_NUMBER = 5;                // the maximum number of user stakes
    uint constant BONUS_DURATION = BLOCKS_PER_DAY * 7;      // bonus duration
    uint constant RATE_BASE = 1000000;                      // used for calculate reward

    ERC20 public immutable _token;
    address public immutable _foundation;

    uint private _nextStakeId = 0;
    Bonus[] private _bonuses;
    Stat private _stat;
    
    mapping (StakeType => Factor) private _factors;       // mapping stake type to factor;
    mapping (uint => Stake) private _stakes;              // mapping stake id to stake;               
    mapping (address => uint[]) private _userStakes;      // mapping user address to stake id list;
    mapping (uint => uint[]) private _bonusRewards;       // mapping bonus id to kinds of rewards;
    mapping (address => uint) private _userStakeAmount;   // mapping user address to total stake amount;

    constructor(address token, address foundation) {
        _token = ERC20(token);
        _foundation = foundation;

        _factors[StakeType.Days30] = Factor(BLOCKS_PER_DAY * 30, 10);
        _factors[StakeType.Days90] = Factor(BLOCKS_PER_DAY * 90, 20);
        _factors[StakeType.Days180] = Factor(BLOCKS_PER_DAY * 180, 30);
        _factors[StakeType.Days360] = Factor(BLOCKS_PER_DAY * 360, 40);
    }

    // foundation transfer FIL to this contract to create bonus
    // allow user to transfer FIL to this contract, and the value will be part of next bonus
    receive() external payable {
        // `isFoundation` will compare the tx.origin address but not msg.sender, the msg.sender 
        // can be `FILPot` contract address, so the `isFoundation` will return false.
        if (isFoundation() && msg.value >= MIN_BONUS_AMOUNT) {
            // foundation should transfer after user staking FIL
            require(_stat.totalPower > 0, "Invalid transfer");

            // bonus amount should be the sum of transfer amount and the contract rest balance
            uint amount = msg.value + _stat.userTransferRest;
            _stat.userTransferRest = 0;
            require(address(this).balance >= amount, "Insufficient balance");
            
            // create bonus, bonus time range the scope of （start, end]
            uint start = block.number;
            uint end = start +  BONUS_DURATION;
            Bonus memory bonus = Bonus(nextBonusId(), amount, start, end);
            _bonuses.push(bonus);

            // set bonus rewards
            uint[] memory rewards = new uint[](uint(StakeType.Days360) + 1);
            for (uint i = uint(StakeType.Days30); i <= uint(StakeType.Days360); i++) {
                rewards[i] = _rewardUnit(i, bonus.amount);
            }
            _bonusRewards[bonus.id] = rewards;

            emit BonusCreated(_foundation, bonus.id, bonus.amount, bonus.start, bonus.end, _stat.totalPower);
        } else {
            _stat.userTransferRest += msg.value;
            _stat.userTotalTransfer += msg.value;
            emit Received(tx.origin, msg.value);
        }
    }

    function staking(uint amount, uint uStakeTyp) external nonReentrant returns (uint) {

        // check stake amount
        require(amount >= MIN_STAKE_AMOUNT, "Invalid stake amount");

        // check user balance 
        address staker = _msgSender();
        require(_token.balanceOf(staker) >= amount, "Insufficient balance");

        // scan user stakes and check valid stake number
        Stake[] memory stakes = getUserStakes(staker);
        require(stakes.length < MAX_USER_STAKE_NUMBER, "User stakes too much");
        
        // get stake duration and power by stake type, and calculate power
        StakeType stktyp = StakeType(uStakeTyp);
        Factor memory factor = _factors[stktyp];
        _stat.totalPower += factor.powerRate * amount;
        _stat.totalStake += amount;        
        _userStakeAmount[staker] += amount;

        // create stake and transfer FIG to this contract
        // mark(fuk): 极限情况，如果bonus和stake在同一区块，按照事件顺序计算
        uint startBonusId = nextBonusId();
        uint stakeId = _nextStakeId++;
        _stakes[stakeId] = Stake(staker, stakeId, amount, block.number, startBonusId, 0, stktyp);
        _userStakes[staker].push(stakeId);
        
        _token.transferFrom(staker, address(this), amount);

        emit StakeCreated(staker, stakeId, amount, uStakeTyp, block.number, startBonusId);

        return amount;
    }

    function unStake(uint stakeId) external nonReentrant returns (uint) { 
        // check authority
        Stake memory stake = _stakes[stakeId];
        address staker = _msgSender();
        require(stake.staker == staker, "Invalid staker");

        // check stake duration
        require(stake.start + _factors[stake.stakeType].duration < block.number, "Stake end not reached");

        // get stake duration and power by stake type, and calculate power     
        Factor memory factor = _factors[stake.stakeType];
        uint power = factor.powerRate * stake.amount;
        _stat.totalPower -= power;
        _stat.totalStake -= stake.amount;
        _userStakeAmount[staker] -= stake.amount;

        // delete stake record
        uint[] storage stakeIds = _userStakes[staker];
        for (uint i = 0; i < stakeIds.length; i++) {
            if (stakeIds[i] == stakeId) {
                stakeIds[i] = stakeIds[stakeIds.length - 1];
                stakeIds.pop();
                break;
            }
        }
        delete _stakes[stakeId];

        // transfer FIG to staker
        uint unWithdrawn = _calculate(stake);
        uint withdrawn = stake.withdrawn + unWithdrawn;
        _token.transfer(staker, unWithdrawn);

        emit StakeDropped(staker, stakeId, stake.amount, uint(stake.stakeType), withdrawn, unWithdrawn);

        return unWithdrawn;
    }

    function withdraw() external nonReentrant returns (uint) {
        uint sum = 0;
        address staker = _msgSender();

        Stake[] memory stakes = getUserStakes(staker);
        for (uint i = 0; i < stakes.length; i++) {
            Stake memory stake = stakes[i];
            uint reward = _calculate(stake);
            if (reward == 0) {
                continue;
            }
            sum += reward;

            // update stake withdrawn in storage but not memory
            _stakes[stake.id].withdrawn += reward;
        }

        if (sum > 0) {
            _token.transfer(staker, sum);
        }

        emit Withdrawn(staker, sum);

        return sum;
    }

    // ---------------------------------------------------------------------------------
    //  view functions
    // 
    // ---------------------------------------------------------------------------------
    function getStake(uint stakeId) public view returns (Stake memory r) {
        r = _stakes[stakeId];
    }

    function getUserStakes(address staker) public view returns (Stake[] memory r) {
        uint[] memory ids = _userStakes[staker];
        r = new Stake[](ids.length);
        for (uint i = 0; i < ids.length; i++) {
            r[i] = _stakes[ids[i]];
        }
    }

    function getUserStakeAmount(address staker) public view returns (uint) {
        return _userStakeAmount[staker];
    }

    function getTotalStakeAmount() public view returns (uint) {
        return _stat.totalStake;
    }

    function getBonus(uint bonusId) public view returns (Bonus memory r) {
        r = _bonuses[bonusId];
    }

    function getBonusRewards(uint bonusId) public view returns (uint[] memory r) {
        r = _bonusRewards[bonusId];
    }

    function getFactor(uint stakeType) public view returns (Factor memory r) {
        r = _factors[StakeType(stakeType)];
    }
    
    function getPower() public view returns (uint r) {
        return _stat.totalPower;
    }

    function getTransfer() public view returns (uint[2] memory r) {
        r[0] = _stat.userTransferRest;
        r[1] = _stat.userTotalTransfer;
    }

    function canWithdraw(address staker) public view returns (uint r) {
        Stake[] memory stakes = getUserStakes(staker);
        for (uint i = 0; i < stakes.length; i++) {
            r += _calculate(stakes[i]);
        }
    }

    // ---------------------------------------------------------------------------------
    //  help functions
    // 
    // ---------------------------------------------------------------------------------
    function _calculate(Stake memory stake) private view returns (uint r) {
        for (uint i = stake.startBounsId; i < _bonuses.length; i++) {
            Bonus memory bonus = _bonuses[i];
            uint rewardUnit = _bonusRewards[bonus.id][uint(stake.stakeType)];
            if (rewardUnit == 0) {
                continue;
            }
            
            // bonus reward equals to `stakeType power * bonus reward amount / totalPower`, 
            // and the bonus time range the scope of （start, end]
            // the stake happend before the `startBonusId`, so the situation of `block.number < bonus.start` wont happend
            if (block.number > bonus.end) {
                r += _reward(rewardUnit, stake.amount);
            } else if (block.number > bonus.start && block.number <= bonus.end) {
                r += _reward(rewardUnit, stake.amount) * (block.number - bonus.start) / (bonus.end - bonus.start);
            }
        }

        require(r >= stake.withdrawn, "Invalid withdraw amount");
        r -= stake.withdrawn;
    }

    // calculate single FIG stake reward, reward equals to `stakeType powerRate * bonus reward amount / totalPower`
    function _rewardUnit(uint stakeType, uint bonusAmount) private view returns (uint) {
        return _factors[StakeType(stakeType)].powerRate * bonusAmount * RATE_BASE / _stat.totalPower;
    }

    function _reward(uint rewardUnit, uint stakeAmount) private pure returns (uint) {
        return  rewardUnit * stakeAmount / RATE_BASE;
    }

    function isFoundation() private view returns (bool) {
        return tx.origin == _foundation;
    }

    function nextBonusId() private view returns (uint) {
        return _bonuses.length;
    }
}