requires "domains.k"

module CASPER-SYNTAX

  imports INT

  syntax KItem ::= InitializeEpoch(Int)
                 | Deposit(Int, Int, Int)
                 | Logout(Int, Int, Int)
                 | Withdraw(Int)
                 | Vote(Int, Int, Int, Int, Int)
                 | Slash(Int, Int, Int, Int, Int,
                         Int, Int, Int, Int, Int)

endmodule

module CASPER

  imports CASPER-SYNTAX
  imports DOMAINS

  configuration <T>
       <k> .K </k>

       <votesMap>
         <votes multiplicity="*" type="Map">
           <epoch> 0 </epoch>
           <hash>  0 </hash>
           <voted> .Map </voted> // validator_index |-> voted?
           <currDynVotes> .Map </currDynVotes> // source_epoch |-> curr_dyn_votes_count
           <prevDynVotes> .Map </prevDynVotes> // source_epoch |-> prev_dyn_votes_count
           <isJustified> false </isJustified>
           <isFinalized> false </isFinalized>
         </votes>
       </votesMap>

       <validatorMap>
         <validator multiplicity="*" type="Map">
           <index> 0 </index>
           <deposit> 0 </deposit>
           <startDynasty> 0 </startDynasty>
           <endDynasty>   0 </endDynasty>
           <withdrawalAddr> 0 </withdrawalAddr>
         </validator>
       </validatorMap>

       <currentDynasty> 0 </currentDynasty>
       <currentEpoch> 0 </currentEpoch>

       <recommendedTargetHash> 0 </recommendedTargetHash>
       <expectedSourceEpoch> 0 </expectedSourceEpoch>
     //<mainHashJustified> false </mainHashJustified>

       <totalCurrDynDeposits> 0 </totalCurrDynDeposits>
       <totalPrevDynDeposits> 0 </totalPrevDynDeposits>
       <deltaDeposits> .Map </deltaDeposits> // dynasty |-> delta_deposits

       <lastJustifiedEpoch> 0 </lastJustifiedEpoch>
       <lastFinalizedEpoch> 0 </lastFinalizedEpoch>

       <blockNumber> 0 </blockNumber>
       <caller> 0 </caller>

       <rewardFactor> 0 </rewardFactor> // TODO: float
       <depositScaleFactor> .Map </depositScaleFactor> // epoch |-> deposit_scale_factor
       <nextValidatorIndex> 0 </nextValidatorIndex>
       <dynastyStartEpoch> .Map </dynastyStartEpoch> // dynasty |-> start_epoch
  </T>

  rule <k> InitializeEpoch(EPOCH) => updateRewardFactor ~> incrementDynasty ... </k>
       <currentEpoch> CURRENT_EPOCH => EPOCH </currentEpoch>
       <blockNumber> BLOCK_NUMBER </blockNumber>
       requires EPOCH <=Int BLOCK_NUMBER /Int epochLength   // TODO: explain why <=Int instead of ==Int
        andBool EPOCH ==Int CURRENT_EPOCH +Int 1

  syntax KItem ::= "updateRewardFactor"

  rule <k> updateRewardFactor => . ... </k>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <expectedSourceEpoch> SOURCE_EPOCH </expectedSourceEpoch>
       <lastFinalizedEpoch> LAST_FINALIZED_EPOCH </lastFinalizedEpoch>
       <votes>
         <epoch> CURRENT_EPOCH -Int 1 </epoch>
         <currDynVotes> ... SOURCE_EPOCH |-> CURR_DYNASTY_VOTES ... </currDynVotes>
         <prevDynVotes> ... SOURCE_EPOCH |-> PREV_DYNASTY_VOTES ... </prevDynVotes>
         ...
       </votes>
       <totalCurrDynDeposits> TOTAL_CURR_DYN_DEPOSITS </totalCurrDynDeposits>
       <totalPrevDynDeposits> TOTAL_PREV_DYN_DEPOSITS </totalPrevDynDeposits>
       <depositScaleFactor>
         ...
         CURRENT_EPOCH -Int 1 |-> DEPOSIT_SCALE_FACTOR
       (
         .Map
       =>
         CURRENT_EPOCH        |-> DEPOSIT_SCALE_FACTOR *Int (1 +Int collectiveReward(CURR_DYNASTY_VOTES, TOTAL_CURR_DYN_DEPOSITS,
                                                                                     PREV_DYNASTY_VOTES, TOTAL_PREV_DYN_DEPOSITS, REWARD_FACTOR,
                                                                                     CURRENT_EPOCH, LAST_FINALIZED_EPOCH))
                                                       /Int (1 +Int REWARD_FACTOR)
       )
         ...
       </depositScaleFactor>
       <rewardFactor>
         REWARD_FACTOR
       =>
         baseInterestFactor /Int sqrtTotalDeposits(TOTAL_CURR_DYN_DEPOSITS, TOTAL_PREV_DYN_DEPOSITS, DEPOSIT_SCALE_FACTOR)
         +Int basePenaltyFactor *Int (CURRENT_EPOCH -Int LAST_FINALIZED_EPOCH)
       </rewardFactor>
       requires TOTAL_CURR_DYN_DEPOSITS >Int 0
        andBool TOTAL_PREV_DYN_DEPOSITS >Int 0
  // TODO: the case of not deposit_exists()

  syntax Int ::= sqrtTotalDeposits(Int, Int, Int) [function]

  rule sqrtTotalDeposits(TOTAL_CURR_DYN_DEPOSITS, TOTAL_PREV_DYN_DEPOSITS, DEPOSIT_SCALE_FACTOR)
       =>
       sqrt(maxInt(TOTAL_CURR_DYN_DEPOSITS, TOTAL_PREV_DYN_DEPOSITS) *Int DEPOSIT_SCALE_FACTOR /Int etherToWei +Int 1) // TODO: decimal

  syntax Int ::= collectiveReward(Int, Int, Int, Int, Int, Int, Int) [function]

  rule collectiveReward(CURR_DYNASTY_VOTES, TOTAL_CURR_DYN_DEPOSITS,
                        PREV_DYNASTY_VOTES, TOTAL_PREV_DYN_DEPOSITS, REWARD_FACTOR,
                        CURRENT_EPOCH, LAST_FINALIZED_EPOCH)
       =>
       minInt(CURR_DYNASTY_VOTES /Int TOTAL_CURR_DYN_DEPOSITS,
              PREV_DYNASTY_VOTES /Int TOTAL_PREV_DYN_DEPOSITS) *Int REWARD_FACTOR /Int 2
       requires CURRENT_EPOCH -Int LAST_FINALIZED_EPOCH <=Int 2  // TODO: explain why <= instead of ==

  rule collectiveReward(_, _, _, _, _, CURRENT_EPOCH, LAST_FINALIZED_EPOCH) => 0
       requires CURRENT_EPOCH -Int LAST_FINALIZED_EPOCH >Int 2

  syntax KItem ::= "incrementDynasty"

  rule <k> incrementDynasty => updateExpectedSourceEpoch ... </k>
       <currentEpoch> EPOCH </currentEpoch>
       <votes>
         <epoch> EPOCH -Int 2 </epoch>
         <isFinalized> true </isFinalized>
         ...
       </votes>
       <currentDynasty> DYNASTY => DYNASTY +Int 1 </currentDynasty>
       <totalCurrDynDeposits> TOTAL_CURR_DYN_DEPOSITS => TOTAL_CURR_DYN_DEPOSITS +Int DELTA_DEPOSITS </totalCurrDynDeposits>
       <totalPrevDynDeposits> _                       => TOTAL_CURR_DYN_DEPOSITS </totalPrevDynDeposits>
       <deltaDeposits> ... DYNASTY +Int 1 |-> DELTA_DEPOSITS ... </deltaDeposits>
       <dynastyStartEpoch> ... (.Map => DYNASTY +Int 1 |-> EPOCH) ... </dynastyStartEpoch>
       requires EPOCH >=Int 2

  // do nothing if (EPOCH - 2) is not finalized
  rule <k> incrementDynasty => updateExpectedSourceEpoch ... </k>
       <currentEpoch> EPOCH </currentEpoch>
       <votes>
         <epoch> EPOCH -Int 2 </epoch>
         <isFinalized> false </isFinalized>
         ...
       </votes>
       requires EPOCH >=Int 2

  syntax KItem ::= "updateExpectedSourceEpoch"

  rule <k> updateExpectedSourceEpoch => . ... </k>
       <currentEpoch> EPOCH </currentEpoch>
       <votes>
         <epoch> EPOCH -Int 1 </epoch>
         <isJustified> true </isJustified>
         ...
       </votes>
       <expectedSourceEpoch> _ => EPOCH -Int 1 </expectedSourceEpoch>
       requires EPOCH >=Int 1

  // do nothing if (EPOCH - 1) is not justified
  rule <k> updateExpectedSourceEpoch => . ... </k>
       <currentEpoch> EPOCH </currentEpoch>
       <votes>
         <epoch> EPOCH -Int 1 </epoch>
         <isJustified> false </isJustified>
         ...
       </votes>
       requires EPOCH >=Int 1

//rule <k> updateExpectedSourceEpoch => . ... </k>
//     <currentEpoch> EPOCH </currentEpoch>
//     <expectedSourceEpoch>
//       EXPECTED_SOURCE_EPOCH => #if MAIN_HASH_JUSTIFIED
//                                #then EPOCH -Int 1
//                                #else EXPECTED_SOURCE_EPOCH #fi
//     </expectedSourceEpoch>
//     <mainHashJustified> MAIN_HASH_JUSTIFIED => false </mainHashJustified>
//     requires EPOCH >Int 0 // TODO: necessary? epoch starts from 0

  rule <k> Deposit(VALIDATION_ADDR, WITHDRAWAL_ADDR, DEPOSIT) => . ... </k>
       <currentDynasty> CURRENT_DYNASTY </currentDynasty>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <blockNumber> BLOCK_NUMBER </blockNumber>
       <depositScaleFactor> ... CURRENT_EPOCH |-> DEPOSIT_SCALE_FACTOR ... </depositScaleFactor>
       <validatorMap>
       (
         .Bag
       =>
         <validator>
           <index> NEXT_VALIDATOR_INDEX </index>
           <deposit> DEPOSIT /Int DEPOSIT_SCALE_FACTOR </deposit>
           <startDynasty> CURRENT_DYNASTY +Int 2 </startDynasty>
           <endDynasty>   defaultEndDynasty      </endDynasty>
           <withdrawalAddr> WITHDRAWAL_ADDR </withdrawalAddr>
         </validator>
       )
         ...
       </validatorMap>
       <deltaDeposits> ... CURRENT_DYNASTY +Int 2 |-> (DELTA_DEPOSITS => DELTA_DEPOSITS +Int (DEPOSIT /Int DEPOSIT_SCALE_FACTOR)) ... </deltaDeposits>
       <nextValidatorIndex> NEXT_VALIDATOR_INDEX => NEXT_VALIDATOR_INDEX +Int 1 </nextValidatorIndex>
       requires CURRENT_EPOCH ==Int BLOCK_NUMBER /Int epochLength
        andBool purityChecker(VALIDATION_ADDR) ==K true
        andBool DEPOSIT >=Int minDepositSize

  rule <k> Logout(VALIDATOR_INDEX, EPOCH, SIG) => . ... </k>
       <currentDynasty> CURRENT_DYNASTY </currentDynasty>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <blockNumber> BLOCK_NUMBER </blockNumber>
       <validator>
         <index> VALIDATOR_INDEX </index>
         <deposit> DEPOSIT </deposit>
         <endDynasty> END_DYNASTY => CURRENT_DYNASTY +Int dynastyLogoutDelay </endDynasty>
         ...
       </validator>
       <deltaDeposits> ... CURRENT_DYNASTY +Int dynastyLogoutDelay |-> (DELTA_DEPOSITS => DELTA_DEPOSITS -Int DEPOSIT) ... </deltaDeposits>
       requires CURRENT_EPOCH ==Int BLOCK_NUMBER /Int epochLength
        andBool CURRENT_EPOCH >=Int EPOCH
        andBool isValidSignature(VALIDATOR_INDEX, EPOCH, SIG)
        andBool END_DYNASTY >Int CURRENT_DYNASTY +Int dynastyLogoutDelay

  rule <k> Withdraw(VALIDATOR_INDEX)
        => send(WITHDRAWAL_ADDR, DEPOSIT *Int DEPOSIT_SCALE_FACTOR) ... </k>
       <currentDynasty> CURRENT_DYNASTY </currentDynasty>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <depositScaleFactor> ... END_EPOCH |-> DEPOSIT_SCALE_FACTOR ... </depositScaleFactor>
       <validator>
         <index> VALIDATOR_INDEX </index>
         <deposit> DEPOSIT => 0 </deposit>
         <startDynasty> _ => 0 </startDynasty>
         <endDynasty> END_DYNASTY => 0 </endDynasty>
         <withdrawalAddr> WITHDRAWAL_ADDR => 0 </withdrawalAddr>
       </validator>
       <dynastyStartEpoch> ... END_DYNASTY +Int 1 |-> END_EPOCH ... </dynastyStartEpoch>
       requires CURRENT_DYNASTY >=Int END_DYNASTY +Int 1
        andBool CURRENT_EPOCH >=Int END_EPOCH +Int withdrawalDelay

  rule <k> Vote(VALIDATOR_INDEX, TARGET_HASH, TARGET_EPOCH, SOURCE_EPOCH, SIG)
        => reward(VALIDATOR_INDEX, SOURCE_EPOCH)
        ~> justify(TARGET_EPOCH, SOURCE_EPOCH)
        ~> finalize(TARGET_EPOCH, SOURCE_EPOCH) ... </k>
       <votesMap>
         <votes>
           <epoch> TARGET_EPOCH </epoch>
           <hash>  TARGET_HASH  </hash>
           <voted> ... VALIDATOR_INDEX |-> (false => true) ... </voted>
           <currDynVotes>
             ...
             SOURCE_EPOCH |-> (CURR_DYNASTY_VOTES => #if inCurrDynasty(START_DYNASTY, CURRENT_DYNASTY, END_DYNASTY)
                                                     #then CURR_DYNASTY_VOTES +Int DEPOSIT
                                                     #else CURR_DYNASTY_VOTES
                                                     #fi)
             ...
           </currDynVotes>
           <prevDynVotes>
             ...
             SOURCE_EPOCH |-> (PREV_DYNASTY_VOTES => #if inPrevDynasty(START_DYNASTY, CURRENT_DYNASTY, END_DYNASTY)
                                                     #then PREV_DYNASTY_VOTES +Int DEPOSIT
                                                     #else PREV_DYNASTY_VOTES
                                                     #fi)
             ...
           </prevDynVotes>
           ...
         </votes>
         <votes>
           <epoch> SOURCE_EPOCH </epoch>
           <isJustified> true </isJustified>
           ...
         </votes>
         ...
       </votesMap>
       <validatorMap>
         <validator>
           <index> VALIDATOR_INDEX </index>
           <deposit> DEPOSIT </deposit>
           <startDynasty> START_DYNASTY </startDynasty>
           <endDynasty>   END_DYNASTY   </endDynasty>
           ...
         </validator>
         ...
       </validatorMap>
       <currentDynasty> CURRENT_DYNASTY </currentDynasty>
       <recommendedTargetHash> TARGET_HASH </recommendedTargetHash>
       requires isValidSignature(VALIDATOR_INDEX, TARGET_HASH, TARGET_EPOCH, SOURCE_EPOCH, SIG)
        andBool (        inCurrDynasty(START_DYNASTY, CURRENT_DYNASTY, END_DYNASTY)
                  orBool inPrevDynasty(START_DYNASTY, CURRENT_DYNASTY, END_DYNASTY) )

  syntax KItem ::= justify(Int, Int)

  rule <k> justify(TARGET_EPOCH, SOURCE_EPOCH) => . ... </k>
       <votes>
         <epoch> TARGET_EPOCH </epoch>
         <currDynVotes> ...  SOURCE_EPOCH |-> CURR_DYNASTY_VOTES ... </currDynVotes>
         <prevDynVotes> ...  SOURCE_EPOCH |-> PREV_DYNASTY_VOTES ... </prevDynVotes>
         <isJustified> _ => true </isJustified>
         ...
       </votes>
       <totalCurrDynDeposits> TOTAL_CURR_DYN_DEPOSITS </totalCurrDynDeposits>
       <totalPrevDynDeposits> TOTAL_PREV_DYN_DEPOSITS </totalPrevDynDeposits>
       <lastJustifiedEpoch> _ => TARGET_EPOCH </lastJustifiedEpoch>
     //<mainHashJustified> _ => true </mainHashJustified>
       requires CURR_DYNASTY_VOTES >=Int TOTAL_CURR_DYN_DEPOSITS *Int 2 /Int 3 // TODO: use fixed-point division
        andBool PREV_DYNASTY_VOTES >=Int TOTAL_PREV_DYN_DEPOSITS *Int 2 /Int 3

  syntax KItem ::= finalize(Int, Int)

  rule <k> finalize(TARGET_EPOCH, SOURCE_EPOCH) => . ... </k>
       <votes>
         <epoch> SOURCE_EPOCH </epoch>
         <isFinalized> _ => true </isFinalized>
         ...
       </votes>
       <lastFinalizedEpoch> _ => SOURCE_EPOCH </lastFinalizedEpoch>
       requires TARGET_EPOCH ==Int SOURCE_EPOCH +Int 1

  rule <k> finalize(TARGET_EPOCH, SOURCE_EPOCH) => . ... </k>
       requires TARGET_EPOCH =/=Int SOURCE_EPOCH +Int 1

  syntax Bool ::= inCurrDynasty(Int, Int, Int) [function]
                | inPrevDynasty(Int, Int, Int) [function]

  rule inCurrDynasty(START_DYNASTY, CURRENT_DYNASTY, END_DYNASTY) => START_DYNASTY <=Int CURRENT_DYNASTY andBool CURRENT_DYNASTY  <Int END_DYNASTY
  rule inPrevDynasty(START_DYNASTY, CURRENT_DYNASTY, END_DYNASTY) => START_DYNASTY  <Int CURRENT_DYNASTY andBool CURRENT_DYNASTY <=Int END_DYNASTY

  rule <k> Slash(VALIDATOR_INDEX1, TARGET_HASH1, TARGET_EPOCH1, SOURCE_EPOCH1, SIG1,
                 VALIDATOR_INDEX2, TARGET_HASH2, TARGET_EPOCH2, SOURCE_EPOCH2, SIG2)
        => send(MSG_SENDER, DEPOSIT *Int DEPOSIT_SCALE_FACTOR /Int 25) ... </k>
       <caller> MSG_SENDER </caller>
       <currentDynasty> CURRENT_DYNASTY </currentDynasty>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <depositScaleFactor> ... CURRENT_EPOCH |-> DEPOSIT_SCALE_FACTOR ... </depositScaleFactor>
       <validator>
         <index> VALIDATOR_INDEX1 </index>
         <deposit> DEPOSIT => 0 </deposit>
         <startDynasty> _ => 0 </startDynasty>
         <endDynasty> END_DYNASTY => 0 </endDynasty>
         <withdrawalAddr> _ => 0</withdrawalAddr>
       </validator>
       <deltaDeposits>
         ...
         CURRENT_DYNASTY +Int 1 |-> (CURR_DELTA_DEPOSITS => CURR_DELTA_DEPOSITS -Int DEPOSIT)
       //    END_DYNASTY        |-> ( END_DELTA_DEPOSITS =>  END_DELTA_DEPOSITS +Int DEPOSIT)  // TODO: fix this when CURRENT_DYNASTY >= END_DYNASTY
         ...
       </deltaDeposits>
       requires isValidSignature(VALIDATOR_INDEX1, TARGET_HASH1, TARGET_EPOCH1, SOURCE_EPOCH1, SIG1)
        andBool isValidSignature(VALIDATOR_INDEX2, TARGET_HASH2, TARGET_EPOCH2, SOURCE_EPOCH2, SIG2)
        andBool VALIDATOR_INDEX1 ==K VALIDATOR_INDEX2
        andBool (        TARGET_HASH1  =/=K TARGET_HASH2
                  orBool TARGET_EPOCH1 =/=K TARGET_EPOCH2
                  orBool SOURCE_EPOCH1 =/=K SOURCE_EPOCH2 )
        andBool (
                         TARGET_EPOCH1 ==K TARGET_EPOCH2
                  orBool ( TARGET_EPOCH1 >Int TARGET_EPOCH2 andBool SOURCE_EPOCH2 >Int SOURCE_EPOCH1 )
                  orBool ( TARGET_EPOCH2 >Int TARGET_EPOCH1 andBool SOURCE_EPOCH1 >Int SOURCE_EPOCH2 )
                )

  // Reward/penalty scheme

  syntax KItem ::= reward(Int, Int)

  rule <k> reward(VALIDATOR_INDEX, SOURCE_EPOCH) => procReward(VALIDATOR_INDEX, DEPOSIT *Int REWARD_FACTOR) ... </k>
       <validator>
         <index> VALIDATOR_INDEX </index>
         <deposit> DEPOSIT </deposit>
         ...
       </validator>
       <expectedSourceEpoch> SOURCE_EPOCH </expectedSourceEpoch>
       <rewardFactor> REWARD_FACTOR </rewardFactor>

  syntax KItem ::= procReward(Int, Int) // TODO: float

  rule <k> procReward(VALIDATOR_INDEX, REWARD) => . ... </k>
       <validator>
         <index> VALIDATOR_INDEX </index>
         <deposit> DEPOSIT => DEPOSIT +Int REWARD </deposit> // TODO: float
         <startDynasty> START_DYNASTY </startDynasty>
         <endDynasty>   END_DYNASTY   </endDynasty>
         ...
       </validator>
       <currentDynasty> CURRENT_DYNASTY </currentDynasty>
       <totalCurrDynDeposits>
         TOTAL_CURR_DYN_DEPOSITS => #if inCurrDynasty(START_DYNASTY, CURRENT_DYNASTY, END_DYNASTY)
                                    #then TOTAL_CURR_DYN_DEPOSITS +Int REWARD
                                    #else TOTAL_CURR_DYN_DEPOSITS #fi
       </totalCurrDynDeposits>
       <totalPrevDynDeposits>
         TOTAL_PREV_DYN_DEPOSITS => #if inPrevDynasty(START_DYNASTY, CURRENT_DYNASTY, END_DYNASTY)
                                    #then TOTAL_PREV_DYN_DEPOSITS +Int REWARD
                                    #else TOTAL_PREV_DYN_DEPOSITS #fi
       </totalPrevDynDeposits>
       <deltaDeposits>
         ...
         END_DYNASTY |-> ( DELTA_DEPOSITS => #if END_DYNASTY <Int defaultEndDynasty
                                             #then DELTA_DEPOSITS -Int REWARD
                                             #else DELTA_DEPOSITS #fi )
         ...
       </deltaDeposits>

  // External functions

  syntax Bool ::= isValidSignature(Int, Int, Int, Int, Int) [function, hook(isValidSignature)]
                | isValidSignature(Int, Int, Int)           [function, hook(isValidSignature)]

  syntax Bool ::= purityChecker(Int) [function, hook(purityChecker)]

  syntax KItem ::= send(Int, Int) [function, hook(send)]

  syntax Int ::= sqrt(Int) [function, hook(sqrt)] // TODO: decimal

  // Parameters

  syntax Int ::= "epochLength" [function]

  syntax Int ::= "defaultEndDynasty" [function]

  syntax Int ::= "baseInterestFactor" [function]

  syntax Int ::= "basePenaltyFactor" [function]

  syntax Int ::= "minDepositSize" [function]

  syntax Int ::= "dynastyLogoutDelay" [function]

  syntax Int ::= "withdrawalDelay" [function]

  // Macros

  syntax Int ::= "etherToWei" [macro]
  rule etherToWei => 1000000000000000000 // 10^18

endmodule
