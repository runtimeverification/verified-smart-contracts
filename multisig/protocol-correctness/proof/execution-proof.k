require "protocol-correctness/pseudocode.k"
require "protocol-correctness/proof/invariant.k"
require "protocol-correctness/proof/execution-proof-helpers.k"

module EXECUTION-PROOF-SYNTAX
  imports PSEUDOCODE-SYNTAX
endmodule

module CONCRETIZE-INSTRUMENTATION
  imports MAP

  imports PSEUDOCODE

  syntax KItem ::= concretizeValue(KItem)

  rule concretizeValue([CSV:ExpressionCSV]) => concretizeValue(CSV)

  rule concretizeValue(u(V:Int)) => concretizeValue(V)

  rule concretizeValue(address(V:Int)) => concretizeValue(V)

  rule concretizeValue(big(V:Int)) => concretizeValue(V)

  rule concretizeValue(meta(V:Int)) => concretizeValue(V)

  rule concretizeValue(bytes(V:String)) => concretizeValue(V)

  rule concretizeValue(BoardMember) => .K
  rule concretizeValue(Proposer) => .K
  rule concretizeValue(None) => .K

  rule concretizeValue(_) => .K [priority(200)]

  syntax KItem ::= concretizeExpressionList(ExpressionList, Int)
  rule concretizeExpressionList([.:ExpressionCSV], X:Int) => .K
    requires X >Int 0
  rule concretizeExpressionList([_:Expression , L:ExpressionCSV], X:Int)
      => concretizeExpressionList([L], X -Int 1)
    requires X >Int 0
  rule concretizeExpressionList([_:ExpressionCSV], X:Int)
      => .K
    requires X <=Int 0

  syntax Expression ::= expressionListGetOrDefault(ExpressionList, Int, Expression)  [function]
  rule expressionListGetOrDefault([.], _:Int, Default:Expression) => Default
  rule expressionListGetOrDefault([_:ExpressionCSV], X:Int, Default:Expression) => Default
    requires X <Int 0
  rule expressionListGetOrDefault([E:Expression, _:ExpressionCSV], 0, _:Expression) => E
  rule expressionListGetOrDefault([_:Expression, Es:ExpressionCSV], X:Int, Default:Expression)
      => expressionListGetOrDefault([Es:ExpressionCSV], X -Int 1, Default)
    requires X >Int 0

  syntax Singleton ::= "singleton"

  syntax IntVarList ::= vars(Int, IntVarList)
                    |   ".IntVarList"

  syntax Bool ::= isLazyConcretize(KItem)  [function, functional]
  rule isLazyConcretize(lazyConcretizeKeysFreezer) => true
  rule isLazyConcretize(lazyConcretizeKeys(_:Map)) => true
  rule isLazyConcretize(lazyConcretizeValues(_:Map)) => true
  rule isLazyConcretize(_:KItem) => false  [owise]

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

  // TODO: Rename this.
  syntax KItem ::= makeConcreteValue(key:KItem, valueType:ReflectionType, Map)
  rule makeConcreteValue(Key:KItem, ValueType:ReflectionType, M:Map)
    =>    splitMap(Key, M, ?_Value:KItem, ?_Remainder:Map)
      ~>  cast(M[Key], ValueType)
      ~>  removeValue
      ~>  concretizeValue(M[Key])
    requires Key in_keys(M)

  syntax KItem ::= makeConcrete(value:KItem, valueType:ReflectionType)
  rule makeConcrete(Value:KItem, ValueType:ReflectionType)
    =>    cast(Value, ValueType)
      ~>  removeValue
      ~>  concretizeValue(Value)
endmodule

module PROOF-INSTRUMENTATION
  imports MAP

  imports PSEUDOCODE

  imports CONCRETIZE-INSTRUMENTATION

  syntax KItem ::= splitEquality(KItem, KItem)
  rule splitEquality(A:KItem, B:KItem) => .K
    requires A ==K B
  rule splitEquality(A:KItem, B:KItem) => .K
    requires notBool (A ==K B)

  syntax KItem ::= splitBoolean(Bool)
  rule splitBoolean(true) => .K
  rule splitBoolean(false) => .K

  syntax KItem ::= branchK(Bool, K, K)
  rule branchK(true, K:K, _:K) => K
  rule branchK(false, _:K, K:K) => K

endmodule

module EXECUTION-PROOF-BOOL
  imports BOOL

  rule B1:Bool orBool _:Bool => true
    requires B1
    [simplification]
  rule _:Bool orBool B2:Bool => true
    requires B2
    [simplification]
  rule B1:Bool orBool B2:Bool => B2
    requires notBool B1
    [simplification]
  rule B1:Bool orBool B2:Bool => B1
    requires notBool B2
    [simplification]
endmodule

module EXECUTION-PROOF
  imports EXECUTION-PROOF-BOOL
  imports EXECUTION-PROOF-HELPERS
  imports PROOF-INSTRUMENTATION

  imports INVARIANT
endmodule