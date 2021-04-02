require "../functions/trusted-unsign-no-action.k"
require "../functions/trusted-unsign-only-signer.k"
require "../functions/trusted-unsign-other-signers-not-first.k"
require "../functions/trusted-unsign-other-signers-first.k"
require "../functions/trusted-unsign-not-signed.k"
require "../functions/trusted-unsign-no-signers.k"
require "../functions/trusted-unsign-Proposer.k"
require "../functions/trusted-unsign-no-role.k"
require "../functions/trusted-unsign-no-user.k"

module PROOF-UNSIGN
  imports INVARIANT-EXECUTION
  imports PSEUDOCODE

  imports TRUSTED-UNSIGN-NO-ACTION
  imports TRUSTED-UNSIGN-ONLY-SIGNER
  imports TRUSTED-UNSIGN-OTHER-SIGNERS-NOT-FIRST
  imports TRUSTED-UNSIGN-OTHER-SIGNERS-FIRST
  imports TRUSTED-UNSIGN-NOT-SIGNED
  imports TRUSTED-UNSIGN-NO-SIGNERS
  imports TRUSTED-UNSIGN-PROPOSER
  imports TRUSTED-UNSIGN-NO-ROLE
  imports TRUSTED-UNSIGN-NO-USER

  claim <T><TT>
          <k> runExternalCalls(
                  (   from _:Address run unsign(_ActionId:Usize);
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
