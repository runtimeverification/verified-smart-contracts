//@ proof
module PROOF-DISCARD-ACTION-NO-ROLE
//@ trusted
// module TRUSTED-DISCARD-ACTION-NO-ROLE
//@ end
  imports FUNCTIONS-EXECUTE

  claim <T><TT>
          <k> call(discardAction(_ActionId:Usize)) ~> K:K
          </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              (CallerAddress |-> UserId:Usize _AddressToUserId:Map) #as AddressToUserId:Map,
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
              ActionLastIndex:Usize,
              ActionData,
              ActionSigners,
              CallerAddress,
              Stack:Stack,
              ?_Variables,
              PerformedActions:List
              ):StateCell
        </TT></T>
    requires true
      andBool notBool u(0) in_keys(UserIdToRole)

      andBool notBool UserId in_keys(UserIdToRole)
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
