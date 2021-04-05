module PROOF-CANNOT-PERFORM
  imports MALICIOUS-USER-EXECUTION
  imports PSEUDOCODE

  claim <T><TT>
          <k> runExternalCallsFromUser(MaliciousAddress:Address) ~> K:K </k>
          invariantState(
              NumUsers:Usize,
              UserIdToAddress:Map,
              AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              UserRoles:Map,
              Quorum:Usize,
              ActionLastIndex0:Usize,
              ActionId:Usize -> Action:Action,
              .Map,
              .List,
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
              ?ActionLastIndex1:Usize,
              ?ActionData1:Map,
              ?ActionSigners1:Map,
              .List,
              PerformedActions:List):StateCell
        </TT></T>
    requires true
        andBool maliciousInvariant(
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
    ensures true
        andBool mapIncluded(AddressToUserId, ?AddressToUserId)
        andBool mapIncluded(UserIdToAddress, ?UserIdToAddress)
        andBool atMostOneSigner(?ActionSigners1)
endmodule
