requires "domains.k"

module CASPER-SYNTAX

  imports INT

  syntax KItem ::= vote(Int, Int, Int, Int, Int)

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
    <recommendedTargetHash> 0 </recommendedTargetHash>
    <mainHashJustified> false </mainHashJustified>
    <totalCurrDynDeposits> 0 </totalCurrDynDeposits>
    <totalPrevDynDeposits> 0 </totalPrevDynDeposits>
    <lastJustifiedEpoch> 0 </lastJustifiedEpoch>
    <lastFinalizedEpoch> 0 </lastFinalizedEpoch>
  </T>

  // TODO: reward
  rule <k> vote(VALIDATOR_INDEX, TARGET_HASH, TARGET_EPOCH, SOURCE_EPOCH, SIG) => justify(TARGET_EPOCH, SOURCE_EPOCH) ~> finalize(TARGET_EPOCH, SOURCE_EPOCH) ... </k>
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
       <votesMap>
         <votes>
           <epoch> TARGET_EPOCH </epoch>
           <currDynVotes> ...  SOURCE_EPOCH |-> CURR_DYNASTY_VOTES ... </currDynVotes>
           <prevDynVotes> ...  SOURCE_EPOCH |-> PREV_DYNASTY_VOTES ... </prevDynVotes>
           <isJustified> _ => true </isJustified>
           ...
         </votes>
         ...
       </votesMap>
       <totalCurrDynDeposits> TOTAL_CURR_DYN_DEPOSITS </totalCurrDynDeposits>
       <totalPrevDynDeposits> TOTAL_PREV_DYN_DEPOSITS </totalPrevDynDeposits>
       <lastJustifiedEpoch> _ => TARGET_EPOCH </lastJustifiedEpoch>
       <mainHashJustified> _ => true </mainHashJustified>
       requires CURR_DYNASTY_VOTES >=Int TOTAL_CURR_DYN_DEPOSITS *Int 2 /Int 3
        andBool PREV_DYNASTY_VOTES >=Int TOTAL_PREV_DYN_DEPOSITS *Int 2 /Int 3

  syntax KItem ::= finalize(Int, Int)
  rule <k> finalize(TARGET_EPOCH, SOURCE_EPOCH) => . ... </k>
       <votesMap>
         <votes>
           <epoch> SOURCE_EPOCH </epoch>
           <isFinalized> _ => true </isFinalized>
           ...
         </votes>
         ...
       </votesMap>
       <lastFinalizedEpoch> _ => SOURCE_EPOCH </lastFinalizedEpoch>
       requires TARGET_EPOCH ==Int SOURCE_EPOCH +Int 1

  rule <k> finalize(TARGET_EPOCH, SOURCE_EPOCH) => . ... </k>
       requires TARGET_EPOCH =/=Int SOURCE_EPOCH +Int 1

  syntax Bool ::= inCurrDynasty(Int, Int, Int) [function]
                | inPrevDynasty(Int, Int, Int) [function]
  rule inCurrDynasty(START_DYNASTY, CURRENT_DYNASTY, END_DYNASTY) => START_DYNASTY <=Int CURRENT_DYNASTY andBool CURRENT_DYNASTY  <Int END_DYNASTY
  rule inPrevDynasty(START_DYNASTY, CURRENT_DYNASTY, END_DYNASTY) => START_DYNASTY  <Int CURRENT_DYNASTY andBool CURRENT_DYNASTY <=Int END_DYNASTY

  syntax Bool ::= isValidSignature(Int, Int, Int, Int, Int) [function, hook(isValidSignature)]

endmodule
