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
  </T>

  // TODO: reward
  rule <k> initializeEpoch(EPOCH) => incrementDynasty ... </k>
       <currentEpoch> CURRENT_EPOCH => EPOCH </currentEpoch>
       <blockNumber> BLOCK_NUMBER </blockNumber>
       requires EPOCH <=Int BLOCK_NUMBER /Int epochLength
        andBool EPOCH ==Int CURRENT_EPOCH +Int 1

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

  // TODO: reward
  rule <k> vote(VALIDATOR_INDEX, TARGET_HASH, TARGET_EPOCH, SOURCE_EPOCH, SIG)
        => justify(TARGET_EPOCH, SOURCE_EPOCH) ~> finalize(TARGET_EPOCH, SOURCE_EPOCH) ... </k>
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

  // External functions

  syntax Bool ::= isValidSignature(Int, Int, Int, Int, Int) [function, hook(isValidSignature)]

  // Parameters

  syntax Int ::= "epochLength" [function]

endmodule
