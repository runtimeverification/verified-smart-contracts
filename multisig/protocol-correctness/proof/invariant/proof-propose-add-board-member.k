require "../functions/functions-execute.k"

require "../functions/trusted-propose-action-BoardMember.k"
require "../functions/trusted-propose-action-Proposer.k"
require "../functions/trusted-propose-action-error-no-user.k"
require "../functions/trusted-propose-action-error-no-role.k"

module PROOF-PROPOSE-ADD-BOARD-MEMBER
  imports INVARIANT-EXECUTION
  imports PSEUDOCODE

  imports TRUSTED-PROPOSE-ACTION-ERROR-NO-ROLE
  imports TRUSTED-PROPOSE-ACTION-ERROR-NO-USER
  imports TRUSTED-PROPOSE-ACTION-BOARDMEMBER
  imports TRUSTED-PROPOSE-ACTION-PROPOSER

  claim <T><TT>
          <k> runExternalCalls(
                  (   from _:Address run proposeAddBoardMember(_Member:Address);
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
              ActionSigners0:Map)
        </TT></T>
      =>
        <T><TT>
          <k> runExternalCalls(EC) </k>
          invariantState(
              NumUsers:Usize,
              UserIdToAddress:Map,
              AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              UserRoles:Map,
              Quorum:Usize,
              ?ActionLastIndex1:Usize,
              ?ActionData1:Map,
              ?ActionSigners1:Map):StateCell
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
        NumUsers:Usize,
        UserIdToAddress:Map,
        AddressToUserId:Map,
        NumBoardMembers:Usize,
        NumProposers:Usize,
        UserRoles:Map,
        Quorum:Usize,
        ?ActionLastIndex1:Usize,
        ?ActionData1:Map,
        ?ActionSigners1:Map,
        usesExpanded)
endmodule
