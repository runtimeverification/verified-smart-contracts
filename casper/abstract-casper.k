requires "domains.k"
requires "real.k"

module ABSTRACT-CASPER-SYNTAX

  imports INT

  syntax KItem ::= "InitializeEpoch"
                 | Deposit(Int, Int, Int)
                 | Logout(Int, Int, Int)
                 | Withdraw(Int)
                 | Vote(Int, Int, Int, Int, Int)
                 | Slash(Int, Int, Int, Int, Int,
                         Int, Int, Int, Int, Int)

endmodule

module ABSTRACT-CASPER

  imports ABSTRACT-CASPER-SYNTAX
  imports DOMAINS
  imports REAL

  configuration <T>
       <k> .K </k>

       // epochs & votes
       <epochs>
         <epoch multiplicity="*" type="Map">
           <id> 0 </id>
         //<dynasty> 0 </dynasty> // TODO: maintain
           <targetHash> 0 </targetHash>
           <voted> .Map </voted> // validator_index |-> voted?
           <currDynVotes> .Map </currDynVotes> // source_epoch |-> curr_dyn_votes_count
           <prevDynVotes> .Map </prevDynVotes> // source_epoch |-> prev_dyn_votes_count
           <isJustified> false </isJustified>
           <isFinalized> false </isFinalized>
         </epoch>
       </epochs>

       // validators
       <validators>
         <validator multiplicity="*" type="Map">
           <index> 0 </index>
           <addr> 0 </addr>
           <withdrawalAddr> 0 </withdrawalAddr>
           <deposit> .Map </deposit> // epoch |-> deposit
           <startDynasty> 0 </startDynasty>
           <endDynasty>   0 </endDynasty>
         </validator>
       </validators>

       // now
       <currentDynasty> 0 </currentDynasty>
       <currentEpoch> 0 </currentEpoch>

       // book-keeping
       <expectedTargetHash> 0 </expectedTargetHash>
       <expectedSourceEpoch> 0 </expectedSourceEpoch>
       //
       <lastJustifiedEpoch> 0 </lastJustifiedEpoch>
       <lastFinalizedEpoch> 0 </lastFinalizedEpoch>
       //
       <dynastyStartEpoch> .Map </dynastyStartEpoch> // dynasty |-> start_epoch
       //
       <totalCurrDynDeposits> 0.0 </totalCurrDynDeposits>
       <totalPrevDynDeposits> 0.0 </totalPrevDynDeposits>

       // external (block/transaction) info
       <blockNumber> 0 </blockNumber>
       <caller> 0 </caller>

       // reward-penalty factors
       <rewardFactor> 0.0 </rewardFactor>

       // counter
       <nextValidatorIndex> 0 </nextValidatorIndex>
  </T>

  //
  // IncrementEpoch
  //

  rule <k> InitializeEpoch
        => updateDeposits
        ~> updateRewardFactor
        ~> incrementEpoch
        ~> incrementDynasty
        ~> updateDynDeposits
       ... </k>

  syntax KItem ::= "updateDeposits"

  // NOTE: conceptually this is called at the end of each epoch
  rule <k> updateDeposits
        => updateDeposit(indexes(<validators> VS </validators>),
             (1.0 +Real collectiveReward(CURR_DYNASTY_VOTES, TOTAL_CURR_DYN_DEPOSITS,
                                         PREV_DYNASTY_VOTES, TOTAL_PREV_DYN_DEPOSITS, REWARD_FACTOR,
                                         CURRENT_EPOCH, LAST_FINALIZED_EPOCH))
             /Real (1.0 +Real REWARD_FACTOR)
           ) ... </k>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <lastFinalizedEpoch> LAST_FINALIZED_EPOCH </lastFinalizedEpoch>
       <expectedSourceEpoch> SOURCE_EPOCH </expectedSourceEpoch>
       <epoch>
         <id> CURRENT_EPOCH </id>
         <currDynVotes> ... SOURCE_EPOCH |-> CURR_DYNASTY_VOTES ... </currDynVotes>
         <prevDynVotes> ... SOURCE_EPOCH |-> PREV_DYNASTY_VOTES ... </prevDynVotes>
         ...
       </epoch>
       <totalCurrDynDeposits> TOTAL_CURR_DYN_DEPOSITS </totalCurrDynDeposits>
       <totalPrevDynDeposits> TOTAL_PREV_DYN_DEPOSITS </totalPrevDynDeposits>
       <validators> VS </validators>
       <rewardFactor> REWARD_FACTOR </rewardFactor>

  syntax Real ::= collectiveReward(Real, Real, Real, Real, Real, Int, Int) [function]

  rule collectiveReward(CURR_DYNASTY_VOTES, TOTAL_CURR_DYN_DEPOSITS,
                        PREV_DYNASTY_VOTES, TOTAL_PREV_DYN_DEPOSITS, REWARD_FACTOR,
                        CURRENT_EPOCH, LAST_FINALIZED_EPOCH)
    => minReal(CURR_DYNASTY_VOTES /Real TOTAL_CURR_DYN_DEPOSITS,    // TODO: why min?
               PREV_DYNASTY_VOTES /Real TOTAL_PREV_DYN_DEPOSITS) *Real REWARD_FACTOR /Real 2.0
       requires CURRENT_EPOCH -Int LAST_FINALIZED_EPOCH ==Int 2

  rule collectiveReward(_, _, _, _, _, CURRENT_EPOCH, LAST_FINALIZED_EPOCH) => 0.0
       requires CURRENT_EPOCH -Int LAST_FINALIZED_EPOCH >Int 2

  syntax KItem ::= updateDeposit(List, Real)

  rule <k> updateDeposit(.List, _) => . ... </k>
  rule <k> updateDeposit(ListItem(VALIDATOR_INDEX) VS, FACTOR) => updateDeposit(VS, FACTOR) ... </k>
       <validators>
         <validator>
           <index> VALIDATOR_INDEX </index>
           <deposit> ... CURRENT_EPOCH +Int 1 |-> (DEPOSIT => DEPOSIT *Real FACTOR) </deposit>    // TODO: even if start_dynasty > current_dynasty ?
           ...
         </validator>
         ...
       </validators>

  // TODO:
  syntax List ::= indexes(ValidatorsCell) [function]

  syntax KItem ::= "updateRewardFactor"

  rule <k> updateRewardFactor => . ... </k>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <lastFinalizedEpoch> LAST_FINALIZED_EPOCH </lastFinalizedEpoch>
       <totalCurrDynDeposits> TOTAL_CURR_DYN_DEPOSITS </totalCurrDynDeposits>
       <totalPrevDynDeposits> TOTAL_PREV_DYN_DEPOSITS </totalPrevDynDeposits>
       <rewardFactor>
         _
       =>
         baseInterestFactor /Real sqrtTotalDeposits(TOTAL_CURR_DYN_DEPOSITS, TOTAL_PREV_DYN_DEPOSITS)
         +Real basePenaltyFactor *Real Int2Real(CURRENT_EPOCH -Int LAST_FINALIZED_EPOCH)
       </rewardFactor>
       requires TOTAL_CURR_DYN_DEPOSITS >Real 0.0
        andBool TOTAL_PREV_DYN_DEPOSITS >Real 0.0      // TODO: the case of not deposit_exists()

  syntax Real ::= sqrtTotalDeposits(Real, Real) [function]

  rule sqrtTotalDeposits(TOTAL_CURR_DYN_DEPOSITS, TOTAL_PREV_DYN_DEPOSITS)
       =>
       sqrtReal(maxReal(TOTAL_CURR_DYN_DEPOSITS, TOTAL_PREV_DYN_DEPOSITS) /Real Int2Real(etherToWei) +Real 1.0)     // TODO: why max?

  syntax KItem ::= "incrementEpoch"

  rule <k> incrementEpoch => updateExpectedSourceEpoch ... </k>
       <currentDynasty> CURRENT_DYNASTY </currentDynasty>
       <currentEpoch> EPOCH => EPOCH +Int 1 </currentEpoch>
       <blockNumber> BLOCK_NUMBER </blockNumber>
       <epochs>
       (
         .Bag
       =>
         <epoch>
           <id> EPOCH +Int 1 </id>
           <targetHash> blockhash((EPOCH +Int 1) *Int epochLength -Int 1) </targetHash>
           <voted> .Map </voted>                // TODO: initialize entries
           <currDynVotes> .Map </currDynVotes>  // TODO: initialize entries
           <prevDynVotes> .Map </prevDynVotes>  // TODO: initialize entries
           <isJustified> false </isJustified>
           <isFinalized> false </isFinalized>
         </epoch>
       )
         ...
       </epochs>
       requires EPOCH +Int 1 ==Int BLOCK_NUMBER /Int epochLength

  syntax KItem ::= "updateExpectedSourceEpoch"

  rule <k> updateExpectedSourceEpoch => . ... </k>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <epoch>
         <id> CURRENT_EPOCH -Int 1 </id>
         <isJustified> true </isJustified>
         ...
       </epoch>
       <expectedSourceEpoch> _ => CURRENT_EPOCH -Int 1 </expectedSourceEpoch>
       requires CURRENT_EPOCH >=Int 1

  // do nothing if (CURRENT_EPOCH - 1) is not justified
  rule <k> updateExpectedSourceEpoch => . ... </k>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <epoch>
         <id> CURRENT_EPOCH -Int 1 </id>
         <isJustified> false </isJustified>
         ...
       </epoch>
       requires CURRENT_EPOCH >=Int 1

  syntax KItem ::= "incrementDynasty"

  rule <k> incrementDynasty => . ... </k>
       <currentDynasty> DYNASTY => DYNASTY +Int 1 </currentDynasty>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <epoch>
         <id> CURRENT_EPOCH -Int 2 </id>
         <isFinalized> true </isFinalized>
         ...
       </epoch>
       <dynastyStartEpoch> ... (.Map => DYNASTY +Int 1 |-> CURRENT_EPOCH) ... </dynastyStartEpoch>
       requires CURRENT_EPOCH >=Int 2

  // do nothing if (EPOCH - 2) is not finalized
  rule <k> incrementDynasty => . ... </k>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <epoch>
         <id> CURRENT_EPOCH -Int 2 </id>
         <isFinalized> false </isFinalized>
         ...
       </epoch>
       requires CURRENT_EPOCH >=Int 2

  syntax KItem ::= "updateDynDeposits"

  rule <k> updateDynDeposits => . ... </k>
       <currentDynasty> CURRENT_DYNASTY </currentDynasty>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <totalCurrDynDeposits> _ => totalCurrDynastyDeposits(CURRENT_DYNASTY, CURRENT_EPOCH, <validators> VS </validators>) </totalCurrDynDeposits>
       <totalPrevDynDeposits> _ => totalPrevDynastyDeposits(CURRENT_DYNASTY, CURRENT_EPOCH, <validators> VS </validators>) </totalPrevDynDeposits>
       <validators> VS </validators>

  syntax Real ::= totalCurrDynastyDeposits(Int, Int, ValidatorsCell) [function]
                | totalPrevDynastyDeposits(Int, Int, ValidatorsCell) [function]

  rule totalCurrDynastyDeposits(CURRENT_DYNASTY, CURRENT_EPOCH, <validators> VS </validators>) => totalDeposits(Curr, CURRENT_DYNASTY, CURRENT_EPOCH, <validators> VS </validators>)
  rule totalPrevDynastyDeposits(CURRENT_DYNASTY, CURRENT_EPOCH, <validators> VS </validators>) => totalDeposits(Prev, CURRENT_DYNASTY, CURRENT_EPOCH, <validators> VS </validators>)

  syntax Real ::= totalDeposits(CurrOrPrev, Int, Int, ValidatorsCell) [function]

  rule totalDeposits(MODE, CURRENT_DYNASTY, CURRENT_EPOCH,
         <validators>
           <validator>
             <deposit> ... CURRENT_EPOCH |-> DEPOSIT </deposit>
             <startDynasty> START_DYNASTY </startDynasty>
             <endDynasty>   END_DYNASTY   </endDynasty>
             ...
           </validator>
           VS
         </validators>
       ) => DEPOSIT *Real (#if inDynasty(MODE, START_DYNASTY, CURRENT_DYNASTY, END_DYNASTY) #then 1.0 #else 0.0 #fi)
            +Real totalDeposits(MODE, CURRENT_DYNASTY, CURRENT_EPOCH, <validators> VS </validators>)

  rule totalDeposits(_, _, _, <validators> .Bag </validators>) => 0.0

  syntax CurrOrPrev ::= "Curr" | "Prev"

  syntax Bool ::= inDynasty(CurrOrPrev, Int, Int, Int) [function]

  rule inDynasty(Curr, START_DYNASTY, CURRENT_DYNASTY, END_DYNASTY) => START_DYNASTY <=Int CURRENT_DYNASTY andBool CURRENT_DYNASTY  <Int END_DYNASTY
  rule inDynasty(Prev, START_DYNASTY, CURRENT_DYNASTY, END_DYNASTY) => START_DYNASTY  <Int CURRENT_DYNASTY andBool CURRENT_DYNASTY <=Int END_DYNASTY

  //
  // Deposit
  //

  rule <k> Deposit(VALIDATION_ADDR, WITHDRAWAL_ADDR, DEPOSIT) => . ... </k>
       <currentDynasty> CURRENT_DYNASTY </currentDynasty>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <blockNumber> BLOCK_NUMBER </blockNumber>
       <validators>
       (
         .Bag
       =>
         <validator>
           <index> NEXT_VALIDATOR_INDEX </index>
           <deposit> CURRENT_EPOCH |-> Int2Real(DEPOSIT) </deposit>     // TODO: may be penalized in the following two dynasties by other validators' behavior?
           <startDynasty> CURRENT_DYNASTY +Int 2 </startDynasty>
           <endDynasty>   defaultEndDynasty      </endDynasty>
           <addr> VALIDATION_ADDR </addr>
           <withdrawalAddr> WITHDRAWAL_ADDR </withdrawalAddr>
         </validator>
       )
         ...
       </validators>
       <nextValidatorIndex> NEXT_VALIDATOR_INDEX => NEXT_VALIDATOR_INDEX +Int 1 </nextValidatorIndex>
       requires CURRENT_EPOCH ==Int BLOCK_NUMBER /Int epochLength
        andBool purityChecker(VALIDATION_ADDR) ==K true
        andBool DEPOSIT >=Int minDepositSize

  //
  // Logout
  //

  rule <k> Logout(VALIDATOR_INDEX, EPOCH, SIG) => . ... </k>    // TODO: why EPOCH parameter needed ?
       <currentDynasty> CURRENT_DYNASTY </currentDynasty>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <blockNumber> BLOCK_NUMBER </blockNumber>
       <validator>
         <index> VALIDATOR_INDEX </index>
         <endDynasty> END_DYNASTY => CURRENT_DYNASTY +Int dynastyLogoutDelay </endDynasty>
         <addr> VALIDATION_ADDR </addr>
         ...
       </validator>
       requires CURRENT_EPOCH ==Int BLOCK_NUMBER /Int epochLength
        andBool CURRENT_EPOCH >=Int EPOCH
        andBool isValidSignature(VALIDATION_ADDR, VALIDATOR_INDEX, EPOCH, SIG)
        andBool END_DYNASTY >Int CURRENT_DYNASTY +Int dynastyLogoutDelay    // TODO: enough for preventing double logouts ?

  //
  // Withdraw
  //

  rule <k> Withdraw(VALIDATOR_INDEX)
        => deleteValidator(VALIDATOR_INDEX)
        ~> send(WITHDRAWAL_ADDR, DEPOSIT) ... </k>
       <currentDynasty> CURRENT_DYNASTY </currentDynasty>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <validator>
         <index> VALIDATOR_INDEX </index>
         <deposit> ... END_EPOCH |-> DEPOSIT ... </deposit>
         <endDynasty> END_DYNASTY </endDynasty>
         <withdrawalAddr> WITHDRAWAL_ADDR </withdrawalAddr>
         ...
       </validator>
       <dynastyStartEpoch> ... END_DYNASTY +Int 1 |-> END_EPOCH ... </dynastyStartEpoch>
       requires CURRENT_DYNASTY >=Int END_DYNASTY +Int 1
        andBool CURRENT_EPOCH >=Int END_EPOCH +Int withdrawalDelay

  syntax KItem ::= deleteValidator(Int)

  rule <k> deleteValidator(VALIDATOR_INDEX) => . ...</k>
       <validator>
         <index> VALIDATOR_INDEX </index>
         <deposit> DEPOSITS:Map => setZero(DEPOSITS) </deposit>  // NOTE: necessary to set to zero (even if withdrawl_addr already becomes zero), for bounty calculation
         <startDynasty> _ => 0 </startDynasty>
         <endDynasty> _ => 0 </endDynasty>
         <addr> _ => 0 </addr>
         <withdrawalAddr> _ => 0 </withdrawalAddr>
       </validator>

  syntax Map ::= setZero(Map)       [function]
               | setZero(Set, Map)  [function]

  rule setZero(M:Map) => setZero(keys(M), M)
  rule setZero(SetItem(K) KS:Set, M) => setZero(KS, M[K <- 0])
  rule setZero(.Set, M) => M

  //
  // Vote
  //

  rule <k> Vote(VALIDATOR_INDEX, TARGET_HASH, TARGET_EPOCH, SOURCE_EPOCH, SIG)
        => reward(VALIDATOR_INDEX, SOURCE_EPOCH)
        ~> justifyAndFinalize(TARGET_EPOCH, SOURCE_EPOCH) ... </k>
       <currentDynasty> CURRENT_DYNASTY </currentDynasty>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <expectedTargetHash> TARGET_HASH </expectedTargetHash>
       <epochs>
         <epoch>
           <id> TARGET_EPOCH </id>
           <targetHash> TARGET_HASH </targetHash>
           <voted> ... VALIDATOR_INDEX |-> (false => true) ... </voted>
           <currDynVotes>
             ...
             SOURCE_EPOCH |-> (CURR_DYNASTY_VOTES => #if inDynasty(Curr, START_DYNASTY, CURRENT_DYNASTY, END_DYNASTY)
                                                     #then CURR_DYNASTY_VOTES +Real DEPOSIT
                                                     #else CURR_DYNASTY_VOTES
                                                     #fi)
             ...
           </currDynVotes>
           <prevDynVotes>
             ...
             SOURCE_EPOCH |-> (PREV_DYNASTY_VOTES => #if inDynasty(Prev, START_DYNASTY, CURRENT_DYNASTY, END_DYNASTY)
                                                     #then PREV_DYNASTY_VOTES +Real DEPOSIT
                                                     #else PREV_DYNASTY_VOTES
                                                     #fi)
             ...
           </prevDynVotes>
           ...
         </epoch>
         <epoch>
           <id> SOURCE_EPOCH </id>
           <isJustified> true </isJustified>
           ...
         </epoch>
         ...
       </epochs>
       <validators>
         <validator>
           <index> VALIDATOR_INDEX </index>
           <deposit> ... CURRENT_EPOCH |-> DEPOSIT </deposit>
           <startDynasty> START_DYNASTY </startDynasty>
           <endDynasty>   END_DYNASTY   </endDynasty>
           <addr> VALIDATION_ADDR </addr>
           ...
         </validator>
         ...
       </validators>
       requires isValidSignature(VALIDATION_ADDR, VALIDATOR_INDEX, TARGET_HASH, TARGET_EPOCH, SOURCE_EPOCH, SIG)
        andBool (        inDynasty(Curr, START_DYNASTY, CURRENT_DYNASTY, END_DYNASTY)
                  orBool inDynasty(Prev, START_DYNASTY, CURRENT_DYNASTY, END_DYNASTY) )

  syntax KItem ::= reward(Int, Int)

  rule <k> reward(VALIDATOR_INDEX, SOURCE_EPOCH) => . ... </k>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <validator>
         <index> VALIDATOR_INDEX </index>
         <deposit> DS:Map CURRENT_EPOCH |-> DEPOSIT (.Map => CURRENT_EPOCH +Int 1 |-> DEPOSIT *Real (1.0 +Real REWARD_FACTOR)) </deposit>
         ...
       </validator>
       <expectedSourceEpoch> SOURCE_EPOCH </expectedSourceEpoch>
       <rewardFactor> REWARD_FACTOR </rewardFactor>
       requires notBool(CURRENT_EPOCH +Int 1 in keys(DS))

  rule <k> reward(VALIDATOR_INDEX, SOURCE_EPOCH) => . ... </k>
       <expectedSourceEpoch> EXPECTED_SOURCE_EPOCH </expectedSourceEpoch>
       requires SOURCE_EPOCH =/=K EXPECTED_SOURCE_EPOCH

  syntax KItem ::= justifyAndFinalize(Int, Int)

  rule <k> justifyAndFinalize(TARGET_EPOCH, SOURCE_EPOCH) => finalize(TARGET_EPOCH, SOURCE_EPOCH) ... </k>
       <epoch>
         <id> TARGET_EPOCH </id>
         <currDynVotes> ...  SOURCE_EPOCH |-> CURR_DYNASTY_VOTES ... </currDynVotes>
         <prevDynVotes> ...  SOURCE_EPOCH |-> PREV_DYNASTY_VOTES ... </prevDynVotes>
         <isJustified> _ => true </isJustified>
         ...
       </epoch>
       <totalCurrDynDeposits> TOTAL_CURR_DYN_DEPOSITS </totalCurrDynDeposits>
       <totalPrevDynDeposits> TOTAL_PREV_DYN_DEPOSITS </totalPrevDynDeposits>
       <lastJustifiedEpoch> _ => TARGET_EPOCH </lastJustifiedEpoch>
       requires CURR_DYNASTY_VOTES >=Real TOTAL_CURR_DYN_DEPOSITS *Real 2.0 /Real 3.0
        andBool PREV_DYNASTY_VOTES >=Real TOTAL_PREV_DYN_DEPOSITS *Real 2.0 /Real 3.0

  syntax KItem ::= finalize(Int, Int)

  rule <k> finalize(TARGET_EPOCH, SOURCE_EPOCH) => . ... </k>
       <epoch>
         <id> SOURCE_EPOCH </id>
         <isFinalized> _ => true </isFinalized>
         ...
       </epoch>
       <lastFinalizedEpoch> _ => SOURCE_EPOCH </lastFinalizedEpoch>
       requires TARGET_EPOCH ==Int SOURCE_EPOCH +Int 1

  rule <k> finalize(TARGET_EPOCH, SOURCE_EPOCH) => . ... </k>
       requires TARGET_EPOCH =/=Int SOURCE_EPOCH +Int 1

  //
  // Slash
  //

  rule <k> Slash(VALIDATOR_INDEX1, TARGET_HASH1, TARGET_EPOCH1, SOURCE_EPOCH1, SIG1,
                 VALIDATOR_INDEX2, TARGET_HASH2, TARGET_EPOCH2, SOURCE_EPOCH2, SIG2)
        => deleteValidator(VALIDATOR_INDEX1)
        ~> send(MSG_SENDER, DEPOSIT /Real 25.0) ... </k>
       <caller> MSG_SENDER </caller>
       <currentEpoch> CURRENT_EPOCH </currentEpoch>
       <validator>
         <index> VALIDATOR_INDEX1 </index>
         <deposit> ... CURRENT_EPOCH |-> DEPOSIT </deposit>     // NOTE: if too late (if already withdrawn), deposit is 0
         <addr> VALIDATION_ADDR </addr>
         ...
       </validator>
       requires isValidSignature(VALIDATION_ADDR, VALIDATOR_INDEX1, TARGET_HASH1, TARGET_EPOCH1, SOURCE_EPOCH1, SIG1)
        andBool isValidSignature(VALIDATION_ADDR, VALIDATOR_INDEX2, TARGET_HASH2, TARGET_EPOCH2, SOURCE_EPOCH2, SIG2)
        andBool VALIDATOR_INDEX1 ==K VALIDATOR_INDEX2
        andBool (        TARGET_HASH1  =/=K TARGET_HASH2
                  orBool TARGET_EPOCH1 =/=K TARGET_EPOCH2
                  orBool SOURCE_EPOCH1 =/=K SOURCE_EPOCH2 )
        andBool (
                         TARGET_EPOCH1 ==K TARGET_EPOCH2
                  orBool ( TARGET_EPOCH1 >Int TARGET_EPOCH2 andBool SOURCE_EPOCH2 >Int SOURCE_EPOCH1 )
                  orBool ( TARGET_EPOCH2 >Int TARGET_EPOCH1 andBool SOURCE_EPOCH1 >Int SOURCE_EPOCH2 )
                )

  //
  // External functions
  //

  syntax Bool ::= isValidSignature(Int, Int, Int, Int, Int, Int) [function, hook(isValidSignature)]
                | isValidSignature(Int, Int, Int, Int)           [function, hook(isValidSignature)]

  syntax Bool ::= purityChecker(Int) [function, hook(purityChecker)]

  syntax KItem ::= send(Int, Real) [function, hook(send)]

  syntax Int ::= blockhash(Int) [function, hook(blockhash)]

  //
  // Parameters
  //

  syntax Int ::= "epochLength" [function]

  syntax Int ::= "defaultEndDynasty" [function]

  syntax Real ::= "baseInterestFactor" [function]

  syntax Real ::= "basePenaltyFactor" [function]

  syntax Int ::= "minDepositSize" [function]

  syntax Int ::= "dynastyLogoutDelay" [function]

  syntax Int ::= "withdrawalDelay" [function]

  //
  // Macros
  //

  syntax Int ::= "etherToWei" [macro]
  rule etherToWei => 1000000000000000000 // 10^18

endmodule
