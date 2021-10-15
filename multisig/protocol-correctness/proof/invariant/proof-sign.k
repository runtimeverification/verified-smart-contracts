require "../functions/trusted-sign-empty-action.k"
require "../functions/trusted-sign-caller-not-user.k"
require "../functions/trusted-sign-caller-none.k"
require "../functions/trusted-sign-caller-proposer.k"
require "../functions/trusted-sign-no-signers.k"
require "../functions/trusted-sign-existing-signers-in-list.k"
require "../functions/trusted-sign-existing-signers-not-in-list.k"

module PROOF-SIGN
  imports INVARIANT-EXECUTION
  imports PSEUDOCODE

  imports TRUSTED-SIGN-EMPTY-ACTION
  imports TRUSTED-SIGN-CALLER-NOT-USER
  imports TRUSTED-SIGN-CALLER-NONE
  imports TRUSTED-SIGN-CALLER-PROPOSER
  imports TRUSTED-SIGN-NO-SIGNERS
  imports TRUSTED-SIGN-EXISTING-SIGNERS-IN-LIST
  imports TRUSTED-SIGN-EXISTING-SIGNERS-NOT-IN-LIST

  claim <T><TT>
          <k> runExternalCalls(
                  (   from _:Address run sign(_ActionId:Usize);
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
              PerformedActions:List)
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
              ?ActionSigners1:Map,
              PerformedActions:List):StateCell
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
