// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

import "./Utils/Conversion.sol";
import "./Utils/Calculation.sol";
import "./Utils/FilecoinAPI.sol";
import "./FILLiquidData.sol";
import "./FILLiquidPool.sol";
import "./FILStake.sol";

interface FILLiquidLogicBorrowPaybackInterface {
    /// @dev borrow FIL from the contract
    /// @param minerId miner id
    /// @param amountFIL the amount of FIL user would like to borrow
    /// @param interestRate approximated interest rate at the point of request
    /// @return amount actual FIL borrowed
    /// @return fee fee deducted
    function borrow(uint64 minerId, uint amountFIL, uint interestRate) external returns (uint amount, uint fee);

    /// @dev payback principal and interest by self
    /// @param minerIdPayee miner id being paid
    /// @param minerIdPayer miner id paying
    /// @param withdrawAmount maximum withdrawal amount
    /// @return principal repaid principal FIL
    /// @return interest repaid interest FIL
    /// @return withdrawn withdrawn FIL
    /// @return mintedFIG FIG minted
    function withdraw4Payback(uint64 minerIdPayee, uint64 minerIdPayer, uint withdrawAmount) external payable returns (uint principal, uint interest, uint withdrawn, uint mintedFIG);

    /// @dev payback principal and interest by anyone
    /// @param minerId miner id
    /// @return principal repaid principal FIL
    /// @return interest repaid interest FIL
    /// @return mintedFIG FIG minted
    function directPayback(uint64 minerId) external payable returns (uint principal, uint interest, uint mintedFIG);

    /// @dev liquidate process
    /// @param minerIdPayee miner id being paid
    /// @param minerIdPayer miner id paying
    /// @return result liquidating result
    function liquidate(uint64 minerIdPayee, uint64 minerIdPayer) external returns (uint[4] memory result);

    /// @dev return borrowing interest rate: a mathematical function of utilizatonRate
    function interestRate() external view returns (uint);

    /// @dev Emitted when user `account` borrows `amountFIL` with `minerId`
    event Borrow(
        uint indexed borrowId,
        address indexed account,
        uint64 indexed minerId,
        uint amountFIL,
        uint fee,
        uint interestRate,
        uint initialTime
    );
    
    /// @dev Emitted when user `account` repays `principal` + `interest` FIL for `minerIdPayee`,
    /// with `withdrawn` withdrawn from `minerIdPayer` and `principal` + `interest` - `withdrawn` from `account` and `mintedFIG` FIG minted
    event Payback(
        address indexed account,
        uint64 indexed minerIdPayee,
        uint64 indexed minerIdPayer,
        uint principal,
        uint interest,
        uint withdrawn,
        uint mintedFIG
    );

    /// @dev Emitted when user `account` liquidate `principal + interest + reward + fee` FIL for `minerId`
    event Liquidate(
        address indexed account,
        uint64 indexed minerIdPayee,
        uint64 indexed minerIdPayer,
        uint principal,
        uint interest,
        uint reward,
        uint fee
    );

    /// @dev Emitted when Borrow with `id` is updated
    event BorrowUpdated(
        uint indexed borrowId,
        uint borrowAmount,
        uint remainingOriginalAmount,
        uint datedTime
    );

    /// @dev Emitted when Borrow with `id` is droped
    event BorrowDropped(
        uint indexed id
    );
}

contract FILLiquidLogicBorrowPayback is Context, FILLiquidLogicBorrowPaybackInterface {
    using Conversion for *;
    struct Response {
        uint amount;
        bool tag;
        string reason;
    }

    address private _owner;
    bool private _switch;

    //administrative factors
    FILLiquidData private _data;
    FILLiquidPool private _pool;
    FilecoinAPI private _filecoinAPI;

    constructor(address filLiquidDataAddr, address payable filLiquidPoolAddr, address filecoinAPIAddr) {
        _owner = _msgSender();
        _data = FILLiquidData(filLiquidDataAddr);
        _pool = FILLiquidPool(filLiquidPoolAddr);
        _filecoinAPI = FilecoinAPI(filecoinAPIAddr);
        _switch = true;
    }

    function borrow(uint64 minerId, uint amount, uint expectInterestRate) isBindMiner(minerId) haveCollateralizing(minerId) switchOn external returns (uint, uint) {
        Response memory response = getBorrowable(minerId, amount);
        require(response.tag, response.reason);
        uint realInterestRate = interestRateBorrow(amount);
        _isHigher(expectInterestRate, realInterestRate);

        uint borrowId = _data.getStatus().accumulatedBorrows;
        _updateBorrow(minerId, borrowId, amount, realInterestRate);

        (,,uint borrowFeeRate,,,,,,,) = _data.getComprehensiveFactors();
        uint[2] memory fees = _data.calculateFee(amount, borrowFeeRate);
        _data.recordBorrow(minerId, fees[0], fees[1]);
        FILLiquidDataInterface.MinerCollateralizingInfo memory info = _data.getCollateralizingMinerInfo(minerId);
        info.borrowAmount += amount;
        _data.updateCollateralizingMinerInfo(minerId, info);
        if (amount > 0) _pool.send(amount);
        if (fees[1] > 0) _sendToFoundation(fees[1]);
        if (fees[0] > 0) _send(minerId, fees[0]);

        emit Borrow(borrowId, _msgSender(), minerId, fees[0], fees[1], realInterestRate, block.timestamp);
        return (fees[0], fees[1]);
    }

    function withdraw4Payback(uint64 minerIdPayee, uint64 minerIdPayer, uint amount) isBindMiner(minerIdPayee) isSameFamily(minerIdPayee, minerIdPayer) isBorrower(minerIdPayee) switchOn external payable returns (uint, uint, uint, uint) {
        Response memory response = _getAvailable(minerIdPayer);
        require(!response.tag, response.reason);
        if (amount > response.amount) {
            amount = response.amount;
        }
        uint[3] memory r = _paybackProcess(minerIdPayee, msg.value + amount);
        uint[2] memory sentBack_withdrawn;
        if (r[0] > amount) {
            sentBack_withdrawn[0] = r[0] - amount;
            payable(_msgSender()).transfer(sentBack_withdrawn[0]);
        } else if (r[0] < amount) {
            sentBack_withdrawn[1] = amount - r[0];
            _pool.withdrawBalance(address(_filecoinAPI), minerIdPayer, sentBack_withdrawn[1]);
        }
        payable(_pool).transfer(r[1] + r[2]);
        uint mintedFIG = _handleInterest(_msgSender(), r[1], r[2]);

        emit Payback(_msgSender(), minerIdPayee, minerIdPayer, r[1], r[2], sentBack_withdrawn[1], mintedFIG);
        return (r[1], r[2], sentBack_withdrawn[1], mintedFIG);
    }

    function directPayback(uint64 minerId) isBorrower(minerId) switchOn external payable returns (uint, uint, uint) {
        uint[3] memory r = _paybackProcess(minerId, msg.value);
        address sender = _msgSender();
        if (r[0] > 0) payable(sender).transfer(r[0]);
        payable(_pool).transfer(r[1] + r[2]);
        uint mintedFIG = _handleInterest(_data.minerUser(minerId), r[1], r[2]);

        emit Payback(sender, minerId, minerId, r[1], r[2], 0, mintedFIG);
        return (r[1], r[2], mintedFIG);
    }

    function liquidate(uint64 minerIdPayee, uint64 minerIdPayer) isSameFamily(minerIdPayee, minerIdPayer) isBorrower(minerIdPayee) switchOn external returns (uint[4] memory result) {
        Response memory response = getLiquidatable(minerIdPayee, minerIdPayer);
        require(response.tag, response.reason);

        // calculate the maximum amount for pinciple+interest
        uint[3] memory r = _paybackProcess(minerIdPayee, _data.getLiquidateAmount(response.amount));
 
        // calculate total withdraw, liquidate fee and reward
        uint totalWithdraw = _data.getWithDrawAmountFromLiquidate(r[1] + r[2]);
        (,,,,,uint liquidateFeeRate) = _data.getLiquidatingFactors();
        uint[2] memory fees = _data.calculateFee(totalWithdraw, liquidateFeeRate);
        uint bonus = fees[0] - (r[1] + r[2]);
        _updateLiquidate(minerIdPayee, totalWithdraw, bonus, fees[1]);

        if (totalWithdraw > 0) _pool.withdrawBalance(address(_filecoinAPI), minerIdPayer, totalWithdraw);
        if (fees[1] > 0) _sendToFoundation(fees[1]);
        address sender = _msgSender();
        if (bonus > 0) payable(sender).transfer(bonus);
        payable(_pool).transfer(r[1] + r[2]);
        result = [r[1], r[2], bonus, fees[1]];

        emit Liquidate(sender, minerIdPayee, minerIdPayer, r[1], r[2], bonus, fees[1]);
    }

    receive() onlyPool switchOn external payable {
    }

    function getAvailableBalance(uint64 minerId) public view returns (uint, bool) {
        Conversion.Integer memory v = _filecoinAPI.getAvailableBalance(minerId).bigInt2Integer();
        return (v.value, v.neg);
    }

    function toAddress(uint64 minerId) public view returns (address) {
        return _filecoinAPI.toAddress(minerId);
    }

    function getBorrowable(uint64 minerId) external view returns (bool, string memory) {
        (,,,,,uint minBorrowAmount,,,,) = _data.getComprehensiveFactors();
        Response memory v = getBorrowable(minerId, minBorrowAmount);
        return (v.tag, v.reason);
    }

    function getBorrowable(uint64 minerId, uint amount) public view returns (Response memory) {
        uint64[] memory miners = _data.userMiners(_data.minerUser(minerId));
        (uint maxLiquidations,,,,,) = _data.getLiquidatingFactors();
        for (uint i = 0; i < miners.length; i++) {
            if (_data.liquidatedTimes(miners[i]) >= maxLiquidations) return Response(0, false, "Too many liquidations");
        }
        (,,,,,uint minBorrowAmount, uint maxExistingBorrows,,,) = _data.getComprehensiveFactors();
        if (_data.rawMinerBorrows(minerId).length >= maxExistingBorrows) return Response(0, false, "Too many borrows");
        Response memory response = _getAvailable(minerId);
        if (response.tag) return Response(0, false, response.reason);
        if (_data.badDebt(_data.minerUser(minerId)) != 0) return Response(0, false, "Family with bad debt");
        if (amount < minBorrowAmount) return Response(0, false, "Lower than minimum");
        if (amount > _data.maxBorrowAllowedByUtilization()) return Response(0, false, "Utilization would exceeds u_m");
        if (amount > _data.maxBorrowAllowed(minerId)) return Response(0, false, "Insufficient collateral");
        return Response(0, true, "");
    }

    function getLiquidatable(uint64 minerIdPayee, uint64 minerIdPayer) public view returns (Response memory) {
        uint lastLiquidate = _data.lastLiquidate(minerIdPayee);
        (,uint minLiquidateInterval,,,,) = _data.getLiquidatingFactors();
        if (lastLiquidate != 0 && block.timestamp - lastLiquidate < minLiquidateInterval) return Response(0, false, "Insufficient interval");
        if (!_data.liquidateCondition(_data.getFamilyStatus(_data.minerUser(minerIdPayee))).liquidatable) return Response(0, false, "Not liquidatable");
        Response memory response = _getAvailable(minerIdPayer);
        if (response.tag) return Response(0, false, response.reason);
        return Response(response.amount, true, "");
    }
    
    function interestRate() public view returns (uint) {
        (uint rateBase,,,,,,,,,) = _data.getComprehensiveFactors();
        (uint u_1, uint r_0, uint r_1,, uint n) = _data.getBorrowPayBackFactors();
        return Calculation.getInterestRate(_data.utilizationRate(), u_1, r_0, r_1, rateBase, n);
    }

    function interestRateBorrow(uint amount) public view returns (uint) {
        (uint rateBase,,,,,,,,,) = _data.getComprehensiveFactors();
        (uint u_1, uint r_0, uint r_1,, uint n) = _data.getBorrowPayBackFactors();
        return Calculation.getInterestRate(_data.utilizationRateBorrow(amount), u_1, r_0, r_1, rateBase, n);
    }

    function paybackAmount(uint borrowAmount, uint borrowPeriod, uint annualRate) public view returns (uint) {
        (uint rateBase,,,,,,,,,) = _data.getComprehensiveFactors();
        return Calculation.getPaybackAmount(borrowAmount, borrowPeriod, annualRate, rateBase);
    }

    function getN(uint u_1, uint u_m, uint r_1, uint r_m, uint rateBase) external pure returns (uint) {
        return Calculation.getN(u_1, u_m, r_1, r_m, rateBase);
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function setOwner(address new_owner) onlyOwner external {
        _owner = new_owner;
    }

    function getAdministrativeFactors() external view returns (address, address, address) {
        return (address(_data), address(_pool), address(_filecoinAPI));
    }

    function setAdministrativeFactors(
        address new_data,
        address payable new_pool,
        address new_filecoinAPI
    ) onlyOwner external {
        _data = FILLiquidData(new_data);
        _pool = FILLiquidPool(new_pool);
        _filecoinAPI = FilecoinAPI(new_filecoinAPI);
    }

    function getSwitch() external view returns (bool) {
        return _switch;
    }

    function turnSwitch(bool new_switch) onlyOwner external {
        _switch = new_switch;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Not owner");
        _;
    }

    modifier onlyPool() {
        require(_msgSender() == address(_pool), "Not pool");
        _;
    }

    modifier isBindMiner(uint64 minerId) {
        require(_msgSender() == _data.minerUser(minerId), "Not bind");
        _;
    }

    modifier isSameFamily(uint64 minerIdPayee, uint64 minerIdPayer) {
        require(_data.minerUser(minerIdPayer) != address(0), "Not bind");
        require(_data.minerUser(minerIdPayer) == _data.minerUser(minerIdPayee), "Not same family");
        _;
    }

    modifier isBorrower(uint64 minerId) {
        require(_data.minerBorrowLength(minerId) != 0, "No borrow");
        _;
    }

    modifier haveCollateralizing(uint64 _id) {
        require(_data.getCollateralizingMinerInfo(_id).quota > 0, "Uncollateralized");
        _;
    }

    modifier switchOn() {
        require(_switch, "Switch is off");
        _;
    }

    function _handleInterest(address minter, uint principal, uint interest) private returns (uint) {
        (,,,,,,address filStake) = _data.getAdministrativeFactors();
        return FILStake(filStake).handleInterest(minter, principal, interest);
    }

    function _getAvailable(uint64 minerId) private view returns (Response memory) {
        (uint available, bool neg) = getAvailableBalance(minerId);
        if (neg) return Response(0, neg, "Negtive available balance");
        else return Response(available, neg, "");
    }

    function _sendToFoundation(uint amount) private {
        (,,,,address payable foundation,,) = _data.getAdministrativeFactors();
        foundation.transfer(amount);
    }

    function _send(uint64 actorId, uint amount) private {
        _filecoinAPI.send(actorId, amount);
    }

    function _isHigher(uint expect, uint realtime) private pure {
        require(realtime <= expect, "Too low");
    }

    function _updateBorrow(uint64 minerId, uint borrowId, uint amount, uint realInterestRate) private {
        FILLiquidDataInterface.BorrowInfo[] memory prevBorrows = _data.rawMinerBorrows(minerId);
        FILLiquidDataInterface.BorrowInfo[] memory borrows = new FILLiquidDataInterface.BorrowInfo[](prevBorrows.length + 1);
        for (uint i = 0; i < prevBorrows.length; i++) {
            borrows[i] = prevBorrows[i];
        }
        borrows[prevBorrows.length] = FILLiquidDataInterface.BorrowInfo({
            id: borrowId,
            borrowAmount: amount,
            remainingOriginalAmount: amount,
            interestRate: realInterestRate,
            datedTime: block.timestamp,
            initialTime: block.timestamp
        });

        //sortMinerBorrows
        if (borrows.length >= 2) {
            FILLiquidDataInterface.BorrowInfo memory last = borrows[borrows.length - 1];
            uint index = 0;
            for (; index < borrows.length - 1; index++) {
                if (borrows[index].interestRate > last.interestRate) break;
            }
            for (uint i = borrows.length - 1; i > index; i--) {
                borrows[i] = borrows[i - 1];
            }
            borrows[index] = last;
        }
        _data.updateMinerBorrows(minerId, borrows);
    }

    function _updateLiquidate(uint64 minerIdPayee, uint totalWithdraw, uint bonus, uint fee) private {
        _data.recordLiquidate(bonus, fee);
        _data.updateLastLiquidate(minerIdPayee, block.timestamp);
        _data.updateLiquidatedTimes(minerIdPayee, _data.liquidatedTimes(minerIdPayee) + 1);
        FILLiquidDataInterface.MinerCollateralizingInfo memory info = _data.getCollateralizingMinerInfo(minerIdPayee);
        info.liquidatedAmount += totalWithdraw;
        _data.updateCollateralizingMinerInfo(minerIdPayee, info);
    }

    function _paybackProcess(uint64 minerId, uint amount) private returns (uint[3] memory r) {
        r[0] = amount;
        FILLiquidDataInterface.BorrowInfo[] memory borrows = _data.rawMinerBorrows(minerId);
        uint len = borrows.length;
        for (uint i = len; i > 0; i--) {
            FILLiquidDataInterface.BorrowInfo memory info = borrows[i - 1];
            uint time = block.timestamp - info.datedTime;
            uint principalAndInterest = paybackAmount(info.borrowAmount, time, info.interestRate);
            uint payBackTotal;
            if (r[0] > principalAndInterest) {
                payBackTotal = principalAndInterest;
                r[0] -= principalAndInterest;
            } else {
                payBackTotal = r[0];
                r[0] = 0;
            }

            uint payBackInterest = principalAndInterest - info.remainingOriginalAmount;
            uint paybackPrincipal;
            if (payBackTotal < payBackInterest) {
                payBackInterest = payBackTotal;
                paybackPrincipal = 0;
            } else {
                paybackPrincipal = payBackTotal - payBackInterest;
            }
            r[2] += payBackInterest;
            r[1] += paybackPrincipal;
            if (principalAndInterest > payBackTotal){
                info.borrowAmount = principalAndInterest - payBackTotal;
                info.datedTime = block.timestamp;
                info.remainingOriginalAmount -= paybackPrincipal;
                emit BorrowUpdated(info.id, info.borrowAmount, info.remainingOriginalAmount, info.datedTime);
            } else {
                emit BorrowDropped(info.id);
                len--;
            }
            if (r[0] == 0) break;
        }
        FILLiquidDataInterface.BorrowInfo[] memory newBorrows = new FILLiquidDataInterface.BorrowInfo[](len);
        for (uint i = 0; i < len; i++) {
            newBorrows[i] = borrows[i];
        }
        _data.updateMinerBorrows(minerId, newBorrows);

        FILLiquidDataInterface.MinerCollateralizingInfo memory collateralizingInfo = _data.getCollateralizingMinerInfo(minerId);
        collateralizingInfo.borrowAmount -= r[1];
        _data.updateCollateralizingMinerInfo(minerId, collateralizingInfo);

        address user = _data.minerUser(minerId);
        uint accumulatedBadDebt = _data.getStatus().accumulatedBadDebt - _data.badDebt(user);
        uint balanceSum = 0;
        uint principleSum = 0;
        uint64[] memory miners = _data.userMiners(user);
        for (uint i = 0; i < miners.length; i++) {
            balanceSum += toAddress(miners[i]).balance;
            FILLiquidDataInterface.BorrowInfo[] memory borrowList = _data.rawMinerBorrows(miners[i]);
            for (uint j = 0; j < borrowList.length; j++) {
                principleSum += borrowList[j].remainingOriginalAmount;
            }
        }
        if (balanceSum == 0 || _data.badDebt(user) != 0) {
            _data.updateBadDebt(user, principleSum);
            accumulatedBadDebt += principleSum;
        }
        _data.recordPayback(minerId, r[1], r[2], accumulatedBadDebt);
    }
}
