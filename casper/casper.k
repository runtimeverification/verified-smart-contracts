requires "domains.k"

module CASPER-SYNTAX

  imports INT

  syntax KItem ::= initializeEpoch(Int)
                 | vote(Int, Int, Int, Int, Int)

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
         </validator>
       </validatorMap>

       <currentDynasty> 0 </currentDynasty>
       <currentEpoch> 0 </currentEpoch>

       <recommendedTargetHash> 0 </recommendedTargetHash>
       <expectedSourceEpoch> 0 </expectedSourceEpoch>
     //<mainHashJustified> false </mainHashJustified>

       <totalCurrDynDeposits> 0 </totalCurrDynDeposits>
       <totalPrevDynDeposits> 0 </totalPrevDynDeposits>
       <deltaDeposits> 0 </deltaDeposits>

       <lastJustifiedEpoch> 0 </lastJustifiedEpoch>
       <lastFinalizedEpoch> 0 </lastFinalizedEpoch>

       <blockNumber> 0 </blockNumber>

       <rewardFactor> 0 </rewardFactor> // TODO: float
       <depositScaleFactor> .Map </depositScaleFactor> // epoch |-> deposit_scale_factor
  </T>

  rule <k> initializeEpoch(EPOCH) => updateRewardFactor ~> incrementDynasty ... </k>
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
       <deltaDeposits> DELTA_DEPOSITS </deltaDeposits>
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


//rule <k> deposit(VALIDATION_ADDR, WITHDRAWAL_ADDR) => . ... </k>

  rule <k> vote(VALIDATOR_INDEX, TARGET_HASH, TARGET_EPOCH, SOURCE_EPOCH, SIG)
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
         DELTA_DEPOSITS => #if END_DYNASTY <Int defaultEndDynasty
                           #then DELTA_DEPOSITS -Int REWARD
                           #else DELTA_DEPOSITS #fi
       </deltaDeposits>

  // External functions

  syntax Bool ::= isValidSignature(Int, Int, Int, Int, Int) [function, hook(isValidSignature)]

  // Parameters

  syntax Int ::= "epochLength" [function]

  syntax Int ::= "defaultEndDynasty" [function]

  syntax Int ::= "baseInterestFactor" [function]

  syntax Int ::= "basePenaltyFactor" [function]

endmodule
