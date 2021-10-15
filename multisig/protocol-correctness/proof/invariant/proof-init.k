require "proof-init-loop.k"

module PROOF-INIT
  imports INVARIANT-EXECUTION
  imports PSEUDOCODE
  imports TRUSTED-INIT-LOOP

  rule forall-v-greater-or-equal-than-u-v-not-in-m(_:Usize, .Map, _:ExpressionList)
      => true  [simplification]

  claim call(listLen(L:ExpressionList)) => u(pListLen(L))
    requires isKResult(L)
    [trusted]

  claim <T><TT>
          <k> runExternalCalls(
                  (   from _:Address run init(_Quorum:Usize, Addresses:ExpressionList);
                      EC:ExternalCommands
                  )
              )
          </k>
          initialState
        </TT></T>
      =>
        <T><TT>
          <k> runExternalCalls(EC) </k>
          invariantState(
              ?NumUsers:Usize,
              ?UserIdToAddress:Map,
              ?AddressToUserId:Map,
              ?NumBoardMembers:Usize,
              ?NumProposers:Usize,
              ?UserIdToRole:Map,
              ?Quorum:Usize,
              ?ActionLastIndex:Usize,
              ?ActionData:Map,
              ?ActionSigners:Map,
              ?PerformedActions:List)
        </TT></T>
    requires    listElementsAreAddresses(Addresses)
        //andBool noCommonItem(u(1), .Map, Addresses)

        andBool isKResult(Addresses)
        andBool noReusedIndexAddress(u(1), .Map, Addresses)
        andBool noReusedIndexRole(u(1), .Map, Addresses)

    ensures invariant(
          ?NumUsers,
          ?UserIdToAddress,
          ?AddressToUserId,
          ?NumBoardMembers,
          ?NumProposers,
          ?UserIdToRole,
          ?Quorum,
          ?ActionLastIndex,
          ?ActionData,
          ?ActionSigners,
          usesExpanded)
      orBool invariantState(
                ?NumUsers:Usize,
                ?UserIdToAddress:Map,
                ?AddressToUserId:Map,
                ?NumBoardMembers:Usize,
                ?NumProposers:Usize,
                ?UserIdToRole:Map,
                ?Quorum:Usize,
                ?ActionLastIndex:Usize,
                ?ActionData:Map,
                ?ActionSigners:Map,
                ?PerformedActions:List)
              ==K initialState
endmodule
