module DELEGATION_2_0_API
  imports DOMAINS

//Based on : https://docs.google.com/spreadsheets/d/12l9mbl0_NsymEJukWHIvIHzJ4YwHHK7HS_9FlrF_qh4
//todo: return value for eahfunction, who can call, other annotations
syntax KItem ::=
    init ( totalDelegationCap:Int, serviceFee:Int )
  | updateRewards ( rewardsForEpoch:Int )
  | changeServiceFee ( serviceFee:Decimal )
  | getServiceFee ( )
  | modifyTotalDelegationCap ( newDelegationCap:Int )
  | getTotalDelegationCap ( )
  | addNodes ( blsEntries: BLSKeySigList )
  | removeNodes ( blsKeys: BLSKeyList )
  | stakeNodes ( blsKeys: BLSKeyList )
  | unStakeNodes ( blsKeys: BLSKeyList )
  | unBondNodes ( blsKeys: BLSKeyList )
  | unJailNodes ( blsKeys: BLSKeyList )
  | getNumNodes ( )
  | getAllNodeStates ( )
  | getUnBondable ( delegator: Address )
  | totalStake ( )
  | getUserActiveStake ( delegator: Address )
  | getUserUnstakedStake ( delegator: Address )
  | getTotalActiveStake ( )
  | getTotalUnstakedStake ( )
  | getNumUsers ( )
  | getUserStake ( delegator: Address )
  | getUserStakeByType ( delegator: Address )
  | delegate ( ) //amount is probably not argument but call value
  | unDelegate ( amount:Int )
  | withdraw ( )
  | getTotalUnclaimedRewards ( )
  | getTotalCumulatedRewards ( )
  | getClaimableRewards ( delegator: Address )
  | claimRewards ( )


syntax Decimal ::= Int //Fixed-point rational, to be divided by 10000

syntax Address ::= Int
syntax BLSKeySigList::= List { BLSKeySig, "," }
syntax BLSKeySig ::= blsKeySig(key:Bytes, sig:Bytes)
syntax BLSKeyList::= List { Bytes, "," }

endmodule
