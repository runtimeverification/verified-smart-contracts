require "proof-count-can-sign.k"
require "proof-perform-add-board-member.k"
require "proof-perform-add-proposer-1.k"
require "proof-perform-add-proposer-2.k"
require "proof-perform-add-proposer-3.k"
require "proof-perform-add-proposer-4.k"
require "proof-perform-add-proposer-5.k"
require "proof-perform-add-proposer-6.k"
require "proof-perform-add-proposer-7.k"
require "proof-perform-add-proposer-8.k"
require "proof-perform-add-proposer-9.k"
require "proof-perform-change-quorum.k"
require "proof-perform-nothing.k"
require "proof-perform-remove-user-1.k"
require "proof-perform-remove-user-2.k"
require "proof-perform-remove-user-3.k"
require "proof-perform-remove-user-4.k"
require "proof-perform-remove-user-5.k"
require "proof-perform-remove-user-6.k"
require "proof-perform-remove-user-7.k"
require "proof-perform-remove-user-8.k"
require "proof-perform-remove-user-9.k"
require "proof-perform-remove-user-10.k"
require "proof-perform-s-c-call.k"
require "proof-perform-s-c-deploy.k"
require "proof-perform-send-egld.k"

module PROOF-PERFORM-ACTION-ENDPOINT
  imports INVARIANT-EXECUTION
  imports PSEUDOCODE

  imports TRUSTED-COUNT-CAN-SIGN
  imports TRUSTED-PERFORM-ADD-BOARD-MEMBER
  imports TRUSTED-PERFORM-ADD-PROPOSER-1
  imports TRUSTED-PERFORM-ADD-PROPOSER-2
  imports TRUSTED-PERFORM-ADD-PROPOSER-3
  imports TRUSTED-PERFORM-ADD-PROPOSER-4
  imports TRUSTED-PERFORM-ADD-PROPOSER-5
  imports TRUSTED-PERFORM-ADD-PROPOSER-6
  imports TRUSTED-PERFORM-ADD-PROPOSER-7
  imports TRUSTED-PERFORM-ADD-PROPOSER-8
  imports TRUSTED-PERFORM-ADD-PROPOSER-9
  imports TRUSTED-PERFORM-CHANGE-QUORUM
  imports TRUSTED-PERFORM-NOTHING
  imports TRUSTED-PERFORM-REMOVE-USER-1
  imports TRUSTED-PERFORM-REMOVE-USER-2
  imports TRUSTED-PERFORM-REMOVE-USER-3
  imports TRUSTED-PERFORM-REMOVE-USER-4
  imports TRUSTED-PERFORM-REMOVE-USER-5
  imports TRUSTED-PERFORM-REMOVE-USER-6
  imports TRUSTED-PERFORM-REMOVE-USER-7
  imports TRUSTED-PERFORM-REMOVE-USER-8
  imports TRUSTED-PERFORM-REMOVE-USER-9
  imports TRUSTED-PERFORM-REMOVE-USER-10
  imports TRUSTED-PERFORM-S-C-CALL
  imports TRUSTED-PERFORM-S-C-DEPLOY
  imports TRUSTED-PERFORM-SEND-EGLD

  claim <T><TT>
          <k> runExternalCalls(
                  (   from _:Address run performActionEndpoint(_ActionId:Usize);
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
              ?NumUsers1:Usize,
              ?UserIdToAddress1:Map,
              ?AddressToUserId1:Map,
              ?NumBoardMembers1:Usize,
              ?NumProposers1:Usize,
              ?UserRoles1:Map,
              ?Quorum1:Usize,
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
        ?NumUsers1:Usize,
        ?UserIdToAddress1:Map,
        ?AddressToUserId1:Map,
        ?NumBoardMembers1:Usize,
        ?NumProposers1:Usize,
        ?UserRoles1:Map,
        ?Quorum1:Usize,
        ?ActionLastIndex1:Usize,
        ?ActionData1:Map,
        ?ActionSigners1:Map,
        usesExpanded)

/*
  claim <T><TT>
          <k> call(userRoleCanPropose(U:UserRole)) ~> K:K
          </k>
          State:StateCell
        </TT></T>
      =>
        <T><TT>
          <k> true ~> K </k>
          State:StateCell
        </TT></T>
    requires notBool U ==K None

  claim <T><TT>
          <k> call(userRoleCanPropose(U:UserRole)) ~> K:K
          </k>
          State:StateCell
        </TT></T>
      =>
        <T><TT>
          <k> false ~> K </k>
          State
        </TT></T>
    requires U ==K None
*/

  claim <T><TT>
          <k> call(getActionSignerIds(ActionId:Usize)) ~> K:K
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
              ActionSigners:Map):StateCell
        </TT></T>
      =>
        <T><TT>
          <k> ActionSigners[ActionId] orDefault [.] ~> K </k>
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
              ActionSigners:Map):StateCell
        </TT></T>

endmodule
