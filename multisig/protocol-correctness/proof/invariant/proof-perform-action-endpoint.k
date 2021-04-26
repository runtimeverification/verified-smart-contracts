//@ proof
require "trusted-perform-parts-1.k"  //@ Bazel remove

module PROOF-PERFORM-ACTION-ENDPOINT
  imports INVARIANT-EXECUTION

  imports TRUSTED-PERFORM-PARTS-1
//@ trusted
// module TRUSTED-PERFORM-ACTION-ENDPOINT
//@ end

  claim <T><TT>
          <k> runExternalCalls(
                  (   from _:Address run performActionEndpoint(_ActionId:Usize);
                      EC:ExternalCommands
                  )
              )
          </k>
          invariantState(
              NumUsers:Usize,
              UserIdToAddress:Map,
              AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              UserRoles:Map,
              Quorum:Usize,
              ActionLastIndex0:Usize,
              ActionData0:Map,
              ActionSigners0:Map,
              _PerformedActions:List)
        </TT></T>
      =>
        <T><TT>
          <k> runExternalCalls(EC) </k>
          invariantState(
              ?NumUsers1:Usize,
              ?UserIdToAddress1:Map,
              ?AddressToUserId1:Map,
              ?NumBoardMembers1:Usize,
              ?NumProposers1:Usize,
              ?UserRoles1:Map,
              ?Quorum1:Usize,
              ?ActionLastIndex1:Usize,
              ?ActionData1:Map,
              ?ActionSigners1:Map,
              ?_PerformedActions:List):StateCell
        </TT></T>
    requires invariant(
        NumUsers:Usize,
        UserIdToAddress:Map,
        AddressToUserId:Map,
        NumBoardMembers:Usize,
        NumProposers:Usize,
        UserRoles:Map,
        Quorum:Usize,
        ActionLastIndex0:Usize,
        ActionData0:Map,
        ActionSigners0:Map,
        expand(expanded))
    ensures invariant(
        ?NumUsers1:Usize,
        ?UserIdToAddress1:Map,
        ?AddressToUserId1:Map,
        ?NumBoardMembers1:Usize,
        ?NumProposers1:Usize,
        ?UserRoles1:Map,
        ?Quorum1:Usize,
        ?ActionLastIndex1:Usize,
        ?ActionData1:Map,
        ?ActionSigners1:Map,
        usesExpanded)

  claim <T><TT>
          <k> call(getActionSignerIds(ActionId:Usize)) ~> K:K
          </k>
          invariantState(
              NumUsers:Usize,
              UserIdToAddress:Map,
              AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              UserRoles:Map,
              Quorum:Usize,
              ActionLastIndex:Usize,
              ActionData:Map,
              ActionSigners:Map,
              _PerformedActions:List):StateCell
        </TT></T>
      =>
        <T><TT>
          <k> ActionSigners[ActionId] orDefault [.] ~> K </k>
          invariantState(
              NumUsers:Usize,
              UserIdToAddress:Map,
              AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              UserRoles:Map,
              Quorum:Usize,
              ActionLastIndex:Usize,
              ActionData:Map,
              ActionSigners:Map,
              ?_PerformedActions:List):StateCell
        </TT></T>
    //@ proof
    //@ trusted
    // [trusted]
    //@ end

endmodule
