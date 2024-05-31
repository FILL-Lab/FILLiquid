// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package fitstake

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

// FITStakeFITStakeInfo is an auto generated low-level Go binding around an user-defined struct.
type FITStakeFITStakeInfo struct {
	AccumulatedInterest      *big.Int
	AccumulatedStake         *big.Int
	AccumulatedStakeDuration *big.Int
	AccumulatedInterestMint  *big.Int
	AccumulatedStakeMint     *big.Int
	AccumulatedWithdrawn     *big.Int
	NextStakeID              *big.Int
	ReleasedFIGStake         *big.Int
}

// FITStakeStake is an auto generated low-level Go binding around an user-defined struct.
type FITStakeStake struct {
	Id          *big.Int
	Amount      *big.Int
	Start       *big.Int
	End         *big.Int
	TotalFIG    *big.Int
	ReleasedFIG *big.Int
}

// FITStakeStakeInfo is an auto generated low-level Go binding around an user-defined struct.
type FITStakeStakeInfo struct {
	Stake          FITStakeStake
	CanWithdrawFIT bool
	CanWithdrawFIG *big.Int
}

// FITStakeStakerInfo is an auto generated low-level Go binding around an user-defined struct.
type FITStakeStakerInfo struct {
	Staker            common.Address
	StakeSum          *big.Int
	TotalFIGSum       *big.Int
	ReleasedFIGSum    *big.Int
	CanWithdrawFITSum *big.Int
	CanWithdrawFIGSum *big.Int
	StakeInfos        []FITStakeStakeInfo
}

// FitstakeMetaData contains all meta data concerning the Fitstake contract.
var FitstakeMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"address\",\"name\":\"new_filLiquid\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"new_governance\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"new_tokenFILTrust\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"new_calculation\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"new_tokenFILGovernance\",\"type\":\"address\"}],\"name\":\"ContractAddrsChanged\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"_n_interest\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"_n_stake\",\"type\":\"uint256\"}],\"name\":\"GovernanceFactorsChanged\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"minter\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"principal\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"interest\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"minted\",\"type\":\"uint256\"}],\"name\":\"Interest\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"address\",\"name\":\"new_owner\",\"type\":\"address\"}],\"name\":\"OwnerChanged\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_rateBase\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_interest_share\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_stake_share\",\"type\":\"uint256\"}],\"name\":\"SharesChanged\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_minStakePeriod\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_maxStakePeriod\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_minStake\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_maxStakes\",\"type\":\"uint256\"}],\"name\":\"StakeParamsChanged\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"staker\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"start\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"end\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"minted\",\"type\":\"uint256\"}],\"name\":\"Staked\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"staker\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"start\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"end\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"realEnd\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"minted\",\"type\":\"uint256\"}],\"name\":\"Unstaked\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"staker\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"WithdrawnFIG\",\"type\":\"event\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"stakeId\",\"type\":\"uint256\"}],\"name\":\"canWithDrawFIG\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"canWithdraw\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"staker\",\"type\":\"address\"}],\"name\":\"canWithdrawFIGAll\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"withdrawn\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256[]\",\"name\":\"params\",\"type\":\"uint256[]\"}],\"name\":\"checkGovernanceFactors\",\"outputs\":[],\"stateMutability\":\"pure\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getAllFactors\",\"outputs\":[{\"internalType\":\"uint256[9]\",\"name\":\"result\",\"type\":\"uint256[9]\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getContractAddrs\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"getCurrentMintedFromInterest\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"stake\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"duration\",\"type\":\"uint256\"}],\"name\":\"getCurrentMintedFromStake\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"stakeId\",\"type\":\"uint256\"}],\"name\":\"getStakeInfoById\",\"outputs\":[{\"components\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"start\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"end\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"totalFIG\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"releasedFIG\",\"type\":\"uint256\"}],\"internalType\":\"structFITStake.Stake\",\"name\":\"stake\",\"type\":\"tuple\"},{\"internalType\":\"bool\",\"name\":\"canWithdrawFIT\",\"type\":\"bool\"},{\"internalType\":\"uint256\",\"name\":\"canWithdrawFIG\",\"type\":\"uint256\"}],\"internalType\":\"structFITStake.StakeInfo\",\"name\":\"\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"staker\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"stakeId\",\"type\":\"uint256\"}],\"name\":\"getStakeInfoByStakerAndId\",\"outputs\":[{\"components\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"start\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"end\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"totalFIG\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"releasedFIG\",\"type\":\"uint256\"}],\"internalType\":\"structFITStake.Stake\",\"name\":\"stake\",\"type\":\"tuple\"},{\"internalType\":\"bool\",\"name\":\"canWithdrawFIT\",\"type\":\"bool\"},{\"internalType\":\"uint256\",\"name\":\"canWithdrawFIG\",\"type\":\"uint256\"}],\"internalType\":\"structFITStake.StakeInfo\",\"name\":\"result\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"stakeId\",\"type\":\"uint256\"}],\"name\":\"getStakerById\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"staker\",\"type\":\"address\"}],\"name\":\"getStakerStakes\",\"outputs\":[{\"components\":[{\"internalType\":\"address\",\"name\":\"staker\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"stakeSum\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"totalFIGSum\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"releasedFIGSum\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"canWithdrawFITSum\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"canWithdrawFIGSum\",\"type\":\"uint256\"},{\"components\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"start\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"end\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"totalFIG\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"releasedFIG\",\"type\":\"uint256\"}],\"internalType\":\"structFITStake.Stake\",\"name\":\"stake\",\"type\":\"tuple\"},{\"internalType\":\"bool\",\"name\":\"canWithdrawFIT\",\"type\":\"bool\"},{\"internalType\":\"uint256\",\"name\":\"canWithdrawFIG\",\"type\":\"uint256\"}],\"internalType\":\"structFITStake.StakeInfo[]\",\"name\":\"stakeInfos\",\"type\":\"tuple[]\"}],\"internalType\":\"structFITStake.StakerInfo\",\"name\":\"result\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"staker\",\"type\":\"address\"}],\"name\":\"getStakerSum\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"staker\",\"type\":\"address\"}],\"name\":\"getStakerTerms\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"stakeSum\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"totalFIGSum\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"releasedFIGSum\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"canWithdrawFITSum\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"canWithdrawFIGSum\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getStakersCount\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"start\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"end\",\"type\":\"uint256\"}],\"name\":\"getStakersSubset\",\"outputs\":[{\"components\":[{\"internalType\":\"address\",\"name\":\"staker\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"stakeSum\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"totalFIGSum\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"releasedFIGSum\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"canWithdrawFITSum\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"canWithdrawFIGSum\",\"type\":\"uint256\"},{\"components\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"id\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"start\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"end\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"totalFIG\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"releasedFIG\",\"type\":\"uint256\"}],\"internalType\":\"structFITStake.Stake\",\"name\":\"stake\",\"type\":\"tuple\"},{\"internalType\":\"bool\",\"name\":\"canWithdrawFIT\",\"type\":\"bool\"},{\"internalType\":\"uint256\",\"name\":\"canWithdrawFIG\",\"type\":\"uint256\"}],\"internalType\":\"structFITStake.StakeInfo[]\",\"name\":\"stakeInfos\",\"type\":\"tuple[]\"}],\"internalType\":\"structFITStake.StakerInfo[]\",\"name\":\"result\",\"type\":\"tuple[]\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getStatus\",\"outputs\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"accumulatedInterest\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedStake\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedStakeDuration\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedInterestMint\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedStakeMint\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"accumulatedWithdrawn\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"nextStakeID\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"releasedFIGStake\",\"type\":\"uint256\"}],\"internalType\":\"structFITStake.FITStakeInfo\",\"name\":\"\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"minter\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"principal\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"interest\",\"type\":\"uint256\"}],\"name\":\"handleInterest\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"minted\",\"type\":\"uint256\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"staker\",\"type\":\"address\"}],\"name\":\"onceStaked\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"owner\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"new_filLiquid\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"new_governance\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"new_tokenFILTrust\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"new_calculation\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"new_tokenFILGovernance\",\"type\":\"address\"}],\"name\":\"setContractAddrs\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256[]\",\"name\":\"params\",\"type\":\"uint256[]\"}],\"name\":\"setGovernanceFactors\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"new_owner\",\"type\":\"address\"}],\"name\":\"setOwner\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"new_rateBase\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"new_interest_share\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"new_stake_share\",\"type\":\"uint256\"}],\"name\":\"setShares\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"new_minStakePeriod\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"new_maxStakePeriod\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"new_minStake\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"new_maxStakes\",\"type\":\"uint256\"}],\"name\":\"setStakeParams\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"maxStart\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"duration\",\"type\":\"uint256\"}],\"name\":\"stakeFilTrust\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"minted\",\"type\":\"uint256\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"stakeId\",\"type\":\"uint256\"}],\"name\":\"unStakeFilTrust\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"minted\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"withdrawnFIG\",\"type\":\"uint256\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"stakeId\",\"type\":\"uint256\"}],\"name\":\"withdrawFIG\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"withdrawn\",\"type\":\"uint256\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"withdrawFIGAll\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"withdrawn\",\"type\":\"uint256\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]",
}

// FitstakeABI is the input ABI used to generate the binding from.
// Deprecated: Use FitstakeMetaData.ABI instead.
var FitstakeABI = FitstakeMetaData.ABI

// Fitstake is an auto generated Go binding around an Ethereum contract.
type Fitstake struct {
	FitstakeCaller     // Read-only binding to the contract
	FitstakeTransactor // Write-only binding to the contract
	FitstakeFilterer   // Log filterer for contract events
}

// FitstakeCaller is an auto generated read-only Go binding around an Ethereum contract.
type FitstakeCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// FitstakeTransactor is an auto generated write-only Go binding around an Ethereum contract.
type FitstakeTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// FitstakeFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type FitstakeFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// FitstakeSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type FitstakeSession struct {
	Contract     *Fitstake         // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// FitstakeCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type FitstakeCallerSession struct {
	Contract *FitstakeCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts   // Call options to use throughout this session
}

// FitstakeTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type FitstakeTransactorSession struct {
	Contract     *FitstakeTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts   // Transaction auth options to use throughout this session
}

// FitstakeRaw is an auto generated low-level Go binding around an Ethereum contract.
type FitstakeRaw struct {
	Contract *Fitstake // Generic contract binding to access the raw methods on
}

// FitstakeCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type FitstakeCallerRaw struct {
	Contract *FitstakeCaller // Generic read-only contract binding to access the raw methods on
}

// FitstakeTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type FitstakeTransactorRaw struct {
	Contract *FitstakeTransactor // Generic write-only contract binding to access the raw methods on
}

// NewFitstake creates a new instance of Fitstake, bound to a specific deployed contract.
func NewFitstake(address common.Address, backend bind.ContractBackend) (*Fitstake, error) {
	contract, err := bindFitstake(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &Fitstake{FitstakeCaller: FitstakeCaller{contract: contract}, FitstakeTransactor: FitstakeTransactor{contract: contract}, FitstakeFilterer: FitstakeFilterer{contract: contract}}, nil
}

// NewFitstakeCaller creates a new read-only instance of Fitstake, bound to a specific deployed contract.
func NewFitstakeCaller(address common.Address, caller bind.ContractCaller) (*FitstakeCaller, error) {
	contract, err := bindFitstake(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &FitstakeCaller{contract: contract}, nil
}

// NewFitstakeTransactor creates a new write-only instance of Fitstake, bound to a specific deployed contract.
func NewFitstakeTransactor(address common.Address, transactor bind.ContractTransactor) (*FitstakeTransactor, error) {
	contract, err := bindFitstake(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &FitstakeTransactor{contract: contract}, nil
}

// NewFitstakeFilterer creates a new log filterer instance of Fitstake, bound to a specific deployed contract.
func NewFitstakeFilterer(address common.Address, filterer bind.ContractFilterer) (*FitstakeFilterer, error) {
	contract, err := bindFitstake(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &FitstakeFilterer{contract: contract}, nil
}

// bindFitstake binds a generic wrapper to an already deployed contract.
func bindFitstake(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := FitstakeMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Fitstake *FitstakeRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Fitstake.Contract.FitstakeCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Fitstake *FitstakeRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Fitstake.Contract.FitstakeTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Fitstake *FitstakeRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Fitstake.Contract.FitstakeTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Fitstake *FitstakeCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Fitstake.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Fitstake *FitstakeTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Fitstake.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Fitstake *FitstakeTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Fitstake.Contract.contract.Transact(opts, method, params...)
}

// CanWithDrawFIG is a free data retrieval call binding the contract method 0x659c0b1b.
//
// Solidity: function canWithDrawFIG(uint256 stakeId) view returns(uint256 canWithdraw)
func (_Fitstake *FitstakeCaller) CanWithDrawFIG(opts *bind.CallOpts, stakeId *big.Int) (*big.Int, error) {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "canWithDrawFIG", stakeId)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// CanWithDrawFIG is a free data retrieval call binding the contract method 0x659c0b1b.
//
// Solidity: function canWithDrawFIG(uint256 stakeId) view returns(uint256 canWithdraw)
func (_Fitstake *FitstakeSession) CanWithDrawFIG(stakeId *big.Int) (*big.Int, error) {
	return _Fitstake.Contract.CanWithDrawFIG(&_Fitstake.CallOpts, stakeId)
}

// CanWithDrawFIG is a free data retrieval call binding the contract method 0x659c0b1b.
//
// Solidity: function canWithDrawFIG(uint256 stakeId) view returns(uint256 canWithdraw)
func (_Fitstake *FitstakeCallerSession) CanWithDrawFIG(stakeId *big.Int) (*big.Int, error) {
	return _Fitstake.Contract.CanWithDrawFIG(&_Fitstake.CallOpts, stakeId)
}

// CanWithdrawFIGAll is a free data retrieval call binding the contract method 0x1b40133c.
//
// Solidity: function canWithdrawFIGAll(address staker) view returns(uint256 withdrawn)
func (_Fitstake *FitstakeCaller) CanWithdrawFIGAll(opts *bind.CallOpts, staker common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "canWithdrawFIGAll", staker)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// CanWithdrawFIGAll is a free data retrieval call binding the contract method 0x1b40133c.
//
// Solidity: function canWithdrawFIGAll(address staker) view returns(uint256 withdrawn)
func (_Fitstake *FitstakeSession) CanWithdrawFIGAll(staker common.Address) (*big.Int, error) {
	return _Fitstake.Contract.CanWithdrawFIGAll(&_Fitstake.CallOpts, staker)
}

// CanWithdrawFIGAll is a free data retrieval call binding the contract method 0x1b40133c.
//
// Solidity: function canWithdrawFIGAll(address staker) view returns(uint256 withdrawn)
func (_Fitstake *FitstakeCallerSession) CanWithdrawFIGAll(staker common.Address) (*big.Int, error) {
	return _Fitstake.Contract.CanWithdrawFIGAll(&_Fitstake.CallOpts, staker)
}

// CheckGovernanceFactors is a free data retrieval call binding the contract method 0xdfda9e62.
//
// Solidity: function checkGovernanceFactors(uint256[] params) pure returns()
func (_Fitstake *FitstakeCaller) CheckGovernanceFactors(opts *bind.CallOpts, params []*big.Int) error {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "checkGovernanceFactors", params)

	if err != nil {
		return err
	}

	return err

}

// CheckGovernanceFactors is a free data retrieval call binding the contract method 0xdfda9e62.
//
// Solidity: function checkGovernanceFactors(uint256[] params) pure returns()
func (_Fitstake *FitstakeSession) CheckGovernanceFactors(params []*big.Int) error {
	return _Fitstake.Contract.CheckGovernanceFactors(&_Fitstake.CallOpts, params)
}

// CheckGovernanceFactors is a free data retrieval call binding the contract method 0xdfda9e62.
//
// Solidity: function checkGovernanceFactors(uint256[] params) pure returns()
func (_Fitstake *FitstakeCallerSession) CheckGovernanceFactors(params []*big.Int) error {
	return _Fitstake.Contract.CheckGovernanceFactors(&_Fitstake.CallOpts, params)
}

// GetAllFactors is a free data retrieval call binding the contract method 0xd37efa9c.
//
// Solidity: function getAllFactors() view returns(uint256[9] result)
func (_Fitstake *FitstakeCaller) GetAllFactors(opts *bind.CallOpts) ([9]*big.Int, error) {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "getAllFactors")

	if err != nil {
		return *new([9]*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new([9]*big.Int)).(*[9]*big.Int)

	return out0, err

}

// GetAllFactors is a free data retrieval call binding the contract method 0xd37efa9c.
//
// Solidity: function getAllFactors() view returns(uint256[9] result)
func (_Fitstake *FitstakeSession) GetAllFactors() ([9]*big.Int, error) {
	return _Fitstake.Contract.GetAllFactors(&_Fitstake.CallOpts)
}

// GetAllFactors is a free data retrieval call binding the contract method 0xd37efa9c.
//
// Solidity: function getAllFactors() view returns(uint256[9] result)
func (_Fitstake *FitstakeCallerSession) GetAllFactors() ([9]*big.Int, error) {
	return _Fitstake.Contract.GetAllFactors(&_Fitstake.CallOpts)
}

// GetContractAddrs is a free data retrieval call binding the contract method 0x892ebb42.
//
// Solidity: function getContractAddrs() view returns(address, address, address, address, address)
func (_Fitstake *FitstakeCaller) GetContractAddrs(opts *bind.CallOpts) (common.Address, common.Address, common.Address, common.Address, common.Address, error) {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "getContractAddrs")

	if err != nil {
		return *new(common.Address), *new(common.Address), *new(common.Address), *new(common.Address), *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)
	out1 := *abi.ConvertType(out[1], new(common.Address)).(*common.Address)
	out2 := *abi.ConvertType(out[2], new(common.Address)).(*common.Address)
	out3 := *abi.ConvertType(out[3], new(common.Address)).(*common.Address)
	out4 := *abi.ConvertType(out[4], new(common.Address)).(*common.Address)

	return out0, out1, out2, out3, out4, err

}

// GetContractAddrs is a free data retrieval call binding the contract method 0x892ebb42.
//
// Solidity: function getContractAddrs() view returns(address, address, address, address, address)
func (_Fitstake *FitstakeSession) GetContractAddrs() (common.Address, common.Address, common.Address, common.Address, common.Address, error) {
	return _Fitstake.Contract.GetContractAddrs(&_Fitstake.CallOpts)
}

// GetContractAddrs is a free data retrieval call binding the contract method 0x892ebb42.
//
// Solidity: function getContractAddrs() view returns(address, address, address, address, address)
func (_Fitstake *FitstakeCallerSession) GetContractAddrs() (common.Address, common.Address, common.Address, common.Address, common.Address, error) {
	return _Fitstake.Contract.GetContractAddrs(&_Fitstake.CallOpts)
}

// GetCurrentMintedFromInterest is a free data retrieval call binding the contract method 0x9c2f4074.
//
// Solidity: function getCurrentMintedFromInterest(uint256 amount) view returns(uint256, uint256)
func (_Fitstake *FitstakeCaller) GetCurrentMintedFromInterest(opts *bind.CallOpts, amount *big.Int) (*big.Int, *big.Int, error) {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "getCurrentMintedFromInterest", amount)

	if err != nil {
		return *new(*big.Int), *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)
	out1 := *abi.ConvertType(out[1], new(*big.Int)).(**big.Int)

	return out0, out1, err

}

// GetCurrentMintedFromInterest is a free data retrieval call binding the contract method 0x9c2f4074.
//
// Solidity: function getCurrentMintedFromInterest(uint256 amount) view returns(uint256, uint256)
func (_Fitstake *FitstakeSession) GetCurrentMintedFromInterest(amount *big.Int) (*big.Int, *big.Int, error) {
	return _Fitstake.Contract.GetCurrentMintedFromInterest(&_Fitstake.CallOpts, amount)
}

// GetCurrentMintedFromInterest is a free data retrieval call binding the contract method 0x9c2f4074.
//
// Solidity: function getCurrentMintedFromInterest(uint256 amount) view returns(uint256, uint256)
func (_Fitstake *FitstakeCallerSession) GetCurrentMintedFromInterest(amount *big.Int) (*big.Int, *big.Int, error) {
	return _Fitstake.Contract.GetCurrentMintedFromInterest(&_Fitstake.CallOpts, amount)
}

// GetCurrentMintedFromStake is a free data retrieval call binding the contract method 0x9b63e9e6.
//
// Solidity: function getCurrentMintedFromStake(uint256 stake, uint256 duration) view returns(uint256, uint256)
func (_Fitstake *FitstakeCaller) GetCurrentMintedFromStake(opts *bind.CallOpts, stake *big.Int, duration *big.Int) (*big.Int, *big.Int, error) {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "getCurrentMintedFromStake", stake, duration)

	if err != nil {
		return *new(*big.Int), *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)
	out1 := *abi.ConvertType(out[1], new(*big.Int)).(**big.Int)

	return out0, out1, err

}

// GetCurrentMintedFromStake is a free data retrieval call binding the contract method 0x9b63e9e6.
//
// Solidity: function getCurrentMintedFromStake(uint256 stake, uint256 duration) view returns(uint256, uint256)
func (_Fitstake *FitstakeSession) GetCurrentMintedFromStake(stake *big.Int, duration *big.Int) (*big.Int, *big.Int, error) {
	return _Fitstake.Contract.GetCurrentMintedFromStake(&_Fitstake.CallOpts, stake, duration)
}

// GetCurrentMintedFromStake is a free data retrieval call binding the contract method 0x9b63e9e6.
//
// Solidity: function getCurrentMintedFromStake(uint256 stake, uint256 duration) view returns(uint256, uint256)
func (_Fitstake *FitstakeCallerSession) GetCurrentMintedFromStake(stake *big.Int, duration *big.Int) (*big.Int, *big.Int, error) {
	return _Fitstake.Contract.GetCurrentMintedFromStake(&_Fitstake.CallOpts, stake, duration)
}

// GetStakeInfoById is a free data retrieval call binding the contract method 0xc5c75f28.
//
// Solidity: function getStakeInfoById(uint256 stakeId) view returns(((uint256,uint256,uint256,uint256,uint256,uint256),bool,uint256))
func (_Fitstake *FitstakeCaller) GetStakeInfoById(opts *bind.CallOpts, stakeId *big.Int) (FITStakeStakeInfo, error) {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "getStakeInfoById", stakeId)

	if err != nil {
		return *new(FITStakeStakeInfo), err
	}

	out0 := *abi.ConvertType(out[0], new(FITStakeStakeInfo)).(*FITStakeStakeInfo)

	return out0, err

}

// GetStakeInfoById is a free data retrieval call binding the contract method 0xc5c75f28.
//
// Solidity: function getStakeInfoById(uint256 stakeId) view returns(((uint256,uint256,uint256,uint256,uint256,uint256),bool,uint256))
func (_Fitstake *FitstakeSession) GetStakeInfoById(stakeId *big.Int) (FITStakeStakeInfo, error) {
	return _Fitstake.Contract.GetStakeInfoById(&_Fitstake.CallOpts, stakeId)
}

// GetStakeInfoById is a free data retrieval call binding the contract method 0xc5c75f28.
//
// Solidity: function getStakeInfoById(uint256 stakeId) view returns(((uint256,uint256,uint256,uint256,uint256,uint256),bool,uint256))
func (_Fitstake *FitstakeCallerSession) GetStakeInfoById(stakeId *big.Int) (FITStakeStakeInfo, error) {
	return _Fitstake.Contract.GetStakeInfoById(&_Fitstake.CallOpts, stakeId)
}

// GetStakeInfoByStakerAndId is a free data retrieval call binding the contract method 0xa29bb19d.
//
// Solidity: function getStakeInfoByStakerAndId(address staker, uint256 stakeId) view returns(((uint256,uint256,uint256,uint256,uint256,uint256),bool,uint256) result)
func (_Fitstake *FitstakeCaller) GetStakeInfoByStakerAndId(opts *bind.CallOpts, staker common.Address, stakeId *big.Int) (FITStakeStakeInfo, error) {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "getStakeInfoByStakerAndId", staker, stakeId)

	if err != nil {
		return *new(FITStakeStakeInfo), err
	}

	out0 := *abi.ConvertType(out[0], new(FITStakeStakeInfo)).(*FITStakeStakeInfo)

	return out0, err

}

// GetStakeInfoByStakerAndId is a free data retrieval call binding the contract method 0xa29bb19d.
//
// Solidity: function getStakeInfoByStakerAndId(address staker, uint256 stakeId) view returns(((uint256,uint256,uint256,uint256,uint256,uint256),bool,uint256) result)
func (_Fitstake *FitstakeSession) GetStakeInfoByStakerAndId(staker common.Address, stakeId *big.Int) (FITStakeStakeInfo, error) {
	return _Fitstake.Contract.GetStakeInfoByStakerAndId(&_Fitstake.CallOpts, staker, stakeId)
}

// GetStakeInfoByStakerAndId is a free data retrieval call binding the contract method 0xa29bb19d.
//
// Solidity: function getStakeInfoByStakerAndId(address staker, uint256 stakeId) view returns(((uint256,uint256,uint256,uint256,uint256,uint256),bool,uint256) result)
func (_Fitstake *FitstakeCallerSession) GetStakeInfoByStakerAndId(staker common.Address, stakeId *big.Int) (FITStakeStakeInfo, error) {
	return _Fitstake.Contract.GetStakeInfoByStakerAndId(&_Fitstake.CallOpts, staker, stakeId)
}

// GetStakerById is a free data retrieval call binding the contract method 0x08fcc606.
//
// Solidity: function getStakerById(uint256 stakeId) view returns(address)
func (_Fitstake *FitstakeCaller) GetStakerById(opts *bind.CallOpts, stakeId *big.Int) (common.Address, error) {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "getStakerById", stakeId)

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// GetStakerById is a free data retrieval call binding the contract method 0x08fcc606.
//
// Solidity: function getStakerById(uint256 stakeId) view returns(address)
func (_Fitstake *FitstakeSession) GetStakerById(stakeId *big.Int) (common.Address, error) {
	return _Fitstake.Contract.GetStakerById(&_Fitstake.CallOpts, stakeId)
}

// GetStakerById is a free data retrieval call binding the contract method 0x08fcc606.
//
// Solidity: function getStakerById(uint256 stakeId) view returns(address)
func (_Fitstake *FitstakeCallerSession) GetStakerById(stakeId *big.Int) (common.Address, error) {
	return _Fitstake.Contract.GetStakerById(&_Fitstake.CallOpts, stakeId)
}

// GetStakerStakes is a free data retrieval call binding the contract method 0x6765174e.
//
// Solidity: function getStakerStakes(address staker) view returns((address,uint256,uint256,uint256,uint256,uint256,((uint256,uint256,uint256,uint256,uint256,uint256),bool,uint256)[]) result)
func (_Fitstake *FitstakeCaller) GetStakerStakes(opts *bind.CallOpts, staker common.Address) (FITStakeStakerInfo, error) {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "getStakerStakes", staker)

	if err != nil {
		return *new(FITStakeStakerInfo), err
	}

	out0 := *abi.ConvertType(out[0], new(FITStakeStakerInfo)).(*FITStakeStakerInfo)

	return out0, err

}

// GetStakerStakes is a free data retrieval call binding the contract method 0x6765174e.
//
// Solidity: function getStakerStakes(address staker) view returns((address,uint256,uint256,uint256,uint256,uint256,((uint256,uint256,uint256,uint256,uint256,uint256),bool,uint256)[]) result)
func (_Fitstake *FitstakeSession) GetStakerStakes(staker common.Address) (FITStakeStakerInfo, error) {
	return _Fitstake.Contract.GetStakerStakes(&_Fitstake.CallOpts, staker)
}

// GetStakerStakes is a free data retrieval call binding the contract method 0x6765174e.
//
// Solidity: function getStakerStakes(address staker) view returns((address,uint256,uint256,uint256,uint256,uint256,((uint256,uint256,uint256,uint256,uint256,uint256),bool,uint256)[]) result)
func (_Fitstake *FitstakeCallerSession) GetStakerStakes(staker common.Address) (FITStakeStakerInfo, error) {
	return _Fitstake.Contract.GetStakerStakes(&_Fitstake.CallOpts, staker)
}

// GetStakerSum is a free data retrieval call binding the contract method 0x3b2eb298.
//
// Solidity: function getStakerSum(address staker) view returns(uint256)
func (_Fitstake *FitstakeCaller) GetStakerSum(opts *bind.CallOpts, staker common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "getStakerSum", staker)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetStakerSum is a free data retrieval call binding the contract method 0x3b2eb298.
//
// Solidity: function getStakerSum(address staker) view returns(uint256)
func (_Fitstake *FitstakeSession) GetStakerSum(staker common.Address) (*big.Int, error) {
	return _Fitstake.Contract.GetStakerSum(&_Fitstake.CallOpts, staker)
}

// GetStakerSum is a free data retrieval call binding the contract method 0x3b2eb298.
//
// Solidity: function getStakerSum(address staker) view returns(uint256)
func (_Fitstake *FitstakeCallerSession) GetStakerSum(staker common.Address) (*big.Int, error) {
	return _Fitstake.Contract.GetStakerSum(&_Fitstake.CallOpts, staker)
}

// GetStakerTerms is a free data retrieval call binding the contract method 0x8c04942b.
//
// Solidity: function getStakerTerms(address staker) view returns(uint256 stakeSum, uint256 totalFIGSum, uint256 releasedFIGSum, uint256 canWithdrawFITSum, uint256 canWithdrawFIGSum)
func (_Fitstake *FitstakeCaller) GetStakerTerms(opts *bind.CallOpts, staker common.Address) (struct {
	StakeSum          *big.Int
	TotalFIGSum       *big.Int
	ReleasedFIGSum    *big.Int
	CanWithdrawFITSum *big.Int
	CanWithdrawFIGSum *big.Int
}, error) {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "getStakerTerms", staker)

	outstruct := new(struct {
		StakeSum          *big.Int
		TotalFIGSum       *big.Int
		ReleasedFIGSum    *big.Int
		CanWithdrawFITSum *big.Int
		CanWithdrawFIGSum *big.Int
	})
	if err != nil {
		return *outstruct, err
	}

	outstruct.StakeSum = *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)
	outstruct.TotalFIGSum = *abi.ConvertType(out[1], new(*big.Int)).(**big.Int)
	outstruct.ReleasedFIGSum = *abi.ConvertType(out[2], new(*big.Int)).(**big.Int)
	outstruct.CanWithdrawFITSum = *abi.ConvertType(out[3], new(*big.Int)).(**big.Int)
	outstruct.CanWithdrawFIGSum = *abi.ConvertType(out[4], new(*big.Int)).(**big.Int)

	return *outstruct, err

}

// GetStakerTerms is a free data retrieval call binding the contract method 0x8c04942b.
//
// Solidity: function getStakerTerms(address staker) view returns(uint256 stakeSum, uint256 totalFIGSum, uint256 releasedFIGSum, uint256 canWithdrawFITSum, uint256 canWithdrawFIGSum)
func (_Fitstake *FitstakeSession) GetStakerTerms(staker common.Address) (struct {
	StakeSum          *big.Int
	TotalFIGSum       *big.Int
	ReleasedFIGSum    *big.Int
	CanWithdrawFITSum *big.Int
	CanWithdrawFIGSum *big.Int
}, error) {
	return _Fitstake.Contract.GetStakerTerms(&_Fitstake.CallOpts, staker)
}

// GetStakerTerms is a free data retrieval call binding the contract method 0x8c04942b.
//
// Solidity: function getStakerTerms(address staker) view returns(uint256 stakeSum, uint256 totalFIGSum, uint256 releasedFIGSum, uint256 canWithdrawFITSum, uint256 canWithdrawFIGSum)
func (_Fitstake *FitstakeCallerSession) GetStakerTerms(staker common.Address) (struct {
	StakeSum          *big.Int
	TotalFIGSum       *big.Int
	ReleasedFIGSum    *big.Int
	CanWithdrawFITSum *big.Int
	CanWithdrawFIGSum *big.Int
}, error) {
	return _Fitstake.Contract.GetStakerTerms(&_Fitstake.CallOpts, staker)
}

// GetStakersCount is a free data retrieval call binding the contract method 0x48284789.
//
// Solidity: function getStakersCount() view returns(uint256)
func (_Fitstake *FitstakeCaller) GetStakersCount(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "getStakersCount")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetStakersCount is a free data retrieval call binding the contract method 0x48284789.
//
// Solidity: function getStakersCount() view returns(uint256)
func (_Fitstake *FitstakeSession) GetStakersCount() (*big.Int, error) {
	return _Fitstake.Contract.GetStakersCount(&_Fitstake.CallOpts)
}

// GetStakersCount is a free data retrieval call binding the contract method 0x48284789.
//
// Solidity: function getStakersCount() view returns(uint256)
func (_Fitstake *FitstakeCallerSession) GetStakersCount() (*big.Int, error) {
	return _Fitstake.Contract.GetStakersCount(&_Fitstake.CallOpts)
}

// GetStakersSubset is a free data retrieval call binding the contract method 0x6ff647ee.
//
// Solidity: function getStakersSubset(uint256 start, uint256 end) view returns((address,uint256,uint256,uint256,uint256,uint256,((uint256,uint256,uint256,uint256,uint256,uint256),bool,uint256)[])[] result)
func (_Fitstake *FitstakeCaller) GetStakersSubset(opts *bind.CallOpts, start *big.Int, end *big.Int) ([]FITStakeStakerInfo, error) {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "getStakersSubset", start, end)

	if err != nil {
		return *new([]FITStakeStakerInfo), err
	}

	out0 := *abi.ConvertType(out[0], new([]FITStakeStakerInfo)).(*[]FITStakeStakerInfo)

	return out0, err

}

// GetStakersSubset is a free data retrieval call binding the contract method 0x6ff647ee.
//
// Solidity: function getStakersSubset(uint256 start, uint256 end) view returns((address,uint256,uint256,uint256,uint256,uint256,((uint256,uint256,uint256,uint256,uint256,uint256),bool,uint256)[])[] result)
func (_Fitstake *FitstakeSession) GetStakersSubset(start *big.Int, end *big.Int) ([]FITStakeStakerInfo, error) {
	return _Fitstake.Contract.GetStakersSubset(&_Fitstake.CallOpts, start, end)
}

// GetStakersSubset is a free data retrieval call binding the contract method 0x6ff647ee.
//
// Solidity: function getStakersSubset(uint256 start, uint256 end) view returns((address,uint256,uint256,uint256,uint256,uint256,((uint256,uint256,uint256,uint256,uint256,uint256),bool,uint256)[])[] result)
func (_Fitstake *FitstakeCallerSession) GetStakersSubset(start *big.Int, end *big.Int) ([]FITStakeStakerInfo, error) {
	return _Fitstake.Contract.GetStakersSubset(&_Fitstake.CallOpts, start, end)
}

// GetStatus is a free data retrieval call binding the contract method 0x4e69d560.
//
// Solidity: function getStatus() view returns((uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256))
func (_Fitstake *FitstakeCaller) GetStatus(opts *bind.CallOpts) (FITStakeFITStakeInfo, error) {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "getStatus")

	if err != nil {
		return *new(FITStakeFITStakeInfo), err
	}

	out0 := *abi.ConvertType(out[0], new(FITStakeFITStakeInfo)).(*FITStakeFITStakeInfo)

	return out0, err

}

// GetStatus is a free data retrieval call binding the contract method 0x4e69d560.
//
// Solidity: function getStatus() view returns((uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256))
func (_Fitstake *FitstakeSession) GetStatus() (FITStakeFITStakeInfo, error) {
	return _Fitstake.Contract.GetStatus(&_Fitstake.CallOpts)
}

// GetStatus is a free data retrieval call binding the contract method 0x4e69d560.
//
// Solidity: function getStatus() view returns((uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256))
func (_Fitstake *FitstakeCallerSession) GetStatus() (FITStakeFITStakeInfo, error) {
	return _Fitstake.Contract.GetStatus(&_Fitstake.CallOpts)
}

// OnceStaked is a free data retrieval call binding the contract method 0x62773316.
//
// Solidity: function onceStaked(address staker) view returns(bool)
func (_Fitstake *FitstakeCaller) OnceStaked(opts *bind.CallOpts, staker common.Address) (bool, error) {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "onceStaked", staker)

	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err

}

// OnceStaked is a free data retrieval call binding the contract method 0x62773316.
//
// Solidity: function onceStaked(address staker) view returns(bool)
func (_Fitstake *FitstakeSession) OnceStaked(staker common.Address) (bool, error) {
	return _Fitstake.Contract.OnceStaked(&_Fitstake.CallOpts, staker)
}

// OnceStaked is a free data retrieval call binding the contract method 0x62773316.
//
// Solidity: function onceStaked(address staker) view returns(bool)
func (_Fitstake *FitstakeCallerSession) OnceStaked(staker common.Address) (bool, error) {
	return _Fitstake.Contract.OnceStaked(&_Fitstake.CallOpts, staker)
}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_Fitstake *FitstakeCaller) Owner(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _Fitstake.contract.Call(opts, &out, "owner")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_Fitstake *FitstakeSession) Owner() (common.Address, error) {
	return _Fitstake.Contract.Owner(&_Fitstake.CallOpts)
}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_Fitstake *FitstakeCallerSession) Owner() (common.Address, error) {
	return _Fitstake.Contract.Owner(&_Fitstake.CallOpts)
}

// HandleInterest is a paid mutator transaction binding the contract method 0xf45ce017.
//
// Solidity: function handleInterest(address minter, uint256 principal, uint256 interest) returns(uint256 minted)
func (_Fitstake *FitstakeTransactor) HandleInterest(opts *bind.TransactOpts, minter common.Address, principal *big.Int, interest *big.Int) (*types.Transaction, error) {
	return _Fitstake.contract.Transact(opts, "handleInterest", minter, principal, interest)
}

// HandleInterest is a paid mutator transaction binding the contract method 0xf45ce017.
//
// Solidity: function handleInterest(address minter, uint256 principal, uint256 interest) returns(uint256 minted)
func (_Fitstake *FitstakeSession) HandleInterest(minter common.Address, principal *big.Int, interest *big.Int) (*types.Transaction, error) {
	return _Fitstake.Contract.HandleInterest(&_Fitstake.TransactOpts, minter, principal, interest)
}

// HandleInterest is a paid mutator transaction binding the contract method 0xf45ce017.
//
// Solidity: function handleInterest(address minter, uint256 principal, uint256 interest) returns(uint256 minted)
func (_Fitstake *FitstakeTransactorSession) HandleInterest(minter common.Address, principal *big.Int, interest *big.Int) (*types.Transaction, error) {
	return _Fitstake.Contract.HandleInterest(&_Fitstake.TransactOpts, minter, principal, interest)
}

// SetContractAddrs is a paid mutator transaction binding the contract method 0x4d72b345.
//
// Solidity: function setContractAddrs(address new_filLiquid, address new_governance, address new_tokenFILTrust, address new_calculation, address new_tokenFILGovernance) returns()
func (_Fitstake *FitstakeTransactor) SetContractAddrs(opts *bind.TransactOpts, new_filLiquid common.Address, new_governance common.Address, new_tokenFILTrust common.Address, new_calculation common.Address, new_tokenFILGovernance common.Address) (*types.Transaction, error) {
	return _Fitstake.contract.Transact(opts, "setContractAddrs", new_filLiquid, new_governance, new_tokenFILTrust, new_calculation, new_tokenFILGovernance)
}

// SetContractAddrs is a paid mutator transaction binding the contract method 0x4d72b345.
//
// Solidity: function setContractAddrs(address new_filLiquid, address new_governance, address new_tokenFILTrust, address new_calculation, address new_tokenFILGovernance) returns()
func (_Fitstake *FitstakeSession) SetContractAddrs(new_filLiquid common.Address, new_governance common.Address, new_tokenFILTrust common.Address, new_calculation common.Address, new_tokenFILGovernance common.Address) (*types.Transaction, error) {
	return _Fitstake.Contract.SetContractAddrs(&_Fitstake.TransactOpts, new_filLiquid, new_governance, new_tokenFILTrust, new_calculation, new_tokenFILGovernance)
}

// SetContractAddrs is a paid mutator transaction binding the contract method 0x4d72b345.
//
// Solidity: function setContractAddrs(address new_filLiquid, address new_governance, address new_tokenFILTrust, address new_calculation, address new_tokenFILGovernance) returns()
func (_Fitstake *FitstakeTransactorSession) SetContractAddrs(new_filLiquid common.Address, new_governance common.Address, new_tokenFILTrust common.Address, new_calculation common.Address, new_tokenFILGovernance common.Address) (*types.Transaction, error) {
	return _Fitstake.Contract.SetContractAddrs(&_Fitstake.TransactOpts, new_filLiquid, new_governance, new_tokenFILTrust, new_calculation, new_tokenFILGovernance)
}

// SetGovernanceFactors is a paid mutator transaction binding the contract method 0xe815b8c4.
//
// Solidity: function setGovernanceFactors(uint256[] params) returns()
func (_Fitstake *FitstakeTransactor) SetGovernanceFactors(opts *bind.TransactOpts, params []*big.Int) (*types.Transaction, error) {
	return _Fitstake.contract.Transact(opts, "setGovernanceFactors", params)
}

// SetGovernanceFactors is a paid mutator transaction binding the contract method 0xe815b8c4.
//
// Solidity: function setGovernanceFactors(uint256[] params) returns()
func (_Fitstake *FitstakeSession) SetGovernanceFactors(params []*big.Int) (*types.Transaction, error) {
	return _Fitstake.Contract.SetGovernanceFactors(&_Fitstake.TransactOpts, params)
}

// SetGovernanceFactors is a paid mutator transaction binding the contract method 0xe815b8c4.
//
// Solidity: function setGovernanceFactors(uint256[] params) returns()
func (_Fitstake *FitstakeTransactorSession) SetGovernanceFactors(params []*big.Int) (*types.Transaction, error) {
	return _Fitstake.Contract.SetGovernanceFactors(&_Fitstake.TransactOpts, params)
}

// SetOwner is a paid mutator transaction binding the contract method 0x13af4035.
//
// Solidity: function setOwner(address new_owner) returns()
func (_Fitstake *FitstakeTransactor) SetOwner(opts *bind.TransactOpts, new_owner common.Address) (*types.Transaction, error) {
	return _Fitstake.contract.Transact(opts, "setOwner", new_owner)
}

// SetOwner is a paid mutator transaction binding the contract method 0x13af4035.
//
// Solidity: function setOwner(address new_owner) returns()
func (_Fitstake *FitstakeSession) SetOwner(new_owner common.Address) (*types.Transaction, error) {
	return _Fitstake.Contract.SetOwner(&_Fitstake.TransactOpts, new_owner)
}

// SetOwner is a paid mutator transaction binding the contract method 0x13af4035.
//
// Solidity: function setOwner(address new_owner) returns()
func (_Fitstake *FitstakeTransactorSession) SetOwner(new_owner common.Address) (*types.Transaction, error) {
	return _Fitstake.Contract.SetOwner(&_Fitstake.TransactOpts, new_owner)
}

// SetShares is a paid mutator transaction binding the contract method 0xa0885e93.
//
// Solidity: function setShares(uint256 new_rateBase, uint256 new_interest_share, uint256 new_stake_share) returns()
func (_Fitstake *FitstakeTransactor) SetShares(opts *bind.TransactOpts, new_rateBase *big.Int, new_interest_share *big.Int, new_stake_share *big.Int) (*types.Transaction, error) {
	return _Fitstake.contract.Transact(opts, "setShares", new_rateBase, new_interest_share, new_stake_share)
}

// SetShares is a paid mutator transaction binding the contract method 0xa0885e93.
//
// Solidity: function setShares(uint256 new_rateBase, uint256 new_interest_share, uint256 new_stake_share) returns()
func (_Fitstake *FitstakeSession) SetShares(new_rateBase *big.Int, new_interest_share *big.Int, new_stake_share *big.Int) (*types.Transaction, error) {
	return _Fitstake.Contract.SetShares(&_Fitstake.TransactOpts, new_rateBase, new_interest_share, new_stake_share)
}

// SetShares is a paid mutator transaction binding the contract method 0xa0885e93.
//
// Solidity: function setShares(uint256 new_rateBase, uint256 new_interest_share, uint256 new_stake_share) returns()
func (_Fitstake *FitstakeTransactorSession) SetShares(new_rateBase *big.Int, new_interest_share *big.Int, new_stake_share *big.Int) (*types.Transaction, error) {
	return _Fitstake.Contract.SetShares(&_Fitstake.TransactOpts, new_rateBase, new_interest_share, new_stake_share)
}

// SetStakeParams is a paid mutator transaction binding the contract method 0xff61ff06.
//
// Solidity: function setStakeParams(uint256 new_minStakePeriod, uint256 new_maxStakePeriod, uint256 new_minStake, uint256 new_maxStakes) returns()
func (_Fitstake *FitstakeTransactor) SetStakeParams(opts *bind.TransactOpts, new_minStakePeriod *big.Int, new_maxStakePeriod *big.Int, new_minStake *big.Int, new_maxStakes *big.Int) (*types.Transaction, error) {
	return _Fitstake.contract.Transact(opts, "setStakeParams", new_minStakePeriod, new_maxStakePeriod, new_minStake, new_maxStakes)
}

// SetStakeParams is a paid mutator transaction binding the contract method 0xff61ff06.
//
// Solidity: function setStakeParams(uint256 new_minStakePeriod, uint256 new_maxStakePeriod, uint256 new_minStake, uint256 new_maxStakes) returns()
func (_Fitstake *FitstakeSession) SetStakeParams(new_minStakePeriod *big.Int, new_maxStakePeriod *big.Int, new_minStake *big.Int, new_maxStakes *big.Int) (*types.Transaction, error) {
	return _Fitstake.Contract.SetStakeParams(&_Fitstake.TransactOpts, new_minStakePeriod, new_maxStakePeriod, new_minStake, new_maxStakes)
}

// SetStakeParams is a paid mutator transaction binding the contract method 0xff61ff06.
//
// Solidity: function setStakeParams(uint256 new_minStakePeriod, uint256 new_maxStakePeriod, uint256 new_minStake, uint256 new_maxStakes) returns()
func (_Fitstake *FitstakeTransactorSession) SetStakeParams(new_minStakePeriod *big.Int, new_maxStakePeriod *big.Int, new_minStake *big.Int, new_maxStakes *big.Int) (*types.Transaction, error) {
	return _Fitstake.Contract.SetStakeParams(&_Fitstake.TransactOpts, new_minStakePeriod, new_maxStakePeriod, new_minStake, new_maxStakes)
}

// StakeFilTrust is a paid mutator transaction binding the contract method 0xd5b3d76d.
//
// Solidity: function stakeFilTrust(uint256 amount, uint256 maxStart, uint256 duration) returns(uint256 minted)
func (_Fitstake *FitstakeTransactor) StakeFilTrust(opts *bind.TransactOpts, amount *big.Int, maxStart *big.Int, duration *big.Int) (*types.Transaction, error) {
	return _Fitstake.contract.Transact(opts, "stakeFilTrust", amount, maxStart, duration)
}

// StakeFilTrust is a paid mutator transaction binding the contract method 0xd5b3d76d.
//
// Solidity: function stakeFilTrust(uint256 amount, uint256 maxStart, uint256 duration) returns(uint256 minted)
func (_Fitstake *FitstakeSession) StakeFilTrust(amount *big.Int, maxStart *big.Int, duration *big.Int) (*types.Transaction, error) {
	return _Fitstake.Contract.StakeFilTrust(&_Fitstake.TransactOpts, amount, maxStart, duration)
}

// StakeFilTrust is a paid mutator transaction binding the contract method 0xd5b3d76d.
//
// Solidity: function stakeFilTrust(uint256 amount, uint256 maxStart, uint256 duration) returns(uint256 minted)
func (_Fitstake *FitstakeTransactorSession) StakeFilTrust(amount *big.Int, maxStart *big.Int, duration *big.Int) (*types.Transaction, error) {
	return _Fitstake.Contract.StakeFilTrust(&_Fitstake.TransactOpts, amount, maxStart, duration)
}

// UnStakeFilTrust is a paid mutator transaction binding the contract method 0x9ba3d7ed.
//
// Solidity: function unStakeFilTrust(uint256 stakeId) returns(uint256 minted, uint256 withdrawnFIG)
func (_Fitstake *FitstakeTransactor) UnStakeFilTrust(opts *bind.TransactOpts, stakeId *big.Int) (*types.Transaction, error) {
	return _Fitstake.contract.Transact(opts, "unStakeFilTrust", stakeId)
}

// UnStakeFilTrust is a paid mutator transaction binding the contract method 0x9ba3d7ed.
//
// Solidity: function unStakeFilTrust(uint256 stakeId) returns(uint256 minted, uint256 withdrawnFIG)
func (_Fitstake *FitstakeSession) UnStakeFilTrust(stakeId *big.Int) (*types.Transaction, error) {
	return _Fitstake.Contract.UnStakeFilTrust(&_Fitstake.TransactOpts, stakeId)
}

// UnStakeFilTrust is a paid mutator transaction binding the contract method 0x9ba3d7ed.
//
// Solidity: function unStakeFilTrust(uint256 stakeId) returns(uint256 minted, uint256 withdrawnFIG)
func (_Fitstake *FitstakeTransactorSession) UnStakeFilTrust(stakeId *big.Int) (*types.Transaction, error) {
	return _Fitstake.Contract.UnStakeFilTrust(&_Fitstake.TransactOpts, stakeId)
}

// WithdrawFIG is a paid mutator transaction binding the contract method 0x6280e40c.
//
// Solidity: function withdrawFIG(uint256 stakeId) returns(uint256 withdrawn)
func (_Fitstake *FitstakeTransactor) WithdrawFIG(opts *bind.TransactOpts, stakeId *big.Int) (*types.Transaction, error) {
	return _Fitstake.contract.Transact(opts, "withdrawFIG", stakeId)
}

// WithdrawFIG is a paid mutator transaction binding the contract method 0x6280e40c.
//
// Solidity: function withdrawFIG(uint256 stakeId) returns(uint256 withdrawn)
func (_Fitstake *FitstakeSession) WithdrawFIG(stakeId *big.Int) (*types.Transaction, error) {
	return _Fitstake.Contract.WithdrawFIG(&_Fitstake.TransactOpts, stakeId)
}

// WithdrawFIG is a paid mutator transaction binding the contract method 0x6280e40c.
//
// Solidity: function withdrawFIG(uint256 stakeId) returns(uint256 withdrawn)
func (_Fitstake *FitstakeTransactorSession) WithdrawFIG(stakeId *big.Int) (*types.Transaction, error) {
	return _Fitstake.Contract.WithdrawFIG(&_Fitstake.TransactOpts, stakeId)
}

// WithdrawFIGAll is a paid mutator transaction binding the contract method 0x7b788341.
//
// Solidity: function withdrawFIGAll() returns(uint256 withdrawn)
func (_Fitstake *FitstakeTransactor) WithdrawFIGAll(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Fitstake.contract.Transact(opts, "withdrawFIGAll")
}

// WithdrawFIGAll is a paid mutator transaction binding the contract method 0x7b788341.
//
// Solidity: function withdrawFIGAll() returns(uint256 withdrawn)
func (_Fitstake *FitstakeSession) WithdrawFIGAll() (*types.Transaction, error) {
	return _Fitstake.Contract.WithdrawFIGAll(&_Fitstake.TransactOpts)
}

// WithdrawFIGAll is a paid mutator transaction binding the contract method 0x7b788341.
//
// Solidity: function withdrawFIGAll() returns(uint256 withdrawn)
func (_Fitstake *FitstakeTransactorSession) WithdrawFIGAll() (*types.Transaction, error) {
	return _Fitstake.Contract.WithdrawFIGAll(&_Fitstake.TransactOpts)
}

// FitstakeContractAddrsChangedIterator is returned from FilterContractAddrsChanged and is used to iterate over the raw logs and unpacked data for ContractAddrsChanged events raised by the Fitstake contract.
type FitstakeContractAddrsChangedIterator struct {
	Event *FitstakeContractAddrsChanged // Event containing the contract specifics and raw log

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
func (it *FitstakeContractAddrsChangedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(FitstakeContractAddrsChanged)
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
		it.Event = new(FitstakeContractAddrsChanged)
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
func (it *FitstakeContractAddrsChangedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *FitstakeContractAddrsChangedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// FitstakeContractAddrsChanged represents a ContractAddrsChanged event raised by the Fitstake contract.
type FitstakeContractAddrsChanged struct {
	NewFilLiquid          common.Address
	NewGovernance         common.Address
	NewTokenFILTrust      common.Address
	NewCalculation        common.Address
	NewTokenFILGovernance common.Address
	Raw                   types.Log // Blockchain specific contextual infos
}

// FilterContractAddrsChanged is a free log retrieval operation binding the contract event 0x6606884445b883dcb132e71ffec2edf6859aec558df09709cd72274eca2ade7d.
//
// Solidity: event ContractAddrsChanged(address new_filLiquid, address new_governance, address new_tokenFILTrust, address new_calculation, address new_tokenFILGovernance)
func (_Fitstake *FitstakeFilterer) FilterContractAddrsChanged(opts *bind.FilterOpts) (*FitstakeContractAddrsChangedIterator, error) {

	logs, sub, err := _Fitstake.contract.FilterLogs(opts, "ContractAddrsChanged")
	if err != nil {
		return nil, err
	}
	return &FitstakeContractAddrsChangedIterator{contract: _Fitstake.contract, event: "ContractAddrsChanged", logs: logs, sub: sub}, nil
}

// WatchContractAddrsChanged is a free log subscription operation binding the contract event 0x6606884445b883dcb132e71ffec2edf6859aec558df09709cd72274eca2ade7d.
//
// Solidity: event ContractAddrsChanged(address new_filLiquid, address new_governance, address new_tokenFILTrust, address new_calculation, address new_tokenFILGovernance)
func (_Fitstake *FitstakeFilterer) WatchContractAddrsChanged(opts *bind.WatchOpts, sink chan<- *FitstakeContractAddrsChanged) (event.Subscription, error) {

	logs, sub, err := _Fitstake.contract.WatchLogs(opts, "ContractAddrsChanged")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(FitstakeContractAddrsChanged)
				if err := _Fitstake.contract.UnpackLog(event, "ContractAddrsChanged", log); err != nil {
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

// ParseContractAddrsChanged is a log parse operation binding the contract event 0x6606884445b883dcb132e71ffec2edf6859aec558df09709cd72274eca2ade7d.
//
// Solidity: event ContractAddrsChanged(address new_filLiquid, address new_governance, address new_tokenFILTrust, address new_calculation, address new_tokenFILGovernance)
func (_Fitstake *FitstakeFilterer) ParseContractAddrsChanged(log types.Log) (*FitstakeContractAddrsChanged, error) {
	event := new(FitstakeContractAddrsChanged)
	if err := _Fitstake.contract.UnpackLog(event, "ContractAddrsChanged", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// FitstakeGovernanceFactorsChangedIterator is returned from FilterGovernanceFactorsChanged and is used to iterate over the raw logs and unpacked data for GovernanceFactorsChanged events raised by the Fitstake contract.
type FitstakeGovernanceFactorsChangedIterator struct {
	Event *FitstakeGovernanceFactorsChanged // Event containing the contract specifics and raw log

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
func (it *FitstakeGovernanceFactorsChangedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(FitstakeGovernanceFactorsChanged)
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
		it.Event = new(FitstakeGovernanceFactorsChanged)
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
func (it *FitstakeGovernanceFactorsChangedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *FitstakeGovernanceFactorsChangedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// FitstakeGovernanceFactorsChanged represents a GovernanceFactorsChanged event raised by the Fitstake contract.
type FitstakeGovernanceFactorsChanged struct {
	NInterest *big.Int
	NStake    *big.Int
	Raw       types.Log // Blockchain specific contextual infos
}

// FilterGovernanceFactorsChanged is a free log retrieval operation binding the contract event 0x973646b36ee6d7e09bb7cb9baee317ae48032cd2da5b3f9d9c1fec689c4da15f.
//
// Solidity: event GovernanceFactorsChanged(uint256 _n_interest, uint256 _n_stake)
func (_Fitstake *FitstakeFilterer) FilterGovernanceFactorsChanged(opts *bind.FilterOpts) (*FitstakeGovernanceFactorsChangedIterator, error) {

	logs, sub, err := _Fitstake.contract.FilterLogs(opts, "GovernanceFactorsChanged")
	if err != nil {
		return nil, err
	}
	return &FitstakeGovernanceFactorsChangedIterator{contract: _Fitstake.contract, event: "GovernanceFactorsChanged", logs: logs, sub: sub}, nil
}

// WatchGovernanceFactorsChanged is a free log subscription operation binding the contract event 0x973646b36ee6d7e09bb7cb9baee317ae48032cd2da5b3f9d9c1fec689c4da15f.
//
// Solidity: event GovernanceFactorsChanged(uint256 _n_interest, uint256 _n_stake)
func (_Fitstake *FitstakeFilterer) WatchGovernanceFactorsChanged(opts *bind.WatchOpts, sink chan<- *FitstakeGovernanceFactorsChanged) (event.Subscription, error) {

	logs, sub, err := _Fitstake.contract.WatchLogs(opts, "GovernanceFactorsChanged")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(FitstakeGovernanceFactorsChanged)
				if err := _Fitstake.contract.UnpackLog(event, "GovernanceFactorsChanged", log); err != nil {
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

// ParseGovernanceFactorsChanged is a log parse operation binding the contract event 0x973646b36ee6d7e09bb7cb9baee317ae48032cd2da5b3f9d9c1fec689c4da15f.
//
// Solidity: event GovernanceFactorsChanged(uint256 _n_interest, uint256 _n_stake)
func (_Fitstake *FitstakeFilterer) ParseGovernanceFactorsChanged(log types.Log) (*FitstakeGovernanceFactorsChanged, error) {
	event := new(FitstakeGovernanceFactorsChanged)
	if err := _Fitstake.contract.UnpackLog(event, "GovernanceFactorsChanged", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// FitstakeInterestIterator is returned from FilterInterest and is used to iterate over the raw logs and unpacked data for Interest events raised by the Fitstake contract.
type FitstakeInterestIterator struct {
	Event *FitstakeInterest // Event containing the contract specifics and raw log

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
func (it *FitstakeInterestIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(FitstakeInterest)
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
		it.Event = new(FitstakeInterest)
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
func (it *FitstakeInterestIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *FitstakeInterestIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// FitstakeInterest represents a Interest event raised by the Fitstake contract.
type FitstakeInterest struct {
	Minter    common.Address
	Principal *big.Int
	Interest  *big.Int
	Minted    *big.Int
	Raw       types.Log // Blockchain specific contextual infos
}

// FilterInterest is a free log retrieval operation binding the contract event 0xa08aac37e477d2f18e6d73657977d05397d642e9fd61dc8da3e6741c7c1223df.
//
// Solidity: event Interest(address indexed minter, uint256 principal, uint256 interest, uint256 minted)
func (_Fitstake *FitstakeFilterer) FilterInterest(opts *bind.FilterOpts, minter []common.Address) (*FitstakeInterestIterator, error) {

	var minterRule []interface{}
	for _, minterItem := range minter {
		minterRule = append(minterRule, minterItem)
	}

	logs, sub, err := _Fitstake.contract.FilterLogs(opts, "Interest", minterRule)
	if err != nil {
		return nil, err
	}
	return &FitstakeInterestIterator{contract: _Fitstake.contract, event: "Interest", logs: logs, sub: sub}, nil
}

// WatchInterest is a free log subscription operation binding the contract event 0xa08aac37e477d2f18e6d73657977d05397d642e9fd61dc8da3e6741c7c1223df.
//
// Solidity: event Interest(address indexed minter, uint256 principal, uint256 interest, uint256 minted)
func (_Fitstake *FitstakeFilterer) WatchInterest(opts *bind.WatchOpts, sink chan<- *FitstakeInterest, minter []common.Address) (event.Subscription, error) {

	var minterRule []interface{}
	for _, minterItem := range minter {
		minterRule = append(minterRule, minterItem)
	}

	logs, sub, err := _Fitstake.contract.WatchLogs(opts, "Interest", minterRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(FitstakeInterest)
				if err := _Fitstake.contract.UnpackLog(event, "Interest", log); err != nil {
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

// ParseInterest is a log parse operation binding the contract event 0xa08aac37e477d2f18e6d73657977d05397d642e9fd61dc8da3e6741c7c1223df.
//
// Solidity: event Interest(address indexed minter, uint256 principal, uint256 interest, uint256 minted)
func (_Fitstake *FitstakeFilterer) ParseInterest(log types.Log) (*FitstakeInterest, error) {
	event := new(FitstakeInterest)
	if err := _Fitstake.contract.UnpackLog(event, "Interest", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// FitstakeOwnerChangedIterator is returned from FilterOwnerChanged and is used to iterate over the raw logs and unpacked data for OwnerChanged events raised by the Fitstake contract.
type FitstakeOwnerChangedIterator struct {
	Event *FitstakeOwnerChanged // Event containing the contract specifics and raw log

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
func (it *FitstakeOwnerChangedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(FitstakeOwnerChanged)
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
		it.Event = new(FitstakeOwnerChanged)
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
func (it *FitstakeOwnerChangedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *FitstakeOwnerChangedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// FitstakeOwnerChanged represents a OwnerChanged event raised by the Fitstake contract.
type FitstakeOwnerChanged struct {
	NewOwner common.Address
	Raw      types.Log // Blockchain specific contextual infos
}

// FilterOwnerChanged is a free log retrieval operation binding the contract event 0xa2ea9883a321a3e97b8266c2b078bfeec6d50c711ed71f874a90d500ae2eaf36.
//
// Solidity: event OwnerChanged(address new_owner)
func (_Fitstake *FitstakeFilterer) FilterOwnerChanged(opts *bind.FilterOpts) (*FitstakeOwnerChangedIterator, error) {

	logs, sub, err := _Fitstake.contract.FilterLogs(opts, "OwnerChanged")
	if err != nil {
		return nil, err
	}
	return &FitstakeOwnerChangedIterator{contract: _Fitstake.contract, event: "OwnerChanged", logs: logs, sub: sub}, nil
}

// WatchOwnerChanged is a free log subscription operation binding the contract event 0xa2ea9883a321a3e97b8266c2b078bfeec6d50c711ed71f874a90d500ae2eaf36.
//
// Solidity: event OwnerChanged(address new_owner)
func (_Fitstake *FitstakeFilterer) WatchOwnerChanged(opts *bind.WatchOpts, sink chan<- *FitstakeOwnerChanged) (event.Subscription, error) {

	logs, sub, err := _Fitstake.contract.WatchLogs(opts, "OwnerChanged")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(FitstakeOwnerChanged)
				if err := _Fitstake.contract.UnpackLog(event, "OwnerChanged", log); err != nil {
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
// Solidity: event OwnerChanged(address new_owner)
func (_Fitstake *FitstakeFilterer) ParseOwnerChanged(log types.Log) (*FitstakeOwnerChanged, error) {
	event := new(FitstakeOwnerChanged)
	if err := _Fitstake.contract.UnpackLog(event, "OwnerChanged", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// FitstakeSharesChangedIterator is returned from FilterSharesChanged and is used to iterate over the raw logs and unpacked data for SharesChanged events raised by the Fitstake contract.
type FitstakeSharesChangedIterator struct {
	Event *FitstakeSharesChanged // Event containing the contract specifics and raw log

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
func (it *FitstakeSharesChangedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(FitstakeSharesChanged)
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
		it.Event = new(FitstakeSharesChanged)
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
func (it *FitstakeSharesChangedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *FitstakeSharesChangedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// FitstakeSharesChanged represents a SharesChanged event raised by the Fitstake contract.
type FitstakeSharesChanged struct {
	NewRateBase      *big.Int
	NewInterestShare *big.Int
	NewStakeShare    *big.Int
	Raw              types.Log // Blockchain specific contextual infos
}

// FilterSharesChanged is a free log retrieval operation binding the contract event 0x5dbe3f8291ed28d19bf6ac90515442cd25d74c94f0f783a91ec56affea1ee1aa.
//
// Solidity: event SharesChanged(uint256 new_rateBase, uint256 new_interest_share, uint256 new_stake_share)
func (_Fitstake *FitstakeFilterer) FilterSharesChanged(opts *bind.FilterOpts) (*FitstakeSharesChangedIterator, error) {

	logs, sub, err := _Fitstake.contract.FilterLogs(opts, "SharesChanged")
	if err != nil {
		return nil, err
	}
	return &FitstakeSharesChangedIterator{contract: _Fitstake.contract, event: "SharesChanged", logs: logs, sub: sub}, nil
}

// WatchSharesChanged is a free log subscription operation binding the contract event 0x5dbe3f8291ed28d19bf6ac90515442cd25d74c94f0f783a91ec56affea1ee1aa.
//
// Solidity: event SharesChanged(uint256 new_rateBase, uint256 new_interest_share, uint256 new_stake_share)
func (_Fitstake *FitstakeFilterer) WatchSharesChanged(opts *bind.WatchOpts, sink chan<- *FitstakeSharesChanged) (event.Subscription, error) {

	logs, sub, err := _Fitstake.contract.WatchLogs(opts, "SharesChanged")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(FitstakeSharesChanged)
				if err := _Fitstake.contract.UnpackLog(event, "SharesChanged", log); err != nil {
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

// ParseSharesChanged is a log parse operation binding the contract event 0x5dbe3f8291ed28d19bf6ac90515442cd25d74c94f0f783a91ec56affea1ee1aa.
//
// Solidity: event SharesChanged(uint256 new_rateBase, uint256 new_interest_share, uint256 new_stake_share)
func (_Fitstake *FitstakeFilterer) ParseSharesChanged(log types.Log) (*FitstakeSharesChanged, error) {
	event := new(FitstakeSharesChanged)
	if err := _Fitstake.contract.UnpackLog(event, "SharesChanged", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// FitstakeStakeParamsChangedIterator is returned from FilterStakeParamsChanged and is used to iterate over the raw logs and unpacked data for StakeParamsChanged events raised by the Fitstake contract.
type FitstakeStakeParamsChangedIterator struct {
	Event *FitstakeStakeParamsChanged // Event containing the contract specifics and raw log

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
func (it *FitstakeStakeParamsChangedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(FitstakeStakeParamsChanged)
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
		it.Event = new(FitstakeStakeParamsChanged)
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
func (it *FitstakeStakeParamsChangedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *FitstakeStakeParamsChangedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// FitstakeStakeParamsChanged represents a StakeParamsChanged event raised by the Fitstake contract.
type FitstakeStakeParamsChanged struct {
	NewMinStakePeriod *big.Int
	NewMaxStakePeriod *big.Int
	NewMinStake       *big.Int
	NewMaxStakes      *big.Int
	Raw               types.Log // Blockchain specific contextual infos
}

// FilterStakeParamsChanged is a free log retrieval operation binding the contract event 0x54cdf2353042a1173fc2a03059a110eb378fa7e80f4ba104e3830cd105aeadcd.
//
// Solidity: event StakeParamsChanged(uint256 new_minStakePeriod, uint256 new_maxStakePeriod, uint256 new_minStake, uint256 new_maxStakes)
func (_Fitstake *FitstakeFilterer) FilterStakeParamsChanged(opts *bind.FilterOpts) (*FitstakeStakeParamsChangedIterator, error) {

	logs, sub, err := _Fitstake.contract.FilterLogs(opts, "StakeParamsChanged")
	if err != nil {
		return nil, err
	}
	return &FitstakeStakeParamsChangedIterator{contract: _Fitstake.contract, event: "StakeParamsChanged", logs: logs, sub: sub}, nil
}

// WatchStakeParamsChanged is a free log subscription operation binding the contract event 0x54cdf2353042a1173fc2a03059a110eb378fa7e80f4ba104e3830cd105aeadcd.
//
// Solidity: event StakeParamsChanged(uint256 new_minStakePeriod, uint256 new_maxStakePeriod, uint256 new_minStake, uint256 new_maxStakes)
func (_Fitstake *FitstakeFilterer) WatchStakeParamsChanged(opts *bind.WatchOpts, sink chan<- *FitstakeStakeParamsChanged) (event.Subscription, error) {

	logs, sub, err := _Fitstake.contract.WatchLogs(opts, "StakeParamsChanged")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(FitstakeStakeParamsChanged)
				if err := _Fitstake.contract.UnpackLog(event, "StakeParamsChanged", log); err != nil {
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

// ParseStakeParamsChanged is a log parse operation binding the contract event 0x54cdf2353042a1173fc2a03059a110eb378fa7e80f4ba104e3830cd105aeadcd.
//
// Solidity: event StakeParamsChanged(uint256 new_minStakePeriod, uint256 new_maxStakePeriod, uint256 new_minStake, uint256 new_maxStakes)
func (_Fitstake *FitstakeFilterer) ParseStakeParamsChanged(log types.Log) (*FitstakeStakeParamsChanged, error) {
	event := new(FitstakeStakeParamsChanged)
	if err := _Fitstake.contract.UnpackLog(event, "StakeParamsChanged", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// FitstakeStakedIterator is returned from FilterStaked and is used to iterate over the raw logs and unpacked data for Staked events raised by the Fitstake contract.
type FitstakeStakedIterator struct {
	Event *FitstakeStaked // Event containing the contract specifics and raw log

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
func (it *FitstakeStakedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(FitstakeStaked)
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
		it.Event = new(FitstakeStaked)
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
func (it *FitstakeStakedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *FitstakeStakedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// FitstakeStaked represents a Staked event raised by the Fitstake contract.
type FitstakeStaked struct {
	Staker common.Address
	Id     *big.Int
	Amount *big.Int
	Start  *big.Int
	End    *big.Int
	Minted *big.Int
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterStaked is a free log retrieval operation binding the contract event 0x6381ea17a5324d29cc015352644672ead5185c1c61a0d3a521eda97e35cec97e.
//
// Solidity: event Staked(address indexed staker, uint256 indexed id, uint256 amount, uint256 start, uint256 end, uint256 minted)
func (_Fitstake *FitstakeFilterer) FilterStaked(opts *bind.FilterOpts, staker []common.Address, id []*big.Int) (*FitstakeStakedIterator, error) {

	var stakerRule []interface{}
	for _, stakerItem := range staker {
		stakerRule = append(stakerRule, stakerItem)
	}
	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _Fitstake.contract.FilterLogs(opts, "Staked", stakerRule, idRule)
	if err != nil {
		return nil, err
	}
	return &FitstakeStakedIterator{contract: _Fitstake.contract, event: "Staked", logs: logs, sub: sub}, nil
}

// WatchStaked is a free log subscription operation binding the contract event 0x6381ea17a5324d29cc015352644672ead5185c1c61a0d3a521eda97e35cec97e.
//
// Solidity: event Staked(address indexed staker, uint256 indexed id, uint256 amount, uint256 start, uint256 end, uint256 minted)
func (_Fitstake *FitstakeFilterer) WatchStaked(opts *bind.WatchOpts, sink chan<- *FitstakeStaked, staker []common.Address, id []*big.Int) (event.Subscription, error) {

	var stakerRule []interface{}
	for _, stakerItem := range staker {
		stakerRule = append(stakerRule, stakerItem)
	}
	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _Fitstake.contract.WatchLogs(opts, "Staked", stakerRule, idRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(FitstakeStaked)
				if err := _Fitstake.contract.UnpackLog(event, "Staked", log); err != nil {
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

// ParseStaked is a log parse operation binding the contract event 0x6381ea17a5324d29cc015352644672ead5185c1c61a0d3a521eda97e35cec97e.
//
// Solidity: event Staked(address indexed staker, uint256 indexed id, uint256 amount, uint256 start, uint256 end, uint256 minted)
func (_Fitstake *FitstakeFilterer) ParseStaked(log types.Log) (*FitstakeStaked, error) {
	event := new(FitstakeStaked)
	if err := _Fitstake.contract.UnpackLog(event, "Staked", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// FitstakeUnstakedIterator is returned from FilterUnstaked and is used to iterate over the raw logs and unpacked data for Unstaked events raised by the Fitstake contract.
type FitstakeUnstakedIterator struct {
	Event *FitstakeUnstaked // Event containing the contract specifics and raw log

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
func (it *FitstakeUnstakedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(FitstakeUnstaked)
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
		it.Event = new(FitstakeUnstaked)
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
func (it *FitstakeUnstakedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *FitstakeUnstakedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// FitstakeUnstaked represents a Unstaked event raised by the Fitstake contract.
type FitstakeUnstaked struct {
	Staker  common.Address
	Id      *big.Int
	Amount  *big.Int
	Start   *big.Int
	End     *big.Int
	RealEnd *big.Int
	Minted  *big.Int
	Raw     types.Log // Blockchain specific contextual infos
}

// FilterUnstaked is a free log retrieval operation binding the contract event 0x99e303fc09f735c25e5c4484adf9e39fe63be9940fe6bab97a10697bd6a34a73.
//
// Solidity: event Unstaked(address indexed staker, uint256 indexed id, uint256 amount, uint256 start, uint256 end, uint256 realEnd, uint256 minted)
func (_Fitstake *FitstakeFilterer) FilterUnstaked(opts *bind.FilterOpts, staker []common.Address, id []*big.Int) (*FitstakeUnstakedIterator, error) {

	var stakerRule []interface{}
	for _, stakerItem := range staker {
		stakerRule = append(stakerRule, stakerItem)
	}
	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _Fitstake.contract.FilterLogs(opts, "Unstaked", stakerRule, idRule)
	if err != nil {
		return nil, err
	}
	return &FitstakeUnstakedIterator{contract: _Fitstake.contract, event: "Unstaked", logs: logs, sub: sub}, nil
}

// WatchUnstaked is a free log subscription operation binding the contract event 0x99e303fc09f735c25e5c4484adf9e39fe63be9940fe6bab97a10697bd6a34a73.
//
// Solidity: event Unstaked(address indexed staker, uint256 indexed id, uint256 amount, uint256 start, uint256 end, uint256 realEnd, uint256 minted)
func (_Fitstake *FitstakeFilterer) WatchUnstaked(opts *bind.WatchOpts, sink chan<- *FitstakeUnstaked, staker []common.Address, id []*big.Int) (event.Subscription, error) {

	var stakerRule []interface{}
	for _, stakerItem := range staker {
		stakerRule = append(stakerRule, stakerItem)
	}
	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _Fitstake.contract.WatchLogs(opts, "Unstaked", stakerRule, idRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(FitstakeUnstaked)
				if err := _Fitstake.contract.UnpackLog(event, "Unstaked", log); err != nil {
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

// ParseUnstaked is a log parse operation binding the contract event 0x99e303fc09f735c25e5c4484adf9e39fe63be9940fe6bab97a10697bd6a34a73.
//
// Solidity: event Unstaked(address indexed staker, uint256 indexed id, uint256 amount, uint256 start, uint256 end, uint256 realEnd, uint256 minted)
func (_Fitstake *FitstakeFilterer) ParseUnstaked(log types.Log) (*FitstakeUnstaked, error) {
	event := new(FitstakeUnstaked)
	if err := _Fitstake.contract.UnpackLog(event, "Unstaked", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// FitstakeWithdrawnFIGIterator is returned from FilterWithdrawnFIG and is used to iterate over the raw logs and unpacked data for WithdrawnFIG events raised by the Fitstake contract.
type FitstakeWithdrawnFIGIterator struct {
	Event *FitstakeWithdrawnFIG // Event containing the contract specifics and raw log

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
func (it *FitstakeWithdrawnFIGIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(FitstakeWithdrawnFIG)
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
		it.Event = new(FitstakeWithdrawnFIG)
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
func (it *FitstakeWithdrawnFIGIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *FitstakeWithdrawnFIGIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// FitstakeWithdrawnFIG represents a WithdrawnFIG event raised by the Fitstake contract.
type FitstakeWithdrawnFIG struct {
	Staker common.Address
	Id     *big.Int
	Amount *big.Int
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterWithdrawnFIG is a free log retrieval operation binding the contract event 0xae664ad57064f59186792883f53f499d9fb0006e83d0a5e4b528b3dce89a03e0.
//
// Solidity: event WithdrawnFIG(address indexed staker, uint256 indexed id, uint256 amount)
func (_Fitstake *FitstakeFilterer) FilterWithdrawnFIG(opts *bind.FilterOpts, staker []common.Address, id []*big.Int) (*FitstakeWithdrawnFIGIterator, error) {

	var stakerRule []interface{}
	for _, stakerItem := range staker {
		stakerRule = append(stakerRule, stakerItem)
	}
	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _Fitstake.contract.FilterLogs(opts, "WithdrawnFIG", stakerRule, idRule)
	if err != nil {
		return nil, err
	}
	return &FitstakeWithdrawnFIGIterator{contract: _Fitstake.contract, event: "WithdrawnFIG", logs: logs, sub: sub}, nil
}

// WatchWithdrawnFIG is a free log subscription operation binding the contract event 0xae664ad57064f59186792883f53f499d9fb0006e83d0a5e4b528b3dce89a03e0.
//
// Solidity: event WithdrawnFIG(address indexed staker, uint256 indexed id, uint256 amount)
func (_Fitstake *FitstakeFilterer) WatchWithdrawnFIG(opts *bind.WatchOpts, sink chan<- *FitstakeWithdrawnFIG, staker []common.Address, id []*big.Int) (event.Subscription, error) {

	var stakerRule []interface{}
	for _, stakerItem := range staker {
		stakerRule = append(stakerRule, stakerItem)
	}
	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}

	logs, sub, err := _Fitstake.contract.WatchLogs(opts, "WithdrawnFIG", stakerRule, idRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(FitstakeWithdrawnFIG)
				if err := _Fitstake.contract.UnpackLog(event, "WithdrawnFIG", log); err != nil {
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

// ParseWithdrawnFIG is a log parse operation binding the contract event 0xae664ad57064f59186792883f53f499d9fb0006e83d0a5e4b528b3dce89a03e0.
//
// Solidity: event WithdrawnFIG(address indexed staker, uint256 indexed id, uint256 amount)
func (_Fitstake *FitstakeFilterer) ParseWithdrawnFIG(log types.Log) (*FitstakeWithdrawnFIG, error) {
	event := new(FitstakeWithdrawnFIG)
	if err := _Fitstake.contract.UnpackLog(event, "WithdrawnFIG", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
