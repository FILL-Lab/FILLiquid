// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FIGStake is Context{

    enum StakeType {
        Days30,           // 0
        Days90,           // 1
        Days180,          // 2  
        Days360           // 3  
    }

    struct Stake {
        uint id;
        uint amount;
        uint start;
        uint duration;                          // in blocks
        address staker;
        uint startBounsId;
        uint withdrawn;                         // already withdraw
        StakeType stakeType;
    }

    struct Bonus {
        uint id;
        uint amount;
        uint start;
        uint startStakeId;
    }

    event BonusCreated(address indexed foundation, uint indexed bonusId, uint amount);
    event StakeCreated(address indexed staker, uint indexed stakeId, uint amount, uint duration);

    uint constant RATE_BASE = 1000000;
    uint constant MIN_BONUS_AMOUNT = 100 * 1e18;
    uint constant MIN_STAKE_AMOUNT = 100 * 1e18;
    uint constant BLOCKS_PER_DAY = 86400 / 32;
    uint constant BONUS_LASTED_BLOCKS = BLOCKS_PER_DAY * 7;
    uint constant MAX_USER_STAKE_NUMBER = 5;

    ERC20 private immutable _token;
    address private immutable _foundation;
    
    uint private _nextStakeId = 0;
    Bonus[] private _bonuses;

    uint private _totalPower = 0;
    uint private _totalStake = 0;
    mapping (uint => uint) private _stakePower;     // mapping stake type to power;
    mapping (uint => Stake) _stakes;                // mapping stake id to stake;               
    mapping (address => uint[]) _userStakes;        // mapping user address to stake id list;
    mapping (uint => uint[]) _bonusRewards;         // mapping bonus id to kinds of rewards;
    mapping (address => uint) _userStakeAmount      // mapping user address to total stake amount;

    constructor(address token, address foundation) {
        _token = ERC20(token);
        _foundation = foundation;
    }

    // foundation transfer FIL to this contract to create bonus
    // allow user to transfer FIL to this contract, and the value will be part of next bonus
    receive() external payable {
        if (isFundation() && msg.value >= MIN_BONUS_AMOUNT) {
            // foundation should transfer after user staking FIL
            require(_totalPower > 0, "Invalid transfer");

            // bonus amount should be the sum of transfer amount and the contract rest balance
            uint amount = msg.value + address(this).balance;

            // create bonus
            Bonus memory bonus = Bonus(nextBonusId(), amount, block.number, _nextStakeId);
            _bonuses.push(bonus);

            // set bonus rewards
            uint[] memory rewards = new uint[](uint(StakeType.Days360) + 1);
            for (uint i = uint(StakeType.Days30); i <= uint(StakeType.Days360); i++) {
                uint power = _stakePower[i];
                uint rewards[i] = power * amount / _totalPower;
            }
            _bonusRewards[bonus.id] = rewards;

            // emit event，todo(fuk): add power and stake power
            emit BonusCreated(_foundation, bonus.id, bonus.amount);
        }
    }

    // 质押
    function stake(uint amount, uint uStakeTyp) external payable returns (uint) {

        // check stake amount
        require(amount >= MIN_STAKE_AMOUNT, "Invalid stake amount");

        // check user balance 
        address staker = _msgSender();
        require(_token.balanceOf(staker) >= amount, "Insufficient balance");

        // scan user stakes and check valid stake number
        Stake[] memory stakes = getStakes(staker);
        uint validStkNum = 0;
        for (uint i = 0; i < stakes.length; i++) {
            if (checkStakeEnd(stake)) {
                validStkNum++;
            }
        }
        require(validStkNum < MAX_USER_STAKE_NUMBER, "User stakes too much");
        
        // get stake duration and power by stake type, and calculate power
        StakeType stktyp = StakeType(uStakeTyp);
        uint[2] memory factors = getStakeDuration(stktyp);
        uint duration = factors[0];
        uint powerRate = factors[1];
        uint power = powerRate * amount;
        _totalPower += power;
        _stakePower[stakeTyp] += power;
        _totalStake += amount;
        _userStakeAmount[staker] += amount;

        // create stake and transfer FIG to this contract
        // mark(fuk): 极限情况，如果bonus和stake在同一区块，按照事件顺序计算
        uint startBonusId = nextBonusId();
        uint stakeId = _nextStakeId++;
        _stakes[stakeId] = Stake(stakeId, amount, block.number, duration, staker, startBonusId, stktyp)
        _userStakes[staker].push(stakeId);
        
        _token.transferFrom(staker, address(this), amount);

        // todo(fuk): emit event
        return amount;
    }

    // 赎回
    function unStake(uint stakeId) external returns (uint) { 
        // check existing
        require(_stakes.contains(stakeId), "Stake not exist");

        // check authority
        Stake memory stake = _stakes[stakeId];
        address staker = _msgSender();
        require(stake.staker == staker, "Invalid staker");

        // check stake duration
        require(checkStakeEnd(stake) == false, "Stake duration not reached");

        // get stake duration and power by stake type, and calculate power     
        uint[2] memory factors = getStakeDuration(stake.stakeType);
        uint duration = factors[0];
        uint powerRate = factors[1];
        uint power = powerRate * amount;
        _totalPower -= power;
        _stakePower[stakeTyp] -= power;
        _totalStake -= amount;
        _userStakeAmount[staker] -= amount;

        // delete stake record
        Stake[] memory stakes = _userStakes[staker];
        for (uint i = 0; i < stakes.length; i++) {
            if (stakes[i].id == stakeId) {
                stakes[i] = stakes[stakes.length - 1];
                stakes.pop();
                break;
            }
        }
        _stakes.delete(stakeId);

        // transfer FIG to staker
        uint canWithdraw = _calculate(stake);
        uint withdrawn = stake.withdrawn + canWithdraw;
        _token.transfer(staker, canWithdraw);

        // todo(fuk): emit event
    }

    // 提现分润
    function withdraw() external returns (uint) {
        uint sum = 0;
        address staker = _msgSender();

        Stake[] memory stakes = _userStakes[staker];
        for (uint i = 0; i < stakes.length; i++) {
            Stake stake = stakes[i];
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
        return sum;
    }

    // ---------------------------------------------------------------------------------
    //  view functions
    // 
    // ---------------------------------------------------------------------------------
    function canWithdraw(address staker) public view returns (uint r) {
        Stake[] memory stakes = _userStakes[staker];
        for (uint i = 0; i < stakes.length; i++) {
            r += _calculate(stakes[i]);
        }
    }

    function _calculate(Stake memory stake) private view returns (uint r) {
        for (uint i = stake.startBounsId; i < _bonuses.length; i++) {
            Bonus memory bonus = _bonuses[i];
            uint[] memory rewards = _bonusRewards[bonus.id];
            for (uint j = 0; j < rewards.length; j++) {
                r += rewards[j] * stake.amount;
            }
        }
        r -= stake.withdrawn;
    }

    function getStakes(address staker) public view returns (Stake[] memory) {
        uint[] ids = _userStakes[staker];
        Stake[] memory stakes = new Stake[](ids.length);
        for (uint i = 0; i < ids.length; i++) {
            stakes[i] = _stakes[ids[i]];
        }
    }

    function isFundation() public view returns (bool) {
        return _msgSender() == _foundation;
    }

    function nextBonusId() public view returns (uint) {
        return _bonuses.length;
    }

    function checkStakeEnd(Stake memory stake) private pure returns (bool) {
        return stake.start + stake.duration < block.number;
    }

    function checkStakeType(uint stakeTyp) private pure returns (bool) {
        return stakeTyp >= uint(StakeType.Days30) && stakeTyp <= uint(StakeType.Days360);
    }

    function getStakeDuration(StakeType stkTyp) private pure returns (uint[2] memory r) {
        if (stkTyp == StakeType.Days30) {
            r[0] = BLOCKS_PER_DAY * 30;
            r[1] = 10;
        } else if (stkTyp == StakeType.Days90) {
            r[0] = BLOCKS_PER_DAY * 90;
            r[1] = 20;
        } else if (stkTyp == StakeType.Days180) {
            r[0] = BLOCKS_PER_DAY * 180;
            r[1] = 30;
        } else if (stkTyp == StakeType.Days360) {
            r[0] = BLOCKS_PER_DAY * 360;
            r[1] = 40;
        } else {
            r[0] = 0;
            r[1] = 0;
        }
    }
}