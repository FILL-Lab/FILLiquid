// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// this contract used for user staking FIG to get FIL bonus rewards,
// and contract description refs to https://github.com/FILL-Lab/FILLiquid/pull/130

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
        uint totalBonus;            // total bonus amount
        uint totalWithdrawn;        // total withdrawn amount
        uint[] totalStakes;         // total stake amount of each stake type
    }

    event BonusCreated(address indexed sender, uint bonusId, uint amount, uint start, uint end, uint totalPower);
    event StakeCreated(address indexed staker, uint stakeId, uint amount, uint stakeType, uint start, uint startBonusId);
    event StakeDropped(address indexed staker, uint stakeId, uint amount, uint stakeType, uint withdrawn, uint unWithdrawn);
    event Withdrawn(address indexed staker, uint amount);

    uint constant MIN_BONUS_AMOUNT = 1 ether;               // todo: update to 100 ether
    uint constant MIN_STAKE_AMOUNT = 100 ether;             // the minimum amount of user staking FIG
    uint constant BLOCKS_PER_DAY = 1; // 86400 / 32;              // blocks in one day
    uint constant MAX_USER_STAKE_NUMBER = 5;                // the maximum number of user stakes
    uint constant BONUS_DURATION = BLOCKS_PER_DAY * 7;      // bonus duration
    uint constant RATE_BASE = 1000000;                      // used for calculate reward

    ERC20 public immutable _token;

    uint private _nextStakeId = 0;
    Bonus[] private _bonuses;
    Stat private _stat;
    
    mapping (StakeType => Factor) private _factors;       // mapping stake type to factor;
    mapping (uint => Stake) private _stakes;              // mapping stake id to stake;               
    mapping (address => uint[]) private _userStakes;      // mapping user address to stake id list;
    mapping (uint => uint[]) private _bonusRewards;       // mapping bonus id to kinds of rewards;
    mapping (address => uint) private _userStakeAmount;   // mapping user address to total stake amount;

    constructor(address token) {
        _token = ERC20(token);

        _factors[StakeType.Days30] = Factor(BLOCKS_PER_DAY * 15, 10);
        _factors[StakeType.Days90] = Factor(BLOCKS_PER_DAY * 30, 20);
        _factors[StakeType.Days180] = Factor(BLOCKS_PER_DAY * 60, 30);
        _factors[StakeType.Days360] = Factor(BLOCKS_PER_DAY * 90, 40);

        _stat.totalStakes = new uint[](uint(StakeType.Days360) + 1);
    }

    receive() external payable {}

    // createBonus returns the bonus amount, any one can create bonus if the contract have enough balance
    function createBonus() external nonReentrant returns (uint) {
        // bonus should be created after the first stake
        require(_stat.totalPower > 0, "Invalid transfer");

        // anyone can create a bonus, not just the foundation. If someone transfers `FIL` to the contract, 
        // this part of `FIL` can also be used as part of the reward. The total amount of the reward should 
        // be the total amount of FIL transferred by the foundation and the user. This value should be greater
        // than MIN_BONUS_AMOUNT and less than the available balance.
        uint amount = avaiableFil();
        require(address(this).balance >= amount, "Insufficient balance");
        require(amount >= MIN_BONUS_AMOUNT, "Invalid bonus amount");

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

        // update stat
        _stat.totalBonus += bonus.amount;

        // notify event to log
        address creator = _msgSender();
        emit BonusCreated(creator, bonus.id, bonus.amount, bonus.start, bonus.end, _stat.totalPower);

        return amount;
    }

    // staking user stake fig to get `filcoin` bonus rewards, the stake amount should be greater 
    // than MIN_STAKE_AMOUNT. each `stake` will get subsequent bonus returns, marking the next 
    // bonus as the starting point. and single user can have up to 5 stakes at the same time.
    function staking(uint amount, uint uStakeTyp) external nonReentrant returns (uint) {

        // check stake amount
        require(amount >= MIN_STAKE_AMOUNT, "Invalid stake amount");

        // check user balance 
        address staker = _msgSender();
        require(_token.balanceOf(staker) >= amount, "Insufficient balance");

        // scan user stakes and check valid stake number
        Stake[] memory stakes = getUserStakes(staker);
        require(stakes.length < MAX_USER_STAKE_NUMBER, "User stakes overflow");
        
        // get stake duration and power by stake type, and calculate power
        StakeType stktyp = StakeType(uStakeTyp);
        Factor memory factor = _factors[stktyp];
        _stat.totalPower += factor.powerRate * amount;
        _stat.totalStake += amount;
        _stat.totalStakes[uStakeTyp] += amount;
        _userStakeAmount[staker] += amount;

        // create stake and transfer FIG to this contract, there  is an extreme case, 
        // if bonus and stake are in the same block, calculated according to the order of events
        uint startBonusId = nextBonusId();
        uint stakeId = _nextStakeId++;
        _stakes[stakeId] = Stake(staker, stakeId, amount, block.number, startBonusId, 0, stktyp);
        _userStakes[staker].push(stakeId);
        
        _token.transferFrom(staker, address(this), amount);

        emit StakeCreated(staker, stakeId, amount, uStakeTyp, block.number, startBonusId);

        return amount;
    }

    // unStake user cancels the stake based on stake identity, and takes back the original fig token,
    // and automatically withdraw the `fil token` rewards generated during the stake period.
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
        _stat.totalStakes[uint(stake.stakeType)] -= stake.amount;
        _userStakeAmount[staker] -= stake.amount;

        // staker retrive `FIG` token and reward `FIL`
        uint unWithdrawn = _calculate(stake);
        uint withdrawn = stake.withdrawn + unWithdrawn;
        _token.transfer(staker, stake.amount);
        payable(staker).transfer(unWithdrawn);
        _stat.totalWithdrawn += unWithdrawn;

        // delete stake record, and the stake.withdrawn should not be updated
        uint[] storage stakeIds = _userStakes[staker];
        for (uint i = 0; i < stakeIds.length; i++) {
            if (stakeIds[i] == stakeId) {
                stakeIds[i] = stakeIds[stakeIds.length - 1];
                stakeIds.pop();
                break;
            }
        }
        delete _stakes[stakeId];

        // notify event
        emit StakeDropped(staker, stakeId, stake.amount, uint(stake.stakeType), withdrawn, unWithdrawn);

        return unWithdrawn;
    }

    // withdraw user manually claim the rewards generated by all stakes up to the current block.
    function withdraw() external nonReentrant returns (uint) {
        uint sum = 0;

        // obtain the message sender's right to receive profit as a staker
        address staker = _msgSender();

        // get all stakes of the user and calculate the reward
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
            _stat.totalWithdrawn += reward;
        }

        // transfer the reward to the user if the reward not empty
        if (sum > 0) {
            payable(staker).transfer(sum);
            emit Withdrawn(staker, sum);
        }

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

    function getBonus(uint bonusId) public view returns (Bonus memory r) {
        r = _bonuses[bonusId];
    }

    function getBonusRewards(uint bonusId) public view returns (uint[] memory r) {
        r = _bonusRewards[bonusId];
    }

    function getFactor(uint stakeType) public view returns (Factor memory r) {
        r = _factors[StakeType(stakeType)];
    }

    function canWithdraw(address staker) public view returns (uint r) {
        Stake[] memory stakes = getUserStakes(staker);
        for (uint i = 0; i < stakes.length; i++) {
            r += _calculate(stakes[i]);
        }
    }

    function getTotalStakeList() public view returns (uint[] memory) {
        return _stat.totalStakes;
    }

    function getBonusNum() public view returns (uint) {
        return _bonuses.length;
    }

    function accumulatedDeposited() public view returns (uint) {
        return address(this).balance + _stat.totalWithdrawn;
    }

    function accumulatedBonus() public view returns (uint) {
        return _stat.totalBonus;
    }

    function accumulatedWithdrawn() public view returns (uint) {
        return _stat.totalWithdrawn;
    }

    function accumulatedStake() public view returns (uint) {
        return _stat.totalStake;
    }

    function accumulatedPower() public view returns (uint) {
        return _stat.totalPower;
    }

    // calculate the avaiable balance which can used be bonus
    function avaiableFil() public view returns (uint) {
        return accumulatedDeposited() - accumulatedBonus();
    }

    // ---------------------------------------------------------------------------------
    //  help functions
    // 
    // ---------------------------------------------------------------------------------

    // calculate stake reward, reward equals to `stakeType powerRate * bonus reward amount / totalPower`
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

    function nextBonusId() private view returns (uint) {
        return _bonuses.length;
    }
}