//@ proof
require "../functions/trusted-propose-action-BoardMember.k"  //@ Bazel remove
require "../functions/trusted-propose-action-Proposer.k"  //@ Bazel remove
require "../functions/trusted-propose-action-error-no-user.k"  //@ Bazel remove
require "../functions/trusted-propose-action-error-no-role.k"  //@ Bazel remove

module PROOF-PROPOSE-ADD-BOARD-MEMBER
  imports TRUSTED-PROPOSE-ACTION-ERROR-NO-ROLE
  imports TRUSTED-PROPOSE-ACTION-ERROR-NO-USER
  imports TRUSTED-PROPOSE-ACTION-BOARDMEMBER
  imports TRUSTED-PROPOSE-ACTION-PROPOSER
//@ trusted
// module TRUSTED-PROPOSE-ADD-BOARD-MEMBER
//@ end
  imports MALICIOUS-USER-EXECUTE
  imports PSEUDOCODE

  claim <T><TT>
          <k> runExternalCall(from MaliciousAddress run proposeAddBoardMember(_UserAddress:Address);) ~> K:K </k>
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
          <k> K </k>
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
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
