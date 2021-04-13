//@ proof
module PROOF-PROPOSE-ACTION-ERROR-NO-USER
//@ trusted
// module TRUSTED-PROPOSE-ACTION-ERROR-NO-USER
//@ end
  imports FUNCTIONS-EXECUTE

  claim <T><TT>
          <k> call(proposeAction(_Action:Action)) ~> K:K
          </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              UserIdToRole:Map,
              Quorum:Usize,
              ActionLastIndex:Usize,
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
          <k> error ~> K </k>
          invariantStateFull(
              NumUsers,
              UserIdToAddress,
              AddressToUserId,
              NumBoardMembers,
              NumProposers,
              UserIdToRole,
              Quorum,
              ActionLastIndex,
              ActionData,
              ActionSigners,
              CallerAddress,
              Stack:Stack,
              ?_Variables:Map,
              PerformedActions:List
              ):StateCell
        </TT></T>
    requires true
      andBool notBool u(0) in_keys(UserIdToRole)

      andBool valuesAreKResult(AddressToUserId)
      andBool valuesAreOfType(AddressToUserId, rUsize)
      andBool valuesAreNotEmpty(AddressToUserId, rUsize)

      andBool valuesAreOfType(UserIdToRole, rUserRole)
      andBool valuesAreKResult(UserIdToRole)

      andBool notBool CallerAddress in_keys(AddressToUserId)
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
