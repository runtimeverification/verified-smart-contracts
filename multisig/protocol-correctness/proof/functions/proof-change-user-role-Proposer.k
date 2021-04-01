module TRUSTED-CHANGE-USER-ROLE-PROPOSER
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
              Stack:List,
              .Map
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
              Stack:List,
              ?_Variables
              ):StateCell
        </TT></T>
    requires true
      andBool addressToUserIdInvariant(AddressToUserId)
    ensures true
    [trusted]
endmodule

module PROOF-CHANGE-USER-ROLE-PROPOSER
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
              .List,  // TODO: Stack:List,
              .Map
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
              .List,  // TODO: Stack:List,
              ?_Variables
              ):StateCell
        </TT></T>
    requires true
      andBool addressToUserIdInvariant(AddressToUserId)
    ensures true
endmodule
