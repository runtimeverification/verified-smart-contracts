require "../map/proof-map-semantics.k"

require "../functions/trusted-sign-empty-action.k"
require "../functions/trusted-sign-caller-not-user.k"
require "../functions/trusted-sign-caller-none.k"
require "../functions/trusted-sign-caller-proposer.k"
require "../functions/trusted-sign-no-signers.k"
require "../functions/trusted-sign-existing-signers-in-list.k"
require "../functions/trusted-sign-existing-signers-not-in-list.k"

module TRUSTED-BOARD-MEMBERS-SIGN-FOR
  imports PROPERTIES-EXECUTE
  imports PSEUDOCODE

  claim <T><TT>
          <k> boardMembersSignFor(ActionIndex:Usize, PartialUserRoles:Map)
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
              (ActionIndex |-> _Action:KItem _ActionData:Map) #as ActionData:Map,
              ActionIndex |-> Signatures:ExpressionList ActionSigners:Map,
              PerformedActions:List)
        </TT></T>
      =>
        <T><TT>
          <k> K:K </k>
          invariantState(
              NumUsers,
              UserIdToAddress,
              AddressToUserId,
              NumBoardMembers,
              NumProposers,
              UserRoles,
              Quorum,
              ActionLastIndex,
              ActionData,
              ActionIndex |-> ?Signatures ActionSigners,
              PerformedActions:List):StateCell
        </TT></T>
    requires invariant(
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserRoles,
            Quorum,
            ActionLastIndex,
            ActionData,
            ActionIndex |-> Signatures ActionSigners,
            expand(expanded))

        andBool newUserIdToRoleInvariant(PartialUserRoles, UserIdToAddress)
        andBool userIdToAddressInvariant(UserIdToAddress, AddressToUserId)
        andBool mapsAreReverse(AddressToUserId, UserIdToAddress)
        andBool mapIncluded(PartialUserRoles, UserRoles)
        andBool valuesAreNotEmpty(ActionData, rAction)

        andBool noMapKeyInList(PartialUserRoles, Signatures)

    ensures invariant(
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserRoles,
            Quorum,
            ActionLastIndex,
            ActionData,
            ActionIndex |-> ?Signatures ActionSigners,
            usesExpanded)

        andBool countCanSignFunction(?Signatures, opaque(UserRoles))
                ==Int countMapValues(PartialUserRoles, BoardMember)
                      +Int countCanSignFunction(Signatures, opaque(UserRoles))
    [trusted]
endmodule

module PROOF-BOARD-MEMBERS-SIGN-FOR
  imports MAP-EXECUTE
  imports PROPERTIES-EXECUTE
  imports PSEUDOCODE

  imports TRUSTED-MAP-SEMANTICS

  imports TRUSTED-SIGN-EMPTY-ACTION
  imports TRUSTED-SIGN-CALLER-NOT-USER
  imports TRUSTED-SIGN-CALLER-NONE
  imports TRUSTED-SIGN-CALLER-PROPOSER
  imports TRUSTED-SIGN-NO-SIGNERS
  imports TRUSTED-SIGN-EXISTING-SIGNERS-IN-LIST
  imports TRUSTED-SIGN-EXISTING-SIGNERS-NOT-IN-LIST

  claim <T><TT>
          <k> boardMembersSignFor(ActionIndex:Usize, PartialUserRoles:Map)
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
              (ActionIndex |-> _Action:KItem _ActionData:Map) #as ActionData:Map,
              ActionIndex |-> Signatures:ExpressionList ActionSigners:Map,
              PerformedActions:List)
        </TT></T>
      =>
        <T><TT>
          <k> K:K </k>
          invariantState(
              NumUsers,
              UserIdToAddress,
              AddressToUserId,
              NumBoardMembers,
              NumProposers,
              UserRoles,
              Quorum,
              ActionLastIndex,
              ActionData,
              ActionIndex |-> ?Signatures ActionSigners,
              PerformedActions:List):StateCell
        </TT></T>
    requires invariant(
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserRoles,
            Quorum,
            ActionLastIndex,
            ActionData,
            ActionIndex |-> Signatures ActionSigners,
            expand(expanded))

        andBool newUserIdToRoleInvariant(PartialUserRoles, UserIdToAddress)
        andBool userIdToAddressInvariant(UserIdToAddress, AddressToUserId)
        andBool mapsAreReverse(AddressToUserId, UserIdToAddress)
        andBool mapIncluded(PartialUserRoles, UserRoles)
        andBool valuesAreNotEmpty(ActionData, rAction)
        andBool noMapKeyInList(PartialUserRoles, Signatures)
    ensures invariant(
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserRoles,
            Quorum,
            ActionLastIndex,
            ActionData,
            ActionIndex |-> ?Signatures ActionSigners,
            usesExpanded)
        andBool countCanSignFunction(?Signatures, opaque(UserRoles))
                ==Int countMapValues(PartialUserRoles, BoardMember)
                      +Int countCanSignFunction(Signatures, opaque(UserRoles))

endmodule
