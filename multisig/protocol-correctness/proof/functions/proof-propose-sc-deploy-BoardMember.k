//@ proof
require "trusted-propose-action-BoardMember.k"  //@ Bazel remove
require "trusted-propose-sc-deploy-fragment.k"  //@ Bazel remove
//@ trusted
//@ end

//@ proof
module PROOF-PROPOSE-SC-DEPLOY-BOARDMEMBER
//@ trusted
// module TRUSTED-PROPOSE-SC-DEPLOY-BOARDMEMBER
//@ end
  imports FUNCTIONS-EXECUTE

  //@ proof
  imports TRUSTED-PROPOSE-ACTION-BOARDMEMBER
  imports TRUSTED-PROPOSE-SC-DEPLOY-FRAGMENT
  //@ trusted
  //@ end

  claim <T><TT>
          <k> call(proposeSCDeploy(
                    Amount:BigUint,
                    Code:BoxedBytes,
                    Upgradeable:Bool,
                    Payable:Bool,
                    Readable:Bool,
                    Args:ExpressionList))
              ~> K:K
          </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              UserIdToRole:Map,
              Quorum:Usize,
              u(ActionLastIndex:Int),
              ActionData:Map,
              ActionSigners:Map,
              CallerAddress:Address,
              //@ proof
              .List,  // TODO: Stack:List,
              //@ trusted
              // Stack:List,
              //@ end
              .Map,
              PerformedActions:List
              )
        </TT></T>
      =>
        <T><TT>
          <k> evaluate(u(ActionLastIndex +Int 1)) ~> K </k>
          invariantStateFull(
              NumUsers,
              UserIdToAddress,
              AddressToUserId,
              NumBoardMembers,
              NumProposers,
              UserIdToRole,
              Quorum,
              u(ActionLastIndex +Int 1),
              u(ActionLastIndex +Int 1)
                      |-> SCDeploy(
                            Amount,
                            Code,
                            codeMetadataFunction(Upgradeable, Payable, Readable),
                            Args)
                  ActionData,
              (u(ActionLastIndex +Int 1) |-> [{AddressToUserId[CallerAddress]}:>Usize, .]) ActionSigners,
              CallerAddress,
              //@ proof
              .List,  // TODO: Stack:List,
              //@ trusted
              // Stack:List,
              //@ end
              ?_Variables,
              PerformedActions:List
              ):StateCell
        </TT></T>
    requires true
      andBool isKResult(Args)

      andBool valuesAreKResult(AddressToUserId)
      andBool valuesAreOfType(AddressToUserId, rUsize)
      andBool valuesAreNotEmpty(AddressToUserId, rUsize)

      andBool valuesAreOfType(UserIdToRole, rUserRole)
      andBool valuesAreKResult(UserIdToRole)

      andBool unusedIdsInMapKeys(ActionLastIndex +Int 1, keysMap(ActionData), expand(expanded))
      andBool unusedIdsInMapKeys(ActionLastIndex +Int 1, keysMap(ActionSigners), expand(expanded))

      andBool CallerAddress in_keys(AddressToUserId)
      andBool AddressToUserId[CallerAddress] in_keys(UserIdToRole)
      andBool UserIdToRole[AddressToUserId[CallerAddress]] ==K BoardMember
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule


