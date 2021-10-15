//@ proof
require "trusted-propose-add-board-member.k"  //@ Bazel remove

module PROOF-CALL-INVARIANT
  imports TRUSTED-PROPOSE-ADD-BOARD-MEMBER
//@ trusted
// module TRUSTED-CALL-INVARIANT
//@ end
  imports MALICIOUS-USER-EXECUTE
  imports PSEUDOCODE

  claim <T><TT>
          <k> runExternalCallFromUser(MaliciousAddress:Address)
              ~> runExternalCallsFromUser(MaliciousAddress:Address, Count:Int)
              ~> K:K
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
              PerformedActions:List)
        </TT></T>
      =>
        <T><TT>
          <k> runExternalCallsFromUser(MaliciousAddress:Address, Count:Int)
              ~> K:K
          </k>
          invariantState(
              NumUsers,
              UserIdToAddress:Map,
              AddressToUserId:Map,
              NumBoardMembers,
              NumProposers,
              UserRoles,
              Quorum,
              u(?ActionLastIndex:Int),
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
            UserIdToAddress,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserRoles,
            Quorum,
            u(?ActionLastIndex),
            ?ActionData,
            ?ActionSigners,
            //@ proof
            usesExpanded
            //@ trusted
            // expand(expanded)
            //@ end
            )
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
