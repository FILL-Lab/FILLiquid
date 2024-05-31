// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package liquid

import (
	"errors"
	"math/big"
	"strings"

	ethereum "github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/event"
)

// Reference imports to suppress errors if they are not otherwise used.
var (
	_ = errors.New
	_ = big.NewInt
	_ = strings.NewReader
	_ = ethereum.NotFound
	_ = bind.Bind
	_ = common.Big1
	_ = types.BloomLookup
	_ = event.NewSubscription
	_ = abi.ConvertType
)

// ConversionInteger is an auto generated low-level Go binding around an user-defined struct.
type ConversionInteger struct {
	Value *big.Int
	Neg   bool
}

// FILLiquidInterfaceBindStatus is an auto generated low-level Go binding around an user-defined struct.
type FILLiquidInterfaceBindStatus struct {
	OnceBound  bool
	StillBound bool
}

// FILLiquidInterfaceBindStatusInfo is an auto generated low-level Go binding around an user-defined struct.
type FILLiquidInterfaceBindStatusInfo struct {
	MinerId uint64
	Status  FILLiquidInterfaceBindStatus
}

// FILLiquidInterfaceBorrowInfo is an auto generated low-level Go binding around an user-defined struct.
type FILLiquidInterfaceBorrowInfo struct {
	Id                      *big.Int
	BorrowAmount            *big.Int
	RemainingOriginalAmount *big.Int
	InterestRate            *big.Int
	DatedTime               *big.Int
	InitialTime             *big.Int
}

// FILLiquidInterfaceBorrowInterestInfo is an auto generated low-level Go binding around an user-defined struct.
type FILLiquidInterfaceBorrowInterestInfo struct {
	Borrow   FILLiquidInterfaceBorrowInfo
	Interest *big.Int
}

// FILLiquidInterfaceFILLiquidInfo is an auto generated low-level Go binding around an user-defined struct.
type FILLiquidInterfaceFILLiquidInfo struct {
	TotalFIL                   *big.Int
	AvailableFIL               *big.Int
	UtilizedLiquidity          *big.Int
	AccumulatedDeposit         *big.Int
	AccumulatedRedeem          *big.Int
	AccumulatedBurntFILTrust   *big.Int
	AccumulatedMintFILTrust    *big.Int
	AccumulatedBorrow          *big.Int
	AccumulatedPayback         *big.Int
	AccumulatedInterest        *big.Int
	AccumulatedRedeemFee       *big.Int
	AccumulatedBorrowFee       *big.Int
	AccumulatedBadDebt         *big.Int
	AccumulatedLiquidateReward *big.Int
	AccumulatedLiquidateFee    *big.Int
	AccumulatedDeposits        *big.Int
	AccumulatedBorrows         *big.Int
	UtilizationRate            *big.Int
	ExchangeRate               *big.Int
	InterestRate               *big.Int
	CollateralizedMiner        *big.Int
	MinerWithBorrows           *big.Int
	RateBase                   *big.Int
}

// FILLiquidInterfaceFamilyStatus is an auto generated low-level Go binding around an user-defined struct.
type FILLiquidInterfaceFamilyStatus struct {
	BalanceSum              *big.Int
	PrincipalAndInterestSum *big.Int
	PrincipleSum            *big.Int
}

// FILLiquidInterfaceLiquidateConditionInfo is an auto generated low-level Go binding around an user-defined struct.
type FILLiquidInterfaceLiquidateConditionInfo struct {
	Rate         *big.Int
	Alertable    bool
	Liquidatable bool
}

// FILLiquidInterfaceMinerBorrowInfo is an auto generated low-level Go binding around an user-defined struct.
type FILLiquidInterfaceMinerBorrowInfo struct {
	MinerId          uint64
	DebtOutStanding  *big.Int
	Balance          *big.Int
	BorrowSum        *big.Int
	AvailableBalance ConversionInteger
	Borrows          []FILLiquidInterfaceBorrowInterestInfo
}

// FILLiquidInterfaceMinerCollateralizingInfo is an auto generated low-level Go binding around an user-defined struct.
type FILLiquidInterfaceMinerCollateralizingInfo struct {
	MinerId          uint64
	Expiration       int64
	Quota            *big.Int
	BorrowAmount     *big.Int
	LiquidatedAmount *big.Int
}

// FILLiquidInterfaceUserInfo is an auto generated low-level Go binding around an user-defined struct.
type FILLiquidInterfaceUserInfo struct {
	User                   common.Address
	DebtOutStanding        *big.Int
	AvailableCredit        *big.Int
	BalanceSum             *big.Int
	BorrowSum              *big.Int
	LiquidateConditionInfo FILLiquidInterfaceLiquidateConditionInfo
	MinerBorrowInfo        []FILLiquidInterfaceMinerBorrowInfo
}

// LiquidMetaData contains all meta data concerning the Liquid contract.
var LiquidMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[{\"internalType\":\"address\",\"name\":\"filTrustAddr\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"validationAddr\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"calculationAddr\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"filecoinAPIAddr\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"fitStakeAddr\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"governanceAddr\",\"type\":\"address\"},{\"internalType\":\"addresspayable\",\"name\":\"foundationAddr\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"borrowId\",\"type\":\"uint256\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amountFIL\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"fee\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"interestRate\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"initialTime\",\"type\":\"uint256\"}],\"name\":\"Borrow\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"}],\"name\":\"BorrowDropped\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"borrowId\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"borrowAmount\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"remainingOriginalAmount\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"datedTime\",\"type\":\"uint256\"}],\"name\":\"BorrowUpdated\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"sender\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"bytes\",\"name\":\"beneficiary\",\"type\":\"bytes\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"quota\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"int64\",\"name\":\"expiration\",\"type\":\"int64\"}],\"name\":\"CollateralizingMiner\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amountFIL\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amountFILTrust\",\"type\":\"uint256\"}],\"name\":\"Deposit\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint64\",\"name\":\"minerIdPayee\",\"type\":\"uint64\"},{\"indexed\":true,\"internalType\":\"uint64\",\"name\":\"minerIdPayer\",\"type\":\"uint64\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"principal\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"interest\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"reward\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"fee\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"mintedFIG\",\"type\":\"uint256\"}],\"name\":\"Liquidate\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"OwnerChanged\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint64\",\"name\":\"minerIdPayee\",\"type\":\"uint64\"},{\"indexed\":true,\"internalType\":\"uint64\",\"name\":\"minerIdPayer\",\"type\":\"uint64\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"principal\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"interest\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"withdrawn\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"mintedFIG\",\"type\":\"uint256\"}],\"name\":\"Payback\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amountFILTrust\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amountFIL\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"fee\",\"type\":\"uint256\"}],\"name\":\"Redeem\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"},{\"indexed\":true,\"internalType\":\"address\",\"name\":\"sender\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"bytes\",\"name\":\"beneficiary\",\"type\":\"bytes\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"quota\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"int64\",\"name\":\"expiration\",\"type\":\"int64\"}],\"name\":\"UncollateralizingMiner\",\"type\":\"event\"},{\"inputs\":[],\"name\":\"allMinersCount\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"start\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"end\",\"type\":\"uint256\"}],\"name\":\"allMinersSubset\",\"outputs\":[{\"components\":[{\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"},{\"components\":[{\"internalType\":\"bool\",\"name\":\"onceBound\",\"type\":\"bool\"},{\"internalType\":\"bool\",\"name\":\"stillBound\",\"type\":\"bool\"}],\"internalType\":\"structFILLiquidInterface.BindStatus\",\"name\":\"status\",\"type\":\"tuple\"}],\"internalType\":\"structFILLiquidInterface.BindStatusInfo[]\",\"name\":\"result\",\"type\":\"tuple[]\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"availableFIL\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"badDebt\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"expectInterestRate\",\"type\":\"uint256\"}],\"name\":\"borrow\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256[]\",\"name\":\"values\",\"type\":\"uint256[]\"}],\"name\":\"checkGovernanceFactors\",\"outputs\":[],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"},{\"internalType\":\"bytes\",\"name\":\"signature\",\"type\":\"bytes\"}],\"name\":\"collateralizingMiner\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"expectAmountFILTrust\",\"type\":\"uint256\"}],\"name\":\"deposit\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"payable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"}],\"name\":\"directPayback\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"payable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"exchangeRate\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getAdministrativeFactors\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"},{\"internalType\":\"addresspayable\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getBorrowPayBackFactors\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"}],\"name\":\"getBorrowable\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"},{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"}],\"name\":\"getCollateralizingMinerInfo\",\"outputs\":[{\"components\":[{\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"},{\"internalType\":\"int64\",\"name\":\"expiration\",\"type\":\"int64\"},{\"internalType\":\"uint256\",\"name\":\"quota\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"borrowAmount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"liquidatedAmount\",\"type\":\"uint256\"}],\"internalType\":\"structFILLiquidInterface.MinerCollateralizingInfo\",\"name\":\"\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getComprehensiveFactors\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"int64\",\"name\":\"\",\"type\":\"int64\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getDepositRedeemFactors\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"getFamilyStatus\",\"outputs\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"balanceSum\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"principalAndInterestSum\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"principleSum\",\"type\":\"uint256\"}],\"internalType\":\"structFILLiquidInterface.FamilyStatus\",\"name\":\"status\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"amountFit\",\"type\":\"uint256\"}],\"name\":\"getFilByRedeem\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"amountFil\",\"type\":\"uint256\"}],\"name\":\"getFitByDeposit\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getLiquidatingFactors\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getStatus\",\"outputs\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"totalFIL\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"availableFIL\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"utilizedLiquidity\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedDeposit\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedRedeem\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedBurntFILTrust\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedMintFILTrust\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedBorrow\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedPayback\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedInterest\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedRedeemFee\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedBorrowFee\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedBadDebt\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedLiquidateReward\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedLiquidateFee\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedDeposits\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedBorrows\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"utilizationRate\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"exchangeRate\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"interestRate\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"collateralizedMiner\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"minerWithBorrows\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"rateBase\",\"type\":\"uint256\"}],\"internalType\":\"structFILLiquidInterface.FILLiquidInfo\",\"name\":\"\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"interestRate\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"interestRateBorrow\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"}],\"name\":\"lastLiquidate\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint64\",\"name\":\"minerIdPayee\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"minerIdPayer\",\"type\":\"uint64\"}],\"name\":\"liquidate\",\"outputs\":[{\"internalType\":\"uint256[4]\",\"name\":\"result\",\"type\":\"uint256[4]\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"}],\"name\":\"liquidatedTimes\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"}],\"name\":\"maxBorrowAllowed\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"maxBorrowAllowedByUtilization\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"maxBorrowAllowedFamily\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"}],\"name\":\"minerBorrows\",\"outputs\":[{\"components\":[{\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"},{\"internalType\":\"uint256\",\"name\":\"debtOutStanding\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"balance\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"borrowSum\",\"type\":\"uint256\"},{\"components\":[{\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"},{\"internalType\":\"bool\",\"name\":\"neg\",\"type\":\"bool\"}],\"internalType\":\"structConversion.Integer\",\"name\":\"availableBalance\",\"type\":\"tuple\"},{\"components\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"borrowAmount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"remainingOriginalAmount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"interestRate\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"datedTime\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"initialTime\",\"type\":\"uint256\"}],\"internalType\":\"structFILLiquidInterface.BorrowInfo\",\"name\":\"borrow\",\"type\":\"tuple\"},{\"internalType\":\"uint256\",\"name\":\"interest\",\"type\":\"uint256\"}],\"internalType\":\"structFILLiquidInterface.BorrowInterestInfo[]\",\"name\":\"borrows\",\"type\":\"tuple[]\"}],\"internalType\":\"structFILLiquidInterface.MinerBorrowInfo\",\"name\":\"result\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"}],\"name\":\"minerStatus\",\"outputs\":[{\"components\":[{\"internalType\":\"bool\",\"name\":\"onceBound\",\"type\":\"bool\"},{\"internalType\":\"bool\",\"name\":\"stillBound\",\"type\":\"bool\"}],\"internalType\":\"structFILLiquidInterface.BindStatus\",\"name\":\"\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"}],\"name\":\"minerUser\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"owner\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"borrowAmount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"borrowPeriod\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"annualRate\",\"type\":\"uint256\"}],\"name\":\"paybackAmount\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"amountFILTrust\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"expectAmountFIL\",\"type\":\"uint256\"}],\"name\":\"redeem\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256[]\",\"name\":\"values\",\"type\":\"uint256[]\"}],\"name\":\"setGovernanceFactors\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"new_owner\",\"type\":\"address\"}],\"name\":\"setOwner\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"totalFILLiquidity\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"}],\"name\":\"uncollateralizingMiner\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"userBorrows\",\"outputs\":[{\"components\":[{\"internalType\":\"address\",\"name\":\"user\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"debtOutStanding\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"availableCredit\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"balanceSum\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"borrowSum\",\"type\":\"uint256\"},{\"components\":[{\"internalType\":\"uint256\",\"name\":\"rate\",\"type\":\"uint256\"},{\"internalType\":\"bool\",\"name\":\"alertable\",\"type\":\"bool\"},{\"internalType\":\"bool\",\"name\":\"liquidatable\",\"type\":\"bool\"}],\"internalType\":\"structFILLiquidInterface.LiquidateConditionInfo\",\"name\":\"liquidateConditionInfo\",\"type\":\"tuple\"},{\"components\":[{\"internalType\":\"uint64\",\"name\":\"minerId\",\"type\":\"uint64\"},{\"internalType\":\"uint256\",\"name\":\"debtOutStanding\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"balance\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"borrowSum\",\"type\":\"uint256\"},{\"components\":[{\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"},{\"internalType\":\"bool\",\"name\":\"neg\",\"type\":\"bool\"}],\"internalType\":\"structConversion.Integer\",\"name\":\"availableBalance\",\"type\":\"tuple\"},{\"components\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"borrowAmount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"remainingOriginalAmount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"interestRate\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"datedTime\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"initialTime\",\"type\":\"uint256\"}],\"internalType\":\"structFILLiquidInterface.BorrowInfo\",\"name\":\"borrow\",\"type\":\"tuple\"},{\"internalType\":\"uint256\",\"name\":\"interest\",\"type\":\"uint256\"}],\"internalType\":\"structFILLiquidInterface.BorrowInterestInfo[]\",\"name\":\"borrows\",\"type\":\"tuple[]\"}],\"internalType\":\"structFILLiquidInterface.MinerBorrowInfo[]\",\"name\":\"minerBorrowInfo\",\"type\":\"tuple[]\"}],\"internalType\":\"structFILLiquidInterface.UserInfo\",\"name\":\"result\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"userMiners\",\"outputs\":[{\"internalType\":\"uint64[]\",\"name\":\"\",\"type\":\"uint64[]\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"utilizationRate\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"utilizationRateBorrow\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"utilizedLiquidity\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint64\",\"name\":\"minerIdPayee\",\"type\":\"uint64\"},{\"internalType\":\"uint64\",\"name\":\"minerIdPayer\",\"type\":\"uint64\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"withdraw4Payback\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"payable\",\"type\":\"function\"}]",
}

// LiquidABI is the input ABI used to generate the binding from.
// Deprecated: Use LiquidMetaData.ABI instead.
var LiquidABI = LiquidMetaData.ABI

// Liquid is an auto generated Go binding around an Ethereum contract.
type Liquid struct {
	LiquidCaller     // Read-only binding to the contract
	LiquidTransactor // Write-only binding to the contract
	LiquidFilterer   // Log filterer for contract events
}

// LiquidCaller is an auto generated read-only Go binding around an Ethereum contract.
type LiquidCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// LiquidTransactor is an auto generated write-only Go binding around an Ethereum contract.
type LiquidTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// LiquidFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type LiquidFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// LiquidSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type LiquidSession struct {
	Contract     *Liquid           // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// LiquidCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type LiquidCallerSession struct {
	Contract *LiquidCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts // Call options to use throughout this session
}

// LiquidTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type LiquidTransactorSession struct {
	Contract     *LiquidTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// LiquidRaw is an auto generated low-level Go binding around an Ethereum contract.
type LiquidRaw struct {
	Contract *Liquid // Generic contract binding to access the raw methods on
}

// LiquidCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type LiquidCallerRaw struct {
	Contract *LiquidCaller // Generic read-only contract binding to access the raw methods on
}

// LiquidTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type LiquidTransactorRaw struct {
	Contract *LiquidTransactor // Generic write-only contract binding to access the raw methods on
}

// NewLiquid creates a new instance of Liquid, bound to a specific deployed contract.
func NewLiquid(address common.Address, backend bind.ContractBackend) (*Liquid, error) {
	contract, err := bindLiquid(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &Liquid{LiquidCaller: LiquidCaller{contract: contract}, LiquidTransactor: LiquidTransactor{contract: contract}, LiquidFilterer: LiquidFilterer{contract: contract}}, nil
}

// NewLiquidCaller creates a new read-only instance of Liquid, bound to a specific deployed contract.
func NewLiquidCaller(address common.Address, caller bind.ContractCaller) (*LiquidCaller, error) {
	contract, err := bindLiquid(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &LiquidCaller{contract: contract}, nil
}

// NewLiquidTransactor creates a new write-only instance of Liquid, bound to a specific deployed contract.
func NewLiquidTransactor(address common.Address, transactor bind.ContractTransactor) (*LiquidTransactor, error) {
	contract, err := bindLiquid(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &LiquidTransactor{contract: contract}, nil
}

// NewLiquidFilterer creates a new log filterer instance of Liquid, bound to a specific deployed contract.
func NewLiquidFilterer(address common.Address, filterer bind.ContractFilterer) (*LiquidFilterer, error) {
	contract, err := bindLiquid(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &LiquidFilterer{contract: contract}, nil
}

// bindLiquid binds a generic wrapper to an already deployed contract.
func bindLiquid(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := LiquidMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Liquid *LiquidRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Liquid.Contract.LiquidCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Liquid *LiquidRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Liquid.Contract.LiquidTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Liquid *LiquidRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Liquid.Contract.LiquidTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Liquid *LiquidCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Liquid.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Liquid *LiquidTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Liquid.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Liquid *LiquidTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Liquid.Contract.contract.Transact(opts, method, params...)
}

// AllMinersCount is a free data retrieval call binding the contract method 0x764f3f32.
//
// Solidity: function allMinersCount() view returns(uint256)
func (_Liquid *LiquidCaller) AllMinersCount(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "allMinersCount")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// AllMinersCount is a free data retrieval call binding the contract method 0x764f3f32.
//
// Solidity: function allMinersCount() view returns(uint256)
func (_Liquid *LiquidSession) AllMinersCount() (*big.Int, error) {
	return _Liquid.Contract.AllMinersCount(&_Liquid.CallOpts)
}

// AllMinersCount is a free data retrieval call binding the contract method 0x764f3f32.
//
// Solidity: function allMinersCount() view returns(uint256)
func (_Liquid *LiquidCallerSession) AllMinersCount() (*big.Int, error) {
	return _Liquid.Contract.AllMinersCount(&_Liquid.CallOpts)
}

// AllMinersSubset is a free data retrieval call binding the contract method 0x54399efd.
//
// Solidity: function allMinersSubset(uint256 start, uint256 end) view returns((uint64,(bool,bool))[] result)
func (_Liquid *LiquidCaller) AllMinersSubset(opts *bind.CallOpts, start *big.Int, end *big.Int) ([]FILLiquidInterfaceBindStatusInfo, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "allMinersSubset", start, end)

	if err != nil {
		return *new([]FILLiquidInterfaceBindStatusInfo), err
	}

	out0 := *abi.ConvertType(out[0], new([]FILLiquidInterfaceBindStatusInfo)).(*[]FILLiquidInterfaceBindStatusInfo)

	return out0, err

}

// AllMinersSubset is a free data retrieval call binding the contract method 0x54399efd.
//
// Solidity: function allMinersSubset(uint256 start, uint256 end) view returns((uint64,(bool,bool))[] result)
func (_Liquid *LiquidSession) AllMinersSubset(start *big.Int, end *big.Int) ([]FILLiquidInterfaceBindStatusInfo, error) {
	return _Liquid.Contract.AllMinersSubset(&_Liquid.CallOpts, start, end)
}

// AllMinersSubset is a free data retrieval call binding the contract method 0x54399efd.
//
// Solidity: function allMinersSubset(uint256 start, uint256 end) view returns((uint64,(bool,bool))[] result)
func (_Liquid *LiquidCallerSession) AllMinersSubset(start *big.Int, end *big.Int) ([]FILLiquidInterfaceBindStatusInfo, error) {
	return _Liquid.Contract.AllMinersSubset(&_Liquid.CallOpts, start, end)
}

// AvailableFIL is a free data retrieval call binding the contract method 0xfe5b7018.
//
// Solidity: function availableFIL() view returns(uint256)
func (_Liquid *LiquidCaller) AvailableFIL(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "availableFIL")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// AvailableFIL is a free data retrieval call binding the contract method 0xfe5b7018.
//
// Solidity: function availableFIL() view returns(uint256)
func (_Liquid *LiquidSession) AvailableFIL() (*big.Int, error) {
	return _Liquid.Contract.AvailableFIL(&_Liquid.CallOpts)
}

// AvailableFIL is a free data retrieval call binding the contract method 0xfe5b7018.
//
// Solidity: function availableFIL() view returns(uint256)
func (_Liquid *LiquidCallerSession) AvailableFIL() (*big.Int, error) {
	return _Liquid.Contract.AvailableFIL(&_Liquid.CallOpts)
}

// BadDebt is a free data retrieval call binding the contract method 0xfdde8d61.
//
// Solidity: function badDebt(address account) view returns(uint256)
func (_Liquid *LiquidCaller) BadDebt(opts *bind.CallOpts, account common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "badDebt", account)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// BadDebt is a free data retrieval call binding the contract method 0xfdde8d61.
//
// Solidity: function badDebt(address account) view returns(uint256)
func (_Liquid *LiquidSession) BadDebt(account common.Address) (*big.Int, error) {
	return _Liquid.Contract.BadDebt(&_Liquid.CallOpts, account)
}

// BadDebt is a free data retrieval call binding the contract method 0xfdde8d61.
//
// Solidity: function badDebt(address account) view returns(uint256)
func (_Liquid *LiquidCallerSession) BadDebt(account common.Address) (*big.Int, error) {
	return _Liquid.Contract.BadDebt(&_Liquid.CallOpts, account)
}

// CheckGovernanceFactors is a free data retrieval call binding the contract method 0xdfda9e62.
//
// Solidity: function checkGovernanceFactors(uint256[] values) view returns()
func (_Liquid *LiquidCaller) CheckGovernanceFactors(opts *bind.CallOpts, values []*big.Int) error {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "checkGovernanceFactors", values)

	if err != nil {
		return err
	}

	return err

}

// CheckGovernanceFactors is a free data retrieval call binding the contract method 0xdfda9e62.
//
// Solidity: function checkGovernanceFactors(uint256[] values) view returns()
func (_Liquid *LiquidSession) CheckGovernanceFactors(values []*big.Int) error {
	return _Liquid.Contract.CheckGovernanceFactors(&_Liquid.CallOpts, values)
}

// CheckGovernanceFactors is a free data retrieval call binding the contract method 0xdfda9e62.
//
// Solidity: function checkGovernanceFactors(uint256[] values) view returns()
func (_Liquid *LiquidCallerSession) CheckGovernanceFactors(values []*big.Int) error {
	return _Liquid.Contract.CheckGovernanceFactors(&_Liquid.CallOpts, values)
}

// ExchangeRate is a free data retrieval call binding the contract method 0x3ba0b9a9.
//
// Solidity: function exchangeRate() view returns(uint256)
func (_Liquid *LiquidCaller) ExchangeRate(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "exchangeRate")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// ExchangeRate is a free data retrieval call binding the contract method 0x3ba0b9a9.
//
// Solidity: function exchangeRate() view returns(uint256)
func (_Liquid *LiquidSession) ExchangeRate() (*big.Int, error) {
	return _Liquid.Contract.ExchangeRate(&_Liquid.CallOpts)
}

// ExchangeRate is a free data retrieval call binding the contract method 0x3ba0b9a9.
//
// Solidity: function exchangeRate() view returns(uint256)
func (_Liquid *LiquidCallerSession) ExchangeRate() (*big.Int, error) {
	return _Liquid.Contract.ExchangeRate(&_Liquid.CallOpts)
}

// GetAdministrativeFactors is a free data retrieval call binding the contract method 0x582979fc.
//
// Solidity: function getAdministrativeFactors() view returns(address, address, address, address, address, address, address)
func (_Liquid *LiquidCaller) GetAdministrativeFactors(opts *bind.CallOpts) (common.Address, common.Address, common.Address, common.Address, common.Address, common.Address, common.Address, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "getAdministrativeFactors")

	if err != nil {
		return *new(common.Address), *new(common.Address), *new(common.Address), *new(common.Address), *new(common.Address), *new(common.Address), *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)
	out1 := *abi.ConvertType(out[1], new(common.Address)).(*common.Address)
	out2 := *abi.ConvertType(out[2], new(common.Address)).(*common.Address)
	out3 := *abi.ConvertType(out[3], new(common.Address)).(*common.Address)
	out4 := *abi.ConvertType(out[4], new(common.Address)).(*common.Address)
	out5 := *abi.ConvertType(out[5], new(common.Address)).(*common.Address)
	out6 := *abi.ConvertType(out[6], new(common.Address)).(*common.Address)

	return out0, out1, out2, out3, out4, out5, out6, err

}

// GetAdministrativeFactors is a free data retrieval call binding the contract method 0x582979fc.
//
// Solidity: function getAdministrativeFactors() view returns(address, address, address, address, address, address, address)
func (_Liquid *LiquidSession) GetAdministrativeFactors() (common.Address, common.Address, common.Address, common.Address, common.Address, common.Address, common.Address, error) {
	return _Liquid.Contract.GetAdministrativeFactors(&_Liquid.CallOpts)
}

// GetAdministrativeFactors is a free data retrieval call binding the contract method 0x582979fc.
//
// Solidity: function getAdministrativeFactors() view returns(address, address, address, address, address, address, address)
func (_Liquid *LiquidCallerSession) GetAdministrativeFactors() (common.Address, common.Address, common.Address, common.Address, common.Address, common.Address, common.Address, error) {
	return _Liquid.Contract.GetAdministrativeFactors(&_Liquid.CallOpts)
}

// GetBorrowPayBackFactors is a free data retrieval call binding the contract method 0xb77d061c.
//
// Solidity: function getBorrowPayBackFactors() view returns(uint256, uint256, uint256, uint256, uint256)
func (_Liquid *LiquidCaller) GetBorrowPayBackFactors(opts *bind.CallOpts) (*big.Int, *big.Int, *big.Int, *big.Int, *big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "getBorrowPayBackFactors")

	if err != nil {
		return *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)
	out1 := *abi.ConvertType(out[1], new(*big.Int)).(**big.Int)
	out2 := *abi.ConvertType(out[2], new(*big.Int)).(**big.Int)
	out3 := *abi.ConvertType(out[3], new(*big.Int)).(**big.Int)
	out4 := *abi.ConvertType(out[4], new(*big.Int)).(**big.Int)

	return out0, out1, out2, out3, out4, err

}

// GetBorrowPayBackFactors is a free data retrieval call binding the contract method 0xb77d061c.
//
// Solidity: function getBorrowPayBackFactors() view returns(uint256, uint256, uint256, uint256, uint256)
func (_Liquid *LiquidSession) GetBorrowPayBackFactors() (*big.Int, *big.Int, *big.Int, *big.Int, *big.Int, error) {
	return _Liquid.Contract.GetBorrowPayBackFactors(&_Liquid.CallOpts)
}

// GetBorrowPayBackFactors is a free data retrieval call binding the contract method 0xb77d061c.
//
// Solidity: function getBorrowPayBackFactors() view returns(uint256, uint256, uint256, uint256, uint256)
func (_Liquid *LiquidCallerSession) GetBorrowPayBackFactors() (*big.Int, *big.Int, *big.Int, *big.Int, *big.Int, error) {
	return _Liquid.Contract.GetBorrowPayBackFactors(&_Liquid.CallOpts)
}

// GetBorrowable is a free data retrieval call binding the contract method 0xf18876e8.
//
// Solidity: function getBorrowable(uint64 minerId) view returns(bool, string)
func (_Liquid *LiquidCaller) GetBorrowable(opts *bind.CallOpts, minerId uint64) (bool, string, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "getBorrowable", minerId)

	if err != nil {
		return *new(bool), *new(string), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)
	out1 := *abi.ConvertType(out[1], new(string)).(*string)

	return out0, out1, err

}

// GetBorrowable is a free data retrieval call binding the contract method 0xf18876e8.
//
// Solidity: function getBorrowable(uint64 minerId) view returns(bool, string)
func (_Liquid *LiquidSession) GetBorrowable(minerId uint64) (bool, string, error) {
	return _Liquid.Contract.GetBorrowable(&_Liquid.CallOpts, minerId)
}

// GetBorrowable is a free data retrieval call binding the contract method 0xf18876e8.
//
// Solidity: function getBorrowable(uint64 minerId) view returns(bool, string)
func (_Liquid *LiquidCallerSession) GetBorrowable(minerId uint64) (bool, string, error) {
	return _Liquid.Contract.GetBorrowable(&_Liquid.CallOpts, minerId)
}

// GetCollateralizingMinerInfo is a free data retrieval call binding the contract method 0xcdbbdc78.
//
// Solidity: function getCollateralizingMinerInfo(uint64 minerId) view returns((uint64,int64,uint256,uint256,uint256))
func (_Liquid *LiquidCaller) GetCollateralizingMinerInfo(opts *bind.CallOpts, minerId uint64) (FILLiquidInterfaceMinerCollateralizingInfo, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "getCollateralizingMinerInfo", minerId)

	if err != nil {
		return *new(FILLiquidInterfaceMinerCollateralizingInfo), err
	}

	out0 := *abi.ConvertType(out[0], new(FILLiquidInterfaceMinerCollateralizingInfo)).(*FILLiquidInterfaceMinerCollateralizingInfo)

	return out0, err

}

// GetCollateralizingMinerInfo is a free data retrieval call binding the contract method 0xcdbbdc78.
//
// Solidity: function getCollateralizingMinerInfo(uint64 minerId) view returns((uint64,int64,uint256,uint256,uint256))
func (_Liquid *LiquidSession) GetCollateralizingMinerInfo(minerId uint64) (FILLiquidInterfaceMinerCollateralizingInfo, error) {
	return _Liquid.Contract.GetCollateralizingMinerInfo(&_Liquid.CallOpts, minerId)
}

// GetCollateralizingMinerInfo is a free data retrieval call binding the contract method 0xcdbbdc78.
//
// Solidity: function getCollateralizingMinerInfo(uint64 minerId) view returns((uint64,int64,uint256,uint256,uint256))
func (_Liquid *LiquidCallerSession) GetCollateralizingMinerInfo(minerId uint64) (FILLiquidInterfaceMinerCollateralizingInfo, error) {
	return _Liquid.Contract.GetCollateralizingMinerInfo(&_Liquid.CallOpts, minerId)
}

// GetComprehensiveFactors is a free data retrieval call binding the contract method 0x54397e5c.
//
// Solidity: function getComprehensiveFactors() view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, int64)
func (_Liquid *LiquidCaller) GetComprehensiveFactors(opts *bind.CallOpts) (*big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, int64, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "getComprehensiveFactors")

	if err != nil {
		return *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(int64), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)
	out1 := *abi.ConvertType(out[1], new(*big.Int)).(**big.Int)
	out2 := *abi.ConvertType(out[2], new(*big.Int)).(**big.Int)
	out3 := *abi.ConvertType(out[3], new(*big.Int)).(**big.Int)
	out4 := *abi.ConvertType(out[4], new(*big.Int)).(**big.Int)
	out5 := *abi.ConvertType(out[5], new(*big.Int)).(**big.Int)
	out6 := *abi.ConvertType(out[6], new(*big.Int)).(**big.Int)
	out7 := *abi.ConvertType(out[7], new(*big.Int)).(**big.Int)
	out8 := *abi.ConvertType(out[8], new(*big.Int)).(**big.Int)
	out9 := *abi.ConvertType(out[9], new(int64)).(*int64)

	return out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, err

}

// GetComprehensiveFactors is a free data retrieval call binding the contract method 0x54397e5c.
//
// Solidity: function getComprehensiveFactors() view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, int64)
func (_Liquid *LiquidSession) GetComprehensiveFactors() (*big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, int64, error) {
	return _Liquid.Contract.GetComprehensiveFactors(&_Liquid.CallOpts)
}

// GetComprehensiveFactors is a free data retrieval call binding the contract method 0x54397e5c.
//
// Solidity: function getComprehensiveFactors() view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, int64)
func (_Liquid *LiquidCallerSession) GetComprehensiveFactors() (*big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, int64, error) {
	return _Liquid.Contract.GetComprehensiveFactors(&_Liquid.CallOpts)
}

// GetDepositRedeemFactors is a free data retrieval call binding the contract method 0x91e11160.
//
// Solidity: function getDepositRedeemFactors() view returns(uint256)
func (_Liquid *LiquidCaller) GetDepositRedeemFactors(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "getDepositRedeemFactors")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetDepositRedeemFactors is a free data retrieval call binding the contract method 0x91e11160.
//
// Solidity: function getDepositRedeemFactors() view returns(uint256)
func (_Liquid *LiquidSession) GetDepositRedeemFactors() (*big.Int, error) {
	return _Liquid.Contract.GetDepositRedeemFactors(&_Liquid.CallOpts)
}

// GetDepositRedeemFactors is a free data retrieval call binding the contract method 0x91e11160.
//
// Solidity: function getDepositRedeemFactors() view returns(uint256)
func (_Liquid *LiquidCallerSession) GetDepositRedeemFactors() (*big.Int, error) {
	return _Liquid.Contract.GetDepositRedeemFactors(&_Liquid.CallOpts)
}

// GetFamilyStatus is a free data retrieval call binding the contract method 0x799e215b.
//
// Solidity: function getFamilyStatus(address account) view returns((uint256,uint256,uint256) status)
func (_Liquid *LiquidCaller) GetFamilyStatus(opts *bind.CallOpts, account common.Address) (FILLiquidInterfaceFamilyStatus, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "getFamilyStatus", account)

	if err != nil {
		return *new(FILLiquidInterfaceFamilyStatus), err
	}

	out0 := *abi.ConvertType(out[0], new(FILLiquidInterfaceFamilyStatus)).(*FILLiquidInterfaceFamilyStatus)

	return out0, err

}

// GetFamilyStatus is a free data retrieval call binding the contract method 0x799e215b.
//
// Solidity: function getFamilyStatus(address account) view returns((uint256,uint256,uint256) status)
func (_Liquid *LiquidSession) GetFamilyStatus(account common.Address) (FILLiquidInterfaceFamilyStatus, error) {
	return _Liquid.Contract.GetFamilyStatus(&_Liquid.CallOpts, account)
}

// GetFamilyStatus is a free data retrieval call binding the contract method 0x799e215b.
//
// Solidity: function getFamilyStatus(address account) view returns((uint256,uint256,uint256) status)
func (_Liquid *LiquidCallerSession) GetFamilyStatus(account common.Address) (FILLiquidInterfaceFamilyStatus, error) {
	return _Liquid.Contract.GetFamilyStatus(&_Liquid.CallOpts, account)
}

// GetFilByRedeem is a free data retrieval call binding the contract method 0xd6167ce5.
//
// Solidity: function getFilByRedeem(uint256 amountFit) view returns(uint256)
func (_Liquid *LiquidCaller) GetFilByRedeem(opts *bind.CallOpts, amountFit *big.Int) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "getFilByRedeem", amountFit)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetFilByRedeem is a free data retrieval call binding the contract method 0xd6167ce5.
//
// Solidity: function getFilByRedeem(uint256 amountFit) view returns(uint256)
func (_Liquid *LiquidSession) GetFilByRedeem(amountFit *big.Int) (*big.Int, error) {
	return _Liquid.Contract.GetFilByRedeem(&_Liquid.CallOpts, amountFit)
}

// GetFilByRedeem is a free data retrieval call binding the contract method 0xd6167ce5.
//
// Solidity: function getFilByRedeem(uint256 amountFit) view returns(uint256)
func (_Liquid *LiquidCallerSession) GetFilByRedeem(amountFit *big.Int) (*big.Int, error) {
	return _Liquid.Contract.GetFilByRedeem(&_Liquid.CallOpts, amountFit)
}

// GetFitByDeposit is a free data retrieval call binding the contract method 0x37b6fa75.
//
// Solidity: function getFitByDeposit(uint256 amountFil) view returns(uint256)
func (_Liquid *LiquidCaller) GetFitByDeposit(opts *bind.CallOpts, amountFil *big.Int) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "getFitByDeposit", amountFil)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetFitByDeposit is a free data retrieval call binding the contract method 0x37b6fa75.
//
// Solidity: function getFitByDeposit(uint256 amountFil) view returns(uint256)
func (_Liquid *LiquidSession) GetFitByDeposit(amountFil *big.Int) (*big.Int, error) {
	return _Liquid.Contract.GetFitByDeposit(&_Liquid.CallOpts, amountFil)
}

// GetFitByDeposit is a free data retrieval call binding the contract method 0x37b6fa75.
//
// Solidity: function getFitByDeposit(uint256 amountFil) view returns(uint256)
func (_Liquid *LiquidCallerSession) GetFitByDeposit(amountFil *big.Int) (*big.Int, error) {
	return _Liquid.Contract.GetFitByDeposit(&_Liquid.CallOpts, amountFil)
}

// GetLiquidatingFactors is a free data retrieval call binding the contract method 0xbd56162b.
//
// Solidity: function getLiquidatingFactors() view returns(uint256, uint256, uint256, uint256, uint256, uint256)
func (_Liquid *LiquidCaller) GetLiquidatingFactors(opts *bind.CallOpts) (*big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "getLiquidatingFactors")

	if err != nil {
		return *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)
	out1 := *abi.ConvertType(out[1], new(*big.Int)).(**big.Int)
	out2 := *abi.ConvertType(out[2], new(*big.Int)).(**big.Int)
	out3 := *abi.ConvertType(out[3], new(*big.Int)).(**big.Int)
	out4 := *abi.ConvertType(out[4], new(*big.Int)).(**big.Int)
	out5 := *abi.ConvertType(out[5], new(*big.Int)).(**big.Int)

	return out0, out1, out2, out3, out4, out5, err

}

// GetLiquidatingFactors is a free data retrieval call binding the contract method 0xbd56162b.
//
// Solidity: function getLiquidatingFactors() view returns(uint256, uint256, uint256, uint256, uint256, uint256)
func (_Liquid *LiquidSession) GetLiquidatingFactors() (*big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, error) {
	return _Liquid.Contract.GetLiquidatingFactors(&_Liquid.CallOpts)
}

// GetLiquidatingFactors is a free data retrieval call binding the contract method 0xbd56162b.
//
// Solidity: function getLiquidatingFactors() view returns(uint256, uint256, uint256, uint256, uint256, uint256)
func (_Liquid *LiquidCallerSession) GetLiquidatingFactors() (*big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, error) {
	return _Liquid.Contract.GetLiquidatingFactors(&_Liquid.CallOpts)
}

// GetStatus is a free data retrieval call binding the contract method 0x4e69d560.
//
// Solidity: function getStatus() view returns((uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256))
func (_Liquid *LiquidCaller) GetStatus(opts *bind.CallOpts) (FILLiquidInterfaceFILLiquidInfo, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "getStatus")

	if err != nil {
		return *new(FILLiquidInterfaceFILLiquidInfo), err
	}

	out0 := *abi.ConvertType(out[0], new(FILLiquidInterfaceFILLiquidInfo)).(*FILLiquidInterfaceFILLiquidInfo)

	return out0, err

}

// GetStatus is a free data retrieval call binding the contract method 0x4e69d560.
//
// Solidity: function getStatus() view returns((uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256))
func (_Liquid *LiquidSession) GetStatus() (FILLiquidInterfaceFILLiquidInfo, error) {
	return _Liquid.Contract.GetStatus(&_Liquid.CallOpts)
}

// GetStatus is a free data retrieval call binding the contract method 0x4e69d560.
//
// Solidity: function getStatus() view returns((uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256))
func (_Liquid *LiquidCallerSession) GetStatus() (FILLiquidInterfaceFILLiquidInfo, error) {
	return _Liquid.Contract.GetStatus(&_Liquid.CallOpts)
}

// InterestRate is a free data retrieval call binding the contract method 0x7c3a00fd.
//
// Solidity: function interestRate() view returns(uint256)
func (_Liquid *LiquidCaller) InterestRate(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "interestRate")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// InterestRate is a free data retrieval call binding the contract method 0x7c3a00fd.
//
// Solidity: function interestRate() view returns(uint256)
func (_Liquid *LiquidSession) InterestRate() (*big.Int, error) {
	return _Liquid.Contract.InterestRate(&_Liquid.CallOpts)
}

// InterestRate is a free data retrieval call binding the contract method 0x7c3a00fd.
//
// Solidity: function interestRate() view returns(uint256)
func (_Liquid *LiquidCallerSession) InterestRate() (*big.Int, error) {
	return _Liquid.Contract.InterestRate(&_Liquid.CallOpts)
}

// InterestRateBorrow is a free data retrieval call binding the contract method 0x5d054588.
//
// Solidity: function interestRateBorrow(uint256 amount) view returns(uint256)
func (_Liquid *LiquidCaller) InterestRateBorrow(opts *bind.CallOpts, amount *big.Int) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "interestRateBorrow", amount)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// InterestRateBorrow is a free data retrieval call binding the contract method 0x5d054588.
//
// Solidity: function interestRateBorrow(uint256 amount) view returns(uint256)
func (_Liquid *LiquidSession) InterestRateBorrow(amount *big.Int) (*big.Int, error) {
	return _Liquid.Contract.InterestRateBorrow(&_Liquid.CallOpts, amount)
}

// InterestRateBorrow is a free data retrieval call binding the contract method 0x5d054588.
//
// Solidity: function interestRateBorrow(uint256 amount) view returns(uint256)
func (_Liquid *LiquidCallerSession) InterestRateBorrow(amount *big.Int) (*big.Int, error) {
	return _Liquid.Contract.InterestRateBorrow(&_Liquid.CallOpts, amount)
}

// LastLiquidate is a free data retrieval call binding the contract method 0x2c829f97.
//
// Solidity: function lastLiquidate(uint64 minerId) view returns(uint256)
func (_Liquid *LiquidCaller) LastLiquidate(opts *bind.CallOpts, minerId uint64) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "lastLiquidate", minerId)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// LastLiquidate is a free data retrieval call binding the contract method 0x2c829f97.
//
// Solidity: function lastLiquidate(uint64 minerId) view returns(uint256)
func (_Liquid *LiquidSession) LastLiquidate(minerId uint64) (*big.Int, error) {
	return _Liquid.Contract.LastLiquidate(&_Liquid.CallOpts, minerId)
}

// LastLiquidate is a free data retrieval call binding the contract method 0x2c829f97.
//
// Solidity: function lastLiquidate(uint64 minerId) view returns(uint256)
func (_Liquid *LiquidCallerSession) LastLiquidate(minerId uint64) (*big.Int, error) {
	return _Liquid.Contract.LastLiquidate(&_Liquid.CallOpts, minerId)
}

// LiquidatedTimes is a free data retrieval call binding the contract method 0xcc5dcb09.
//
// Solidity: function liquidatedTimes(uint64 minerId) view returns(uint256)
func (_Liquid *LiquidCaller) LiquidatedTimes(opts *bind.CallOpts, minerId uint64) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "liquidatedTimes", minerId)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// LiquidatedTimes is a free data retrieval call binding the contract method 0xcc5dcb09.
//
// Solidity: function liquidatedTimes(uint64 minerId) view returns(uint256)
func (_Liquid *LiquidSession) LiquidatedTimes(minerId uint64) (*big.Int, error) {
	return _Liquid.Contract.LiquidatedTimes(&_Liquid.CallOpts, minerId)
}

// LiquidatedTimes is a free data retrieval call binding the contract method 0xcc5dcb09.
//
// Solidity: function liquidatedTimes(uint64 minerId) view returns(uint256)
func (_Liquid *LiquidCallerSession) LiquidatedTimes(minerId uint64) (*big.Int, error) {
	return _Liquid.Contract.LiquidatedTimes(&_Liquid.CallOpts, minerId)
}

// MaxBorrowAllowed is a free data retrieval call binding the contract method 0x91546352.
//
// Solidity: function maxBorrowAllowed(uint64 minerId) view returns(uint256)
func (_Liquid *LiquidCaller) MaxBorrowAllowed(opts *bind.CallOpts, minerId uint64) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "maxBorrowAllowed", minerId)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// MaxBorrowAllowed is a free data retrieval call binding the contract method 0x91546352.
//
// Solidity: function maxBorrowAllowed(uint64 minerId) view returns(uint256)
func (_Liquid *LiquidSession) MaxBorrowAllowed(minerId uint64) (*big.Int, error) {
	return _Liquid.Contract.MaxBorrowAllowed(&_Liquid.CallOpts, minerId)
}

// MaxBorrowAllowed is a free data retrieval call binding the contract method 0x91546352.
//
// Solidity: function maxBorrowAllowed(uint64 minerId) view returns(uint256)
func (_Liquid *LiquidCallerSession) MaxBorrowAllowed(minerId uint64) (*big.Int, error) {
	return _Liquid.Contract.MaxBorrowAllowed(&_Liquid.CallOpts, minerId)
}

// MaxBorrowAllowedByUtilization is a free data retrieval call binding the contract method 0xdf4b0aef.
//
// Solidity: function maxBorrowAllowedByUtilization() view returns(uint256)
func (_Liquid *LiquidCaller) MaxBorrowAllowedByUtilization(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "maxBorrowAllowedByUtilization")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// MaxBorrowAllowedByUtilization is a free data retrieval call binding the contract method 0xdf4b0aef.
//
// Solidity: function maxBorrowAllowedByUtilization() view returns(uint256)
func (_Liquid *LiquidSession) MaxBorrowAllowedByUtilization() (*big.Int, error) {
	return _Liquid.Contract.MaxBorrowAllowedByUtilization(&_Liquid.CallOpts)
}

// MaxBorrowAllowedByUtilization is a free data retrieval call binding the contract method 0xdf4b0aef.
//
// Solidity: function maxBorrowAllowedByUtilization() view returns(uint256)
func (_Liquid *LiquidCallerSession) MaxBorrowAllowedByUtilization() (*big.Int, error) {
	return _Liquid.Contract.MaxBorrowAllowedByUtilization(&_Liquid.CallOpts)
}

// MaxBorrowAllowedFamily is a free data retrieval call binding the contract method 0x7a7cc806.
//
// Solidity: function maxBorrowAllowedFamily(address account) view returns(uint256)
func (_Liquid *LiquidCaller) MaxBorrowAllowedFamily(opts *bind.CallOpts, account common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "maxBorrowAllowedFamily", account)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// MaxBorrowAllowedFamily is a free data retrieval call binding the contract method 0x7a7cc806.
//
// Solidity: function maxBorrowAllowedFamily(address account) view returns(uint256)
func (_Liquid *LiquidSession) MaxBorrowAllowedFamily(account common.Address) (*big.Int, error) {
	return _Liquid.Contract.MaxBorrowAllowedFamily(&_Liquid.CallOpts, account)
}

// MaxBorrowAllowedFamily is a free data retrieval call binding the contract method 0x7a7cc806.
//
// Solidity: function maxBorrowAllowedFamily(address account) view returns(uint256)
func (_Liquid *LiquidCallerSession) MaxBorrowAllowedFamily(account common.Address) (*big.Int, error) {
	return _Liquid.Contract.MaxBorrowAllowedFamily(&_Liquid.CallOpts, account)
}

// MinerBorrows is a free data retrieval call binding the contract method 0x244e01b0.
//
// Solidity: function minerBorrows(uint64 minerId) view returns((uint64,uint256,uint256,uint256,(uint256,bool),((uint256,uint256,uint256,uint256,uint256,uint256),uint256)[]) result)
func (_Liquid *LiquidCaller) MinerBorrows(opts *bind.CallOpts, minerId uint64) (FILLiquidInterfaceMinerBorrowInfo, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "minerBorrows", minerId)

	if err != nil {
		return *new(FILLiquidInterfaceMinerBorrowInfo), err
	}

	out0 := *abi.ConvertType(out[0], new(FILLiquidInterfaceMinerBorrowInfo)).(*FILLiquidInterfaceMinerBorrowInfo)

	return out0, err

}

// MinerBorrows is a free data retrieval call binding the contract method 0x244e01b0.
//
// Solidity: function minerBorrows(uint64 minerId) view returns((uint64,uint256,uint256,uint256,(uint256,bool),((uint256,uint256,uint256,uint256,uint256,uint256),uint256)[]) result)
func (_Liquid *LiquidSession) MinerBorrows(minerId uint64) (FILLiquidInterfaceMinerBorrowInfo, error) {
	return _Liquid.Contract.MinerBorrows(&_Liquid.CallOpts, minerId)
}

// MinerBorrows is a free data retrieval call binding the contract method 0x244e01b0.
//
// Solidity: function minerBorrows(uint64 minerId) view returns((uint64,uint256,uint256,uint256,(uint256,bool),((uint256,uint256,uint256,uint256,uint256,uint256),uint256)[]) result)
func (_Liquid *LiquidCallerSession) MinerBorrows(minerId uint64) (FILLiquidInterfaceMinerBorrowInfo, error) {
	return _Liquid.Contract.MinerBorrows(&_Liquid.CallOpts, minerId)
}

// MinerStatus is a free data retrieval call binding the contract method 0x0f06b526.
//
// Solidity: function minerStatus(uint64 minerId) view returns((bool,bool))
func (_Liquid *LiquidCaller) MinerStatus(opts *bind.CallOpts, minerId uint64) (FILLiquidInterfaceBindStatus, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "minerStatus", minerId)

	if err != nil {
		return *new(FILLiquidInterfaceBindStatus), err
	}

	out0 := *abi.ConvertType(out[0], new(FILLiquidInterfaceBindStatus)).(*FILLiquidInterfaceBindStatus)

	return out0, err

}

// MinerStatus is a free data retrieval call binding the contract method 0x0f06b526.
//
// Solidity: function minerStatus(uint64 minerId) view returns((bool,bool))
func (_Liquid *LiquidSession) MinerStatus(minerId uint64) (FILLiquidInterfaceBindStatus, error) {
	return _Liquid.Contract.MinerStatus(&_Liquid.CallOpts, minerId)
}

// MinerStatus is a free data retrieval call binding the contract method 0x0f06b526.
//
// Solidity: function minerStatus(uint64 minerId) view returns((bool,bool))
func (_Liquid *LiquidCallerSession) MinerStatus(minerId uint64) (FILLiquidInterfaceBindStatus, error) {
	return _Liquid.Contract.MinerStatus(&_Liquid.CallOpts, minerId)
}

// MinerUser is a free data retrieval call binding the contract method 0x24295714.
//
// Solidity: function minerUser(uint64 minerId) view returns(address)
func (_Liquid *LiquidCaller) MinerUser(opts *bind.CallOpts, minerId uint64) (common.Address, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "minerUser", minerId)

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// MinerUser is a free data retrieval call binding the contract method 0x24295714.
//
// Solidity: function minerUser(uint64 minerId) view returns(address)
func (_Liquid *LiquidSession) MinerUser(minerId uint64) (common.Address, error) {
	return _Liquid.Contract.MinerUser(&_Liquid.CallOpts, minerId)
}

// MinerUser is a free data retrieval call binding the contract method 0x24295714.
//
// Solidity: function minerUser(uint64 minerId) view returns(address)
func (_Liquid *LiquidCallerSession) MinerUser(minerId uint64) (common.Address, error) {
	return _Liquid.Contract.MinerUser(&_Liquid.CallOpts, minerId)
}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_Liquid *LiquidCaller) Owner(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "owner")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_Liquid *LiquidSession) Owner() (common.Address, error) {
	return _Liquid.Contract.Owner(&_Liquid.CallOpts)
}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_Liquid *LiquidCallerSession) Owner() (common.Address, error) {
	return _Liquid.Contract.Owner(&_Liquid.CallOpts)
}

// PaybackAmount is a free data retrieval call binding the contract method 0xc9abb10f.
//
// Solidity: function paybackAmount(uint256 borrowAmount, uint256 borrowPeriod, uint256 annualRate) view returns(uint256)
func (_Liquid *LiquidCaller) PaybackAmount(opts *bind.CallOpts, borrowAmount *big.Int, borrowPeriod *big.Int, annualRate *big.Int) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "paybackAmount", borrowAmount, borrowPeriod, annualRate)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// PaybackAmount is a free data retrieval call binding the contract method 0xc9abb10f.
//
// Solidity: function paybackAmount(uint256 borrowAmount, uint256 borrowPeriod, uint256 annualRate) view returns(uint256)
func (_Liquid *LiquidSession) PaybackAmount(borrowAmount *big.Int, borrowPeriod *big.Int, annualRate *big.Int) (*big.Int, error) {
	return _Liquid.Contract.PaybackAmount(&_Liquid.CallOpts, borrowAmount, borrowPeriod, annualRate)
}

// PaybackAmount is a free data retrieval call binding the contract method 0xc9abb10f.
//
// Solidity: function paybackAmount(uint256 borrowAmount, uint256 borrowPeriod, uint256 annualRate) view returns(uint256)
func (_Liquid *LiquidCallerSession) PaybackAmount(borrowAmount *big.Int, borrowPeriod *big.Int, annualRate *big.Int) (*big.Int, error) {
	return _Liquid.Contract.PaybackAmount(&_Liquid.CallOpts, borrowAmount, borrowPeriod, annualRate)
}

// TotalFILLiquidity is a free data retrieval call binding the contract method 0x775cc2c9.
//
// Solidity: function totalFILLiquidity() view returns(uint256)
func (_Liquid *LiquidCaller) TotalFILLiquidity(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "totalFILLiquidity")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// TotalFILLiquidity is a free data retrieval call binding the contract method 0x775cc2c9.
//
// Solidity: function totalFILLiquidity() view returns(uint256)
func (_Liquid *LiquidSession) TotalFILLiquidity() (*big.Int, error) {
	return _Liquid.Contract.TotalFILLiquidity(&_Liquid.CallOpts)
}

// TotalFILLiquidity is a free data retrieval call binding the contract method 0x775cc2c9.
//
// Solidity: function totalFILLiquidity() view returns(uint256)
func (_Liquid *LiquidCallerSession) TotalFILLiquidity() (*big.Int, error) {
	return _Liquid.Contract.TotalFILLiquidity(&_Liquid.CallOpts)
}

// UserBorrows is a free data retrieval call binding the contract method 0x77593cc4.
//
// Solidity: function userBorrows(address account) view returns((address,uint256,uint256,uint256,uint256,(uint256,bool,bool),(uint64,uint256,uint256,uint256,(uint256,bool),((uint256,uint256,uint256,uint256,uint256,uint256),uint256)[])[]) result)
func (_Liquid *LiquidCaller) UserBorrows(opts *bind.CallOpts, account common.Address) (FILLiquidInterfaceUserInfo, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "userBorrows", account)

	if err != nil {
		return *new(FILLiquidInterfaceUserInfo), err
	}

	out0 := *abi.ConvertType(out[0], new(FILLiquidInterfaceUserInfo)).(*FILLiquidInterfaceUserInfo)

	return out0, err

}

// UserBorrows is a free data retrieval call binding the contract method 0x77593cc4.
//
// Solidity: function userBorrows(address account) view returns((address,uint256,uint256,uint256,uint256,(uint256,bool,bool),(uint64,uint256,uint256,uint256,(uint256,bool),((uint256,uint256,uint256,uint256,uint256,uint256),uint256)[])[]) result)
func (_Liquid *LiquidSession) UserBorrows(account common.Address) (FILLiquidInterfaceUserInfo, error) {
	return _Liquid.Contract.UserBorrows(&_Liquid.CallOpts, account)
}

// UserBorrows is a free data retrieval call binding the contract method 0x77593cc4.
//
// Solidity: function userBorrows(address account) view returns((address,uint256,uint256,uint256,uint256,(uint256,bool,bool),(uint64,uint256,uint256,uint256,(uint256,bool),((uint256,uint256,uint256,uint256,uint256,uint256),uint256)[])[]) result)
func (_Liquid *LiquidCallerSession) UserBorrows(account common.Address) (FILLiquidInterfaceUserInfo, error) {
	return _Liquid.Contract.UserBorrows(&_Liquid.CallOpts, account)
}

// UserMiners is a free data retrieval call binding the contract method 0xf0836b44.
//
// Solidity: function userMiners(address account) view returns(uint64[])
func (_Liquid *LiquidCaller) UserMiners(opts *bind.CallOpts, account common.Address) ([]uint64, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "userMiners", account)

	if err != nil {
		return *new([]uint64), err
	}

	out0 := *abi.ConvertType(out[0], new([]uint64)).(*[]uint64)

	return out0, err

}

// UserMiners is a free data retrieval call binding the contract method 0xf0836b44.
//
// Solidity: function userMiners(address account) view returns(uint64[])
func (_Liquid *LiquidSession) UserMiners(account common.Address) ([]uint64, error) {
	return _Liquid.Contract.UserMiners(&_Liquid.CallOpts, account)
}

// UserMiners is a free data retrieval call binding the contract method 0xf0836b44.
//
// Solidity: function userMiners(address account) view returns(uint64[])
func (_Liquid *LiquidCallerSession) UserMiners(account common.Address) ([]uint64, error) {
	return _Liquid.Contract.UserMiners(&_Liquid.CallOpts, account)
}

// UtilizationRate is a free data retrieval call binding the contract method 0x6c321c8a.
//
// Solidity: function utilizationRate() view returns(uint256)
func (_Liquid *LiquidCaller) UtilizationRate(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "utilizationRate")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// UtilizationRate is a free data retrieval call binding the contract method 0x6c321c8a.
//
// Solidity: function utilizationRate() view returns(uint256)
func (_Liquid *LiquidSession) UtilizationRate() (*big.Int, error) {
	return _Liquid.Contract.UtilizationRate(&_Liquid.CallOpts)
}

// UtilizationRate is a free data retrieval call binding the contract method 0x6c321c8a.
//
// Solidity: function utilizationRate() view returns(uint256)
func (_Liquid *LiquidCallerSession) UtilizationRate() (*big.Int, error) {
	return _Liquid.Contract.UtilizationRate(&_Liquid.CallOpts)
}

// UtilizationRateBorrow is a free data retrieval call binding the contract method 0xcc0c9ab8.
//
// Solidity: function utilizationRateBorrow(uint256 amount) view returns(uint256)
func (_Liquid *LiquidCaller) UtilizationRateBorrow(opts *bind.CallOpts, amount *big.Int) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "utilizationRateBorrow", amount)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// UtilizationRateBorrow is a free data retrieval call binding the contract method 0xcc0c9ab8.
//
// Solidity: function utilizationRateBorrow(uint256 amount) view returns(uint256)
func (_Liquid *LiquidSession) UtilizationRateBorrow(amount *big.Int) (*big.Int, error) {
	return _Liquid.Contract.UtilizationRateBorrow(&_Liquid.CallOpts, amount)
}

// UtilizationRateBorrow is a free data retrieval call binding the contract method 0xcc0c9ab8.
//
// Solidity: function utilizationRateBorrow(uint256 amount) view returns(uint256)
func (_Liquid *LiquidCallerSession) UtilizationRateBorrow(amount *big.Int) (*big.Int, error) {
	return _Liquid.Contract.UtilizationRateBorrow(&_Liquid.CallOpts, amount)
}

// UtilizedLiquidity is a free data retrieval call binding the contract method 0x9d0ffd9c.
//
// Solidity: function utilizedLiquidity() view returns(uint256)
func (_Liquid *LiquidCaller) UtilizedLiquidity(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _Liquid.contract.Call(opts, &out, "utilizedLiquidity")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// UtilizedLiquidity is a free data retrieval call binding the contract method 0x9d0ffd9c.
//
// Solidity: function utilizedLiquidity() view returns(uint256)
func (_Liquid *LiquidSession) UtilizedLiquidity() (*big.Int, error) {
	return _Liquid.Contract.UtilizedLiquidity(&_Liquid.CallOpts)
}

// UtilizedLiquidity is a free data retrieval call binding the contract method 0x9d0ffd9c.
//
// Solidity: function utilizedLiquidity() view returns(uint256)
func (_Liquid *LiquidCallerSession) UtilizedLiquidity() (*big.Int, error) {
	return _Liquid.Contract.UtilizedLiquidity(&_Liquid.CallOpts)
}

// Borrow is a paid mutator transaction binding the contract method 0xea9f348a.
//
// Solidity: function borrow(uint64 minerId, uint256 amount, uint256 expectInterestRate) returns(uint256, uint256)
func (_Liquid *LiquidTransactor) Borrow(opts *bind.TransactOpts, minerId uint64, amount *big.Int, expectInterestRate *big.Int) (*types.Transaction, error) {
	return _Liquid.contract.Transact(opts, "borrow", minerId, amount, expectInterestRate)
}

// Borrow is a paid mutator transaction binding the contract method 0xea9f348a.
//
// Solidity: function borrow(uint64 minerId, uint256 amount, uint256 expectInterestRate) returns(uint256, uint256)
func (_Liquid *LiquidSession) Borrow(minerId uint64, amount *big.Int, expectInterestRate *big.Int) (*types.Transaction, error) {
	return _Liquid.Contract.Borrow(&_Liquid.TransactOpts, minerId, amount, expectInterestRate)
}

// Borrow is a paid mutator transaction binding the contract method 0xea9f348a.
//
// Solidity: function borrow(uint64 minerId, uint256 amount, uint256 expectInterestRate) returns(uint256, uint256)
func (_Liquid *LiquidTransactorSession) Borrow(minerId uint64, amount *big.Int, expectInterestRate *big.Int) (*types.Transaction, error) {
	return _Liquid.Contract.Borrow(&_Liquid.TransactOpts, minerId, amount, expectInterestRate)
}

// CollateralizingMiner is a paid mutator transaction binding the contract method 0xf821ac8f.
//
// Solidity: function collateralizingMiner(uint64 minerId, bytes signature) returns()
func (_Liquid *LiquidTransactor) CollateralizingMiner(opts *bind.TransactOpts, minerId uint64, signature []byte) (*types.Transaction, error) {
	return _Liquid.contract.Transact(opts, "collateralizingMiner", minerId, signature)
}

// CollateralizingMiner is a paid mutator transaction binding the contract method 0xf821ac8f.
//
// Solidity: function collateralizingMiner(uint64 minerId, bytes signature) returns()
func (_Liquid *LiquidSession) CollateralizingMiner(minerId uint64, signature []byte) (*types.Transaction, error) {
	return _Liquid.Contract.CollateralizingMiner(&_Liquid.TransactOpts, minerId, signature)
}

// CollateralizingMiner is a paid mutator transaction binding the contract method 0xf821ac8f.
//
// Solidity: function collateralizingMiner(uint64 minerId, bytes signature) returns()
func (_Liquid *LiquidTransactorSession) CollateralizingMiner(minerId uint64, signature []byte) (*types.Transaction, error) {
	return _Liquid.Contract.CollateralizingMiner(&_Liquid.TransactOpts, minerId, signature)
}

// Deposit is a paid mutator transaction binding the contract method 0xb6b55f25.
//
// Solidity: function deposit(uint256 expectAmountFILTrust) payable returns(uint256)
func (_Liquid *LiquidTransactor) Deposit(opts *bind.TransactOpts, expectAmountFILTrust *big.Int) (*types.Transaction, error) {
	return _Liquid.contract.Transact(opts, "deposit", expectAmountFILTrust)
}

// Deposit is a paid mutator transaction binding the contract method 0xb6b55f25.
//
// Solidity: function deposit(uint256 expectAmountFILTrust) payable returns(uint256)
func (_Liquid *LiquidSession) Deposit(expectAmountFILTrust *big.Int) (*types.Transaction, error) {
	return _Liquid.Contract.Deposit(&_Liquid.TransactOpts, expectAmountFILTrust)
}

// Deposit is a paid mutator transaction binding the contract method 0xb6b55f25.
//
// Solidity: function deposit(uint256 expectAmountFILTrust) payable returns(uint256)
func (_Liquid *LiquidTransactorSession) Deposit(expectAmountFILTrust *big.Int) (*types.Transaction, error) {
	return _Liquid.Contract.Deposit(&_Liquid.TransactOpts, expectAmountFILTrust)
}

// DirectPayback is a paid mutator transaction binding the contract method 0x239e6b6d.
//
// Solidity: function directPayback(uint64 minerId) payable returns(uint256, uint256, uint256)
func (_Liquid *LiquidTransactor) DirectPayback(opts *bind.TransactOpts, minerId uint64) (*types.Transaction, error) {
	return _Liquid.contract.Transact(opts, "directPayback", minerId)
}

// DirectPayback is a paid mutator transaction binding the contract method 0x239e6b6d.
//
// Solidity: function directPayback(uint64 minerId) payable returns(uint256, uint256, uint256)
func (_Liquid *LiquidSession) DirectPayback(minerId uint64) (*types.Transaction, error) {
	return _Liquid.Contract.DirectPayback(&_Liquid.TransactOpts, minerId)
}

// DirectPayback is a paid mutator transaction binding the contract method 0x239e6b6d.
//
// Solidity: function directPayback(uint64 minerId) payable returns(uint256, uint256, uint256)
func (_Liquid *LiquidTransactorSession) DirectPayback(minerId uint64) (*types.Transaction, error) {
	return _Liquid.Contract.DirectPayback(&_Liquid.TransactOpts, minerId)
}

// Liquidate is a paid mutator transaction binding the contract method 0xf6378e1c.
//
// Solidity: function liquidate(uint64 minerIdPayee, uint64 minerIdPayer) returns(uint256[4] result)
func (_Liquid *LiquidTransactor) Liquidate(opts *bind.TransactOpts, minerIdPayee uint64, minerIdPayer uint64) (*types.Transaction, error) {
	return _Liquid.contract.Transact(opts, "liquidate", minerIdPayee, minerIdPayer)
}

// Liquidate is a paid mutator transaction binding the contract method 0xf6378e1c.
//
// Solidity: function liquidate(uint64 minerIdPayee, uint64 minerIdPayer) returns(uint256[4] result)
func (_Liquid *LiquidSession) Liquidate(minerIdPayee uint64, minerIdPayer uint64) (*types.Transaction, error) {
	return _Liquid.Contract.Liquidate(&_Liquid.TransactOpts, minerIdPayee, minerIdPayer)
}

// Liquidate is a paid mutator transaction binding the contract method 0xf6378e1c.
//
// Solidity: function liquidate(uint64 minerIdPayee, uint64 minerIdPayer) returns(uint256[4] result)
func (_Liquid *LiquidTransactorSession) Liquidate(minerIdPayee uint64, minerIdPayer uint64) (*types.Transaction, error) {
	return _Liquid.Contract.Liquidate(&_Liquid.TransactOpts, minerIdPayee, minerIdPayer)
}

// Redeem is a paid mutator transaction binding the contract method 0x7cbc2373.
//
// Solidity: function redeem(uint256 amountFILTrust, uint256 expectAmountFIL) returns(uint256, uint256)
func (_Liquid *LiquidTransactor) Redeem(opts *bind.TransactOpts, amountFILTrust *big.Int, expectAmountFIL *big.Int) (*types.Transaction, error) {
	return _Liquid.contract.Transact(opts, "redeem", amountFILTrust, expectAmountFIL)
}

// Redeem is a paid mutator transaction binding the contract method 0x7cbc2373.
//
// Solidity: function redeem(uint256 amountFILTrust, uint256 expectAmountFIL) returns(uint256, uint256)
func (_Liquid *LiquidSession) Redeem(amountFILTrust *big.Int, expectAmountFIL *big.Int) (*types.Transaction, error) {
	return _Liquid.Contract.Redeem(&_Liquid.TransactOpts, amountFILTrust, expectAmountFIL)
}

// Redeem is a paid mutator transaction binding the contract method 0x7cbc2373.
//
// Solidity: function redeem(uint256 amountFILTrust, uint256 expectAmountFIL) returns(uint256, uint256)
func (_Liquid *LiquidTransactorSession) Redeem(amountFILTrust *big.Int, expectAmountFIL *big.Int) (*types.Transaction, error) {
	return _Liquid.Contract.Redeem(&_Liquid.TransactOpts, amountFILTrust, expectAmountFIL)
}

// SetGovernanceFactors is a paid mutator transaction binding the contract method 0xe815b8c4.
//
// Solidity: function setGovernanceFactors(uint256[] values) returns()
func (_Liquid *LiquidTransactor) SetGovernanceFactors(opts *bind.TransactOpts, values []*big.Int) (*types.Transaction, error) {
	return _Liquid.contract.Transact(opts, "setGovernanceFactors", values)
}

// SetGovernanceFactors is a paid mutator transaction binding the contract method 0xe815b8c4.
//
// Solidity: function setGovernanceFactors(uint256[] values) returns()
func (_Liquid *LiquidSession) SetGovernanceFactors(values []*big.Int) (*types.Transaction, error) {
	return _Liquid.Contract.SetGovernanceFactors(&_Liquid.TransactOpts, values)
}

// SetGovernanceFactors is a paid mutator transaction binding the contract method 0xe815b8c4.
//
// Solidity: function setGovernanceFactors(uint256[] values) returns()
func (_Liquid *LiquidTransactorSession) SetGovernanceFactors(values []*big.Int) (*types.Transaction, error) {
	return _Liquid.Contract.SetGovernanceFactors(&_Liquid.TransactOpts, values)
}

// SetOwner is a paid mutator transaction binding the contract method 0x13af4035.
//
// Solidity: function setOwner(address new_owner) returns()
func (_Liquid *LiquidTransactor) SetOwner(opts *bind.TransactOpts, new_owner common.Address) (*types.Transaction, error) {
	return _Liquid.contract.Transact(opts, "setOwner", new_owner)
}

// SetOwner is a paid mutator transaction binding the contract method 0x13af4035.
//
// Solidity: function setOwner(address new_owner) returns()
func (_Liquid *LiquidSession) SetOwner(new_owner common.Address) (*types.Transaction, error) {
	return _Liquid.Contract.SetOwner(&_Liquid.TransactOpts, new_owner)
}

// SetOwner is a paid mutator transaction binding the contract method 0x13af4035.
//
// Solidity: function setOwner(address new_owner) returns()
func (_Liquid *LiquidTransactorSession) SetOwner(new_owner common.Address) (*types.Transaction, error) {
	return _Liquid.Contract.SetOwner(&_Liquid.TransactOpts, new_owner)
}

// UncollateralizingMiner is a paid mutator transaction binding the contract method 0x0a165167.
//
// Solidity: function uncollateralizingMiner(uint64 minerId) returns()
func (_Liquid *LiquidTransactor) UncollateralizingMiner(opts *bind.TransactOpts, minerId uint64) (*types.Transaction, error) {
	return _Liquid.contract.Transact(opts, "uncollateralizingMiner", minerId)
}

// UncollateralizingMiner is a paid mutator transaction binding the contract method 0x0a165167.
//
// Solidity: function uncollateralizingMiner(uint64 minerId) returns()
func (_Liquid *LiquidSession) UncollateralizingMiner(minerId uint64) (*types.Transaction, error) {
	return _Liquid.Contract.UncollateralizingMiner(&_Liquid.TransactOpts, minerId)
}

// UncollateralizingMiner is a paid mutator transaction binding the contract method 0x0a165167.
//
// Solidity: function uncollateralizingMiner(uint64 minerId) returns()
func (_Liquid *LiquidTransactorSession) UncollateralizingMiner(minerId uint64) (*types.Transaction, error) {
	return _Liquid.Contract.UncollateralizingMiner(&_Liquid.TransactOpts, minerId)
}

// Withdraw4Payback is a paid mutator transaction binding the contract method 0x222da096.
//
// Solidity: function withdraw4Payback(uint64 minerIdPayee, uint64 minerIdPayer, uint256 amount) payable returns(uint256, uint256, uint256, uint256)
func (_Liquid *LiquidTransactor) Withdraw4Payback(opts *bind.TransactOpts, minerIdPayee uint64, minerIdPayer uint64, amount *big.Int) (*types.Transaction, error) {
	return _Liquid.contract.Transact(opts, "withdraw4Payback", minerIdPayee, minerIdPayer, amount)
}

// Withdraw4Payback is a paid mutator transaction binding the contract method 0x222da096.
//
// Solidity: function withdraw4Payback(uint64 minerIdPayee, uint64 minerIdPayer, uint256 amount) payable returns(uint256, uint256, uint256, uint256)
func (_Liquid *LiquidSession) Withdraw4Payback(minerIdPayee uint64, minerIdPayer uint64, amount *big.Int) (*types.Transaction, error) {
	return _Liquid.Contract.Withdraw4Payback(&_Liquid.TransactOpts, minerIdPayee, minerIdPayer, amount)
}

// Withdraw4Payback is a paid mutator transaction binding the contract method 0x222da096.
//
// Solidity: function withdraw4Payback(uint64 minerIdPayee, uint64 minerIdPayer, uint256 amount) payable returns(uint256, uint256, uint256, uint256)
func (_Liquid *LiquidTransactorSession) Withdraw4Payback(minerIdPayee uint64, minerIdPayer uint64, amount *big.Int) (*types.Transaction, error) {
	return _Liquid.Contract.Withdraw4Payback(&_Liquid.TransactOpts, minerIdPayee, minerIdPayer, amount)
}

// LiquidBorrowIterator is returned from FilterBorrow and is used to iterate over the raw logs and unpacked data for Borrow events raised by the Liquid contract.
type LiquidBorrowIterator struct {
	Event *LiquidBorrow // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *LiquidBorrowIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(LiquidBorrow)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(LiquidBorrow)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *LiquidBorrowIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *LiquidBorrowIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// LiquidBorrow represents a Borrow event raised by the Liquid contract.
type LiquidBorrow struct {
	BorrowId     *big.Int
	Account      common.Address
	MinerId      uint64
	AmountFIL    *big.Int
	Fee          *big.Int
	InterestRate *big.Int
	InitialTime  *big.Int
	Raw          types.Log // Blockchain specific contextual infos
}

// FilterBorrow is a free log retrieval operation binding the contract event 0x5bd2d43871ae1fc7c039d3a6f68abeb98f57e679cab45ecd3e7866ef70ebdfdf.
//
// Solidity: event Borrow(uint256 indexed borrowId, address indexed account, uint64 indexed minerId, uint256 amountFIL, uint256 fee, uint256 interestRate, uint256 initialTime)
func (_Liquid *LiquidFilterer) FilterBorrow(opts *bind.FilterOpts, borrowId []*big.Int, account []common.Address, minerId []uint64) (*LiquidBorrowIterator, error) {

	var borrowIdRule []interface{}
	for _, borrowIdItem := range borrowId {
		borrowIdRule = append(borrowIdRule, borrowIdItem)
	}
	var accountRule []interface{}
	for _, accountItem := range account {
		accountRule = append(accountRule, accountItem)
	}
	var minerIdRule []interface{}
	for _, minerIdItem := range minerId {
		minerIdRule = append(minerIdRule, minerIdItem)
	}

	logs, sub, err := _Liquid.contract.FilterLogs(opts, "Borrow", borrowIdRule, accountRule, minerIdRule)
	if err != nil {
		return nil, err
	}
	return &LiquidBorrowIterator{contract: _Liquid.contract, event: "Borrow", logs: logs, sub: sub}, nil
}

// WatchBorrow is a free log subscription operation binding the contract event 0x5bd2d43871ae1fc7c039d3a6f68abeb98f57e679cab45ecd3e7866ef70ebdfdf.
//
// Solidity: event Borrow(uint256 indexed borrowId, address indexed account, uint64 indexed minerId, uint256 amountFIL, uint256 fee, uint256 interestRate, uint256 initialTime)
func (_Liquid *LiquidFilterer) WatchBorrow(opts *bind.WatchOpts, sink chan<- *LiquidBorrow, borrowId []*big.Int, account []common.Address, minerId []uint64) (event.Subscription, error) {

	var borrowIdRule []interface{}
	for _, borrowIdItem := range borrowId {
		borrowIdRule = append(borrowIdRule, borrowIdItem)
	}
	var accountRule []interface{}
	for _, accountItem := range account {
		accountRule = append(accountRule, accountItem)
	}
	var minerIdRule []interface{}
	for _, minerIdItem := range minerId {
		minerIdRule = append(minerIdRule, minerIdItem)
	}

	logs, sub, err := _Liquid.contract.WatchLogs(opts, "Borrow", borrowIdRule, accountRule, minerIdRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(LiquidBorrow)
				if err := _Liquid.contract.UnpackLog(event, "Borrow", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseBorrow is a log parse operation binding the contract event 0x5bd2d43871ae1fc7c039d3a6f68abeb98f57e679cab45ecd3e7866ef70ebdfdf.
//
// Solidity: event Borrow(uint256 indexed borrowId, address indexed account, uint64 indexed minerId, uint256 amountFIL, uint256 fee, uint256 interestRate, uint256 initialTime)
func (_Liquid *LiquidFilterer) ParseBorrow(log types.Log) (*LiquidBorrow, error) {
	event := new(LiquidBorrow)
	if err := _Liquid.contract.UnpackLog(event, "Borrow", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// LiquidBorrowDroppedIterator is returned from FilterBorrowDropped and is used to iterate over the raw logs and unpacked data for BorrowDropped events raised by the Liquid contract.
type LiquidBorrowDroppedIterator struct {
	Event *LiquidBorrowDropped // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *LiquidBorrowDroppedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(LiquidBorrowDropped)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(LiquidBorrowDropped)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *LiquidBorrowDroppedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *LiquidBorrowDroppedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// LiquidBorrowDropped represents a BorrowDropped event raised by the Liquid contract.
type LiquidBorrowDropped struct {
	Id  *big.Int
	Raw types.Log // Blockchain specific contextual infos
}

// FilterBorrowDropped is a free log retrieval operation binding the contract event 0x61d9b77650600fcdd4c22c24b0a4d497d700008af6309e753f41545b056f58ea.
//
// Solidity: event BorrowDropped(uint256 indexed id)
func (_Liquid *LiquidFilterer) FilterBorrowDropped(opts *bind.FilterOpts, id []*big.Int) (*LiquidBorrowDroppedIterator, error) {

	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _Liquid.contract.FilterLogs(opts, "BorrowDropped", idRule)
	if err != nil {
		return nil, err
	}
	return &LiquidBorrowDroppedIterator{contract: _Liquid.contract, event: "BorrowDropped", logs: logs, sub: sub}, nil
}

// WatchBorrowDropped is a free log subscription operation binding the contract event 0x61d9b77650600fcdd4c22c24b0a4d497d700008af6309e753f41545b056f58ea.
//
// Solidity: event BorrowDropped(uint256 indexed id)
func (_Liquid *LiquidFilterer) WatchBorrowDropped(opts *bind.WatchOpts, sink chan<- *LiquidBorrowDropped, id []*big.Int) (event.Subscription, error) {

	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _Liquid.contract.WatchLogs(opts, "BorrowDropped", idRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(LiquidBorrowDropped)
				if err := _Liquid.contract.UnpackLog(event, "BorrowDropped", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseBorrowDropped is a log parse operation binding the contract event 0x61d9b77650600fcdd4c22c24b0a4d497d700008af6309e753f41545b056f58ea.
//
// Solidity: event BorrowDropped(uint256 indexed id)
func (_Liquid *LiquidFilterer) ParseBorrowDropped(log types.Log) (*LiquidBorrowDropped, error) {
	event := new(LiquidBorrowDropped)
	if err := _Liquid.contract.UnpackLog(event, "BorrowDropped", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// LiquidBorrowUpdatedIterator is returned from FilterBorrowUpdated and is used to iterate over the raw logs and unpacked data for BorrowUpdated events raised by the Liquid contract.
type LiquidBorrowUpdatedIterator struct {
	Event *LiquidBorrowUpdated // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *LiquidBorrowUpdatedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(LiquidBorrowUpdated)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(LiquidBorrowUpdated)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *LiquidBorrowUpdatedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *LiquidBorrowUpdatedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// LiquidBorrowUpdated represents a BorrowUpdated event raised by the Liquid contract.
type LiquidBorrowUpdated struct {
	BorrowId                *big.Int
	BorrowAmount            *big.Int
	RemainingOriginalAmount *big.Int
	DatedTime               *big.Int
	Raw                     types.Log // Blockchain specific contextual infos
}

// FilterBorrowUpdated is a free log retrieval operation binding the contract event 0x9b384078886b8b1c6dc4a4555209acf654e3f9b126bb8acd843e013a2cd23267.
//
// Solidity: event BorrowUpdated(uint256 indexed borrowId, uint256 borrowAmount, uint256 remainingOriginalAmount, uint256 datedTime)
func (_Liquid *LiquidFilterer) FilterBorrowUpdated(opts *bind.FilterOpts, borrowId []*big.Int) (*LiquidBorrowUpdatedIterator, error) {

	var borrowIdRule []interface{}
	for _, borrowIdItem := range borrowId {
		borrowIdRule = append(borrowIdRule, borrowIdItem)
	}

	logs, sub, err := _Liquid.contract.FilterLogs(opts, "BorrowUpdated", borrowIdRule)
	if err != nil {
		return nil, err
	}
	return &LiquidBorrowUpdatedIterator{contract: _Liquid.contract, event: "BorrowUpdated", logs: logs, sub: sub}, nil
}

// WatchBorrowUpdated is a free log subscription operation binding the contract event 0x9b384078886b8b1c6dc4a4555209acf654e3f9b126bb8acd843e013a2cd23267.
//
// Solidity: event BorrowUpdated(uint256 indexed borrowId, uint256 borrowAmount, uint256 remainingOriginalAmount, uint256 datedTime)
func (_Liquid *LiquidFilterer) WatchBorrowUpdated(opts *bind.WatchOpts, sink chan<- *LiquidBorrowUpdated, borrowId []*big.Int) (event.Subscription, error) {

	var borrowIdRule []interface{}
	for _, borrowIdItem := range borrowId {
		borrowIdRule = append(borrowIdRule, borrowIdItem)
	}

	logs, sub, err := _Liquid.contract.WatchLogs(opts, "BorrowUpdated", borrowIdRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(LiquidBorrowUpdated)
				if err := _Liquid.contract.UnpackLog(event, "BorrowUpdated", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseBorrowUpdated is a log parse operation binding the contract event 0x9b384078886b8b1c6dc4a4555209acf654e3f9b126bb8acd843e013a2cd23267.
//
// Solidity: event BorrowUpdated(uint256 indexed borrowId, uint256 borrowAmount, uint256 remainingOriginalAmount, uint256 datedTime)
func (_Liquid *LiquidFilterer) ParseBorrowUpdated(log types.Log) (*LiquidBorrowUpdated, error) {
	event := new(LiquidBorrowUpdated)
	if err := _Liquid.contract.UnpackLog(event, "BorrowUpdated", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// LiquidCollateralizingMinerIterator is returned from FilterCollateralizingMiner and is used to iterate over the raw logs and unpacked data for CollateralizingMiner events raised by the Liquid contract.
type LiquidCollateralizingMinerIterator struct {
	Event *LiquidCollateralizingMiner // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *LiquidCollateralizingMinerIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(LiquidCollateralizingMiner)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(LiquidCollateralizingMiner)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *LiquidCollateralizingMinerIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *LiquidCollateralizingMinerIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// LiquidCollateralizingMiner represents a CollateralizingMiner event raised by the Liquid contract.
type LiquidCollateralizingMiner struct {
	MinerId     uint64
	Sender      common.Address
	Beneficiary []byte
	Quota       *big.Int
	Expiration  int64
	Raw         types.Log // Blockchain specific contextual infos
}

// FilterCollateralizingMiner is a free log retrieval operation binding the contract event 0x144b0f9e24444cb25dccbad166502e742085e4fc91394e3dd0d21db835088e2c.
//
// Solidity: event CollateralizingMiner(uint64 indexed minerId, address indexed sender, bytes beneficiary, uint256 quota, int64 expiration)
func (_Liquid *LiquidFilterer) FilterCollateralizingMiner(opts *bind.FilterOpts, minerId []uint64, sender []common.Address) (*LiquidCollateralizingMinerIterator, error) {

	var minerIdRule []interface{}
	for _, minerIdItem := range minerId {
		minerIdRule = append(minerIdRule, minerIdItem)
	}
	var senderRule []interface{}
	for _, senderItem := range sender {
		senderRule = append(senderRule, senderItem)
	}

	logs, sub, err := _Liquid.contract.FilterLogs(opts, "CollateralizingMiner", minerIdRule, senderRule)
	if err != nil {
		return nil, err
	}
	return &LiquidCollateralizingMinerIterator{contract: _Liquid.contract, event: "CollateralizingMiner", logs: logs, sub: sub}, nil
}

// WatchCollateralizingMiner is a free log subscription operation binding the contract event 0x144b0f9e24444cb25dccbad166502e742085e4fc91394e3dd0d21db835088e2c.
//
// Solidity: event CollateralizingMiner(uint64 indexed minerId, address indexed sender, bytes beneficiary, uint256 quota, int64 expiration)
func (_Liquid *LiquidFilterer) WatchCollateralizingMiner(opts *bind.WatchOpts, sink chan<- *LiquidCollateralizingMiner, minerId []uint64, sender []common.Address) (event.Subscription, error) {

	var minerIdRule []interface{}
	for _, minerIdItem := range minerId {
		minerIdRule = append(minerIdRule, minerIdItem)
	}
	var senderRule []interface{}
	for _, senderItem := range sender {
		senderRule = append(senderRule, senderItem)
	}

	logs, sub, err := _Liquid.contract.WatchLogs(opts, "CollateralizingMiner", minerIdRule, senderRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(LiquidCollateralizingMiner)
				if err := _Liquid.contract.UnpackLog(event, "CollateralizingMiner", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseCollateralizingMiner is a log parse operation binding the contract event 0x144b0f9e24444cb25dccbad166502e742085e4fc91394e3dd0d21db835088e2c.
//
// Solidity: event CollateralizingMiner(uint64 indexed minerId, address indexed sender, bytes beneficiary, uint256 quota, int64 expiration)
func (_Liquid *LiquidFilterer) ParseCollateralizingMiner(log types.Log) (*LiquidCollateralizingMiner, error) {
	event := new(LiquidCollateralizingMiner)
	if err := _Liquid.contract.UnpackLog(event, "CollateralizingMiner", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// LiquidDepositIterator is returned from FilterDeposit and is used to iterate over the raw logs and unpacked data for Deposit events raised by the Liquid contract.
type LiquidDepositIterator struct {
	Event *LiquidDeposit // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *LiquidDepositIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(LiquidDeposit)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(LiquidDeposit)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *LiquidDepositIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *LiquidDepositIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// LiquidDeposit represents a Deposit event raised by the Liquid contract.
type LiquidDeposit struct {
	Account        common.Address
	AmountFIL      *big.Int
	AmountFILTrust *big.Int
	Raw            types.Log // Blockchain specific contextual infos
}

// FilterDeposit is a free log retrieval operation binding the contract event 0x90890809c654f11d6e72a28fa60149770a0d11ec6c92319d6ceb2bb0a4ea1a15.
//
// Solidity: event Deposit(address indexed account, uint256 amountFIL, uint256 amountFILTrust)
func (_Liquid *LiquidFilterer) FilterDeposit(opts *bind.FilterOpts, account []common.Address) (*LiquidDepositIterator, error) {

	var accountRule []interface{}
	for _, accountItem := range account {
		accountRule = append(accountRule, accountItem)
	}

	logs, sub, err := _Liquid.contract.FilterLogs(opts, "Deposit", accountRule)
	if err != nil {
		return nil, err
	}
	return &LiquidDepositIterator{contract: _Liquid.contract, event: "Deposit", logs: logs, sub: sub}, nil
}

// WatchDeposit is a free log subscription operation binding the contract event 0x90890809c654f11d6e72a28fa60149770a0d11ec6c92319d6ceb2bb0a4ea1a15.
//
// Solidity: event Deposit(address indexed account, uint256 amountFIL, uint256 amountFILTrust)
func (_Liquid *LiquidFilterer) WatchDeposit(opts *bind.WatchOpts, sink chan<- *LiquidDeposit, account []common.Address) (event.Subscription, error) {

	var accountRule []interface{}
	for _, accountItem := range account {
		accountRule = append(accountRule, accountItem)
	}

	logs, sub, err := _Liquid.contract.WatchLogs(opts, "Deposit", accountRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(LiquidDeposit)
				if err := _Liquid.contract.UnpackLog(event, "Deposit", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseDeposit is a log parse operation binding the contract event 0x90890809c654f11d6e72a28fa60149770a0d11ec6c92319d6ceb2bb0a4ea1a15.
//
// Solidity: event Deposit(address indexed account, uint256 amountFIL, uint256 amountFILTrust)
func (_Liquid *LiquidFilterer) ParseDeposit(log types.Log) (*LiquidDeposit, error) {
	event := new(LiquidDeposit)
	if err := _Liquid.contract.UnpackLog(event, "Deposit", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// LiquidLiquidateIterator is returned from FilterLiquidate and is used to iterate over the raw logs and unpacked data for Liquidate events raised by the Liquid contract.
type LiquidLiquidateIterator struct {
	Event *LiquidLiquidate // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *LiquidLiquidateIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(LiquidLiquidate)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(LiquidLiquidate)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *LiquidLiquidateIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *LiquidLiquidateIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// LiquidLiquidate represents a Liquidate event raised by the Liquid contract.
type LiquidLiquidate struct {
	Account      common.Address
	MinerIdPayee uint64
	MinerIdPayer uint64
	Principal    *big.Int
	Interest     *big.Int
	Reward       *big.Int
	Fee          *big.Int
	MintedFIG    *big.Int
	Raw          types.Log // Blockchain specific contextual infos
}

// FilterLiquidate is a free log retrieval operation binding the contract event 0xc0f45f36225747fbc4ff6b061d4210560974dd6cf09d1e46dd3feb7a7360e0ad.
//
// Solidity: event Liquidate(address indexed account, uint64 indexed minerIdPayee, uint64 indexed minerIdPayer, uint256 principal, uint256 interest, uint256 reward, uint256 fee, uint256 mintedFIG)
func (_Liquid *LiquidFilterer) FilterLiquidate(opts *bind.FilterOpts, account []common.Address, minerIdPayee []uint64, minerIdPayer []uint64) (*LiquidLiquidateIterator, error) {

	var accountRule []interface{}
	for _, accountItem := range account {
		accountRule = append(accountRule, accountItem)
	}
	var minerIdPayeeRule []interface{}
	for _, minerIdPayeeItem := range minerIdPayee {
		minerIdPayeeRule = append(minerIdPayeeRule, minerIdPayeeItem)
	}
	var minerIdPayerRule []interface{}
	for _, minerIdPayerItem := range minerIdPayer {
		minerIdPayerRule = append(minerIdPayerRule, minerIdPayerItem)
	}

	logs, sub, err := _Liquid.contract.FilterLogs(opts, "Liquidate", accountRule, minerIdPayeeRule, minerIdPayerRule)
	if err != nil {
		return nil, err
	}
	return &LiquidLiquidateIterator{contract: _Liquid.contract, event: "Liquidate", logs: logs, sub: sub}, nil
}

// WatchLiquidate is a free log subscription operation binding the contract event 0xc0f45f36225747fbc4ff6b061d4210560974dd6cf09d1e46dd3feb7a7360e0ad.
//
// Solidity: event Liquidate(address indexed account, uint64 indexed minerIdPayee, uint64 indexed minerIdPayer, uint256 principal, uint256 interest, uint256 reward, uint256 fee, uint256 mintedFIG)
func (_Liquid *LiquidFilterer) WatchLiquidate(opts *bind.WatchOpts, sink chan<- *LiquidLiquidate, account []common.Address, minerIdPayee []uint64, minerIdPayer []uint64) (event.Subscription, error) {

	var accountRule []interface{}
	for _, accountItem := range account {
		accountRule = append(accountRule, accountItem)
	}
	var minerIdPayeeRule []interface{}
	for _, minerIdPayeeItem := range minerIdPayee {
		minerIdPayeeRule = append(minerIdPayeeRule, minerIdPayeeItem)
	}
	var minerIdPayerRule []interface{}
	for _, minerIdPayerItem := range minerIdPayer {
		minerIdPayerRule = append(minerIdPayerRule, minerIdPayerItem)
	}

	logs, sub, err := _Liquid.contract.WatchLogs(opts, "Liquidate", accountRule, minerIdPayeeRule, minerIdPayerRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(LiquidLiquidate)
				if err := _Liquid.contract.UnpackLog(event, "Liquidate", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseLiquidate is a log parse operation binding the contract event 0xc0f45f36225747fbc4ff6b061d4210560974dd6cf09d1e46dd3feb7a7360e0ad.
//
// Solidity: event Liquidate(address indexed account, uint64 indexed minerIdPayee, uint64 indexed minerIdPayer, uint256 principal, uint256 interest, uint256 reward, uint256 fee, uint256 mintedFIG)
func (_Liquid *LiquidFilterer) ParseLiquidate(log types.Log) (*LiquidLiquidate, error) {
	event := new(LiquidLiquidate)
	if err := _Liquid.contract.UnpackLog(event, "Liquidate", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// LiquidOwnerChangedIterator is returned from FilterOwnerChanged and is used to iterate over the raw logs and unpacked data for OwnerChanged events raised by the Liquid contract.
type LiquidOwnerChangedIterator struct {
	Event *LiquidOwnerChanged // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *LiquidOwnerChangedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(LiquidOwnerChanged)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(LiquidOwnerChanged)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *LiquidOwnerChangedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *LiquidOwnerChangedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// LiquidOwnerChanged represents a OwnerChanged event raised by the Liquid contract.
type LiquidOwnerChanged struct {
	Account common.Address
	Raw     types.Log // Blockchain specific contextual infos
}

// FilterOwnerChanged is a free log retrieval operation binding the contract event 0xa2ea9883a321a3e97b8266c2b078bfeec6d50c711ed71f874a90d500ae2eaf36.
//
// Solidity: event OwnerChanged(address indexed account)
func (_Liquid *LiquidFilterer) FilterOwnerChanged(opts *bind.FilterOpts, account []common.Address) (*LiquidOwnerChangedIterator, error) {

	var accountRule []interface{}
	for _, accountItem := range account {
		accountRule = append(accountRule, accountItem)
	}

	logs, sub, err := _Liquid.contract.FilterLogs(opts, "OwnerChanged", accountRule)
	if err != nil {
		return nil, err
	}
	return &LiquidOwnerChangedIterator{contract: _Liquid.contract, event: "OwnerChanged", logs: logs, sub: sub}, nil
}

// WatchOwnerChanged is a free log subscription operation binding the contract event 0xa2ea9883a321a3e97b8266c2b078bfeec6d50c711ed71f874a90d500ae2eaf36.
//
// Solidity: event OwnerChanged(address indexed account)
func (_Liquid *LiquidFilterer) WatchOwnerChanged(opts *bind.WatchOpts, sink chan<- *LiquidOwnerChanged, account []common.Address) (event.Subscription, error) {

	var accountRule []interface{}
	for _, accountItem := range account {
		accountRule = append(accountRule, accountItem)
	}

	logs, sub, err := _Liquid.contract.WatchLogs(opts, "OwnerChanged", accountRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(LiquidOwnerChanged)
				if err := _Liquid.contract.UnpackLog(event, "OwnerChanged", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseOwnerChanged is a log parse operation binding the contract event 0xa2ea9883a321a3e97b8266c2b078bfeec6d50c711ed71f874a90d500ae2eaf36.
//
// Solidity: event OwnerChanged(address indexed account)
func (_Liquid *LiquidFilterer) ParseOwnerChanged(log types.Log) (*LiquidOwnerChanged, error) {
	event := new(LiquidOwnerChanged)
	if err := _Liquid.contract.UnpackLog(event, "OwnerChanged", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// LiquidPaybackIterator is returned from FilterPayback and is used to iterate over the raw logs and unpacked data for Payback events raised by the Liquid contract.
type LiquidPaybackIterator struct {
	Event *LiquidPayback // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *LiquidPaybackIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(LiquidPayback)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(LiquidPayback)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *LiquidPaybackIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *LiquidPaybackIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// LiquidPayback represents a Payback event raised by the Liquid contract.
type LiquidPayback struct {
	Account      common.Address
	MinerIdPayee uint64
	MinerIdPayer uint64
	Principal    *big.Int
	Interest     *big.Int
	Withdrawn    *big.Int
	MintedFIG    *big.Int
	Raw          types.Log // Blockchain specific contextual infos
}

// FilterPayback is a free log retrieval operation binding the contract event 0xde610750e8cb5c762c87d228aa6c3937950a600734cdc601c3d6f42f85996329.
//
// Solidity: event Payback(address indexed account, uint64 indexed minerIdPayee, uint64 indexed minerIdPayer, uint256 principal, uint256 interest, uint256 withdrawn, uint256 mintedFIG)
func (_Liquid *LiquidFilterer) FilterPayback(opts *bind.FilterOpts, account []common.Address, minerIdPayee []uint64, minerIdPayer []uint64) (*LiquidPaybackIterator, error) {

	var accountRule []interface{}
	for _, accountItem := range account {
		accountRule = append(accountRule, accountItem)
	}
	var minerIdPayeeRule []interface{}
	for _, minerIdPayeeItem := range minerIdPayee {
		minerIdPayeeRule = append(minerIdPayeeRule, minerIdPayeeItem)
	}
	var minerIdPayerRule []interface{}
	for _, minerIdPayerItem := range minerIdPayer {
		minerIdPayerRule = append(minerIdPayerRule, minerIdPayerItem)
	}

	logs, sub, err := _Liquid.contract.FilterLogs(opts, "Payback", accountRule, minerIdPayeeRule, minerIdPayerRule)
	if err != nil {
		return nil, err
	}
	return &LiquidPaybackIterator{contract: _Liquid.contract, event: "Payback", logs: logs, sub: sub}, nil
}

// WatchPayback is a free log subscription operation binding the contract event 0xde610750e8cb5c762c87d228aa6c3937950a600734cdc601c3d6f42f85996329.
//
// Solidity: event Payback(address indexed account, uint64 indexed minerIdPayee, uint64 indexed minerIdPayer, uint256 principal, uint256 interest, uint256 withdrawn, uint256 mintedFIG)
func (_Liquid *LiquidFilterer) WatchPayback(opts *bind.WatchOpts, sink chan<- *LiquidPayback, account []common.Address, minerIdPayee []uint64, minerIdPayer []uint64) (event.Subscription, error) {

	var accountRule []interface{}
	for _, accountItem := range account {
		accountRule = append(accountRule, accountItem)
	}
	var minerIdPayeeRule []interface{}
	for _, minerIdPayeeItem := range minerIdPayee {
		minerIdPayeeRule = append(minerIdPayeeRule, minerIdPayeeItem)
	}
	var minerIdPayerRule []interface{}
	for _, minerIdPayerItem := range minerIdPayer {
		minerIdPayerRule = append(minerIdPayerRule, minerIdPayerItem)
	}

	logs, sub, err := _Liquid.contract.WatchLogs(opts, "Payback", accountRule, minerIdPayeeRule, minerIdPayerRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(LiquidPayback)
				if err := _Liquid.contract.UnpackLog(event, "Payback", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParsePayback is a log parse operation binding the contract event 0xde610750e8cb5c762c87d228aa6c3937950a600734cdc601c3d6f42f85996329.
//
// Solidity: event Payback(address indexed account, uint64 indexed minerIdPayee, uint64 indexed minerIdPayer, uint256 principal, uint256 interest, uint256 withdrawn, uint256 mintedFIG)
func (_Liquid *LiquidFilterer) ParsePayback(log types.Log) (*LiquidPayback, error) {
	event := new(LiquidPayback)
	if err := _Liquid.contract.UnpackLog(event, "Payback", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// LiquidRedeemIterator is returned from FilterRedeem and is used to iterate over the raw logs and unpacked data for Redeem events raised by the Liquid contract.
type LiquidRedeemIterator struct {
	Event *LiquidRedeem // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *LiquidRedeemIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(LiquidRedeem)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(LiquidRedeem)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *LiquidRedeemIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *LiquidRedeemIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// LiquidRedeem represents a Redeem event raised by the Liquid contract.
type LiquidRedeem struct {
	Account        common.Address
	AmountFILTrust *big.Int
	AmountFIL      *big.Int
	Fee            *big.Int
	Raw            types.Log // Blockchain specific contextual infos
}

// FilterRedeem is a free log retrieval operation binding the contract event 0xbd5034ffbd47e4e72a94baa2cdb74c6fad73cb3bcdc13036b72ec8306f5a7646.
//
// Solidity: event Redeem(address indexed account, uint256 amountFILTrust, uint256 amountFIL, uint256 fee)
func (_Liquid *LiquidFilterer) FilterRedeem(opts *bind.FilterOpts, account []common.Address) (*LiquidRedeemIterator, error) {

	var accountRule []interface{}
	for _, accountItem := range account {
		accountRule = append(accountRule, accountItem)
	}

	logs, sub, err := _Liquid.contract.FilterLogs(opts, "Redeem", accountRule)
	if err != nil {
		return nil, err
	}
	return &LiquidRedeemIterator{contract: _Liquid.contract, event: "Redeem", logs: logs, sub: sub}, nil
}

// WatchRedeem is a free log subscription operation binding the contract event 0xbd5034ffbd47e4e72a94baa2cdb74c6fad73cb3bcdc13036b72ec8306f5a7646.
//
// Solidity: event Redeem(address indexed account, uint256 amountFILTrust, uint256 amountFIL, uint256 fee)
func (_Liquid *LiquidFilterer) WatchRedeem(opts *bind.WatchOpts, sink chan<- *LiquidRedeem, account []common.Address) (event.Subscription, error) {

	var accountRule []interface{}
	for _, accountItem := range account {
		accountRule = append(accountRule, accountItem)
	}

	logs, sub, err := _Liquid.contract.WatchLogs(opts, "Redeem", accountRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(LiquidRedeem)
				if err := _Liquid.contract.UnpackLog(event, "Redeem", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseRedeem is a log parse operation binding the contract event 0xbd5034ffbd47e4e72a94baa2cdb74c6fad73cb3bcdc13036b72ec8306f5a7646.
//
// Solidity: event Redeem(address indexed account, uint256 amountFILTrust, uint256 amountFIL, uint256 fee)
func (_Liquid *LiquidFilterer) ParseRedeem(log types.Log) (*LiquidRedeem, error) {
	event := new(LiquidRedeem)
	if err := _Liquid.contract.UnpackLog(event, "Redeem", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// LiquidUncollateralizingMinerIterator is returned from FilterUncollateralizingMiner and is used to iterate over the raw logs and unpacked data for UncollateralizingMiner events raised by the Liquid contract.
type LiquidUncollateralizingMinerIterator struct {
	Event *LiquidUncollateralizingMiner // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *LiquidUncollateralizingMinerIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(LiquidUncollateralizingMiner)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(LiquidUncollateralizingMiner)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *LiquidUncollateralizingMinerIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *LiquidUncollateralizingMinerIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// LiquidUncollateralizingMiner represents a UncollateralizingMiner event raised by the Liquid contract.
type LiquidUncollateralizingMiner struct {
	MinerId     uint64
	Sender      common.Address
	Beneficiary []byte
	Quota       *big.Int
	Expiration  int64
	Raw         types.Log // Blockchain specific contextual infos
}

// FilterUncollateralizingMiner is a free log retrieval operation binding the contract event 0x867bb64e0964be26cb216c9f89071847ed0cb22dba52ed0d1ff37b545bcfec23.
//
// Solidity: event UncollateralizingMiner(uint64 indexed minerId, address indexed sender, bytes beneficiary, uint256 quota, int64 expiration)
func (_Liquid *LiquidFilterer) FilterUncollateralizingMiner(opts *bind.FilterOpts, minerId []uint64, sender []common.Address) (*LiquidUncollateralizingMinerIterator, error) {

	var minerIdRule []interface{}
	for _, minerIdItem := range minerId {
		minerIdRule = append(minerIdRule, minerIdItem)
	}
	var senderRule []interface{}
	for _, senderItem := range sender {
		senderRule = append(senderRule, senderItem)
	}

	logs, sub, err := _Liquid.contract.FilterLogs(opts, "UncollateralizingMiner", minerIdRule, senderRule)
	if err != nil {
		return nil, err
	}
	return &LiquidUncollateralizingMinerIterator{contract: _Liquid.contract, event: "UncollateralizingMiner", logs: logs, sub: sub}, nil
}

// WatchUncollateralizingMiner is a free log subscription operation binding the contract event 0x867bb64e0964be26cb216c9f89071847ed0cb22dba52ed0d1ff37b545bcfec23.
//
// Solidity: event UncollateralizingMiner(uint64 indexed minerId, address indexed sender, bytes beneficiary, uint256 quota, int64 expiration)
func (_Liquid *LiquidFilterer) WatchUncollateralizingMiner(opts *bind.WatchOpts, sink chan<- *LiquidUncollateralizingMiner, minerId []uint64, sender []common.Address) (event.Subscription, error) {

	var minerIdRule []interface{}
	for _, minerIdItem := range minerId {
		minerIdRule = append(minerIdRule, minerIdItem)
	}
	var senderRule []interface{}
	for _, senderItem := range sender {
		senderRule = append(senderRule, senderItem)
	}

	logs, sub, err := _Liquid.contract.WatchLogs(opts, "UncollateralizingMiner", minerIdRule, senderRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(LiquidUncollateralizingMiner)
				if err := _Liquid.contract.UnpackLog(event, "UncollateralizingMiner", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseUncollateralizingMiner is a log parse operation binding the contract event 0x867bb64e0964be26cb216c9f89071847ed0cb22dba52ed0d1ff37b545bcfec23.
//
// Solidity: event UncollateralizingMiner(uint64 indexed minerId, address indexed sender, bytes beneficiary, uint256 quota, int64 expiration)
func (_Liquid *LiquidFilterer) ParseUncollateralizingMiner(log types.Log) (*LiquidUncollateralizingMiner, error) {
	event := new(LiquidUncollateralizingMiner)
	if err := _Liquid.contract.UnpackLog(event, "UncollateralizingMiner", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
