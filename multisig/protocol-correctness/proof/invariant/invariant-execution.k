require "../execution-proof.k"
require "../functions/functions-execute.k"

require "count-can-sign-parts.k"
require "init-loop-parts.k"
require "perform-parts.k"

module INVARIANT-EXECUTION-SYNTAX
  imports EXECUTION-PROOF-SYNTAX
endmodule

// TODO: Delete.
module TEST
  imports INT

  syntax KItem ::= sub(Int)
  rule sub(I:Int) => .K requires I <=Int 0
  rule sub(I:Int) => sub(I -Int 1) requires notBool (I <=Int 0)
endmodule

module INVARIANT-INSTRUMENTATION
  imports MAP

  imports PROOF-INSTRUMENTATION
  imports PSEUDOCODE

  rule  nullableMapLookup(_:KItem, M:Map, _:ReflectionType)
        ~> (.K => lazyConcretizeKeys(M))
        ~> K:KItem
    requires notBool isLazyConcretize(K)
     [priority(20)]
  rule (E:Expression => .K) ~> lazyConcretizeKeys(_) ~> (.K => E)
    [priority(20)]

  rule  nullableMapSet(_:KItem, _:KItem, _:Map, _:ReflectionType)  // This may be needed only for addressToUserID, in init.
        ~> (.K => lazyConcretizeKeysFreezer)
        ~> K:KItem
    requires notBool isLazyConcretize(K)
    [priority(20)]
  rule (M:Map ~> lazyConcretizeKeysFreezer) => (lazyConcretizeKeys(M) ~> M)
    [priority(20)]

  // syntax KItem ::= lazySplitMap(k:KItem, m:Map, value:KItem, remainder:Map)
  // rule lazySplitMap(K:KItem, M:Map, Value:KItem, Remainder:Map)
  //     => splitMap(K, M, Value, Remainder)
endmodule

module PERFORM-SPLIT-ACTION-INSTRUMENTATION
  imports PSEUDOCODE

  syntax KItem ::= "splitting-action"
  rule  <k> pushContext ~> (.K => splitAction(A) ~> splitting-action) ~> call(performAction(A:Action))
        ...</k>
    [priority(10)]
  rule  <k> (splitting-action => .K) ...</k>
    [priority(20)]

  syntax KItem ::= splitAction(Action)
  rule splitAction(Nothing) => .K
  rule splitAction(AddBoardMember(_:Address)) => .K
  rule splitAction(AddProposer(_:Address)) => .K
  rule splitAction(RemoveUser(address(_:Int))) => .K
  rule splitAction(ChangeQuorum(_:Usize)) => .K
  rule splitAction(SendEgld(_To:Address, _Amount:BigUint, _Data:BoxedBytes)) => .K
  rule splitAction(SCDeploy(
          _Amount:BigUint,
          _Code:BoxedBytes,
          _CodeMetadata:CodeMetadata,
          _Arguments:ExpressionList))
      => .K
  rule splitAction(SCCall(
          _To:Address,
          _Amount:BigUint,
          _Function:BoxedBytes,
          _Arguments:ExpressionList))
      => .K

endmodule

module PERFORM-ACTION-REMOVE-USER-INSTRUMENTATION
  imports INVARIANT-INSTRUMENTATION
  imports PERFORM-SPLIT-ACTION-INSTRUMENTATION
  imports PSEUDOCODE

  syntax KItem ::= splittingDeleteCaller(Address)
  syntax KItem ::= splittingDeleteCaller1(Address)
  syntax KItem ::= splittingDeleteCaller2(Usize)
  rule  (splitting-action => splittingDeleteCaller(A))
        ~> call(performAction(RemoveUser(A:Address)))
    [priority(10)]

  rule  <k> splittingDeleteCaller(A:Address)
            =>  branchK(
                  A in_keys(AddressToUserId),
                  splittingDeleteCaller1(A),
                  .K
                )
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
  rule  <k> (
              splittingDeleteCaller1(A:Address)
              => makeConcreteValue(A, rUsize, AddressToUserId)
                ~> branchK(
                      AddressToUserId[A] in_keys(UserIdToRole),
                      splittingDeleteCaller2({AddressToUserId[A]}:>Usize),
                      .K
                )
            )
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <user-roles>UserIdToRole:Map</user-roles>
    requires A in_keys(AddressToUserId)

  rule  <k> (
              splittingDeleteCaller2(UserId:Usize)
              => makeConcreteValue(UserId, rUserRole, UserIdToRole)
                ~> lazyConcretizeKeys(UserIdToRole)  // TODO: Likely not needed.
                ~> branchK(
                      UserIdToRole[UserId] ==K BoardMember,
                      splitBoolean(Quorum <=Int NumBoardMembers -Int 1),
                      splitBoolean(Quorum <=Int NumBoardMembers)
                  )
                ~> splitBoolean(NumBoardMembers -Int 1 +Int NumProposers >Int 0)
            )
        ...</k>
        <user-roles>UserIdToRole:Map</user-roles>
        <num-board-members>u(NumBoardMembers:Int)</num-board-members>
        <num-proposers>u(NumProposers:Int)</num-proposers>
        <quorum>u(Quorum:Int)</quorum>
    requires UserId in_keys(UserIdToRole)
endmodule

module PERFORM-ACTION-SC-DEPLOY-INSTRUMENTATION
  imports PERFORM-SPLIT-ACTION-INSTRUMENTATION
  imports INVARIANT-INSTRUMENTATION

  rule  <k> (splitting-action => concretizeValue(Arguments))
            ~> call(performAction(SCDeploy(
                        _Amount:BigUint,
                        _Code:BoxedBytes,
                        _CodeMetadata:CodeMetadata,
                        Arguments:ExpressionList)))
        ...</k>
    [priority(10)]

endmodule

module PROPOSE-SC-DEPLOY-INSTRUMENTATION
  imports PROOF-INSTRUMENTATION
  imports PSEUDOCODE

  syntax KItem ::= "split-sc-deploy"
  syntax KItem ::= "split-sc-deploy1"

  rule  preCall
        ~> (.K => split-sc-deploy)
        ~> call(proposeSCDeploy(_:BigUint, _:BoxedBytes, _:Bool, _:Bool, _:Bool, _:ExpressionList))
  [priority(20)]

  rule  <k> split-sc-deploy
            =>  branchK(
                  Caller in_keys(AddressToUserId),
                  makeConcreteValue(Caller, rUsize, AddressToUserId)
                    ~>  split-sc-deploy1,
                  .K
                )
        ... </k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <caller-address>Caller:KItem</caller-address>

  rule  <k> split-sc-deploy1
            =>  branchK(
                  AddressToUserId[Caller] in_keys(UserIdToRole),
                  makeConcreteValue(AddressToUserId[Caller], rUserRole, UserIdToRole),
                  .K
                )
        ... </k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <user-roles> UserIdToRole:Map </user-roles>
        <caller-address>Caller:KItem</caller-address>
endmodule

module PERFORM-ACTION-ADD-PROPOSER-INSTRUMENTATION
  imports INVARIANT-INSTRUMENTATION
  imports PERFORM-SPLIT-ACTION-INSTRUMENTATION
  imports PSEUDOCODE

  syntax KItem ::= splittingActionProposer(Address)

  rule  <k> (
              splitting-action
              =>  branchK(
                    A1 in_keys(AddressToUserId),
                    splittingActionProposer(A1),
                    .K
                  )
            )
            ~> call(performAction(AddProposer(A1:Address)))
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
    [priority(10)]

  rule  <k> splittingActionProposer(A1:Address)
            =>    makeConcreteValue(A1, rUsize, AddressToUserId)
              ~>  branchK(
                    AddressToUserId[A1] in_keys(UserIdToRole),
                    makeConcreteValue(AddressToUserId[A1], rUserRole, UserIdToRole),
                    .K
                  )
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <user-roles> UserIdToRole:Map </user-roles>
    requires A1 in_keys(AddressToUserId)
      // TODO: Do I need AddressToUserId[A1] in_keys(UserIdToRole)?
endmodule

module CHANGE-USER-ROLE-INSTRUMENTATION
  imports INVARIANT-INSTRUMENTATION
  imports PSEUDOCODE

  syntax KItem ::= splitChangeUserRole(Address)
  syntax KItem ::= splitChangeUserRole2(Address)
  syntax KItem ::= splitChangeUserRole3(Usize)

  rule  preCall
        ~> (.K => splitChangeUserRole(UserAddress))
        ~> call(changeUserRole(UserAddress:Address, _NewRole:UserRole))
  [priority(20)]

  rule  <k> splitChangeUserRole(Address:Address)
            =>  branchK(
                  Address in_keys(AddressToUserId),
                  splitChangeUserRole2(Address),
                  .K
                )
        ... </k>
        <address-to-user-id> AddressToUserId:Map </address-to-user-id>

  rule  <k> splitChangeUserRole2(Address:Address)
            =>    makeConcreteValue(Address, rUsize, AddressToUserId)
              ~>  branchK(
                    AddressToUserId[Address] in_keys(UserIdToRole),
                    makeConcreteValue(AddressToUserId[Address], rUserRole, UserIdToRole),
                    .K
                  )
        ... </k>
        <address-to-user-id> AddressToUserId:Map </address-to-user-id>
        <user-roles>UserIdToRole:Map</user-roles>
    requires Address in_keys(AddressToUserId)
endmodule

module SIGN-INSTRUMENTATION
  imports PSEUDOCODE
  imports INVARIANT-INSTRUMENTATION

  syntax KItem ::= splitSign(Usize)
  syntax KItem ::= splitSign2(Usize)
  syntax KItem ::= splitSign3(Usize)

  rule  preCall
        ~> (.K => splitSign(ActionId))
        ~> call(sign(ActionId:Usize))
  [priority(20)]

  rule  <k> splitSign(ActionId:Usize)
            =>  branchK(
                    ActionId in_keys(ActionData),
                    branchK(
                      CallerAddress in_keys(AddressToUserId),
                      splitSign2(ActionId),
                      .K
                    ),
                    .K
                  )
        ... </k>
        <address-to-user-id> AddressToUserId:Map </address-to-user-id>
        <caller-address>CallerAddress:KItem</caller-address>
        <action-data>ActionData:Map</action-data>

  rule  <k> splitSign2(ActionId:Usize)
            =>    makeConcreteValue(CallerAddress, rUsize, AddressToUserId)
              ~>  branchK(
                    AddressToUserId[CallerAddress] in_keys(UserIdToRole),
                    splitSign3(ActionId),
                    .K
                  )
        ... </k>
        <address-to-user-id> AddressToUserId:Map </address-to-user-id>
        <user-roles>UserIdToRole:Map</user-roles>
        <caller-address>CallerAddress:KItem</caller-address>
    requires CallerAddress in_keys(AddressToUserId)

  rule  <k> splitSign3(ActionId:Usize)
            =>    makeConcreteValue(AddressToUserId[CallerAddress], rUserRole, UserIdToRole)
              ~>  branchK(
                    UserIdToRole[AddressToUserId[CallerAddress]] ==K BoardMember,
                    branchK(
                      ActionId in_keys(ActionSigners),
                      makeConcreteValue(ActionId, rExpressionList, ActionSigners),
                      .K
                    ),
                    .K
                  )
        ... </k>
        <address-to-user-id> AddressToUserId:Map </address-to-user-id>
        <user-roles>UserIdToRole:Map</user-roles>
        <caller-address>CallerAddress:KItem</caller-address>
        <action-signers>ActionSigners:Map</action-signers>
    requires CallerAddress in_keys(AddressToUserId)
      andBool AddressToUserId[CallerAddress] in_keys(UserIdToRole)
endmodule

module DISCARD-ACTION-INSTRUMENTATION
  imports INVARIANT-INSTRUMENTATION
  imports PROOF-INSTRUMENTATION
  imports EXECUTION-PROOF
  imports PSEUDOCODE

  syntax KItem ::= splitDiscardAction(actionId:Usize)
  syntax KItem ::= splitDiscardAction1(actionId:Usize)
  syntax KItem ::= splitDiscardAction2(actionId:Usize)
  syntax KItem ::= splitDiscardAction3(actionId:Usize)
  syntax KItem ::= splitDiscardAction4(actionId:Usize)

  rule  preCall
        ~> (.K => splitDiscardAction(ActionId))
        ~> call(discardAction(ActionId:Usize))
    [priority(20)]

  rule  <k> splitDiscardAction(ActionId:Usize)
            =>  branchK(
                  Caller in_keys(AddressToUserId),
                  splitDiscardAction1(ActionId),
                  .K
                )
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <caller-address>Caller:KItem</caller-address>

  rule  <k> splitDiscardAction1(ActionId:Usize)
            =>    makeConcreteValue(Caller, rUsize, AddressToUserId)
              ~>  branchK(
                    AddressToUserId[Caller] in_keys(UserIdToRole),
                    splitDiscardAction2(ActionId),
                    .K
                  )
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <user-roles> UserIdToRole:Map </user-roles>
        <caller-address>Caller:KItem</caller-address>
    requires Caller in_keys(AddressToUserId)

  rule  <k> splitDiscardAction2(ActionId:Usize)
            =>    makeConcreteValue(AddressToUserId[Caller], rUserRole, UserIdToRole)
              ~>  branchK(
                    ActionId in_keys(ActionSigners),
                    splitDiscardAction3(ActionId),
                    splitDiscardAction4(ActionId)
                  )
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <user-roles> UserIdToRole:Map </user-roles>
        <caller-address>Caller:KItem</caller-address>
        <action-signers>ActionSigners:Map</action-signers>
    requires Caller in_keys(AddressToUserId)

  rule  <k> splitDiscardAction3(ActionId:Usize)
            =>    makeConcreteValue(ActionId, rExpressionList, ActionSigners)
              ~>  branchK(
                    ActionId in_keys(ActionData),
                    makeConcreteValue(ActionId, rAction, ActionData),
                    splitDiscardAction4(ActionId)
                  )
        ...</k>
        <action-data>ActionData</action-data>
        <action-signers>ActionSigners</action-signers>
    requires ActionId in_keys(ActionSigners)
  rule  <k> splitDiscardAction4(ActionId:Usize)
            =>    branchK(
                    countCanSignFunction({ActionSigners[ActionId]}:>ExpressionList, opaque(UserIdToRole)) >Int 0,
                    .K,
                    .K
                  )
        ...</k>
        <action-signers>ActionSigners</action-signers>
        <user-roles> UserIdToRole:Map </user-roles>
    requires ActionId in_keys(ActionSigners)
      andBool isExpressionList(ActionSigners[ActionId])

endmodule

module INVARIANT-EXECUTION
  imports EXECUTION-PROOF
  imports FUNCTIONS-EXECUTE

  imports INVARIANT-INSTRUMENTATION
  imports SIGN-INSTRUMENTATION
  imports CHANGE-USER-ROLE-INSTRUMENTATION
  imports PROPOSE-ACTION-INSTRUMENTATION
  imports PERFORM-ACTION-ADD-PROPOSER-INSTRUMENTATION
  imports PERFORM-ACTION-SC-DEPLOY-INSTRUMENTATION
  imports PERFORM-ACTION-REMOVE-USER-INSTRUMENTATION
  imports PERFORM-SPLIT-ACTION-INSTRUMENTATION
  imports PROPOSE-SC-DEPLOY-INSTRUMENTATION
  imports DISCARD-ACTION-INSTRUMENTATION

  imports COUNT-CAN-SIGN-PARTS
  imports INIT-LOOP-PARTS
  imports PERFORM-PARTS

  // TODO: Delete.
  imports TEST
endmodule