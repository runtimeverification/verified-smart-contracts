require "protocol-correctness/proof/execution-proof.k"
require "protocol-correctness/proof/invariant/invariant-execution.k"

module MALICIOUS-USER-EXECUTE-SYNTAX
  imports EXECUTION-PROOF-SYNTAX
endmodule

module MALICIOUS-USER-INVARIANT-FUNCTIONS
  imports MAP
  imports PSEUDOCODE-SYNTAX

  syntax Bool ::= onlyThisSigner(addressToUserId:Map, Address, actionSigners:Map)
      [function, functional]

  rule  onlyThisSigner(
            _AddressToUserId:Map,
            _Address:Address,
            .Map)
      => true
  rule  onlyThisSigner(
            AddressToUserId:Map,
            Address:Address,
            _Key |-> Signers ActionSigners:Map)
      =>
        #if Address in_keys(AddressToUserId)
        #then oneElementList(AddressToUserId[Address] orDefault void, Signers)
        #else false
        #fi
        andBool onlyThisSigner(AddressToUserId, Address, ActionSigners)
    [simplification]

  syntax Bool ::= oneElementList(element:KItem, ExpressionList) [function, functional]
  rule oneElementList(E:Expression, [E, .]) => true
  rule oneElementList(_, _) => false [owise]
endmodule

module MALICIOUS-USER-INVARIANT
  imports INVARIANT
  imports MALICIOUS-USER-INVARIANT-FUNCTIONS

  syntax Bool ::= maliciousInvariant(
            maliciousAddress:Address,
            numUsers:Usize,
            // initialUserIdToAddress:Map,
            currentUserIdToAddress:Map,
            // initialAddressToUserId:Map,
            currentAddressToUserId:Map,
            numBoardMembers:Usize,
            numProposers:Usize,
            userRoles:Map,
            quorum:Usize,
            actionLastIndex:Usize,
            actionData:Map,
            actionSigners:Map,
            PropertyHandling)
      [function, functional]

  rule  maliciousInvariant(
            MaliciousAddress:Address,
            NumUsers:Usize,
            // InitialUserIdToAddress:Map,
            CurrentUserIdToAddress:Map,
            // InitialAddressToUserId:Map,
            CurrentAddressToUserId:Map,
            NumBoardMembers:Usize,
            NumProposers:Usize,
            UserRoles:Map,
            u(Quorum:Int),
            ActionLastIndex:Usize,
            ActionData:Map,
            ActionSigners:Map,
            Handling:PropertyHandling)
      => true
        andBool invariant(
            NumUsers,
            CurrentUserIdToAddress,
            CurrentAddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserRoles,
            u(Quorum),
            ActionLastIndex,
            ActionData,
            ActionSigners,
            Handling)
        // andBool mapIncluded(InitialUserIdToAddress, CurrentUserIdToAddress)
        // andBool mapIncluded(InitialAddressToUserId, CurrentAddressToUserId)
        andBool onlyThisSigner(CurrentAddressToUserId, MaliciousAddress, ActionSigners)
        andBool Quorum >=Int 2
endmodule


module MALICIOUS-USER-HELPERS
  imports PSEUDOCODE-SYNTAX

  syntax KItem ::= runExternalCallsFromUser(Address, steps:Int)

  rule runExternalCallsFromUser(_:Address, Steps:Int) => .K
    requires Steps <=Int 0
  rule runExternalCallsFromUser(A:Address, Steps:Int)
      => runExternalCallFromUser(A) ~> runExternalCallsFromUser(A, Steps -Int 1)
    requires Steps >Int 0

  syntax KItem ::= runExternalCallFromUser(Address)

  rule  runExternalCallFromUser(A:Address)
        => runExternalCall(from A run proposeAddBoardMember(?_UserAddress:Address);)
  rule  runExternalCallFromUser(A:Address)
        => runExternalCall(from A run proposeAddProposer(?_UserAddress:Address);)
  rule  runExternalCallFromUser(A:Address)
        => runExternalCall(from A run proposeRemoveUser(?_UserAddress:Address);)
  rule  runExternalCallFromUser(A:Address)
        => runExternalCall(from A run proposeChangeQuorum(?_Quorum:Usize);)
  rule  runExternalCallFromUser(A:Address)
        => runExternalCall(from A run proposeSendEgld(
            ?_To:Address, ?_Amount:BigUint, ?_Data:BoxedBytes);)
  rule  runExternalCallFromUser(A:Address)
        => runExternalCall(from A run proposeSCDeploy(
            ?_Amount:BigUint,
            ?_Code:BoxedBytes,
            ?_Upgradeable:Bool,
            ?_Payable:Bool,
            ?_Readable:Bool,
            ?_Args:ExpressionList);)
  rule  runExternalCallFromUser(A:Address)
        => runExternalCall(from A run proposeSCCall(
            ?_To:Address,
            ?_Amount:BigUint,
            ?_Function:BoxedBytes,
            ?_Args:ExpressionList);)
  rule  runExternalCallFromUser(A:Address)
        => runExternalCall(from A run sign(?_ActionId:Usize);)
  rule  runExternalCallFromUser(A:Address)
        => runExternalCall(from A run unsign(?_ActionId:Usize);)
  rule  runExternalCallFromUser(A:Address)
        => runExternalCall(from A run performActionEndpoint(?_ActionId:Usize);)
  rule  runExternalCallFromUser(A:Address)
        => runExternalCall(from A run discardAction(?_ActionId:Usize);)
endmodule

module MALICIOUS-USER-EXECUTE
  imports EXECUTION-PROOF
  imports INVARIANT-EXECUTION
  imports MALICIOUS-USER-INVARIANT
  imports MALICIOUS-USER-HELPERS
endmodule