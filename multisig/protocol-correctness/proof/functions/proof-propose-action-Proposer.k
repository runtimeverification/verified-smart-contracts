//@ proof
module PROOF-PROPOSE-ACTION-PROPOSER
//@ trusted
// module TRUSTED-PROPOSE-ACTION-PROPOSER
//@ end

  imports EXECUTION-PROOF-HELPERS
  imports FUNCTIONS-EXECUTE

  claim <T><TT>
          <k> call(proposeAction(Action:Action)) ~> K:K
          </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              UserIdToRole:Map,
              Quorum:Usize,
              u(ActionLastIndex:Int),
              ActionData:Map,
              ActionSigners:Map,
              CallerAddress:Address,
              Stack:Stack,
              .Map,
              PerformedActions:List
              )
        </TT></T>
      =>
        <T><TT>
          <k> u(ActionLastIndex +Int 1) ~> K </k>
          invariantStateFull(
              NumUsers,
              UserIdToAddress,
              AddressToUserId,
              NumBoardMembers,
              NumProposers,
              UserIdToRole,
              Quorum,
              u(ActionLastIndex +Int 1),
              u(ActionLastIndex +Int 1) |-> Action ActionData,
              ActionSigners,
              CallerAddress,
              Stack:Stack,
              ?_Variables,
              PerformedActions:List
              ):StateCell
        </TT></T>
    requires true
      andBool isKResult(Action)
      andBool valueIsNotEmpty(Action, rAction)

      andBool valuesAreKResult(AddressToUserId)
      andBool valuesAreOfType(AddressToUserId, rUsize)
      andBool valuesAreNotEmpty(AddressToUserId, rUsize)

      andBool valuesAreOfType(UserIdToRole, rUserRole)
      andBool valuesAreKResult(UserIdToRole)

      andBool unusedIdsInMapKeys(ActionLastIndex +Int 1, keysMap(ActionData), expand(expanded))
      andBool unusedIdsInMapKeys(ActionLastIndex +Int 1, keysMap(ActionSigners), expand(expanded))

      andBool CallerAddress in_keys(AddressToUserId)
      andBool AddressToUserId[CallerAddress] in_keys(UserIdToRole)
      andBool UserIdToRole[AddressToUserId[CallerAddress]] ==K Proposer
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
