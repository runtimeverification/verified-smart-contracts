//@ proof
module PROOF-PERFORM-ACTION-ENDPOINT-FRAGMENT-NEW
//@ trusted
// module TRUSTED-PERFORM-ACTION-ENDPOINT-FRAGMENT-NEW
//@ end
  imports FUNCTIONS-EXECUTE

  claim <T><TT>
          <k> runPseudoCode(
                  caller_address = getCaller();
                  caller_id = getUserId(caller_address);
                  caller_role = getUserIdToRole(caller_id);
                  require(userRoleCanPerformAction(caller_role));
                  require(quorumReached(ActionId:Usize));
                  performActionFromId(ActionId);
              )
              ~> K:K
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
          <k> error ~> K:K </k>
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
              caller_address |-> CallerAddress
                caller_id |-> u(0)
                caller_role |-> None,
              PerformedActions:List
              )
        </TT></T>
    requires true
        andBool notBool CallerAddress in_keys(AddressToUserId)
        andBool notBool u(0) in_keys(UserIdToRole)
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
