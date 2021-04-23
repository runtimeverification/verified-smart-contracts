module PROOF-CANNOT-PERFORM
  imports MALICIOUS-USER-EXECUTE
  imports PSEUDOCODE

  claim <T><TT>
          <k> runExternalCallsFromUser(MaliciousAddress:Address, _Count:Int) ~> K:K </k>
          invariantState(
              NumUsers:Usize,
              UserIdToAddress:Map,
              AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              UserRoles:Map,
              u(Quorum:Int),
              ActionLastIndex:Usize,
              ActionData:Map,
              ActionSigners:Map,
              PerformedActions:List)
        </TT></T>
      =>
        <T><TT>
          <k> K </k>
          invariantState(
              NumUsers,
              ?UserIdToAddress:Map,
              ?AddressToUserId:Map,
              NumBoardMembers,
              NumProposers,
              UserRoles,
              u(Quorum),
              ?ActionLastIndex1:Usize,
              ?ActionData1:Map,
              ?ActionSigners1:Map,
              PerformedActions:List):StateCell
        </TT></T>
    requires true
        andBool maliciousInvariant(
            MaliciousAddress,
            NumUsers,
            UserIdToAddress,
            UserIdToAddress,
            AddressToUserId,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserRoles,
            u(Quorum),
            ActionLastIndex,
            ActionData,
            ActionSigners,
            expand(expanded))

        // andBool Quorum >=Int 2
    ensures true
        andBool maliciousInvariant(
            MaliciousAddress,
            NumUsers,
            UserIdToAddress,
            ?UserIdToAddress,
            AddressToUserId,
            ?AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserRoles,
            u(Quorum),
            ?ActionLastIndex,
            ?ActionData,
            ?ActionSigners,
            usesExpanded)
endmodule
