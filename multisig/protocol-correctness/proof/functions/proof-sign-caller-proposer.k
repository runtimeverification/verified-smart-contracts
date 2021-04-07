//@ proof
module PROOF-SIGN-CALLER-PROPOSER
//@ trusted
// module TRUSTED-SIGN-CALLER-PROPOSER
//@ end
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
              //@ proof
              .List,  // TODO: Stack:List,
              //@ trusted
              // Stack:List,
              //@ end
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
              //@ proof
              .List,  // TODO: Stack:List,
              //@ trusted
              // Stack:List,
              //@ end
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
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
