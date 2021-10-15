//@ proof
require "../functions/trusted-perform-action-endpoint-add-proposer-New.k"  //@ Bazel remove

module PROOF-PERFORM-PARTS-ADD-PROPOSER-NEW
  imports TRUSTED-PERFORM-ACTION-ENDPOINT-ADD-PROPOSER-NEW
//@ trusted
// module TRUSTED-PERFORM-PARTS-ADD-PROPOSER-NEW
//@ end

  imports PERFORM-ACTION-ENDPOINT-INSTRUMENTATION

  claim <T><TT>
          <k> add-proposer-New.k ~> call(performActionEndpoint(ActionId:Usize)) ~> K:K </k>
          invariantStateFull(
              u(NumUsers:Int),
              UserIdToAddress:Map,
              (CallerAddress |-> CallerId:Usize
                  _AddressToUserId:Map
              ) #as AddressToUserId:Map,
              u(NumBoardMembers:Int),
              u(NumProposers:Int),
              (CallerId |-> Role:UserRole
                  _UserIdToRole:Map
              ) #as UserIdToRole:Map,
              u(Quorum:Int),
              ActionLastIndex:Usize,
              ActionId |-> AddProposer(UserAddress:Address) #as Action:Action
                  ActionData:Map,
              ActionSigners:Map,
              CallerAddress:Address,
              Stack:Stack,
              .Map,
              PerformedActions:List
              )
        </TT></T>
      =>
        <T><TT>
          <k> evaluate(void) ~> K:K </k>
          invariantStateFull(
              u(NumUsers +Int 1),
              u(NumUsers +Int 1) |-> UserAddress UserIdToAddress,
              UserAddress |-> u(NumUsers +Int 1) AddressToUserId,
              u(NumBoardMembers),
              u(NumProposers +Int 1),
              u(NumUsers +Int 1) |-> Proposer UserIdToRole,
              u(Quorum),
              ActionLastIndex,
              ActionData,
              ActionSigners[ActionId <- undef],
              CallerAddress,
              Stack,
              ?_Variables:Map,
              ListItem(Action) PerformedActions
              )
        </TT></T>
    requires true
        // perform-from-id
        andBool isKResult(Action)

        andBool NumUsers >=Int 0
        // TODO: Perhaps replace with unusedIdsInMapValues(AddressToUserId) +
        // someting to map values to keys.
        andBool unusedIdsInMapKeys(NumUsers +Int 1, keysMap(UserIdToAddress), expand(expanded))
        andBool unusedIdsInMapKeys(NumUsers +Int 1, keysMap(UserIdToRole), expand(expanded))
        andBool Quorum <=Int NumBoardMembers

        andBool notBool UserAddress in_keys(AddressToUserId)

        // perform-fragment
        andBool actionSignersInvariant(ActionSigners)
        andBool userIdToRoleInvariant(UserIdToRole)
        andBool (Role ==K BoardMember orBool Role ==K Proposer)
        andBool Quorum <=Int countCanSignFunction({ActionSigners[ActionId] orDefault [.]}:>ExpressionList, opaque(UserIdToRole))
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
