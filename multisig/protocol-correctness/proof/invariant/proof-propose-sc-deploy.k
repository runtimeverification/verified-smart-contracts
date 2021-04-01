require "../functions/functions-execute.k"

require "../functions/proof-propose-action-BoardMember.k"
require "../functions/proof-propose-action-Proposer.k"
require "../functions/proof-propose-action-error.k"

module PROOF-PROPOSE-SC-DEPLOY
  imports INVARIANT-EXECUTION
  imports PSEUDOCODE

  imports TRUSTED-PROPOSE-ACTION-ERROR
  imports TRUSTED-PROPOSE-ACTION-BOARDMEMBER
  imports TRUSTED-PROPOSE-ACTION-PROPOSER

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
