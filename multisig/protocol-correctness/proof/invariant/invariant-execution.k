require "../execution-proof.k"

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

  syntax Singleton ::= "singleton"

  syntax IntVarList ::= vars(Int, IntVarList)
                    |   ".IntVarList"

  syntax Bool ::= isLazyConcretize(KItem)  [function, functional]
  rule isLazyConcretize(lazyConcretizeKeysFreezer) => true
  rule isLazyConcretize(lazyConcretizeKeys(_:Map)) => true
  rule isLazyConcretize(lazyConcretizeValues(_:Map)) => true
  rule isLazyConcretize(_:KItem) => false  [owise]

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

  syntax Singleton ::= concretizeKeys(Map, IntVarList)  [function, functional]
  rule concretizeKeys((K:Usize |-> _:KItem M:Map) #as _:Map, vars(U:Int, Vars:IntVarList))
      => concretizeKeys(M, Vars)
    ensures K ==K u(U:Int)
      // => concretizeKeys(M, Vars) #And #Ceil(K #And u(U:Int))
    [simplification(40)]
  rule concretizeKeys(_:Map, _:IntVarList) => singleton
    [simplification(50)]

  syntax Singleton ::= concretizeValues(Map, IntVarList)  [function, functional]
  rule concretizeValues((_:KItem |-> V:Usize M:Map) #as _:Map, vars(U:Int, Vars:IntVarList))
      => concretizeValues(M, Vars)
    ensures V ==K u(U:Int)
      // => concretizeKeys(M, Vars) #And #Ceil(K #And u(U:Int))
    [simplification(40)]
  rule concretizeValues(_:Map, _:IntVarList) => singleton
    [simplification(50)]

  syntax KItem ::= concretized(Singleton)
  rule concretized(singleton) => .K

  syntax KItem ::= "lazyConcretizeKeysFreezer"

  syntax KItem ::= lazyConcretizeKeys(Map)
  rule lazyConcretizeKeys(M:Map) => concretized(concretizeKeys(M, vars(?_, vars(?_, .IntVarList))))

  syntax KItem ::= lazyConcretizeValues(Map)
  rule lazyConcretizeValues(M:Map) => concretized(concretizeValues(M, vars(?_, vars(?_, .IntVarList))))

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

  syntax KItem ::= splittingDeleteCaller(Address)
  syntax KItem ::= splittingDeleteCaller1(Address)
  syntax KItem ::= splittingDeleteCaller2(Usize)
  rule  (splitting-action => splittingDeleteCaller(A))
        ~> call(performAction(RemoveUser(A:Address)))
    [priority(10)]

  rule  <k> splittingDeleteCaller(A:Address)
            =>    splitBoolean(A in_keys(AddressToUserId))
              ~>  branchK(
                    A in_keys(AddressToUserId),
                    splittingDeleteCaller1(A),
                    .K
                  )
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
  rule  <k> (
              splittingDeleteCaller1(A:Address)
              => splitMap(
                  A, AddressToUserId,
                  ?_UserId:KItem, ?_AddressToUserIdRemainder:Map)
                ~> cast(AddressToUserId[A], rUsize)
                ~> removeValue
                ~> splitBoolean(AddressToUserId[A] in_keys(UserIdToRole))
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
              => splitMap(
                  UserId, UserIdToRole,
                  ?_UserRole:KItem, ?_UserIdToRoleRemainder:Map)
                ~> cast(UserIdToRole[UserId], rUserRole)
                ~> removeValue
                ~> lazyConcretizeKeys(UserIdToRole)
                ~> splitBoolean(UserIdToRole[UserId] ==K BoardMember)
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

  syntax KItem ::= concretizeValue(KItem)
  rule concretizeValue([CSV:ExpressionCSV]) => concretizeValue(CSV)
  rule concretizeValue(u(V:Int)) => concretizeValue(V)
  rule concretizeValue(address(V:Int)) => concretizeValue(V)
  rule concretizeValue(BoardMember) => .K
  rule concretizeValue(Proposer) => .K
  rule concretizeValue(None) => .K

  rule concretizeValue(_) => .K [priority(200)]

  syntax KItem ::= "concretize-sc-deploy"
  rule  <k> (
              splitting-action
              =>  concretizeValue(Arguments)
                  ~> concretize-sc-deploy
            )
            ~> call(performAction(SCDeploy(
                        _Amount:BigUint,
                        _Code:BoxedBytes,
                        _CodeMetadata:CodeMetadata,
                        Arguments:ExpressionList)))
        ...</k>
    [priority(10)]
  rule  concretize-sc-deploy => .K
    [priority(20)]

  syntax KItem ::= lazySplitMap(k:KItem, m:Map, value:KItem, remainder:Map)
  rule lazySplitMap(K:KItem, M:Map, Value:KItem, Remainder:Map)
      => splitMap(K, M, Value, Remainder)

  syntax KItem ::= "splitting-add-proposer-in-keys-atuid"
  rule  <k> (
              splitting-action
              =>   splitBoolean(A1 in_keys(AddressToUserId))
                ~> branchK(
                    A1 in_keys(AddressToUserId),
                    lazySplitMap(
                        A1, AddressToUserId,
                        ?_UserId:KItem, ?_AddressToUserIdRemainder:Map)
                      ~> cast(AddressToUserId[A1], rUsize)
                      ~> removeValue
                      ~> concretizeValue(AddressToUserId[A1])
                      ~> concretizeValue(A1)
                      ~> lazySplitMap(
                          AddressToUserId[A1], UserIdToRole,
                          ?_UserRole:KItem, ?_UserIdToRoleRemainder:Map)
                      ~> cast(UserIdToRole[AddressToUserId[A1]], rUserRole)
                      ~> removeValue
                      ~> concretizeValue(UserIdToRole[AddressToUserId[A1]])
                      ~> .K,
                    .K
                  )
                ~> splitting-add-proposer-in-keys-atuid
            )
            ~> call(performAction(AddProposer(A1:Address)))
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <user-roles> UserIdToRole:Map </user-roles>
    [priority(10)]
  rule  splitting-add-proposer-in-keys-atuid => .K
    [priority(20)]

endmodule

module INVARIANT-EXECUTION
  imports EXECUTION-PROOF

  imports INVARIANT-INSTRUMENTATION

  imports COUNT-CAN-SIGN-PARTS
  imports INIT-LOOP-PARTS
  imports PERFORM-PARTS

  // TODO: Delete.
  imports TEST
endmodule