// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package governance

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

// GovernanceGovernanceInfo is an auto generated low-level Go binding around an user-defined struct.
type GovernanceGovernanceInfo struct {
	Bonders               *big.Int
	TotalBondedAmount     *big.Int
	FirstActiveProposalId *big.Int
}

// GovernanceProposalInfo is an auto generated low-level Go binding around an user-defined struct.
type GovernanceProposalInfo struct {
	Category        uint8
	Start           *big.Int
	Deadline        *big.Int
	Deposited       *big.Int
	DiscussionIndex *big.Int
	Executed        bool
	Result          uint8
	Text            string
	Proposer        common.Address
	Values          []*big.Int
}

// GovernanceVoting is an auto generated low-level Go binding around an user-defined struct.
type GovernanceVoting struct {
	AmountTotal *big.Int
	Amounts     [4]*big.Int
}

// GovernanceVotingStatusInfo is an auto generated low-level Go binding around an user-defined struct.
type GovernanceVotingStatusInfo struct {
	Voters      []common.Address
	AmountTotal *big.Int
	Amounts     [4]*big.Int
}

// GovernanceMetaData contains all meta data concerning the Governance contract.
var GovernanceMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"bonder\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"Bonded\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"address\",\"name\":\"new_filLiquid\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"new_fitStake\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"new_tokenFILGovernance\",\"type\":\"address\"}],\"name\":\"ContractAddrsChanged\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"executor\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"proposalId\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"enumGovernance.voteResult\",\"name\":\"result\",\"type\":\"uint8\"}],\"name\":\"Executed\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_rateBase\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_minYes\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_maxNo\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_maxNoWithVeto\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_quorum\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_liquidate\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_depositRatioThreshold\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_depositAmountThreshold\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_voteThreshold\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_votingPeriod\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_executionPeriod\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"new_maxActiveProposals\",\"type\":\"uint256\"}],\"name\":\"FactorsChanged\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"account\",\"type\":\"address\"}],\"name\":\"OwnerChanged\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"proposer\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"proposalId\",\"type\":\"uint256\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"discussionIndex\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"enumGovernance.proposalCategory\",\"name\":\"category\",\"type\":\"uint8\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"deadline\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"deposited\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"string\",\"name\":\"text\",\"type\":\"string\"},{\"indexed\":false,\"internalType\":\"uint256[]\",\"name\":\"values\",\"type\":\"uint256[]\"}],\"name\":\"Proposed\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"bonder\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"Unbonded\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"voter\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"proposalId\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"enumGovernance.voteCategory\",\"name\":\"category\",\"type\":\"uint8\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"Voted\",\"type\":\"event\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"bond\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"name\":\"bondedAmount\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"proposalId\",\"type\":\"uint256\"}],\"name\":\"canExecute\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"},{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"canPropose\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"},{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"sender\",\"type\":\"address\"}],\"name\":\"canUnbond\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"},{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"proposalId\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"canVote\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"},{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"proposalId\",\"type\":\"uint256\"}],\"name\":\"execute\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getContractAddrs\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getDepositThreshold\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"result\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getFactors\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getProposalCount\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"proposalId\",\"type\":\"uint256\"}],\"name\":\"getProposalInfo\",\"outputs\":[{\"components\":[{\"internalType\":\"enumGovernance.proposalCategory\",\"name\":\"category\",\"type\":\"uint8\"},{\"internalType\":\"uint256\",\"name\":\"start\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"deadline\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"deposited\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"discussionIndex\",\"type\":\"uint256\"},{\"internalType\":\"bool\",\"name\":\"executed\",\"type\":\"bool\"},{\"internalType\":\"enumGovernance.voteResult\",\"name\":\"result\",\"type\":\"uint8\"},{\"internalType\":\"string\",\"name\":\"text\",\"type\":\"string\"},{\"internalType\":\"address\",\"name\":\"proposer\",\"type\":\"address\"},{\"internalType\":\"uint256[]\",\"name\":\"values\",\"type\":\"uint256[]\"}],\"internalType\":\"structGovernance.ProposalInfo\",\"name\":\"\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"proposalId\",\"type\":\"uint256\"}],\"name\":\"getProposalVoterCount\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"proposalId\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"from\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"to\",\"type\":\"uint256\"}],\"name\":\"getProposalVoters\",\"outputs\":[{\"internalType\":\"address[]\",\"name\":\"result\",\"type\":\"address[]\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getStatus\",\"outputs\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"bonders\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"totalBondedAmount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"firstActiveProposalId\",\"type\":\"uint256\"}],\"internalType\":\"structGovernance.GovernanceInfo\",\"name\":\"\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"proposalId\",\"type\":\"uint256\"}],\"name\":\"getVoteResult\",\"outputs\":[{\"internalType\":\"enumGovernance.voteResult\",\"name\":\"\",\"type\":\"uint8\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"proposalId\",\"type\":\"uint256\"}],\"name\":\"getVoteStatus\",\"outputs\":[{\"components\":[{\"internalType\":\"address[]\",\"name\":\"voters\",\"type\":\"address[]\"},{\"internalType\":\"uint256\",\"name\":\"amountTotal\",\"type\":\"uint256\"},{\"internalType\":\"uint256[4]\",\"name\":\"amounts\",\"type\":\"uint256[4]\"}],\"internalType\":\"structGovernance.VotingStatusInfo\",\"name\":\"\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"proposalId\",\"type\":\"uint256\"}],\"name\":\"getVoteStatusBrief\",\"outputs\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"amountTotal\",\"type\":\"uint256\"},{\"internalType\":\"uint256[4]\",\"name\":\"amounts\",\"type\":\"uint256[4]\"}],\"internalType\":\"structGovernance.Voting\",\"name\":\"\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"owner\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"enumGovernance.proposalCategory\",\"name\":\"category\",\"type\":\"uint8\"},{\"internalType\":\"uint256\",\"name\":\"discussionIndex\",\"type\":\"uint256\"},{\"internalType\":\"string\",\"name\":\"text\",\"type\":\"string\"},{\"internalType\":\"uint256[]\",\"name\":\"values\",\"type\":\"uint256[]\"}],\"name\":\"propose\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"renew1stActiveProposal\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"i\",\"type\":\"uint256\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"new_filLiquid\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"new_fitStake\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"new_tokenFILGovernance\",\"type\":\"address\"}],\"name\":\"setContractAddrs\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"new_rateBase\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"new_minYes\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"new_maxNo\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"new_maxNoWithVeto\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"new_quorum\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"new_liquidate\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"new_depositRatioThreshold\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"new_depositAmountThreshold\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"new_voteThreshold\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"new_votingPeriod\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"new_executionPeriod\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"new_maxActiveProposals\",\"type\":\"uint256\"}],\"name\":\"setFactors\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"new_owner\",\"type\":\"address\"}],\"name\":\"setOwner\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"name\":\"totalBondedAmounts\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"},{\"internalType\":\"bool\",\"name\":\"initialized\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"unbond\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"proposalId\",\"type\":\"uint256\"},{\"internalType\":\"enumGovernance.voteCategory\",\"name\":\"category\",\"type\":\"uint8\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"vote\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"voter\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"proposalId\",\"type\":\"uint256\"}],\"name\":\"votedForProposal\",\"outputs\":[{\"components\":[{\"internalType\":\"uint256\",\"name\":\"amountTotal\",\"type\":\"uint256\"},{\"internalType\":\"uint256[4]\",\"name\":\"amounts\",\"type\":\"uint256[4]\"}],\"internalType\":\"structGovernance.Voting\",\"name\":\"\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"bonder\",\"type\":\"address\"}],\"name\":\"votingProposalSum\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"count\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"maxVote\",\"type\":\"uint256\"}],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]",
}

// GovernanceABI is the input ABI used to generate the binding from.
// Deprecated: Use GovernanceMetaData.ABI instead.
var GovernanceABI = GovernanceMetaData.ABI

// Governance is an auto generated Go binding around an Ethereum contract.
type Governance struct {
	GovernanceCaller     // Read-only binding to the contract
	GovernanceTransactor // Write-only binding to the contract
	GovernanceFilterer   // Log filterer for contract events
}

// GovernanceCaller is an auto generated read-only Go binding around an Ethereum contract.
type GovernanceCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// GovernanceTransactor is an auto generated write-only Go binding around an Ethereum contract.
type GovernanceTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// GovernanceFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type GovernanceFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// GovernanceSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type GovernanceSession struct {
	Contract     *Governance       // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// GovernanceCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type GovernanceCallerSession struct {
	Contract *GovernanceCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts     // Call options to use throughout this session
}

// GovernanceTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type GovernanceTransactorSession struct {
	Contract     *GovernanceTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts     // Transaction auth options to use throughout this session
}

// GovernanceRaw is an auto generated low-level Go binding around an Ethereum contract.
type GovernanceRaw struct {
	Contract *Governance // Generic contract binding to access the raw methods on
}

// GovernanceCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type GovernanceCallerRaw struct {
	Contract *GovernanceCaller // Generic read-only contract binding to access the raw methods on
}

// GovernanceTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type GovernanceTransactorRaw struct {
	Contract *GovernanceTransactor // Generic write-only contract binding to access the raw methods on
}

// NewGovernance creates a new instance of Governance, bound to a specific deployed contract.
func NewGovernance(address common.Address, backend bind.ContractBackend) (*Governance, error) {
	contract, err := bindGovernance(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &Governance{GovernanceCaller: GovernanceCaller{contract: contract}, GovernanceTransactor: GovernanceTransactor{contract: contract}, GovernanceFilterer: GovernanceFilterer{contract: contract}}, nil
}

// NewGovernanceCaller creates a new read-only instance of Governance, bound to a specific deployed contract.
func NewGovernanceCaller(address common.Address, caller bind.ContractCaller) (*GovernanceCaller, error) {
	contract, err := bindGovernance(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &GovernanceCaller{contract: contract}, nil
}

// NewGovernanceTransactor creates a new write-only instance of Governance, bound to a specific deployed contract.
func NewGovernanceTransactor(address common.Address, transactor bind.ContractTransactor) (*GovernanceTransactor, error) {
	contract, err := bindGovernance(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &GovernanceTransactor{contract: contract}, nil
}

// NewGovernanceFilterer creates a new log filterer instance of Governance, bound to a specific deployed contract.
func NewGovernanceFilterer(address common.Address, filterer bind.ContractFilterer) (*GovernanceFilterer, error) {
	contract, err := bindGovernance(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &GovernanceFilterer{contract: contract}, nil
}

// bindGovernance binds a generic wrapper to an already deployed contract.
func bindGovernance(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := GovernanceMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Governance *GovernanceRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Governance.Contract.GovernanceCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Governance *GovernanceRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Governance.Contract.GovernanceTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Governance *GovernanceRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Governance.Contract.GovernanceTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Governance *GovernanceCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Governance.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Governance *GovernanceTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Governance.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Governance *GovernanceTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Governance.Contract.contract.Transact(opts, method, params...)
}

// BondedAmount is a free data retrieval call binding the contract method 0xa302d064.
//
// Solidity: function bondedAmount(address ) view returns(uint256)
func (_Governance *GovernanceCaller) BondedAmount(opts *bind.CallOpts, arg0 common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Governance.contract.Call(opts, &out, "bondedAmount", arg0)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// BondedAmount is a free data retrieval call binding the contract method 0xa302d064.
//
// Solidity: function bondedAmount(address ) view returns(uint256)
func (_Governance *GovernanceSession) BondedAmount(arg0 common.Address) (*big.Int, error) {
	return _Governance.Contract.BondedAmount(&_Governance.CallOpts, arg0)
}

// BondedAmount is a free data retrieval call binding the contract method 0xa302d064.
//
// Solidity: function bondedAmount(address ) view returns(uint256)
func (_Governance *GovernanceCallerSession) BondedAmount(arg0 common.Address) (*big.Int, error) {
	return _Governance.Contract.BondedAmount(&_Governance.CallOpts, arg0)
}

// CanExecute is a free data retrieval call binding the contract method 0xcc63604a.
//
// Solidity: function canExecute(uint256 proposalId) view returns(bool, string)
func (_Governance *GovernanceCaller) CanExecute(opts *bind.CallOpts, proposalId *big.Int) (bool, string, error) {
	var out []interface{}
	err := _Governance.contract.Call(opts, &out, "canExecute", proposalId)

	if err != nil {
		return *new(bool), *new(string), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)
	out1 := *abi.ConvertType(out[1], new(string)).(*string)

	return out0, out1, err

}

// CanExecute is a free data retrieval call binding the contract method 0xcc63604a.
//
// Solidity: function canExecute(uint256 proposalId) view returns(bool, string)
func (_Governance *GovernanceSession) CanExecute(proposalId *big.Int) (bool, string, error) {
	return _Governance.Contract.CanExecute(&_Governance.CallOpts, proposalId)
}

// CanExecute is a free data retrieval call binding the contract method 0xcc63604a.
//
// Solidity: function canExecute(uint256 proposalId) view returns(bool, string)
func (_Governance *GovernanceCallerSession) CanExecute(proposalId *big.Int) (bool, string, error) {
	return _Governance.Contract.CanExecute(&_Governance.CallOpts, proposalId)
}

// CanVote is a free data retrieval call binding the contract method 0xef233c0b.
//
// Solidity: function canVote(uint256 proposalId, uint256 amount) view returns(bool, string)
func (_Governance *GovernanceCaller) CanVote(opts *bind.CallOpts, proposalId *big.Int, amount *big.Int) (bool, string, error) {
	var out []interface{}
	err := _Governance.contract.Call(opts, &out, "canVote", proposalId, amount)

	if err != nil {
		return *new(bool), *new(string), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)
	out1 := *abi.ConvertType(out[1], new(string)).(*string)

	return out0, out1, err

}

// CanVote is a free data retrieval call binding the contract method 0xef233c0b.
//
// Solidity: function canVote(uint256 proposalId, uint256 amount) view returns(bool, string)
func (_Governance *GovernanceSession) CanVote(proposalId *big.Int, amount *big.Int) (bool, string, error) {
	return _Governance.Contract.CanVote(&_Governance.CallOpts, proposalId, amount)
}

// CanVote is a free data retrieval call binding the contract method 0xef233c0b.
//
// Solidity: function canVote(uint256 proposalId, uint256 amount) view returns(bool, string)
func (_Governance *GovernanceCallerSession) CanVote(proposalId *big.Int, amount *big.Int) (bool, string, error) {
	return _Governance.Contract.CanVote(&_Governance.CallOpts, proposalId, amount)
}

// GetContractAddrs is a free data retrieval call binding the contract method 0x892ebb42.
//
// Solidity: function getContractAddrs() view returns(address, address, address)
func (_Governance *GovernanceCaller) GetContractAddrs(opts *bind.CallOpts) (common.Address, common.Address, common.Address, error) {
	var out []interface{}
	err := _Governance.contract.Call(opts, &out, "getContractAddrs")

	if err != nil {
		return *new(common.Address), *new(common.Address), *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)
	out1 := *abi.ConvertType(out[1], new(common.Address)).(*common.Address)
	out2 := *abi.ConvertType(out[2], new(common.Address)).(*common.Address)

	return out0, out1, out2, err

}

// GetContractAddrs is a free data retrieval call binding the contract method 0x892ebb42.
//
// Solidity: function getContractAddrs() view returns(address, address, address)
func (_Governance *GovernanceSession) GetContractAddrs() (common.Address, common.Address, common.Address, error) {
	return _Governance.Contract.GetContractAddrs(&_Governance.CallOpts)
}

// GetContractAddrs is a free data retrieval call binding the contract method 0x892ebb42.
//
// Solidity: function getContractAddrs() view returns(address, address, address)
func (_Governance *GovernanceCallerSession) GetContractAddrs() (common.Address, common.Address, common.Address, error) {
	return _Governance.Contract.GetContractAddrs(&_Governance.CallOpts)
}

// GetDepositThreshold is a free data retrieval call binding the contract method 0x85bb4de8.
//
// Solidity: function getDepositThreshold() view returns(uint256 result)
func (_Governance *GovernanceCaller) GetDepositThreshold(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _Governance.contract.Call(opts, &out, "getDepositThreshold")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetDepositThreshold is a free data retrieval call binding the contract method 0x85bb4de8.
//
// Solidity: function getDepositThreshold() view returns(uint256 result)
func (_Governance *GovernanceSession) GetDepositThreshold() (*big.Int, error) {
	return _Governance.Contract.GetDepositThreshold(&_Governance.CallOpts)
}

// GetDepositThreshold is a free data retrieval call binding the contract method 0x85bb4de8.
//
// Solidity: function getDepositThreshold() view returns(uint256 result)
func (_Governance *GovernanceCallerSession) GetDepositThreshold() (*big.Int, error) {
	return _Governance.Contract.GetDepositThreshold(&_Governance.CallOpts)
}

// GetFactors is a free data retrieval call binding the contract method 0xf8320e21.
//
// Solidity: function getFactors() view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256)
func (_Governance *GovernanceCaller) GetFactors(opts *bind.CallOpts) (*big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, error) {
	var out []interface{}
	err := _Governance.contract.Call(opts, &out, "getFactors")

	if err != nil {
		return *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), *new(*big.Int), err
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
	out9 := *abi.ConvertType(out[9], new(*big.Int)).(**big.Int)
	out10 := *abi.ConvertType(out[10], new(*big.Int)).(**big.Int)
	out11 := *abi.ConvertType(out[11], new(*big.Int)).(**big.Int)

	return out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, err

}

// GetFactors is a free data retrieval call binding the contract method 0xf8320e21.
//
// Solidity: function getFactors() view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256)
func (_Governance *GovernanceSession) GetFactors() (*big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, error) {
	return _Governance.Contract.GetFactors(&_Governance.CallOpts)
}

// GetFactors is a free data retrieval call binding the contract method 0xf8320e21.
//
// Solidity: function getFactors() view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256)
func (_Governance *GovernanceCallerSession) GetFactors() (*big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, *big.Int, error) {
	return _Governance.Contract.GetFactors(&_Governance.CallOpts)
}

// GetProposalCount is a free data retrieval call binding the contract method 0xc08cc02d.
//
// Solidity: function getProposalCount() view returns(uint256)
func (_Governance *GovernanceCaller) GetProposalCount(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _Governance.contract.Call(opts, &out, "getProposalCount")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetProposalCount is a free data retrieval call binding the contract method 0xc08cc02d.
//
// Solidity: function getProposalCount() view returns(uint256)
func (_Governance *GovernanceSession) GetProposalCount() (*big.Int, error) {
	return _Governance.Contract.GetProposalCount(&_Governance.CallOpts)
}

// GetProposalCount is a free data retrieval call binding the contract method 0xc08cc02d.
//
// Solidity: function getProposalCount() view returns(uint256)
func (_Governance *GovernanceCallerSession) GetProposalCount() (*big.Int, error) {
	return _Governance.Contract.GetProposalCount(&_Governance.CallOpts)
}

// GetProposalInfo is a free data retrieval call binding the contract method 0xbc903cb8.
//
// Solidity: function getProposalInfo(uint256 proposalId) view returns((uint8,uint256,uint256,uint256,uint256,bool,uint8,string,address,uint256[]))
func (_Governance *GovernanceCaller) GetProposalInfo(opts *bind.CallOpts, proposalId *big.Int) (GovernanceProposalInfo, error) {
	var out []interface{}
	err := _Governance.contract.Call(opts, &out, "getProposalInfo", proposalId)

	if err != nil {
		return *new(GovernanceProposalInfo), err
	}

	out0 := *abi.ConvertType(out[0], new(GovernanceProposalInfo)).(*GovernanceProposalInfo)

	return out0, err

}

// GetProposalInfo is a free data retrieval call binding the contract method 0xbc903cb8.
//
// Solidity: function getProposalInfo(uint256 proposalId) view returns((uint8,uint256,uint256,uint256,uint256,bool,uint8,string,address,uint256[]))
func (_Governance *GovernanceSession) GetProposalInfo(proposalId *big.Int) (GovernanceProposalInfo, error) {
	return _Governance.Contract.GetProposalInfo(&_Governance.CallOpts, proposalId)
}

// GetProposalInfo is a free data retrieval call binding the contract method 0xbc903cb8.
//
// Solidity: function getProposalInfo(uint256 proposalId) view returns((uint8,uint256,uint256,uint256,uint256,bool,uint8,string,address,uint256[]))
func (_Governance *GovernanceCallerSession) GetProposalInfo(proposalId *big.Int) (GovernanceProposalInfo, error) {
	return _Governance.Contract.GetProposalInfo(&_Governance.CallOpts, proposalId)
}

// GetProposalVoterCount is a free data retrieval call binding the contract method 0x6a7cc6d4.
//
// Solidity: function getProposalVoterCount(uint256 proposalId) view returns(uint256)
func (_Governance *GovernanceCaller) GetProposalVoterCount(opts *bind.CallOpts, proposalId *big.Int) (*big.Int, error) {
	var out []interface{}
	err := _Governance.contract.Call(opts, &out, "getProposalVoterCount", proposalId)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetProposalVoterCount is a free data retrieval call binding the contract method 0x6a7cc6d4.
//
// Solidity: function getProposalVoterCount(uint256 proposalId) view returns(uint256)
func (_Governance *GovernanceSession) GetProposalVoterCount(proposalId *big.Int) (*big.Int, error) {
	return _Governance.Contract.GetProposalVoterCount(&_Governance.CallOpts, proposalId)
}

// GetProposalVoterCount is a free data retrieval call binding the contract method 0x6a7cc6d4.
//
// Solidity: function getProposalVoterCount(uint256 proposalId) view returns(uint256)
func (_Governance *GovernanceCallerSession) GetProposalVoterCount(proposalId *big.Int) (*big.Int, error) {
	return _Governance.Contract.GetProposalVoterCount(&_Governance.CallOpts, proposalId)
}

// GetProposalVoters is a free data retrieval call binding the contract method 0xe354048f.
//
// Solidity: function getProposalVoters(uint256 proposalId, uint256 from, uint256 to) view returns(address[] result)
func (_Governance *GovernanceCaller) GetProposalVoters(opts *bind.CallOpts, proposalId *big.Int, from *big.Int, to *big.Int) ([]common.Address, error) {
	var out []interface{}
	err := _Governance.contract.Call(opts, &out, "getProposalVoters", proposalId, from, to)

	if err != nil {
		return *new([]common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new([]common.Address)).(*[]common.Address)

	return out0, err

}

// GetProposalVoters is a free data retrieval call binding the contract method 0xe354048f.
//
// Solidity: function getProposalVoters(uint256 proposalId, uint256 from, uint256 to) view returns(address[] result)
func (_Governance *GovernanceSession) GetProposalVoters(proposalId *big.Int, from *big.Int, to *big.Int) ([]common.Address, error) {
	return _Governance.Contract.GetProposalVoters(&_Governance.CallOpts, proposalId, from, to)
}

// GetProposalVoters is a free data retrieval call binding the contract method 0xe354048f.
//
// Solidity: function getProposalVoters(uint256 proposalId, uint256 from, uint256 to) view returns(address[] result)
func (_Governance *GovernanceCallerSession) GetProposalVoters(proposalId *big.Int, from *big.Int, to *big.Int) ([]common.Address, error) {
	return _Governance.Contract.GetProposalVoters(&_Governance.CallOpts, proposalId, from, to)
}

// GetStatus is a free data retrieval call binding the contract method 0x4e69d560.
//
// Solidity: function getStatus() view returns((uint256,uint256,uint256))
func (_Governance *GovernanceCaller) GetStatus(opts *bind.CallOpts) (GovernanceGovernanceInfo, error) {
	var out []interface{}
	err := _Governance.contract.Call(opts, &out, "getStatus")

	if err != nil {
		return *new(GovernanceGovernanceInfo), err
	}

	out0 := *abi.ConvertType(out[0], new(GovernanceGovernanceInfo)).(*GovernanceGovernanceInfo)

	return out0, err

}

// GetStatus is a free data retrieval call binding the contract method 0x4e69d560.
//
// Solidity: function getStatus() view returns((uint256,uint256,uint256))
func (_Governance *GovernanceSession) GetStatus() (GovernanceGovernanceInfo, error) {
	return _Governance.Contract.GetStatus(&_Governance.CallOpts)
}

// GetStatus is a free data retrieval call binding the contract method 0x4e69d560.
//
// Solidity: function getStatus() view returns((uint256,uint256,uint256))
func (_Governance *GovernanceCallerSession) GetStatus() (GovernanceGovernanceInfo, error) {
	return _Governance.Contract.GetStatus(&_Governance.CallOpts)
}

// GetVoteResult is a free data retrieval call binding the contract method 0xbfa0fc93.
//
// Solidity: function getVoteResult(uint256 proposalId) view returns(uint8)
func (_Governance *GovernanceCaller) GetVoteResult(opts *bind.CallOpts, proposalId *big.Int) (uint8, error) {
	var out []interface{}
	err := _Governance.contract.Call(opts, &out, "getVoteResult", proposalId)

	if err != nil {
		return *new(uint8), err
	}

	out0 := *abi.ConvertType(out[0], new(uint8)).(*uint8)

	return out0, err

}

// GetVoteResult is a free data retrieval call binding the contract method 0xbfa0fc93.
//
// Solidity: function getVoteResult(uint256 proposalId) view returns(uint8)
func (_Governance *GovernanceSession) GetVoteResult(proposalId *big.Int) (uint8, error) {
	return _Governance.Contract.GetVoteResult(&_Governance.CallOpts, proposalId)
}

// GetVoteResult is a free data retrieval call binding the contract method 0xbfa0fc93.
//
// Solidity: function getVoteResult(uint256 proposalId) view returns(uint8)
func (_Governance *GovernanceCallerSession) GetVoteResult(proposalId *big.Int) (uint8, error) {
	return _Governance.Contract.GetVoteResult(&_Governance.CallOpts, proposalId)
}

// GetVoteStatus is a free data retrieval call binding the contract method 0x0519bb83.
//
// Solidity: function getVoteStatus(uint256 proposalId) view returns((address[],uint256,uint256[4]))
func (_Governance *GovernanceCaller) GetVoteStatus(opts *bind.CallOpts, proposalId *big.Int) (GovernanceVotingStatusInfo, error) {
	var out []interface{}
	err := _Governance.contract.Call(opts, &out, "getVoteStatus", proposalId)

	if err != nil {
		return *new(GovernanceVotingStatusInfo), err
	}

	out0 := *abi.ConvertType(out[0], new(GovernanceVotingStatusInfo)).(*GovernanceVotingStatusInfo)

	return out0, err

}

// GetVoteStatus is a free data retrieval call binding the contract method 0x0519bb83.
//
// Solidity: function getVoteStatus(uint256 proposalId) view returns((address[],uint256,uint256[4]))
func (_Governance *GovernanceSession) GetVoteStatus(proposalId *big.Int) (GovernanceVotingStatusInfo, error) {
	return _Governance.Contract.GetVoteStatus(&_Governance.CallOpts, proposalId)
}

// GetVoteStatus is a free data retrieval call binding the contract method 0x0519bb83.
//
// Solidity: function getVoteStatus(uint256 proposalId) view returns((address[],uint256,uint256[4]))
func (_Governance *GovernanceCallerSession) GetVoteStatus(proposalId *big.Int) (GovernanceVotingStatusInfo, error) {
	return _Governance.Contract.GetVoteStatus(&_Governance.CallOpts, proposalId)
}

// GetVoteStatusBrief is a free data retrieval call binding the contract method 0x6c6c8836.
//
// Solidity: function getVoteStatusBrief(uint256 proposalId) view returns((uint256,uint256[4]))
func (_Governance *GovernanceCaller) GetVoteStatusBrief(opts *bind.CallOpts, proposalId *big.Int) (GovernanceVoting, error) {
	var out []interface{}
	err := _Governance.contract.Call(opts, &out, "getVoteStatusBrief", proposalId)

	if err != nil {
		return *new(GovernanceVoting), err
	}

	out0 := *abi.ConvertType(out[0], new(GovernanceVoting)).(*GovernanceVoting)

	return out0, err

}

// GetVoteStatusBrief is a free data retrieval call binding the contract method 0x6c6c8836.
//
// Solidity: function getVoteStatusBrief(uint256 proposalId) view returns((uint256,uint256[4]))
func (_Governance *GovernanceSession) GetVoteStatusBrief(proposalId *big.Int) (GovernanceVoting, error) {
	return _Governance.Contract.GetVoteStatusBrief(&_Governance.CallOpts, proposalId)
}

// GetVoteStatusBrief is a free data retrieval call binding the contract method 0x6c6c8836.
//
// Solidity: function getVoteStatusBrief(uint256 proposalId) view returns((uint256,uint256[4]))
func (_Governance *GovernanceCallerSession) GetVoteStatusBrief(proposalId *big.Int) (GovernanceVoting, error) {
	return _Governance.Contract.GetVoteStatusBrief(&_Governance.CallOpts, proposalId)
}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_Governance *GovernanceCaller) Owner(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _Governance.contract.Call(opts, &out, "owner")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_Governance *GovernanceSession) Owner() (common.Address, error) {
	return _Governance.Contract.Owner(&_Governance.CallOpts)
}

// Owner is a free data retrieval call binding the contract method 0x8da5cb5b.
//
// Solidity: function owner() view returns(address)
func (_Governance *GovernanceCallerSession) Owner() (common.Address, error) {
	return _Governance.Contract.Owner(&_Governance.CallOpts)
}

// TotalBondedAmounts is a free data retrieval call binding the contract method 0xaee99797.
//
// Solidity: function totalBondedAmounts(uint256 ) view returns(uint256 amount, bool initialized)
func (_Governance *GovernanceCaller) TotalBondedAmounts(opts *bind.CallOpts, arg0 *big.Int) (struct {
	Amount      *big.Int
	Initialized bool
}, error) {
	var out []interface{}
	err := _Governance.contract.Call(opts, &out, "totalBondedAmounts", arg0)

	outstruct := new(struct {
		Amount      *big.Int
		Initialized bool
	})
	if err != nil {
		return *outstruct, err
	}

	outstruct.Amount = *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)
	outstruct.Initialized = *abi.ConvertType(out[1], new(bool)).(*bool)

	return *outstruct, err

}

// TotalBondedAmounts is a free data retrieval call binding the contract method 0xaee99797.
//
// Solidity: function totalBondedAmounts(uint256 ) view returns(uint256 amount, bool initialized)
func (_Governance *GovernanceSession) TotalBondedAmounts(arg0 *big.Int) (struct {
	Amount      *big.Int
	Initialized bool
}, error) {
	return _Governance.Contract.TotalBondedAmounts(&_Governance.CallOpts, arg0)
}

// TotalBondedAmounts is a free data retrieval call binding the contract method 0xaee99797.
//
// Solidity: function totalBondedAmounts(uint256 ) view returns(uint256 amount, bool initialized)
func (_Governance *GovernanceCallerSession) TotalBondedAmounts(arg0 *big.Int) (struct {
	Amount      *big.Int
	Initialized bool
}, error) {
	return _Governance.Contract.TotalBondedAmounts(&_Governance.CallOpts, arg0)
}

// VotedForProposal is a free data retrieval call binding the contract method 0x15b87d10.
//
// Solidity: function votedForProposal(address voter, uint256 proposalId) view returns((uint256,uint256[4]))
func (_Governance *GovernanceCaller) VotedForProposal(opts *bind.CallOpts, voter common.Address, proposalId *big.Int) (GovernanceVoting, error) {
	var out []interface{}
	err := _Governance.contract.Call(opts, &out, "votedForProposal", voter, proposalId)

	if err != nil {
		return *new(GovernanceVoting), err
	}

	out0 := *abi.ConvertType(out[0], new(GovernanceVoting)).(*GovernanceVoting)

	return out0, err

}

// VotedForProposal is a free data retrieval call binding the contract method 0x15b87d10.
//
// Solidity: function votedForProposal(address voter, uint256 proposalId) view returns((uint256,uint256[4]))
func (_Governance *GovernanceSession) VotedForProposal(voter common.Address, proposalId *big.Int) (GovernanceVoting, error) {
	return _Governance.Contract.VotedForProposal(&_Governance.CallOpts, voter, proposalId)
}

// VotedForProposal is a free data retrieval call binding the contract method 0x15b87d10.
//
// Solidity: function votedForProposal(address voter, uint256 proposalId) view returns((uint256,uint256[4]))
func (_Governance *GovernanceCallerSession) VotedForProposal(voter common.Address, proposalId *big.Int) (GovernanceVoting, error) {
	return _Governance.Contract.VotedForProposal(&_Governance.CallOpts, voter, proposalId)
}

// Bond is a paid mutator transaction binding the contract method 0x9940686e.
//
// Solidity: function bond(uint256 amount) returns()
func (_Governance *GovernanceTransactor) Bond(opts *bind.TransactOpts, amount *big.Int) (*types.Transaction, error) {
	return _Governance.contract.Transact(opts, "bond", amount)
}

// Bond is a paid mutator transaction binding the contract method 0x9940686e.
//
// Solidity: function bond(uint256 amount) returns()
func (_Governance *GovernanceSession) Bond(amount *big.Int) (*types.Transaction, error) {
	return _Governance.Contract.Bond(&_Governance.TransactOpts, amount)
}

// Bond is a paid mutator transaction binding the contract method 0x9940686e.
//
// Solidity: function bond(uint256 amount) returns()
func (_Governance *GovernanceTransactorSession) Bond(amount *big.Int) (*types.Transaction, error) {
	return _Governance.Contract.Bond(&_Governance.TransactOpts, amount)
}

// CanPropose is a paid mutator transaction binding the contract method 0x76e14804.
//
// Solidity: function canPropose() returns(bool, string)
func (_Governance *GovernanceTransactor) CanPropose(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Governance.contract.Transact(opts, "canPropose")
}

// CanPropose is a paid mutator transaction binding the contract method 0x76e14804.
//
// Solidity: function canPropose() returns(bool, string)
func (_Governance *GovernanceSession) CanPropose() (*types.Transaction, error) {
	return _Governance.Contract.CanPropose(&_Governance.TransactOpts)
}

// CanPropose is a paid mutator transaction binding the contract method 0x76e14804.
//
// Solidity: function canPropose() returns(bool, string)
func (_Governance *GovernanceTransactorSession) CanPropose() (*types.Transaction, error) {
	return _Governance.Contract.CanPropose(&_Governance.TransactOpts)
}

// CanUnbond is a paid mutator transaction binding the contract method 0xc85ab7f5.
//
// Solidity: function canUnbond(address sender) returns(uint256, bool, string)
func (_Governance *GovernanceTransactor) CanUnbond(opts *bind.TransactOpts, sender common.Address) (*types.Transaction, error) {
	return _Governance.contract.Transact(opts, "canUnbond", sender)
}

// CanUnbond is a paid mutator transaction binding the contract method 0xc85ab7f5.
//
// Solidity: function canUnbond(address sender) returns(uint256, bool, string)
func (_Governance *GovernanceSession) CanUnbond(sender common.Address) (*types.Transaction, error) {
	return _Governance.Contract.CanUnbond(&_Governance.TransactOpts, sender)
}

// CanUnbond is a paid mutator transaction binding the contract method 0xc85ab7f5.
//
// Solidity: function canUnbond(address sender) returns(uint256, bool, string)
func (_Governance *GovernanceTransactorSession) CanUnbond(sender common.Address) (*types.Transaction, error) {
	return _Governance.Contract.CanUnbond(&_Governance.TransactOpts, sender)
}

// Execute is a paid mutator transaction binding the contract method 0xfe0d94c1.
//
// Solidity: function execute(uint256 proposalId) returns()
func (_Governance *GovernanceTransactor) Execute(opts *bind.TransactOpts, proposalId *big.Int) (*types.Transaction, error) {
	return _Governance.contract.Transact(opts, "execute", proposalId)
}

// Execute is a paid mutator transaction binding the contract method 0xfe0d94c1.
//
// Solidity: function execute(uint256 proposalId) returns()
func (_Governance *GovernanceSession) Execute(proposalId *big.Int) (*types.Transaction, error) {
	return _Governance.Contract.Execute(&_Governance.TransactOpts, proposalId)
}

// Execute is a paid mutator transaction binding the contract method 0xfe0d94c1.
//
// Solidity: function execute(uint256 proposalId) returns()
func (_Governance *GovernanceTransactorSession) Execute(proposalId *big.Int) (*types.Transaction, error) {
	return _Governance.Contract.Execute(&_Governance.TransactOpts, proposalId)
}

// Propose is a paid mutator transaction binding the contract method 0xfaa525f3.
//
// Solidity: function propose(uint8 category, uint256 discussionIndex, string text, uint256[] values) returns()
func (_Governance *GovernanceTransactor) Propose(opts *bind.TransactOpts, category uint8, discussionIndex *big.Int, text string, values []*big.Int) (*types.Transaction, error) {
	return _Governance.contract.Transact(opts, "propose", category, discussionIndex, text, values)
}

// Propose is a paid mutator transaction binding the contract method 0xfaa525f3.
//
// Solidity: function propose(uint8 category, uint256 discussionIndex, string text, uint256[] values) returns()
func (_Governance *GovernanceSession) Propose(category uint8, discussionIndex *big.Int, text string, values []*big.Int) (*types.Transaction, error) {
	return _Governance.Contract.Propose(&_Governance.TransactOpts, category, discussionIndex, text, values)
}

// Propose is a paid mutator transaction binding the contract method 0xfaa525f3.
//
// Solidity: function propose(uint8 category, uint256 discussionIndex, string text, uint256[] values) returns()
func (_Governance *GovernanceTransactorSession) Propose(category uint8, discussionIndex *big.Int, text string, values []*big.Int) (*types.Transaction, error) {
	return _Governance.Contract.Propose(&_Governance.TransactOpts, category, discussionIndex, text, values)
}

// Renew1stActiveProposal is a paid mutator transaction binding the contract method 0x78b1e189.
//
// Solidity: function renew1stActiveProposal() returns(uint256 i)
func (_Governance *GovernanceTransactor) Renew1stActiveProposal(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Governance.contract.Transact(opts, "renew1stActiveProposal")
}

// Renew1stActiveProposal is a paid mutator transaction binding the contract method 0x78b1e189.
//
// Solidity: function renew1stActiveProposal() returns(uint256 i)
func (_Governance *GovernanceSession) Renew1stActiveProposal() (*types.Transaction, error) {
	return _Governance.Contract.Renew1stActiveProposal(&_Governance.TransactOpts)
}

// Renew1stActiveProposal is a paid mutator transaction binding the contract method 0x78b1e189.
//
// Solidity: function renew1stActiveProposal() returns(uint256 i)
func (_Governance *GovernanceTransactorSession) Renew1stActiveProposal() (*types.Transaction, error) {
	return _Governance.Contract.Renew1stActiveProposal(&_Governance.TransactOpts)
}

// SetContractAddrs is a paid mutator transaction binding the contract method 0x4f414711.
//
// Solidity: function setContractAddrs(address new_filLiquid, address new_fitStake, address new_tokenFILGovernance) returns()
func (_Governance *GovernanceTransactor) SetContractAddrs(opts *bind.TransactOpts, new_filLiquid common.Address, new_fitStake common.Address, new_tokenFILGovernance common.Address) (*types.Transaction, error) {
	return _Governance.contract.Transact(opts, "setContractAddrs", new_filLiquid, new_fitStake, new_tokenFILGovernance)
}

// SetContractAddrs is a paid mutator transaction binding the contract method 0x4f414711.
//
// Solidity: function setContractAddrs(address new_filLiquid, address new_fitStake, address new_tokenFILGovernance) returns()
func (_Governance *GovernanceSession) SetContractAddrs(new_filLiquid common.Address, new_fitStake common.Address, new_tokenFILGovernance common.Address) (*types.Transaction, error) {
	return _Governance.Contract.SetContractAddrs(&_Governance.TransactOpts, new_filLiquid, new_fitStake, new_tokenFILGovernance)
}

// SetContractAddrs is a paid mutator transaction binding the contract method 0x4f414711.
//
// Solidity: function setContractAddrs(address new_filLiquid, address new_fitStake, address new_tokenFILGovernance) returns()
func (_Governance *GovernanceTransactorSession) SetContractAddrs(new_filLiquid common.Address, new_fitStake common.Address, new_tokenFILGovernance common.Address) (*types.Transaction, error) {
	return _Governance.Contract.SetContractAddrs(&_Governance.TransactOpts, new_filLiquid, new_fitStake, new_tokenFILGovernance)
}

// SetFactors is a paid mutator transaction binding the contract method 0x819361a1.
//
// Solidity: function setFactors(uint256 new_rateBase, uint256 new_minYes, uint256 new_maxNo, uint256 new_maxNoWithVeto, uint256 new_quorum, uint256 new_liquidate, uint256 new_depositRatioThreshold, uint256 new_depositAmountThreshold, uint256 new_voteThreshold, uint256 new_votingPeriod, uint256 new_executionPeriod, uint256 new_maxActiveProposals) returns()
func (_Governance *GovernanceTransactor) SetFactors(opts *bind.TransactOpts, new_rateBase *big.Int, new_minYes *big.Int, new_maxNo *big.Int, new_maxNoWithVeto *big.Int, new_quorum *big.Int, new_liquidate *big.Int, new_depositRatioThreshold *big.Int, new_depositAmountThreshold *big.Int, new_voteThreshold *big.Int, new_votingPeriod *big.Int, new_executionPeriod *big.Int, new_maxActiveProposals *big.Int) (*types.Transaction, error) {
	return _Governance.contract.Transact(opts, "setFactors", new_rateBase, new_minYes, new_maxNo, new_maxNoWithVeto, new_quorum, new_liquidate, new_depositRatioThreshold, new_depositAmountThreshold, new_voteThreshold, new_votingPeriod, new_executionPeriod, new_maxActiveProposals)
}

// SetFactors is a paid mutator transaction binding the contract method 0x819361a1.
//
// Solidity: function setFactors(uint256 new_rateBase, uint256 new_minYes, uint256 new_maxNo, uint256 new_maxNoWithVeto, uint256 new_quorum, uint256 new_liquidate, uint256 new_depositRatioThreshold, uint256 new_depositAmountThreshold, uint256 new_voteThreshold, uint256 new_votingPeriod, uint256 new_executionPeriod, uint256 new_maxActiveProposals) returns()
func (_Governance *GovernanceSession) SetFactors(new_rateBase *big.Int, new_minYes *big.Int, new_maxNo *big.Int, new_maxNoWithVeto *big.Int, new_quorum *big.Int, new_liquidate *big.Int, new_depositRatioThreshold *big.Int, new_depositAmountThreshold *big.Int, new_voteThreshold *big.Int, new_votingPeriod *big.Int, new_executionPeriod *big.Int, new_maxActiveProposals *big.Int) (*types.Transaction, error) {
	return _Governance.Contract.SetFactors(&_Governance.TransactOpts, new_rateBase, new_minYes, new_maxNo, new_maxNoWithVeto, new_quorum, new_liquidate, new_depositRatioThreshold, new_depositAmountThreshold, new_voteThreshold, new_votingPeriod, new_executionPeriod, new_maxActiveProposals)
}

// SetFactors is a paid mutator transaction binding the contract method 0x819361a1.
//
// Solidity: function setFactors(uint256 new_rateBase, uint256 new_minYes, uint256 new_maxNo, uint256 new_maxNoWithVeto, uint256 new_quorum, uint256 new_liquidate, uint256 new_depositRatioThreshold, uint256 new_depositAmountThreshold, uint256 new_voteThreshold, uint256 new_votingPeriod, uint256 new_executionPeriod, uint256 new_maxActiveProposals) returns()
func (_Governance *GovernanceTransactorSession) SetFactors(new_rateBase *big.Int, new_minYes *big.Int, new_maxNo *big.Int, new_maxNoWithVeto *big.Int, new_quorum *big.Int, new_liquidate *big.Int, new_depositRatioThreshold *big.Int, new_depositAmountThreshold *big.Int, new_voteThreshold *big.Int, new_votingPeriod *big.Int, new_executionPeriod *big.Int, new_maxActiveProposals *big.Int) (*types.Transaction, error) {
	return _Governance.Contract.SetFactors(&_Governance.TransactOpts, new_rateBase, new_minYes, new_maxNo, new_maxNoWithVeto, new_quorum, new_liquidate, new_depositRatioThreshold, new_depositAmountThreshold, new_voteThreshold, new_votingPeriod, new_executionPeriod, new_maxActiveProposals)
}

// SetOwner is a paid mutator transaction binding the contract method 0x13af4035.
//
// Solidity: function setOwner(address new_owner) returns(address)
func (_Governance *GovernanceTransactor) SetOwner(opts *bind.TransactOpts, new_owner common.Address) (*types.Transaction, error) {
	return _Governance.contract.Transact(opts, "setOwner", new_owner)
}

// SetOwner is a paid mutator transaction binding the contract method 0x13af4035.
//
// Solidity: function setOwner(address new_owner) returns(address)
func (_Governance *GovernanceSession) SetOwner(new_owner common.Address) (*types.Transaction, error) {
	return _Governance.Contract.SetOwner(&_Governance.TransactOpts, new_owner)
}

// SetOwner is a paid mutator transaction binding the contract method 0x13af4035.
//
// Solidity: function setOwner(address new_owner) returns(address)
func (_Governance *GovernanceTransactorSession) SetOwner(new_owner common.Address) (*types.Transaction, error) {
	return _Governance.Contract.SetOwner(&_Governance.TransactOpts, new_owner)
}

// Unbond is a paid mutator transaction binding the contract method 0x27de9e32.
//
// Solidity: function unbond(uint256 amount) returns()
func (_Governance *GovernanceTransactor) Unbond(opts *bind.TransactOpts, amount *big.Int) (*types.Transaction, error) {
	return _Governance.contract.Transact(opts, "unbond", amount)
}

// Unbond is a paid mutator transaction binding the contract method 0x27de9e32.
//
// Solidity: function unbond(uint256 amount) returns()
func (_Governance *GovernanceSession) Unbond(amount *big.Int) (*types.Transaction, error) {
	return _Governance.Contract.Unbond(&_Governance.TransactOpts, amount)
}

// Unbond is a paid mutator transaction binding the contract method 0x27de9e32.
//
// Solidity: function unbond(uint256 amount) returns()
func (_Governance *GovernanceTransactorSession) Unbond(amount *big.Int) (*types.Transaction, error) {
	return _Governance.Contract.Unbond(&_Governance.TransactOpts, amount)
}

// Vote is a paid mutator transaction binding the contract method 0xe520251a.
//
// Solidity: function vote(uint256 proposalId, uint8 category, uint256 amount) returns()
func (_Governance *GovernanceTransactor) Vote(opts *bind.TransactOpts, proposalId *big.Int, category uint8, amount *big.Int) (*types.Transaction, error) {
	return _Governance.contract.Transact(opts, "vote", proposalId, category, amount)
}

// Vote is a paid mutator transaction binding the contract method 0xe520251a.
//
// Solidity: function vote(uint256 proposalId, uint8 category, uint256 amount) returns()
func (_Governance *GovernanceSession) Vote(proposalId *big.Int, category uint8, amount *big.Int) (*types.Transaction, error) {
	return _Governance.Contract.Vote(&_Governance.TransactOpts, proposalId, category, amount)
}

// Vote is a paid mutator transaction binding the contract method 0xe520251a.
//
// Solidity: function vote(uint256 proposalId, uint8 category, uint256 amount) returns()
func (_Governance *GovernanceTransactorSession) Vote(proposalId *big.Int, category uint8, amount *big.Int) (*types.Transaction, error) {
	return _Governance.Contract.Vote(&_Governance.TransactOpts, proposalId, category, amount)
}

// VotingProposalSum is a paid mutator transaction binding the contract method 0x2faf60e3.
//
// Solidity: function votingProposalSum(address bonder) returns(uint256 count, uint256 maxVote)
func (_Governance *GovernanceTransactor) VotingProposalSum(opts *bind.TransactOpts, bonder common.Address) (*types.Transaction, error) {
	return _Governance.contract.Transact(opts, "votingProposalSum", bonder)
}

// VotingProposalSum is a paid mutator transaction binding the contract method 0x2faf60e3.
//
// Solidity: function votingProposalSum(address bonder) returns(uint256 count, uint256 maxVote)
func (_Governance *GovernanceSession) VotingProposalSum(bonder common.Address) (*types.Transaction, error) {
	return _Governance.Contract.VotingProposalSum(&_Governance.TransactOpts, bonder)
}

// VotingProposalSum is a paid mutator transaction binding the contract method 0x2faf60e3.
//
// Solidity: function votingProposalSum(address bonder) returns(uint256 count, uint256 maxVote)
func (_Governance *GovernanceTransactorSession) VotingProposalSum(bonder common.Address) (*types.Transaction, error) {
	return _Governance.Contract.VotingProposalSum(&_Governance.TransactOpts, bonder)
}

// GovernanceBondedIterator is returned from FilterBonded and is used to iterate over the raw logs and unpacked data for Bonded events raised by the Governance contract.
type GovernanceBondedIterator struct {
	Event *GovernanceBonded // Event containing the contract specifics and raw log

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
func (it *GovernanceBondedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(GovernanceBonded)
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
		it.Event = new(GovernanceBonded)
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
func (it *GovernanceBondedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *GovernanceBondedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// GovernanceBonded represents a Bonded event raised by the Governance contract.
type GovernanceBonded struct {
	Bonder common.Address
	Amount *big.Int
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterBonded is a free log retrieval operation binding the contract event 0xd0a009034e24a39106653c4903cf28b1947b8a9964d03206648e0f0a5de74a46.
//
// Solidity: event Bonded(address indexed bonder, uint256 amount)
func (_Governance *GovernanceFilterer) FilterBonded(opts *bind.FilterOpts, bonder []common.Address) (*GovernanceBondedIterator, error) {

	var bonderRule []interface{}
	for _, bonderItem := range bonder {
		bonderRule = append(bonderRule, bonderItem)
	}

	logs, sub, err := _Governance.contract.FilterLogs(opts, "Bonded", bonderRule)
	if err != nil {
		return nil, err
	}
	return &GovernanceBondedIterator{contract: _Governance.contract, event: "Bonded", logs: logs, sub: sub}, nil
}

// WatchBonded is a free log subscription operation binding the contract event 0xd0a009034e24a39106653c4903cf28b1947b8a9964d03206648e0f0a5de74a46.
//
// Solidity: event Bonded(address indexed bonder, uint256 amount)
func (_Governance *GovernanceFilterer) WatchBonded(opts *bind.WatchOpts, sink chan<- *GovernanceBonded, bonder []common.Address) (event.Subscription, error) {

	var bonderRule []interface{}
	for _, bonderItem := range bonder {
		bonderRule = append(bonderRule, bonderItem)
	}

	logs, sub, err := _Governance.contract.WatchLogs(opts, "Bonded", bonderRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(GovernanceBonded)
				if err := _Governance.contract.UnpackLog(event, "Bonded", log); err != nil {
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

// ParseBonded is a log parse operation binding the contract event 0xd0a009034e24a39106653c4903cf28b1947b8a9964d03206648e0f0a5de74a46.
//
// Solidity: event Bonded(address indexed bonder, uint256 amount)
func (_Governance *GovernanceFilterer) ParseBonded(log types.Log) (*GovernanceBonded, error) {
	event := new(GovernanceBonded)
	if err := _Governance.contract.UnpackLog(event, "Bonded", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// GovernanceContractAddrsChangedIterator is returned from FilterContractAddrsChanged and is used to iterate over the raw logs and unpacked data for ContractAddrsChanged events raised by the Governance contract.
type GovernanceContractAddrsChangedIterator struct {
	Event *GovernanceContractAddrsChanged // Event containing the contract specifics and raw log

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
func (it *GovernanceContractAddrsChangedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(GovernanceContractAddrsChanged)
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
		it.Event = new(GovernanceContractAddrsChanged)
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
func (it *GovernanceContractAddrsChangedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *GovernanceContractAddrsChangedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// GovernanceContractAddrsChanged represents a ContractAddrsChanged event raised by the Governance contract.
type GovernanceContractAddrsChanged struct {
	NewFilLiquid          common.Address
	NewFitStake           common.Address
	NewTokenFILGovernance common.Address
	Raw                   types.Log // Blockchain specific contextual infos
}

// FilterContractAddrsChanged is a free log retrieval operation binding the contract event 0x4417ad5e4ad3f00e9ccbc31840d22d4c772bc58371c22fe7814ac5612aed46c8.
//
// Solidity: event ContractAddrsChanged(address new_filLiquid, address new_fitStake, address new_tokenFILGovernance)
func (_Governance *GovernanceFilterer) FilterContractAddrsChanged(opts *bind.FilterOpts) (*GovernanceContractAddrsChangedIterator, error) {

	logs, sub, err := _Governance.contract.FilterLogs(opts, "ContractAddrsChanged")
	if err != nil {
		return nil, err
	}
	return &GovernanceContractAddrsChangedIterator{contract: _Governance.contract, event: "ContractAddrsChanged", logs: logs, sub: sub}, nil
}

// WatchContractAddrsChanged is a free log subscription operation binding the contract event 0x4417ad5e4ad3f00e9ccbc31840d22d4c772bc58371c22fe7814ac5612aed46c8.
//
// Solidity: event ContractAddrsChanged(address new_filLiquid, address new_fitStake, address new_tokenFILGovernance)
func (_Governance *GovernanceFilterer) WatchContractAddrsChanged(opts *bind.WatchOpts, sink chan<- *GovernanceContractAddrsChanged) (event.Subscription, error) {

	logs, sub, err := _Governance.contract.WatchLogs(opts, "ContractAddrsChanged")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(GovernanceContractAddrsChanged)
				if err := _Governance.contract.UnpackLog(event, "ContractAddrsChanged", log); err != nil {
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

// ParseContractAddrsChanged is a log parse operation binding the contract event 0x4417ad5e4ad3f00e9ccbc31840d22d4c772bc58371c22fe7814ac5612aed46c8.
//
// Solidity: event ContractAddrsChanged(address new_filLiquid, address new_fitStake, address new_tokenFILGovernance)
func (_Governance *GovernanceFilterer) ParseContractAddrsChanged(log types.Log) (*GovernanceContractAddrsChanged, error) {
	event := new(GovernanceContractAddrsChanged)
	if err := _Governance.contract.UnpackLog(event, "ContractAddrsChanged", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// GovernanceExecutedIterator is returned from FilterExecuted and is used to iterate over the raw logs and unpacked data for Executed events raised by the Governance contract.
type GovernanceExecutedIterator struct {
	Event *GovernanceExecuted // Event containing the contract specifics and raw log

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
func (it *GovernanceExecutedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(GovernanceExecuted)
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
		it.Event = new(GovernanceExecuted)
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
func (it *GovernanceExecutedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *GovernanceExecutedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// GovernanceExecuted represents a Executed event raised by the Governance contract.
type GovernanceExecuted struct {
	Executor   common.Address
	ProposalId *big.Int
	Result     uint8
	Raw        types.Log // Blockchain specific contextual infos
}

// FilterExecuted is a free log retrieval operation binding the contract event 0x5732b45b4bf13341d749e465ed724d2b147b95fee2e3578c2d62865a8d417bf7.
//
// Solidity: event Executed(address indexed executor, uint256 indexed proposalId, uint8 result)
func (_Governance *GovernanceFilterer) FilterExecuted(opts *bind.FilterOpts, executor []common.Address, proposalId []*big.Int) (*GovernanceExecutedIterator, error) {

	var executorRule []interface{}
	for _, executorItem := range executor {
		executorRule = append(executorRule, executorItem)
	}
	var proposalIdRule []interface{}
	for _, proposalIdItem := range proposalId {
		proposalIdRule = append(proposalIdRule, proposalIdItem)
	}

	logs, sub, err := _Governance.contract.FilterLogs(opts, "Executed", executorRule, proposalIdRule)
	if err != nil {
		return nil, err
	}
	return &GovernanceExecutedIterator{contract: _Governance.contract, event: "Executed", logs: logs, sub: sub}, nil
}

// WatchExecuted is a free log subscription operation binding the contract event 0x5732b45b4bf13341d749e465ed724d2b147b95fee2e3578c2d62865a8d417bf7.
//
// Solidity: event Executed(address indexed executor, uint256 indexed proposalId, uint8 result)
func (_Governance *GovernanceFilterer) WatchExecuted(opts *bind.WatchOpts, sink chan<- *GovernanceExecuted, executor []common.Address, proposalId []*big.Int) (event.Subscription, error) {

	var executorRule []interface{}
	for _, executorItem := range executor {
		executorRule = append(executorRule, executorItem)
	}
	var proposalIdRule []interface{}
	for _, proposalIdItem := range proposalId {
		proposalIdRule = append(proposalIdRule, proposalIdItem)
	}

	logs, sub, err := _Governance.contract.WatchLogs(opts, "Executed", executorRule, proposalIdRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(GovernanceExecuted)
				if err := _Governance.contract.UnpackLog(event, "Executed", log); err != nil {
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

// ParseExecuted is a log parse operation binding the contract event 0x5732b45b4bf13341d749e465ed724d2b147b95fee2e3578c2d62865a8d417bf7.
//
// Solidity: event Executed(address indexed executor, uint256 indexed proposalId, uint8 result)
func (_Governance *GovernanceFilterer) ParseExecuted(log types.Log) (*GovernanceExecuted, error) {
	event := new(GovernanceExecuted)
	if err := _Governance.contract.UnpackLog(event, "Executed", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// GovernanceFactorsChangedIterator is returned from FilterFactorsChanged and is used to iterate over the raw logs and unpacked data for FactorsChanged events raised by the Governance contract.
type GovernanceFactorsChangedIterator struct {
	Event *GovernanceFactorsChanged // Event containing the contract specifics and raw log

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
func (it *GovernanceFactorsChangedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(GovernanceFactorsChanged)
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
		it.Event = new(GovernanceFactorsChanged)
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
func (it *GovernanceFactorsChangedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *GovernanceFactorsChangedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// GovernanceFactorsChanged represents a FactorsChanged event raised by the Governance contract.
type GovernanceFactorsChanged struct {
	NewRateBase               *big.Int
	NewMinYes                 *big.Int
	NewMaxNo                  *big.Int
	NewMaxNoWithVeto          *big.Int
	NewQuorum                 *big.Int
	NewLiquidate              *big.Int
	NewDepositRatioThreshold  *big.Int
	NewDepositAmountThreshold *big.Int
	NewVoteThreshold          *big.Int
	NewVotingPeriod           *big.Int
	NewExecutionPeriod        *big.Int
	NewMaxActiveProposals     *big.Int
	Raw                       types.Log // Blockchain specific contextual infos
}

// FilterFactorsChanged is a free log retrieval operation binding the contract event 0x623dd5e9c3b74e503c581f496bbd12b9f4a40c6846fcb9c684be062e98265b68.
//
// Solidity: event FactorsChanged(uint256 new_rateBase, uint256 new_minYes, uint256 new_maxNo, uint256 new_maxNoWithVeto, uint256 new_quorum, uint256 new_liquidate, uint256 new_depositRatioThreshold, uint256 new_depositAmountThreshold, uint256 new_voteThreshold, uint256 new_votingPeriod, uint256 new_executionPeriod, uint256 new_maxActiveProposals)
func (_Governance *GovernanceFilterer) FilterFactorsChanged(opts *bind.FilterOpts) (*GovernanceFactorsChangedIterator, error) {

	logs, sub, err := _Governance.contract.FilterLogs(opts, "FactorsChanged")
	if err != nil {
		return nil, err
	}
	return &GovernanceFactorsChangedIterator{contract: _Governance.contract, event: "FactorsChanged", logs: logs, sub: sub}, nil
}

// WatchFactorsChanged is a free log subscription operation binding the contract event 0x623dd5e9c3b74e503c581f496bbd12b9f4a40c6846fcb9c684be062e98265b68.
//
// Solidity: event FactorsChanged(uint256 new_rateBase, uint256 new_minYes, uint256 new_maxNo, uint256 new_maxNoWithVeto, uint256 new_quorum, uint256 new_liquidate, uint256 new_depositRatioThreshold, uint256 new_depositAmountThreshold, uint256 new_voteThreshold, uint256 new_votingPeriod, uint256 new_executionPeriod, uint256 new_maxActiveProposals)
func (_Governance *GovernanceFilterer) WatchFactorsChanged(opts *bind.WatchOpts, sink chan<- *GovernanceFactorsChanged) (event.Subscription, error) {

	logs, sub, err := _Governance.contract.WatchLogs(opts, "FactorsChanged")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(GovernanceFactorsChanged)
				if err := _Governance.contract.UnpackLog(event, "FactorsChanged", log); err != nil {
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

// ParseFactorsChanged is a log parse operation binding the contract event 0x623dd5e9c3b74e503c581f496bbd12b9f4a40c6846fcb9c684be062e98265b68.
//
// Solidity: event FactorsChanged(uint256 new_rateBase, uint256 new_minYes, uint256 new_maxNo, uint256 new_maxNoWithVeto, uint256 new_quorum, uint256 new_liquidate, uint256 new_depositRatioThreshold, uint256 new_depositAmountThreshold, uint256 new_voteThreshold, uint256 new_votingPeriod, uint256 new_executionPeriod, uint256 new_maxActiveProposals)
func (_Governance *GovernanceFilterer) ParseFactorsChanged(log types.Log) (*GovernanceFactorsChanged, error) {
	event := new(GovernanceFactorsChanged)
	if err := _Governance.contract.UnpackLog(event, "FactorsChanged", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// GovernanceOwnerChangedIterator is returned from FilterOwnerChanged and is used to iterate over the raw logs and unpacked data for OwnerChanged events raised by the Governance contract.
type GovernanceOwnerChangedIterator struct {
	Event *GovernanceOwnerChanged // Event containing the contract specifics and raw log

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
func (it *GovernanceOwnerChangedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(GovernanceOwnerChanged)
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
		it.Event = new(GovernanceOwnerChanged)
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
func (it *GovernanceOwnerChangedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *GovernanceOwnerChangedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// GovernanceOwnerChanged represents a OwnerChanged event raised by the Governance contract.
type GovernanceOwnerChanged struct {
	Account common.Address
	Raw     types.Log // Blockchain specific contextual infos
}

// FilterOwnerChanged is a free log retrieval operation binding the contract event 0xa2ea9883a321a3e97b8266c2b078bfeec6d50c711ed71f874a90d500ae2eaf36.
//
// Solidity: event OwnerChanged(address indexed account)
func (_Governance *GovernanceFilterer) FilterOwnerChanged(opts *bind.FilterOpts, account []common.Address) (*GovernanceOwnerChangedIterator, error) {

	var accountRule []interface{}
	for _, accountItem := range account {
		accountRule = append(accountRule, accountItem)
	}

	logs, sub, err := _Governance.contract.FilterLogs(opts, "OwnerChanged", accountRule)
	if err != nil {
		return nil, err
	}
	return &GovernanceOwnerChangedIterator{contract: _Governance.contract, event: "OwnerChanged", logs: logs, sub: sub}, nil
}

// WatchOwnerChanged is a free log subscription operation binding the contract event 0xa2ea9883a321a3e97b8266c2b078bfeec6d50c711ed71f874a90d500ae2eaf36.
//
// Solidity: event OwnerChanged(address indexed account)
func (_Governance *GovernanceFilterer) WatchOwnerChanged(opts *bind.WatchOpts, sink chan<- *GovernanceOwnerChanged, account []common.Address) (event.Subscription, error) {

	var accountRule []interface{}
	for _, accountItem := range account {
		accountRule = append(accountRule, accountItem)
	}

	logs, sub, err := _Governance.contract.WatchLogs(opts, "OwnerChanged", accountRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(GovernanceOwnerChanged)
				if err := _Governance.contract.UnpackLog(event, "OwnerChanged", log); err != nil {
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
func (_Governance *GovernanceFilterer) ParseOwnerChanged(log types.Log) (*GovernanceOwnerChanged, error) {
	event := new(GovernanceOwnerChanged)
	if err := _Governance.contract.UnpackLog(event, "OwnerChanged", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// GovernanceProposedIterator is returned from FilterProposed and is used to iterate over the raw logs and unpacked data for Proposed events raised by the Governance contract.
type GovernanceProposedIterator struct {
	Event *GovernanceProposed // Event containing the contract specifics and raw log

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
func (it *GovernanceProposedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(GovernanceProposed)
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
		it.Event = new(GovernanceProposed)
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
func (it *GovernanceProposedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *GovernanceProposedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// GovernanceProposed represents a Proposed event raised by the Governance contract.
type GovernanceProposed struct {
	Proposer        common.Address
	ProposalId      *big.Int
	DiscussionIndex *big.Int
	Category        uint8
	Deadline        *big.Int
	Deposited       *big.Int
	Text            string
	Values          []*big.Int
	Raw             types.Log // Blockchain specific contextual infos
}

// FilterProposed is a free log retrieval operation binding the contract event 0x79375c338b1530ad22e970695f07089e99c3aeedd830fdd2f3c77df06db831db.
//
// Solidity: event Proposed(address indexed proposer, uint256 indexed proposalId, uint256 indexed discussionIndex, uint8 category, uint256 deadline, uint256 deposited, string text, uint256[] values)
func (_Governance *GovernanceFilterer) FilterProposed(opts *bind.FilterOpts, proposer []common.Address, proposalId []*big.Int, discussionIndex []*big.Int) (*GovernanceProposedIterator, error) {

	var proposerRule []interface{}
	for _, proposerItem := range proposer {
		proposerRule = append(proposerRule, proposerItem)
	}
	var proposalIdRule []interface{}
	for _, proposalIdItem := range proposalId {
		proposalIdRule = append(proposalIdRule, proposalIdItem)
	}
	var discussionIndexRule []interface{}
	for _, discussionIndexItem := range discussionIndex {
		discussionIndexRule = append(discussionIndexRule, discussionIndexItem)
	}

	logs, sub, err := _Governance.contract.FilterLogs(opts, "Proposed", proposerRule, proposalIdRule, discussionIndexRule)
	if err != nil {
		return nil, err
	}
	return &GovernanceProposedIterator{contract: _Governance.contract, event: "Proposed", logs: logs, sub: sub}, nil
}

// WatchProposed is a free log subscription operation binding the contract event 0x79375c338b1530ad22e970695f07089e99c3aeedd830fdd2f3c77df06db831db.
//
// Solidity: event Proposed(address indexed proposer, uint256 indexed proposalId, uint256 indexed discussionIndex, uint8 category, uint256 deadline, uint256 deposited, string text, uint256[] values)
func (_Governance *GovernanceFilterer) WatchProposed(opts *bind.WatchOpts, sink chan<- *GovernanceProposed, proposer []common.Address, proposalId []*big.Int, discussionIndex []*big.Int) (event.Subscription, error) {

	var proposerRule []interface{}
	for _, proposerItem := range proposer {
		proposerRule = append(proposerRule, proposerItem)
	}
	var proposalIdRule []interface{}
	for _, proposalIdItem := range proposalId {
		proposalIdRule = append(proposalIdRule, proposalIdItem)
	}
	var discussionIndexRule []interface{}
	for _, discussionIndexItem := range discussionIndex {
		discussionIndexRule = append(discussionIndexRule, discussionIndexItem)
	}

	logs, sub, err := _Governance.contract.WatchLogs(opts, "Proposed", proposerRule, proposalIdRule, discussionIndexRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(GovernanceProposed)
				if err := _Governance.contract.UnpackLog(event, "Proposed", log); err != nil {
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

// ParseProposed is a log parse operation binding the contract event 0x79375c338b1530ad22e970695f07089e99c3aeedd830fdd2f3c77df06db831db.
//
// Solidity: event Proposed(address indexed proposer, uint256 indexed proposalId, uint256 indexed discussionIndex, uint8 category, uint256 deadline, uint256 deposited, string text, uint256[] values)
func (_Governance *GovernanceFilterer) ParseProposed(log types.Log) (*GovernanceProposed, error) {
	event := new(GovernanceProposed)
	if err := _Governance.contract.UnpackLog(event, "Proposed", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// GovernanceUnbondedIterator is returned from FilterUnbonded and is used to iterate over the raw logs and unpacked data for Unbonded events raised by the Governance contract.
type GovernanceUnbondedIterator struct {
	Event *GovernanceUnbonded // Event containing the contract specifics and raw log

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
func (it *GovernanceUnbondedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(GovernanceUnbonded)
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
		it.Event = new(GovernanceUnbonded)
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
func (it *GovernanceUnbondedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *GovernanceUnbondedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// GovernanceUnbonded represents a Unbonded event raised by the Governance contract.
type GovernanceUnbonded struct {
	Bonder common.Address
	Amount *big.Int
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterUnbonded is a free log retrieval operation binding the contract event 0xd24dbf5e9299ce53c3aa9f7227ff1cc8441c2faae04509aa370ca3703385d6b4.
//
// Solidity: event Unbonded(address indexed bonder, uint256 amount)
func (_Governance *GovernanceFilterer) FilterUnbonded(opts *bind.FilterOpts, bonder []common.Address) (*GovernanceUnbondedIterator, error) {

	var bonderRule []interface{}
	for _, bonderItem := range bonder {
		bonderRule = append(bonderRule, bonderItem)
	}

	logs, sub, err := _Governance.contract.FilterLogs(opts, "Unbonded", bonderRule)
	if err != nil {
		return nil, err
	}
	return &GovernanceUnbondedIterator{contract: _Governance.contract, event: "Unbonded", logs: logs, sub: sub}, nil
}

// WatchUnbonded is a free log subscription operation binding the contract event 0xd24dbf5e9299ce53c3aa9f7227ff1cc8441c2faae04509aa370ca3703385d6b4.
//
// Solidity: event Unbonded(address indexed bonder, uint256 amount)
func (_Governance *GovernanceFilterer) WatchUnbonded(opts *bind.WatchOpts, sink chan<- *GovernanceUnbonded, bonder []common.Address) (event.Subscription, error) {

	var bonderRule []interface{}
	for _, bonderItem := range bonder {
		bonderRule = append(bonderRule, bonderItem)
	}

	logs, sub, err := _Governance.contract.WatchLogs(opts, "Unbonded", bonderRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(GovernanceUnbonded)
				if err := _Governance.contract.UnpackLog(event, "Unbonded", log); err != nil {
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

// ParseUnbonded is a log parse operation binding the contract event 0xd24dbf5e9299ce53c3aa9f7227ff1cc8441c2faae04509aa370ca3703385d6b4.
//
// Solidity: event Unbonded(address indexed bonder, uint256 amount)
func (_Governance *GovernanceFilterer) ParseUnbonded(log types.Log) (*GovernanceUnbonded, error) {
	event := new(GovernanceUnbonded)
	if err := _Governance.contract.UnpackLog(event, "Unbonded", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// GovernanceVotedIterator is returned from FilterVoted and is used to iterate over the raw logs and unpacked data for Voted events raised by the Governance contract.
type GovernanceVotedIterator struct {
	Event *GovernanceVoted // Event containing the contract specifics and raw log

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
func (it *GovernanceVotedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(GovernanceVoted)
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
		it.Event = new(GovernanceVoted)
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
func (it *GovernanceVotedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *GovernanceVotedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// GovernanceVoted represents a Voted event raised by the Governance contract.
type GovernanceVoted struct {
	Voter      common.Address
	ProposalId *big.Int
	Category   uint8
	Amount     *big.Int
	Raw        types.Log // Blockchain specific contextual infos
}

// FilterVoted is a free log retrieval operation binding the contract event 0x27eb20ecadc80d52f641a540b295d208f7c3735545d321b08e505116c6013199.
//
// Solidity: event Voted(address indexed voter, uint256 indexed proposalId, uint8 category, uint256 amount)
func (_Governance *GovernanceFilterer) FilterVoted(opts *bind.FilterOpts, voter []common.Address, proposalId []*big.Int) (*GovernanceVotedIterator, error) {

	var voterRule []interface{}
	for _, voterItem := range voter {
		voterRule = append(voterRule, voterItem)
	}
	var proposalIdRule []interface{}
	for _, proposalIdItem := range proposalId {
		proposalIdRule = append(proposalIdRule, proposalIdItem)
	}

	logs, sub, err := _Governance.contract.FilterLogs(opts, "Voted", voterRule, proposalIdRule)
	if err != nil {
		return nil, err
	}
	return &GovernanceVotedIterator{contract: _Governance.contract, event: "Voted", logs: logs, sub: sub}, nil
}

// WatchVoted is a free log subscription operation binding the contract event 0x27eb20ecadc80d52f641a540b295d208f7c3735545d321b08e505116c6013199.
//
// Solidity: event Voted(address indexed voter, uint256 indexed proposalId, uint8 category, uint256 amount)
func (_Governance *GovernanceFilterer) WatchVoted(opts *bind.WatchOpts, sink chan<- *GovernanceVoted, voter []common.Address, proposalId []*big.Int) (event.Subscription, error) {

	var voterRule []interface{}
	for _, voterItem := range voter {
		voterRule = append(voterRule, voterItem)
	}
	var proposalIdRule []interface{}
	for _, proposalIdItem := range proposalId {
		proposalIdRule = append(proposalIdRule, proposalIdItem)
	}

	logs, sub, err := _Governance.contract.WatchLogs(opts, "Voted", voterRule, proposalIdRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(GovernanceVoted)
				if err := _Governance.contract.UnpackLog(event, "Voted", log); err != nil {
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

// ParseVoted is a log parse operation binding the contract event 0x27eb20ecadc80d52f641a540b295d208f7c3735545d321b08e505116c6013199.
//
// Solidity: event Voted(address indexed voter, uint256 indexed proposalId, uint8 category, uint256 amount)
func (_Governance *GovernanceFilterer) ParseVoted(log types.Log) (*GovernanceVoted, error) {
	event := new(GovernanceVoted)
	if err := _Governance.contract.UnpackLog(event, "Voted", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
