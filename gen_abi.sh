#!bin/bash

abigen --abi=goabi/fil_liquid.abi --pkg=liquid -out=goabi/fil_liquid_abi.go
abigen --abi=goabi/governance.abi --pkg=governance -out=goabi/governance_abi.go
abigen --abi=goabi/fit_stake.abi --pkg=fitstake -out=goabi/fit_stake_abi.go
abigen --abi=goabi/batch_transfer.abi --pkg=batch -out=goabi/batch_transfer_abi.go
abigen --abi=goabi/claim.abi --pkg=claim -out=goabi/claim_abi.go
abigen --abi=goabi/fig_stake.abi --pkg=figstake -out=goabi/fig_stake_abi.go
