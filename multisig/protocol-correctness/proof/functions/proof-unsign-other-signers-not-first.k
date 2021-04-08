//@ proof
module PROOF-UNSIGN-OTHER-SIGNERS-NOT-FIRST
  imports FUNCTIONS-EXECUTE
//@ trusted
// module TRUSTED-UNSIGN-OTHER-SIGNERS-NOT-FIRST
  // imports EXECUTION-PROOF
//@ end

  claim <T><TT>
          <k> call(unsign(ActionId:Usize)) ~> K:K
          </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              (CallerAddress |-> UserId:Usize _AddressToUserId:Map) #as AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              (UserId |-> BoardMember _UserIdToRole:Map) #as UserIdToRole:Map,
              Quorum:Usize,
              u(ActionLastIndex:Int),
              (ActionId |-> Action:Action _ActionData:Map) #as ActionData:Map,
              ActionId |-> [(First:Usize, _Signers:ExpressionCSV) #as Signers:ExpressionCSV] ActionSigners:Map,
              CallerAddress:Address,
              //@ proof
              .List,  // TODO: Stack:List,
              //@ trusted
              // Stack:List,
              //@ end
              .Map
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
              u(ActionLastIndex),
              ActionData,
              ActionId |-> [#listSwapRemove(Signers, #listFind([Signers], UserId))] ActionSigners,
              CallerAddress,
              //@ proof
              .List,  // TODO: Stack:List,
              //@ trusted
              // Stack:List,
              //@ end
              ?_Variables
              ):StateCell
        </TT></T>
    requires true
      andBool isKResult(Action)
      andBool valueIsNotEmpty(Action, rAction)
      andBool isKResult(Signers)

      andBool #listFind([Signers], UserId) >=Int 0
      andBool notBool First ==K UserId  // TODO: Combine with the above.
      // andBool pListLen([Signers]) >=Int 2
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
