module DELEGATION_2_0_API
  imports DOMAINS

//Based on : https://docs.google.com/spreadsheets/d/12l9mbl0_NsymEJukWHIvIHzJ4YwHHK7HS_9FlrF_qh4

//Public functions
//---------------------

//todo: who can call, other annotations
//todo view functions are not necessarily K functions
syntax KItem ::=
    init ( totalDelegationCap: Funds, serviceFee: Decimal )
  | updateRewards ( rewardsForEpoch: Funds )
  | changeServiceFee ( serviceFee:Decimal )
  | modifyTotalDelegationCap ( newDelegationCap: Funds )
  | addNodes ( blsEntries: BLSKeySigList )
  | removeNodes ( blsKeys: BLSKeyList )
  | stakeNodes ( blsKeys: BLSKeyList )
  | unStakeNodes ( blsKeys: BLSKeyList )
  | unBondNodes ( blsKeys: BLSKeyList )
  | unJailNodes ( blsKeys: BLSKeyList )

syntax Decimal ::=
    getServiceFee ( )
syntax Int ::=
    getTotalDelegationCap ( )
  | getNumNodes ( )

syntax Map ::=
  getAllNodeStates ( ) //Map[BLSKey -> NodeState]

syntax Funds ::= getUserUnBondable ( delegator: Address )
  | getUserActiveStake ( delegator: Address )
  | getUserUnStakedValue ( delegator: Address )
  | getTotalActiveStake ( )
  | getTotalUnStaked ( )

syntax Int ::=
    getNumUsers ( )

syntax Funds ::=
    getTotalCumulatedRewards() //todo check return type
  | getClaimableRewards( delegator: Address )

syntax KItem ::=
    delegate ( ) //todo amount is probably not argument but call value
  | unDelegate ( amount:Funds ) //caller address must be delegator
  | withdraw ( )                //caller address must be delegator
  | claimRewards ( )            //caller address must be delegator

syntax Funds ::=
    getTotalUnStakedFromNodes ( )
  | getTotalUnBondedFromNodes ( )

syntax ContractConfig ::=
    getContractConfig ( )

//Types
//---------------------

syntax Decimal ::= Int //Fixed-point rational, to be divided by 10000
syntax Funds   ::= Int //Funds may only be integer in Delegator contract.

syntax Address ::= Int
syntax BLSKeySigList::= List { BLSKeySig, "," }
syntax BLSKeySig ::= blsKeySig(key:Bytes, sig:Bytes)
syntax BLSKeyList::= List { Bytes, "," }

syntax NodeState ::= Inactive | Staked | UnStaked

syntax ContractConfig ::= @ContractConfig ( maxDelegationCap:  Funds,
                                            serviceFee:        Decimal,
                                            initialOwnerFunds: Funds,
                                            createdNonce:      Int
                                          )

endmodule
