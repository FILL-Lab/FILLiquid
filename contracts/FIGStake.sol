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
        uint withdrawn;                         // already withdraw
        StakeType stakeType;
    }

    struct Bonus {
        uint id;
        uint amount;
        uint start;
        uint end;
    }

    struct Factor {
        uint duration;
        uint powerRate;
    }

    event BonusCreated(address indexed sender, uint bonusId, uint amount, uint start, uint totalPower, uint[] powers);
    event StakeCreated(address indexed staker, uint stakeId, uint amount, uint stakeType, uint start, uint startBonusId, uint power);
    event StakeDropped(address indexed staker, uint stakeId, uint amount, uint stakeType, uint withdrawn, uint unWithdrawn, uint power);
    event withdrawed(address indexed staker, uint amount);

    uint constant MIN_BONUS_AMOUNT = 100 ether;
    uint constant MIN_STAKE_AMOUNT = 100 ether;
    uint constant BLOCKS_PER_DAY = 86400 / 32;
    uint constant MAX_USER_STAKE_NUMBER = 5;
    uint constant BONUS_DURATION = BLOCKS_PER_DAY * 7;

    ERC20 public immutable _token;
    address public immutable _foundation;
    
    uint private _nextStakeId = 0;
    Bonus[] private _bonuses;

    uint private _totalPower = 0;
    uint private _totalStake = 0;
    uint private _userTransfer = 0;                       // user but not foundation transfer FIL to this contract, and the value will be part of next bonus
    uint private _userTotalTransfer = 0;                  // the sum of FIL transfered by user but not foundation
    mapping (StakeType => Factor) private _factors;       // mapping stake type to factor;
    mapping (StakeType => uint) private _stakePower;      // mapping stake type to power;
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
    receive() external payable nonReentrant {
        if (isFundation() && msg.value >= MIN_BONUS_AMOUNT) {
            // foundation should transfer after user staking FIL
            require(_totalPower > 0, "Invalid transfer");

            // bonus amount should be the sum of transfer amount and the contract rest balance
            uint amount = msg.value + _userTransfer;
            _userTransfer = 0;
            require(address(this).balance >= amount, "Insufficient balance");
            
            // create bonus, bonus time range the scope of （start, end]
            uint start = block.number;
            uint end = start +  BONUS_DURATION;
            Bonus memory bonus = Bonus(nextBonusId(), amount, start, end);
            _bonuses.push(bonus);

            // set bonus rewards
            uint[] memory rewards = new uint[](uint(StakeType.Days360) + 1);
            uint[] memory powers = new uint[](uint(StakeType.Days360) + 1);
            for (uint i = uint(StakeType.Days30); i <= uint(StakeType.Days360); i++) {
                uint power = _stakePower[StakeType(i)];
                rewards[i] = power * amount / _totalPower;
                powers[i] = power;
            }
            _bonusRewards[bonus.id] = rewards;

            // emit event，todo(fuk): add power and stake power
            emit BonusCreated(_foundation, bonus.id, bonus.amount, bonus.start, _totalPower, powers);
        } else {
            _userTransfer += msg.value;
            _userTotalTransfer += msg.value;
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
        uint power = factor.powerRate * amount;
        _totalPower += power;
        _stakePower[stktyp] += power;
        _totalStake += amount;
        _userStakeAmount[staker] += amount;

        // create stake and transfer FIG to this contract
        // mark(fuk): 极限情况，如果bonus和stake在同一区块，按照事件顺序计算
        uint startBonusId = nextBonusId();
        uint stakeId = _nextStakeId++;
        _stakes[stakeId] = Stake(staker, stakeId, amount, block.number, startBonusId, 0, stktyp);
        _userStakes[staker].push(stakeId);
        
        _token.transferFrom(staker, address(this), amount);

        emit StakeCreated(staker, stakeId, amount, uStakeTyp, block.number, startBonusId, power);

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
        _totalPower -= power;
        _stakePower[stake.stakeType] -= power;
        _totalStake -= stake.amount;
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

        emit StakeDropped(staker, stakeId, stake.amount, uint(stake.stakeType), withdrawn, unWithdrawn, power);

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
            stake.withdrawn += reward;
        }

        if (sum > 0) {
            _token.transfer(staker, sum);
        }

        emit withdrawed(staker, sum);

        return sum;
    }

    // ---------------------------------------------------------------------------------
    //  view functions
    // 
    // ---------------------------------------------------------------------------------
    function getStake(uint stakeId) public view returns (Stake memory) {
        return _stakes[stakeId];
    }

    function getUserStakes(address staker) public view returns (Stake[] memory stakes) {
        uint[] memory ids = _userStakes[staker];
        for (uint i = 0; i < ids.length; i++) {
            stakes[i] = _stakes[ids[i]];
        }
    }

    function getUserStakeAmount(address staker) public view returns (uint) {
        return _userStakeAmount[staker];
    }

    function getTotalStakeAmount() public view returns (uint) {
        return _totalStake;
    }

    function getBonus(uint bonusId) public view returns (Bonus memory) {
        return _bonuses[bonusId];
    }

    function getBonusRewards(uint bonusId) public view returns (uint[] memory r) {
        return _bonusRewards[bonusId];
    }

    function getFactor(uint stakeType) public view returns (Factor memory) {
        return _factors[StakeType(stakeType)];
    }
    
    function getPower() public view returns (uint[5] memory r) {
        r[0] = _totalPower;
        r[1] = _stakePower[StakeType.Days30];
        r[2] = _stakePower[StakeType.Days90];
        r[3] = _stakePower[StakeType.Days180];
        r[4] = _stakePower[StakeType.Days360];
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
            uint reward = _bonusRewards[bonus.id][uint(stake.stakeType)];
            if (reward == 0) {
                continue;
            }
            
            // bonus reward equals to `stakeType power * bonus reward amount / totalPower`, 
            // and the bonus time range the scope of （start, end]
            // the stake happend before the `startBonusId`, so the situation of `block.number < bonus.start` wont happend
            if (block.number > bonus.end) {
                r += reward * stake.amount;
            } else if (block.number > bonus.start && block.number <= bonus.end) {
                r += reward * stake.amount * (block.number - bonus.start) / (bonus.end - bonus.start);
            }
        }

        require(r >= stake.withdrawn, "Invalid withdraw amount");
        r -= stake.withdrawn;
    }

    function isFundation() private view returns (bool) {
        return _msgSender() == _foundation;
    }

    function nextBonusId() private view returns (uint) {
        return _bonuses.length;
    }
}