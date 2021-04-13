//@ proof
module PROOF-CHANGE-USER-ROLE-PROPOSER
//@ trusted
// module TRUSTED-CHANGE-USER-ROLE-PROPOSER
//@ end
  imports FUNCTIONS-EXECUTE

  claim <T><TT>
          <k> call(changeUserRole(UserAddress:Address, NewRole:UserRole)) ~> K:K
          </k>
          invariantStateFull(
              u(NumUsers:Int),
              UserIdToAddress:Map,
              (UserAddress |-> UserId:Usize _AddressToUserId:Map) #as AddressToUserId:Map,
              u(NumBoardMembers:Int),
              u(NumProposers:Int),
              UserId |-> Proposer UserIdToRole:Map,
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
          <k> evaluate(void) ~> K </k>
          invariantStateFull(
              u(NumUsers),
              UserIdToAddress,
              AddressToUserId,
              u(NumBoardMembers +Int #if NewRole ==K BoardMember #then 1 #else 0 #fi),
              u(NumProposers -Int 1 +Int #if NewRole ==K Proposer #then 1 #else 0 #fi),
              #if NewRole ==K None #then UserIdToRole #else UserId |-> NewRole UserIdToRole #fi,
              Quorum,
              u(ActionLastIndex),
              ActionData,
              ActionSigners,
              CallerAddress,
              Stack:Stack,
              ?_Variables,
              PerformedActions:List
              ):StateCell
        </TT></T>
    requires true
      andBool addressToUserIdInvariant(AddressToUserId)
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
