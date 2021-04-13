//@ proof
module PROOF-COUNT-CAN-SIGN
  imports FUNCTIONS-EXECUTE
//@ trusted
// module TRUSTED-COUNT-CAN-SIGN
  // imports EXECUTION-PROOF
//@ end

  claim <T> <TT>
          <k>
            call(countCanSign(SignerIds:ExpressionList)) ~> K:K
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
        </TT> </T>
      => <T> <TT>
          <k>
            evaluate(u(countCanSignFunction(SignerIds, opaque(UserIdToRole)))) ~> K
          </k>
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
              Stack,
              ?_Variables,
              PerformedActions:List)
        </TT> </T>
    requires true
        andBool isKResult(SignerIds)
        andBool listElementsAreUsize(SignerIds)
        andBool userIdToRoleInvariant(UserIdToRole)
    ensures true
  //@ proof
  //@ trusted
  // [trusted]
  //@ end
endmodule
