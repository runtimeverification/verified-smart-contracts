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

  // TODO: Move in execution-proof.k
  syntax KItem ::= makeConcreteValue(key:KItem, valueType:ReflectionType, Map)
  rule makeConcreteValue(Key:KItem, ValueType:ReflectionType, M:Map)
    => lazySplitMap(Key, M, ?_Value:KItem, ?_Remainder:Map)
      ~>  cast(M[Key], ValueType)
      ~>  removeValue
      ~> concretizeValue(M[Key])
    requires Key in_keys(M)

  syntax KItem ::= lazySplitMap(k:KItem, m:Map, value:KItem, remainder:Map)
  rule lazySplitMap(K:KItem, M:Map, Value:KItem, Remainder:Map)
      => splitMap(K, M, Value, Remainder)
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

  syntax KItem ::= "concretize-sc-deploy"
  rule  <k> (splitting-action => concretizeValue(Arguments))
            ~> call(performAction(SCDeploy(
                        _Amount:BigUint,
                        _Code:BoxedBytes,
                        _CodeMetadata:CodeMetadata,
                        Arguments:ExpressionList)))
        ...</k>
    [priority(10)]
endmodule

module PERFORM-ACTION-ADD-PROPOSER-INSTRUMENTATION
  imports INVARIANT-INSTRUMENTATION
  imports PERFORM-SPLIT-ACTION-INSTRUMENTATION
  imports PSEUDOCODE
 
  syntax KItem ::= splittingActionProposer1(Address)
  syntax KItem ::= splittingActionProposer2(Address)

  rule  <k> (
              splitting-action
              =>  branchK(
                    A1 in_keys(AddressToUserId),
                    splittingActionProposer1(A1),
                    .K
                  )
            )
            ~> call(performAction(AddProposer(A1:Address)))
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
    [priority(10)]

  rule  <k> splittingActionProposer1(A1:Address)
            =>   makeConcreteValue(A1, rUsize, AddressToUserId)
              ~> splittingActionProposer2(A1)
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
    requires A1 in_keys(AddressToUserId)
      // TODO: Do I need AddressToUserId[A1] in_keys(UserIdToRole)?

  // TODO: Merge this rule with the previous one.
  rule  <k> splittingActionProposer2(A1:Address)
            =>   makeConcreteValue(AddressToUserId[A1], rUserRole, UserIdToRole)
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <user-roles> UserIdToRole:Map </user-roles>
    requires true
      andBool A1 in_keys(AddressToUserId)
      andBool AddressToUserId[A1] in_keys(UserIdToRole)

endmodule

module PROPOSE-ACTION-INSTRUMENTATION
  imports INVARIANT-INSTRUMENTATION
  imports PSEUDOCODE

  syntax KItem ::= "split-propose-action"
  syntax KItem ::= "split-propose-action1"
  syntax KItem ::= "split-propose-action2"

  rule preCall ~> (.K => split-propose-action) ~> call(proposeAction(_Action:Action))
  [priority(20)]

  rule  <k> split-propose-action
            =>  branchK(
                  Caller in_keys(AddressToUserId),
                  lazySplitMap(
                      Caller, AddressToUserId,
                      ?_UserId:KItem, ?_AddressToUserIdRemainder:Map)
                    ~>  split-propose-action1,
                  .K
                )
        ... </k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <caller-address>Caller:KItem</caller-address>

  rule  <k> split-propose-action1
            =>  branchK(
                  AddressToUserId[Caller] in_keys(UserIdToRole),
                  lazySplitMap(
                      AddressToUserId[Caller], UserIdToRole,
                      ?_UserRole:KItem, ?_UserIdToRoleRemainder:Map)
                    ~> split-propose-action2,
                  .K
                )
        ... </k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <user-roles> UserIdToRole:Map </user-roles>
        <caller-address>Caller:KItem</caller-address>

  rule  <k> split-propose-action2
            =>   cast(UserIdToRole[AddressToUserId[Caller]], rUserRole)
              ~> removeValue
              ~> concretizeValue(UserIdToRole[AddressToUserId[Caller]])
        ... </k>

        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <user-roles> UserIdToRole:Map </user-roles>
        <caller-address>Caller:KItem</caller-address>
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
            =>    lazySplitMap(
                        Address, AddressToUserId,
                        ?_UserId:KItem, ?_AddressToUserIdRemainder:Map)
              ~>  cast(AddressToUserId[Address], rUsize)
              ~>  removeValue
              ~>  concretizeValue(AddressToUserId[Address])
              ~>  branchK(
                    AddressToUserId[Address] in_keys(UserIdToRole),
                    splitChangeUserRole3({AddressToUserId[Address]}:>Usize),
                    .K
                  )
        ... </k>
        <address-to-user-id> AddressToUserId:Map </address-to-user-id>
        <user-roles>UserIdToRole:Map</user-roles>
    requires Address in_keys(AddressToUserId)

  rule  <k> splitChangeUserRole3(UserId:Usize)
            =>    lazySplitMap(
                        UserId, UserIdToRole,
                        ?_UserRole:KItem, ?_UserIdToRoleRemainder:Map)
              ~>  cast(UserIdToRole[UserId], rUserRole)
              ~>  removeValue
              ~>  concretizeValue(UserIdToRole[UserId])
        ... </k>
        <user-roles>UserIdToRole:Map</user-roles>
    requires UserId in_keys(UserIdToRole)
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

  imports COUNT-CAN-SIGN-PARTS
  imports INIT-LOOP-PARTS
  imports PERFORM-PARTS

  // TODO: Delete.
  imports TEST
endmodule