module PROOF-CALL-INVARIANT
  imports MALICIOUS-USER-EXECUTE
  imports PSEUDOCODE

  claim <T><TT>
          <k> runExternalCallFromUser(MaliciousAddress:Address) ~> K:K </k>
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
              PerformedActions:List)
        </TT></T>
      =>
        <T><TT>
          <k> runExternalCalls(EC) </k>
          invariantState(
              NumUsers,
              ?UserIdToAddress:Map,
              ?AddressToUserId:Map,
              NumBoardMembers,
              NumProposers,
              UserRoles,
              Quorum,
              ?ActionLastIndex:Usize,
              ?ActionData:Map,
              ?ActionSigners:Map,
              PerformedActions:List):StateCell
        </TT></T>
    requires true
        andBool maliciousInvariant(
            MaliciousAddress,
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserRoles,
            Quorum,
            ActionLastIndex,
            ActionData,
            ActionSigners,
            expand(expanded))
    ensures true
        andBool maliciousInvariant(
            MaliciousAddress,
            NumUsers,
            ?UserIdToAddress,
            ?AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserRoles,
            Quorum,
            ?ActionLastIndex,
            ?ActionData,
            ?ActionSigners,
            usesExpanded)
endmodule
