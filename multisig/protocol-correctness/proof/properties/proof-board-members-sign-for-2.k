require "../map/proof-map-semantics.k"

module TRUSTED-BOARD-MEMBERS-SIGN-FOR-2
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
              ActionSigners:Map)
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
              (ActionIndex |-> ?Signatures) ActionSigners):StateCell
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
            ActionSigners,
            expand(expanded))

        andBool newUserIdToRoleInvariant(PartialUserRoles, UserIdToAddress)
        andBool userIdToAddressInvariant(UserIdToAddress, AddressToUserId)
        andBool mapsAreReverse(AddressToUserId, UserIdToAddress)
        andBool mapIncluded(PartialUserRoles, UserRoles)
        andBool valuesAreNotEmpty(ActionData, rAction)
        andBool notBool ActionIndex in_keys(ActionSigners)
        andBool countMapValues(PartialUserRoles, BoardMember) >Int 0

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
            (ActionIndex |-> ?Signatures) ActionSigners,
            usesExpanded)

        andBool countCanSignFunction(?Signatures, opaque(UserRoles))
                ==Int countMapValues(PartialUserRoles, BoardMember)
    [trusted]
endmodule

module PROOF-BOARD-MEMBERS-SIGN-FOR-2
  imports MAP-EXECUTE
  imports PROPERTIES-EXECUTE
  imports PSEUDOCODE

  imports TRUSTED-MAP-SEMANTICS

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
              ActionSigners:Map)
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
              (ActionIndex |-> ?Signatures) ActionSigners):StateCell
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
            ActionSigners,
            expand(expanded))

        andBool newUserIdToRoleInvariant(PartialUserRoles, UserIdToAddress)
        andBool userIdToAddressInvariant(UserIdToAddress, AddressToUserId)
        andBool mapsAreReverse(AddressToUserId, UserIdToAddress)
        andBool mapIncluded(PartialUserRoles, UserRoles)
        andBool valuesAreNotEmpty(ActionData, rAction)
        andBool notBool ActionIndex in_keys(ActionSigners)
        andBool countMapValues(PartialUserRoles, BoardMember) >Int 0

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
            (ActionIndex |-> ?Signatures) ActionSigners,
            usesExpanded)

        andBool countCanSignFunction(?Signatures, opaque(UserRoles))
                ==Int countMapValues(PartialUserRoles, BoardMember)
endmodule
