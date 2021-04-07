require "../functions/functions-execute.k"

require "../functions/trusted-propose-sc-deploy-BoardMember.k"
require "../functions/trusted-propose-sc-deploy-Proposer.k"
require "../functions/trusted-propose-sc-deploy-error-no-user.k"
require "../functions/trusted-propose-sc-deploy-error-no-role.k"

module PROOF-PROPOSE-SC-DEPLOY
  imports INVARIANT-EXECUTION
  imports PSEUDOCODE

  imports TRUSTED-PROPOSE-SC-DEPLOY-ERROR-NO-USER
  imports TRUSTED-PROPOSE-SC-DEPLOY-ERROR-NO-ROLE
  imports TRUSTED-PROPOSE-SC-DEPLOY-BOARDMEMBER
  imports TRUSTED-PROPOSE-SC-DEPLOY-PROPOSER

  claim <T><TT>
          <k> runExternalCalls(
                  (   from _:Address run proposeSCDeploy(
                                _Amount:BigUint,
                                _Code:BoxedBytes,
                                _Upgradeable:Bool,
                                _Payable:Bool,
                                _Readable:Bool,
                                Args:ExpressionList);
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
              NumUsers:Usize,
              UserIdToAddress:Map,
              AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              UserRoles:Map,
              Quorum:Usize,
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
        andBool isKResult(Args)
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
