//@ proof
module PROOF-UNSIGN-NO-ACTION
  imports FUNCTIONS-EXECUTE
//@ trusted
// module TRUSTED-UNSIGN-NO-ACTION
  // imports EXECUTION-PROOF
//@ end

  claim <T><TT>
          <k> call(unsign(ActionId:Usize)) ~> K:K
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
              u(ActionLastIndex),
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
      andBool notBool ActionId in_keys(ActionData)
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
