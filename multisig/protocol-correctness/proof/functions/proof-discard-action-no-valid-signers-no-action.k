//@ proof
require "trusted-count-can-sign.k"  //@ Bazel remove
//@ trusted
//@ end

//@ proof
module PROOF-DISCARD-ACTION-NO-VALID-SIGNERS-NO-ACTION
  imports FUNCTIONS-EXECUTE
  imports TRUSTED-COUNT-CAN-SIGN
//@ trusted
// module TRUSTED-DISCARD-ACTION-NO-VALID-SIGNERS-NO-ACTION
  // imports EXECUTION-PROOF
//@ end

  // TODO: I think that this is an invalid case that should be discarded
  // by the main invariant.
  claim <T><TT>
          <k> call(discardAction(ActionId:Usize)) ~> K:K
          </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              (CallerAddress |-> UserId:Usize _AddressToUserId:Map) #as AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              (UserId |-> Role:UserRole _UserIdToRole:Map) #as UserIdToRole:Map,
              Quorum:Usize,
              ActionLastIndex:Usize,
              ActionData:Map,
              ActionId |-> SignerIds ActionSigners:Map,
              CallerAddress:Address,
              Stack:Stack,
              .Map,
              PerformedActions:List
              )
        </TT></T>
      =>
        <T><TT>
          <k> void ~> K </k>
          invariantStateFull(
              NumUsers,
              UserIdToAddress,
              AddressToUserId,
              NumBoardMembers,
              NumProposers,
              UserIdToRole,
              Quorum,
              ActionLastIndex:Usize,
              ActionData,
              ActionSigners,
              CallerAddress,
              Stack:Stack,
              ?_Variables,
              PerformedActions:List
              ):StateCell
        </TT></T>
    requires true
      andBool notBool u(0) in_keys(UserIdToRole)

      andBool isKResult(SignerIds)
      andBool listElementsAreUsize(SignerIds)
      andBool userIdToRoleInvariant(UserIdToRole)


      andBool (Role ==K BoardMember orBool Role ==K Proposer)
      andBool countCanSignFunction(SignerIds, opaque(UserIdToRole)) ==Int 0
      andBool notBool ActionId in_keys(ActionData)
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
