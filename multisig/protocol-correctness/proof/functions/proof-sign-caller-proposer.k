module TRUSTED-SIGN-CALLER-PROPOSER
  imports FUNCTIONS-EXECUTE

  claim <T><TT>
          <k> call(sign(ActionId:Usize)) ~> K:K
          </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              (CallerAddress |-> UserId:Usize _AddressToUserId:Map) #as AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              (UserId |-> Proposer _UserIdToRole:Map) #as UserIdToRole:Map,
              Quorum:Usize,
              ActionLastIndex:Usize,
              ActionData:Map,
              ActionSigners:Map,
              CallerAddress:Address,
              Stack:List,
              .Map
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
              Stack:List,
              ?_Variables
              ):StateCell
        </TT></T>
    requires true
      andBool notBool u(0) in_keys(UserIdToRole)
      andBool actionDataInvariant(ActionData)
      andBool userIdToRoleInvariant(UserIdToRole)
   
      andBool ActionId in_keys(ActionData)
      // andBool notBool ActionId in_keys(ActionSigners)
    ensures true
    [trusted]
endmodule

module PROOF-SIGN-CALLER-PROPOSER
  imports FUNCTIONS-EXECUTE

  claim <T><TT>
          <k> call(sign(ActionId:Usize)) ~> K:K
          </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              (CallerAddress |-> UserId:Usize _AddressToUserId:Map) #as AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              (UserId |-> Proposer _UserIdToRole:Map) #as UserIdToRole:Map,
              Quorum:Usize,
              ActionLastIndex:Usize,
              ActionData:Map,
              ActionSigners:Map,
              CallerAddress:Address,
              .List,  // TODO: Stack:List,
              .Map
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
              .List,  // TODO: Stack:List,
              ?_Variables
              ):StateCell
        </TT></T>
    requires true
      andBool notBool u(0) in_keys(UserIdToRole)
      andBool actionDataInvariant(ActionData)
      andBool userIdToRoleInvariant(UserIdToRole)

      andBool ActionId in_keys(ActionData)
      // andBool notBool ActionId in_keys(ActionSigners)
    ensures true
endmodule
