//@ proof
require "trusted-count-can-sign.k"  //@ Bazel remove
//@ trusted
//@ end

//@ proof
module PROOF-DISCARD-ACTION-NO-SIGNERS
  imports FUNCTIONS-EXECUTE
  imports TRUSTED-COUNT-CAN-SIGN
//@ trusted
// module TRUSTED-DISCARD-ACTION-NO-SIGNERS
  // imports EXECUTION-PROOF
//@ end

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
              ActionId |-> _:Action ActionData:Map,
              ActionSigners:Map,
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

      andBool userIdToRoleInvariant(UserIdToRole)


      andBool (Role ==K BoardMember orBool Role ==K Proposer)
      andBool notBool ActionId in_keys(ActionSigners)
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
