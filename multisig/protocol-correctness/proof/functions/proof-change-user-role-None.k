//@ proof
module PROOF-CHANGE-USER-ROLE-NONE
//@ trusted
// module TRUSTED-CHANGE-USER-ROLE-NONE
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
              UserIdToRole:Map,
              Quorum:Usize,
              u(ActionLastIndex:Int),
              ActionData:Map,
              ActionSigners:Map,
              CallerAddress:Address,
              //@ proof
              .List,  // TODO: Stack:List,
              //@ trusted
              // Stack:List,
              //@ end
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
              u(NumProposers +Int #if NewRole ==K Proposer #then 1 #else 0 #fi),
              #if NewRole ==K None #then UserIdToRole #else UserId |-> NewRole UserIdToRole #fi,
              Quorum,
              u(ActionLastIndex),
              ActionData,
              ActionSigners,
              CallerAddress,
              //@ proof
              .List,  // TODO: Stack:List,
              //@ trusted
              // Stack:List,
              //@ end
              ?_Variables,
              PerformedActions:List
              ):StateCell
        </TT></T>
    requires true
      andBool addressToUserIdInvariant(AddressToUserId)

      andBool notBool UserId in_keys(UserIdToRole)
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
