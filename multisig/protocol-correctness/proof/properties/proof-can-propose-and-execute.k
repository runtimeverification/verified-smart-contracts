require "../invariant/proof-count-can-sign.k"
require "../map/proof-map-semantics.k"
require "proof-board-members-sign-for.k"
require "proof-board-members-sign-for-2.k"
require "proof-board-members-sign-for-3.k"

require "../functions/trusted-propose-action-BoardMember.k"
require "../functions/trusted-propose-action-Proposer.k"
require "../functions/trusted-propose-action-error-no-user.k"
require "../functions/trusted-propose-action-error-no-role.k"

module PROOF-CAN-PROPOSE-AND-EXECUTE
  imports MAP-EXECUTE
  imports PROPERTIES-EXECUTE
  imports PSEUDOCODE

  imports TRUSTED-BOARD-MEMBERS-SIGN-FOR
  imports TRUSTED-BOARD-MEMBERS-SIGN-FOR-2
  imports TRUSTED-BOARD-MEMBERS-SIGN-FOR-3

  imports TRUSTED-COUNT-CAN-SIGN
  imports TRUSTED-MAP-SEMANTICS

  imports TRUSTED-PROPOSE-ACTION-ERROR-NO-ROLE
  imports TRUSTED-PROPOSE-ACTION-ERROR-NO-USER
  imports TRUSTED-PROPOSE-ACTION-BOARDMEMBER
  imports TRUSTED-PROPOSE-ACTION-PROPOSER

  claim <T><TT>
          <k> pickBoardMemberOrProposer(UserIdToRole)
              ~> withPickedUserCall(proposeChangeQuorum(u(0)))
              ~> allBoardMembersSignFor(add(ActionLastIndex, u(1)))
              ~> pickBoardMemberOrProposer(UserIdToRole)
              ~> withPickedUserCall(performActionEndpoint(add(ActionLastIndex, u(1))))
          </k>
          invariantState(
              NumUsers:Usize,
              UserIdToAddress:Map,
              AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              UserIdToRole:Map,
              Quorum:Usize,
              ActionLastIndex:Usize,
              ActionData:Map,
              ActionSigners:Map)
        </TT></T>
      =>
        <T><TT>
          <k> .K </k>
          invariantState(
              NumUsers:Usize,
              UserIdToAddress:Map,
              AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              UserIdToRole:Map,
              u(0),
              add(ActionLastIndex, u(1)),
              ActionData:Map,
              ActionSigners:Map):StateCell
        </TT></T>
    requires invariant(
          NumUsers:Usize,
          UserIdToAddress:Map,
          AddressToUserId:Map,
          NumBoardMembers:Usize,
          NumProposers:Usize,
          UserIdToRole:Map,
          Quorum:Usize,
          ActionLastIndex:Usize,
          ActionData:Map,
          ActionSigners:Map,
          expand(expand(expanded)))
      // TODO: Move everything below to the invariant.
      andBool valuesAreOfType(UserIdToAddress, rAddress)
      andBool valuesAreKResult(UserIdToAddress)

      andBool newUserIdToRoleInvariant(UserIdToRole, UserIdToAddress)
      andBool userIdToAddressInvariant(UserIdToAddress, AddressToUserId)
      andBool mapsAreReverse(AddressToUserId, UserIdToAddress)

      andBool valuesAreNotEmpty(ActionData, rAction)

      andBool mapCount(UserIdToRole, MEP.IsValue(BoardMember))
          +Int mapCount(UserIdToRole, MEP.IsValue(Proposer))
          >Int 0

endmodule