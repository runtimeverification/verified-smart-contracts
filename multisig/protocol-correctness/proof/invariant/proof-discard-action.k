require "../functions/trusted-discard-action-has-signers.k"
require "../functions/trusted-discard-action-no-role.k"
require "../functions/trusted-discard-action-no-signers.k"
require "../functions/trusted-discard-action-no-user.k"
require "../functions/trusted-discard-action-no-valid-signers.k"

module PROOF-DISCARD-ACTION
  imports INVARIANT-EXECUTION
  imports PSEUDOCODE

  imports TRUSTED-DISCARD-ACTION-HAS-SIGNERS
  imports TRUSTED-DISCARD-ACTION-NO-ROLE
  imports TRUSTED-DISCARD-ACTION-NO-SIGNERS
  imports TRUSTED-DISCARD-ACTION-NO-USER
  imports TRUSTED-DISCARD-ACTION-NO-VALID-SIGNERS

  claim <T><TT>
          <k> runExternalCalls(
                  (   from _:Address run discardAction(ActionId:Usize);
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
              NumUsers,
              UserIdToAddress,
              AddressToUserId,
              NumBoardMembers,
              NumProposers,
              UserRoles,
              Quorum,
              ?ActionLastIndex1:Usize,
              ?ActionData1:Map,
              ?ActionSigners1:Map):StateCell
        </TT></T>
    requires invariant(
        NumUsers,
        UserIdToAddress,
        AddressToUserId,
        NumBoardMembers,
        NumProposers,
        UserRoles,
        Quorum,
        ActionLastIndex0,
        ActionData0,
        ActionSigners0,
        expand(expanded))
    ensures invariant(
        NumUsers,
        UserIdToAddress,
        AddressToUserId,
        NumBoardMembers,
        NumProposers,
        UserRoles,
        Quorum,
        ?ActionLastIndex1:Usize,
        ?ActionData1:Map,
        ?ActionSigners1:Map,
        usesExpanded)
endmodule
