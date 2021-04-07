require "../pseudocode.k"
require "invariant.k"
require "map/map-execute.k"

module EXECUTION-PROOF-SYNTAX
  imports PSEUDOCODE-SYNTAX
endmodule

module EXECUTION-PROOF-HELPERS
  imports MAP-SYMBOLIC
  imports SET

  imports PSEUDOCODE
  imports MAP-EXECUTE

  // Expand and PropertyHandling form a stupid trick used to control symbolic
  // function application.
  // Any function that receives them as an argument should not depend on them,
  // i.e it should have the same value for all possible PropertyHandling values.
  syntax Expand ::= "expanded" | expand(Expand)
  syntax PropertyHandling ::= "usesExpanded" | Expand
  // TODO: Delete above or below.
  syntax Int ::= expand(Int)  [function, functional, no-evaluators]
  syntax Int ::= "usesExpanded"  [function, functional, no-evaluators]

  syntax Int ::= pListLen(ExpressionList)  [function, functional, smtlib(pListLen)]
  rule pListLen([.]) => 0
  rule pListLen([_:Expression, Es:ExpressionCSV]) => 1 +Int pListLen([Es])

  rule pListLen(_) >=Int 0 => true  [simplification, smt-lemma]

  // Override the default behaviour.
  rule isDefaultValue(E:ExpressionList, rExpressionList)
      => notBool (pListLen(E) >Int 0)
  rule pListLen([#pushList(_, _)]) >Int 0 => true
      [simplification]

  syntax Bool ::= noCommonItem(Usize, Map, ExpressionList)  [function, functional]
  rule noCommonItem(_:Usize, _:Map, [.]) => true
  rule noCommonItem(U:Usize, M:Map, [E:Expression , Es:ExpressionCSV])
      =>  notBool (E in_keys(M))
          andBool noCommonItem(add(U, u(1)), (E |-> U) M, [Es])

  syntax Bool ::= noReusedIndexAddress(Usize, Map, ExpressionList)  [function, functional]
  rule noReusedIndexAddress(U:Usize, M:Map, [.]) => forall-v-greater-or-equal-than-u-v-not-in-m(U, M, [.])
  rule noReusedIndexAddress(U:Usize, M:Map, [E:Expression , Es:ExpressionCSV] #as L)
      =>  forall-v-greater-or-equal-than-u-v-not-in-m(U, M, L)
          andBool noReusedIndexAddress(add(U, u(1)), (U |-> E) M, [Es])

  syntax Bool ::= noReusedIndexRole(Usize, Map, ExpressionList)  [function, functional]
  rule noReusedIndexRole(U:Usize, M:Map, [.]) => forall-v-greater-or-equal-than-u-v-not-in-m(U, M, [.])
  rule noReusedIndexRole(U:Usize, M:Map, [_:Expression , Es:ExpressionCSV] #as L)
      =>  forall-v-greater-or-equal-than-u-v-not-in-m(U, M, L)
          andBool noReusedIndexRole(add(U, u(1)), (U |-> BoardMember) M, [Es])

  syntax Bool ::= "forall-v-greater-or-equal-than-u-v-not-in-m" "(" Usize "," Map "," ExpressionList ")"   [function, functional]
  rule forall-v-greater-or-equal-than-u-v-not-in-m(U, M, [.])
      =>  notBool U in_keys(M)
  rule forall-v-greater-or-equal-than-u-v-not-in-m(U, M, [_:Expression , Es:ExpressionCSV])
      =>  notBool U in_keys(M)
          andBool forall-v-greater-or-equal-than-u-v-not-in-m(add(U, u(1)), M, [Es])

  syntax Usize ::= usizeWithDefault(KItem, Usize)  [function, functional]
  rule usizeWithDefault(uninitialized, Default:Usize) => Default
  rule usizeWithDefault(V:Usize, _:Usize) => V

  syntax Int ::= usizeToInt(Usize)  [function, functional]
  rule usizeToInt(u(V:Int)) => V

  syntax Bool ::= listElementsAreAddresses(ExpressionList)  [function, functional]
  rule listElementsAreAddresses([.]) => true
  rule listElementsAreAddresses([E:Expression , Es:ExpressionCSV])
      => isAddress(E) andBool listElementsAreAddresses([Es])

  syntax Bool ::= listElementsAreUsize(KItem)  [function, functional]
  rule listElementsAreUsize([.]) => true
  rule listElementsAreUsize([E:Expression, Es:ExpressionCSV])
      => isUsize(E) andBool listElementsAreUsize([Es])
  rule listElementsAreUsize(_:KItem) => false
    [owise]
  rule listElementsAreUsize([E:Expression, Es:ExpressionCSV])
      => isUsize(E) andBool listElementsAreUsize([Es])
    [simplification]

  syntax Bool ::= valuesAreExpressionListOfUsize(Map)  [function, functional]
  rule valuesAreExpressionListOfUsize(.Map) => true
  rule valuesAreExpressionListOfUsize((_ |-> V M:Map) #as _:Map)
      =>  isExpressionList(V)
          andBool listElementsAreUsize(V)
          andBool valuesAreExpressionListOfUsize(M)
  rule valuesAreExpressionListOfUsize((_ |-> V M:Map) #as _:Map)
      =>  isExpressionList(V)
          andBool listElementsAreUsize(V)
          andBool valuesAreExpressionListOfUsize(M)
    [simplification]

  syntax Bool ::= valuesAreKResult(Map)  [function, functional]
  rule valuesAreKResult(.Map) => true
  rule valuesAreKResult((_ |-> V M:Map) #as _:Map)
      => isKResult(V) andBool valuesAreKResult(M)
  rule valuesAreKResult((_ |-> V M:Map) #as _:Map)
      => isKResult(V) andBool valuesAreKResult(M)
    [simplification]

  syntax Bool ::= valuesAreOfType(Map, ReflectionType)  [function, functional]
  rule valuesAreOfType(.Map, _:ReflectionType) => true
  rule valuesAreOfType((_ |-> V M:Map) #as _:Map, T:ReflectionType)
      => valueOfType(V, T) andBool valuesAreOfType(M, T)
  rule valuesAreOfType((_ |-> V M:Map) #as _:Map, T:ReflectionType)
      => valueOfType(V, T) andBool valuesAreOfType(M, T)
    [simplification]

  syntax Bool ::= keysAreKResult(Map)  [function, functional]
  rule keysAreKResult(.Map) => true
  rule keysAreKResult((K:KItem |-> _:KItem M:Map) #as _:Map)
      => isKResult(K) andBool keysAreKResult(M)
  rule keysAreKResult((K:KItem |-> _:KItem M:Map) #as _:Map)
      => isKResult(K) andBool keysAreKResult(M)
    [simplification]

  syntax Bool ::= keysAreOfType(Map, ReflectionType)  [function, functional]
  rule keysAreOfType(.Map, _:ReflectionType) => true
  rule keysAreOfType((K:KItem |-> _:KItem M:Map) #as _:Map, T:ReflectionType)
      => valueOfType(K, T) andBool keysAreOfType(M, T)
  rule keysAreOfType((K:KItem |-> _:KItem M:Map) #as _:Map, T:ReflectionType)
      => valueOfType(K, T) andBool keysAreOfType(M, T)
    [simplification]

  syntax Bool ::= valueIsNotEmpty(KItem, ReflectionType)  [function, functional]
  rule valueIsNotEmpty(V:KItem, T:ReflectionType)
      => notBool (V ==K defaultValue(T))

  syntax Bool ::= valuesAreNotEmpty(Map, ReflectionType)  [function, functional]
  rule valuesAreNotEmpty(.Map, _:ReflectionType) => true
  rule valuesAreNotEmpty((_ |-> V M:Map) #as _:Map, T:ReflectionType)
      => valuesAreNotEmpty(M, T) andBool valueIsNotEmpty(V, T)
  rule valuesAreNotEmpty((_ |-> V M:Map) #as _:Map, T:ReflectionType)
      => valuesAreNotEmpty(M, T) andBool valueIsNotEmpty(V, T)
    [simplification]

  syntax Bool ::= valuesAreDistinct(Map)  [function, functional]
  rule valuesAreDistinct(.Map) => true
  rule valuesAreDistinct((_:KItem |-> V:KItem M:Map) #as _:Map)
      => valuesAreDistinct(M) andBool valueNotInMapValues(V, M)
    [simplification]

  syntax Bool ::= valueNotInMapValues(KItem, Map)  [function, functional]
  rule valueNotInMapValues(_:KItem, .Map) => true
  rule valueNotInMapValues(V1:KItem, (_:KItem |-> V2:KItem M:Map) #as _:Map)
      => (notBool (V1 ==K V2)) andBool valueNotInMapValues(V1, M)
    [simplification]
  rule valueNotInMapValues(u(X:Int +Int 4), M:Map) => true
    requires #noReusedIndexValue(X +Int 3, M, expanded)
    [simplification]

  syntax Bool ::= noReusedIndexValue(Int, Map, PropertyHandling)  [function, functional]
  syntax Bool ::= #noReusedIndexValue(Int, Map, PropertyHandling)  [function, functional]

  rule noReusedIndexValue(_Index:Int, .Map, _:PropertyHandling) => true

  rule noReusedIndexValue(Index:Int, (_:KItem |-> V:Usize M:Map) #as _:Map, Expand:PropertyHandling)
      => Index >Int usizeToInt(V) andBool noReusedIndexValue(Index, M, Expand)
    [simplification(20)]
  rule noReusedIndexValue(Index:Int, M:Map, Handling:PropertyHandling)
      => true
        andBool valueNotInMapValues(u(Index), M)
        andBool #noReusedIndexValue(Index, M, Handling)
    [simplification(50)]

  rule #noReusedIndexValue(_Index:Int, .Map, expanded) => true
  rule #noReusedIndexValue(Index:Int, (_:KItem |-> V:Usize M:Map) #as _:Map, Expand:PropertyHandling)
      => Index >Int usizeToInt(V) andBool #noReusedIndexValue(Index, M, Expand)
    [simplification(20)]
  rule #noReusedIndexValue(Index:Int, M:Map, expand(Expand:Expand))
      =>  noReusedIndexValue(Index +Int 1, M, Expand)
    [simplification(50)]

  rule #noReusedIndexValue(X:Int, M:Map, usesExpanded)
      => true
    requires false
      orBool #noReusedIndexValue(X, M, expanded)
      orBool (true
          andBool valueNotInMapValues(u(X), M)
          andBool #noReusedIndexValue(X +Int 1, M, expanded)
      )
      orBool (true
          andBool valueNotInMapValues(u(X), M)
          andBool valueNotInMapValues(u(X +Int 1), M)
          andBool #noReusedIndexValue(X +Int 2, M, expanded)
      )
    [simplification]

  rule #noReusedIndexValue(X:Int +Int 4, M:Map, expanded)
      => true
    requires #noReusedIndexValue(X +Int 3, M, expanded)
    [simplification]
  rule #noReusedIndexValue(X:Int +Int 2, M:Map, expanded)
      => true
    requires true
      andBool #noReusedIndexValue(X +Int 3, M, expanded)
      andBool valueNotInMapValues(u(X +Int 2), M)
    [simplification]

  syntax Bool ::= allValuesBecomeKeys(Map, Map)  [function, functional]
  syntax Bool ::= #allValuesBecomeKeys(Map, Map)  [function, functional]

  rule allValuesBecomeKeys(M:Map, N:Map) => #allValuesBecomeKeys(M, keysMap(N))

  rule #allValuesBecomeKeys(.Map, _:Map) => true
  // TODO: This does not work if the key is in the map. Fix it and everything else.
  rule #allValuesBecomeKeys((_ |-> V M:Map) #as _:Map, N:Map)
      => V in_keys(N) andBool #allValuesBecomeKeys(M, N)
    [simplification]
  rule #allValuesBecomeKeys(M:Map, (_ |-> _ N:Map) #as _:Map) => true
    requires #allValuesBecomeKeys(M, N)
    [simplification]

  syntax Bool ::= mapsAreReverse(Map, Map) [function, functional]
  syntax Bool ::= mapsAreReverseHalf(Map, Map) [function, functional]

  rule mapsAreReverse(M:Map, N:Map)
      => mapsAreReverseHalf(M, N) andBool mapsAreReverseHalf(N, M)

  rule mapsAreReverseHalf(.Map, _:Map) => true
  rule mapsAreReverseHalf((K:KItem |-> V:KItem M:Map) #as _:Map, N:Map)
      => V in_keys(N) andBool N[V] ==K K andBool mapsAreReverseHalf(M, N)
    [simplification]

  syntax Bool ::= mapIncluded(Map, Map) [function, functional]

  rule mapIncluded(.Map, _:Map) => true
  rule mapIncluded((K:KItem |-> V:KItem M:Map) #as _:Map, N:Map)
      => K in_keys(N) andBool N[K] ==K V andBool mapIncluded(M, N)
    [simplification]
  rule mapIncluded(M:Map, M:Map) => true
    [simplification]
  rule mapIncluded(M1:Map, _:KItem |-> _:KItem M2:Map) => true
    requires M1 ==K M2
    [simplification]
  // Not sure why this does not work instead of the above:
  rule mapIncluded(M:Map, _:KItem |-> _:KItem M:Map) => true
    [simplification]

  rule X:Int -Int X:Int => 0  [simplification]
  // Int addition normalization
  rule X:Int +Int (Y:Int +Int Z:Int) => (X +Int Y) +Int Z  [simplification]
  // rule (X:Int +Int Y:Int) => (Y +Int X)  [simplification, concrete(X), symbolic(Y)]
  rule (A:Int +Int I:Int) +Int B:Int => (A +Int B) +Int I [simplification, concrete(I), symbolic(A,B)]
  //rule (X:Int +Int Y:Int) +Int Z:Int => X +Int (Y +Int Z) [simplification, concrete(Y), concrete(Z)]

  syntax Bool ::= unusedIdsInMapKeys(lastIndex:Int, Map, expand:PropertyHandling)  [function, functional]

  rule unusedIdsInMapKeys(_:Int, .Map, _:PropertyHandling) => true
  rule unusedIdsInMapKeys(LastIndex:Int, (U:Usize |-> _:KItem M:Map) #as _:Map, Handling:PropertyHandling)
    => unusedIdsInMapKeys(LastIndex, M, Handling)
      andBool LastIndex >Int usizeToInt(U)
    [simplification(30)]
  rule unusedIdsInMapKeys(LastIndex:Int, M:Map, expand(Expand:Expand))
    => notBool u(LastIndex) in_keys(M)  // TODO: Maybe check before wrapping
      andBool unusedIdsInMapKeys(LastIndex +Int 1, M, Expand)
    [simplification]

  rule unusedIdsInMapKeys(LastIndex:Int +Int 4, M:Map, expanded)
    => true
    requires unusedIdsInMapKeys(LastIndex +Int 3, M, expanded)
    [simplification]
  rule unusedIdsInMapKeys(LastIndex:Int +Int 2, M:Map, expanded)
    => true
    requires true
      andBool notBool u(LastIndex +Int 2) in_keys(M)
      andBool unusedIdsInMapKeys(LastIndex +Int 3, M, expanded)
    [simplification]

  rule unusedIdsInMapKeys(LastIndex:Int, M:Map, usesExpanded)
    => true
    requires false
      orBool unusedIdsInMapKeys(LastIndex, M, expanded)
      orBool (true
        andBool notBool u(LastIndex) in_keys(M)
        andBool unusedIdsInMapKeys(LastIndex +Int 1, M, expanded)
      )
      orBool (true
        andBool notBool u(LastIndex) in_keys(M)
        andBool notBool u(LastIndex +Int 1) in_keys(M)
        andBool unusedIdsInMapKeys(LastIndex +Int 2, M, expanded)
      )
    [simplification]

  rule unusedIdsInMapKeys(LastIndex:Int +Int 1, keysMap(M):Map, usesExpanded)
    => true
    requires true
        andBool notBool u(LastIndex +Int 1) in_keys(M)
        andBool unusedIdsInMapKeys(LastIndex +Int 2, keysMap(M), expanded)
    [simplification]

  /*
  rule unusedIdsInMapKeys(LastIndex:Int +Int 1, M:Map, usesExpanded)
    => true
    requires notBool u(LastIndex +Int 1) in_keys(M)
      andBool unusedIdsInMapKeys(LastIndex +Int 2, M, expanded)
    [simplification]
  */

  syntax Bool ::= unusedIdsInMapValues(lastIndex:Int, Map, handling:PropertyHandling)  [function, functional]
  rule unusedIdsInMapValues(_:Int, .Map, _:PropertyHandling) => true
  rule unusedIdsInMapValues(
          LastIndex:Int,
          (_:KItem |-> Value:Usize M:Map) #as _:Map,
          Handling:PropertyHandling
      )
      => unusedIdsInMapValues(LastIndex, M, Handling)
      andBool LastIndex >Int usizeToInt(Value)
    [simplification(10)]
  rule unusedIdsInMapValues(LastIndex:Int, M:Map, expand(_:Expand))
      => unusedIdsInMapValues(LastIndex, M, expanded)

  rule unusedIdsInMapValues(LastIndex:Int +Int 3, M:Map, _:PropertyHandling)
      => true
    requires unusedIdsInMapValues(LastIndex +Int 2, M, expanded)
    [simplification]

  rule unusedIdsInMapValues(LastIndex:Int, M:Map, usesExpanded)
      => true
    requires false
      orBool unusedIdsInMapValues(LastIndex -Int 1, M, expanded)
      orBool unusedIdsInMapValues(LastIndex, M, expanded)
    [simplification]

  syntax Bool ::= noMapKeyInList(Map, ExpressionList)  [function, functional]
  rule noMapKeyInList(.Map, _:ExpressionList) => true
  // TODO: Do I need this?
  rule noMapKeyInList(.Map, [.]) => true
    [simplification]
  rule noMapKeyInList(M:Map, [E:Expression, .]) => true
    requires notBool E in_keys(M)
    [simplification]
  rule noMapKeyInList((K:KItem |-> _:KItem M:Map) #as _:Map, L:ExpressionList)
    => true
      andBool notBool #listContains(L, K)
      andBool noMapKeyInList(M, L)
    [simplification]
  rule noMapKeyInList(M:Map, [#pushList(L:ExpressionCSV, E:Expression)])
    => true
    requires noMapKeyInList(M, [L])
      andBool notBool E in_keys(M)
    [simplification]

  syntax Map ::= keysMap(Map)  [function, functional]
  rule keysMap(.Map) => .Map
  rule keysMap((K:KItem |-> _:KItem M:Map) #as _:Map) => K |-> 0 keysMap(M)
    [simplification]
  rule X:KItem in_keys(keysMap(M:Map)) => X in_keys(M)
    [simplification]

  rule #Ceil(@M:Map (@K:KItem |-> @V:KItem))
      =>  {(@K in_keys(@M)) #Equals false}
          #And #Ceil(@M)
          #And #Ceil(@K)
          #And #Ceil(@V)
    [anywhere, simplification(20)]

  syntax Int ::= countMapValues(Map, KItem)  [function, functional, smtlib(countMapValues)]
  rule countMapValues(.Map, _) => 0
  rule countMapValues(((_ |-> U) M:Map) #as _:Map, V:KItem) => countMapValues(M, V) +Int countValue(U, V)
    [simplification]

  syntax Int ::= countValue(KItem, KItem) [function, functional, smtlib(countMapValue)]
  rule countValue(V:KItem, V:KItem) => 1
  rule countValue(_:KItem, _:KItem) => 0 [owise]
  //  requires notBool (V1 ==K V2)

  rule 0 <=Int countValue(_:KItem, _:KItem) => true [simplification, smt-lemma]
  rule countValue(_:KItem, _:KItem) >=Int 0 => true [simplification]
  rule countValue(_:KItem, _:KItem) <=Int 1 => true [simplification, smt-lemma]

  rule 0 <=Int countMapValues(_, _) => true  [simplification, smt-lemma]
  rule countMapValues(_, _) >=Int 0 => true  [simplification]

  rule countMapValues(X, Y) >Int 0 => true requires notBool countMapValues(X, Y) ==Int 0 [simplification]

  rule countMapValues(_, _) +Int X:Int <=Int 0 => false
    requires X >Int 0
    [simplification]
  // TODO: Replace these with generic int rules.
  rule 0 <=Int countMapValues(A, B) +Int X:Int => countMapValues(A, B) +Int X >=Int 0
    [simplification]
  rule countMapValues(_, _) +Int X:Int >=Int 0 => true
    requires X >=Int 0
    [simplification]
  rule countMapValues(_, _) +Int X:Int >Int 0 => true
    requires X >Int 0
    [simplification]
  rule countValue(_, _) +Int X:Int >=Int 0 => true
    requires X >=Int 0
    [simplification]
  rule countValue(_, _) +Int X:Int >Int 0 => true
    requires X >Int 0
    [simplification]
  /*
  rule countMapValues(_, _) +Int 1 >=Int 0 => true  [simplification]
  rule countMapValues(_, _) +Int 2 >=Int 0 => true  [simplification]
  rule countMapValues(_, _) +Int 1 +Int countMapValues(_, _) >Int 0 => true  [simplification]
  rule countMapValues(_, _) +Int countMapValues(_, _) +Int X:Int >Int 0
      => true
    requires X >Int 0
    [simplification]
  rule countMapValues(_, _) +Int countValue(_, _) >=Int 0 => true  [simplification]
  rule countMapValues(_, _) +Int countValue(_, _) +Int X:Int >=Int 0
      => true
    requires X >=Int 0
    [simplification]
  rule countMapValues(_, _) +Int countMapValues(_, _) +Int countValue(_, _) +Int 1 >Int 0
      => true
    [simplification]
  */

  // TODO: Proof for this.
  syntax Bool ::= canSignFunction(UserRole)  [function, functional]
  rule canSignFunction(Role:UserRole) => Role ==K BoardMember

  syntax Int ::= countCanSignFunction(signerIDs:ExpressionList, userIdToRole:Map)  [function, functional]
  syntax Int ::= #countCanSignFunction(userID:Usize, signerIDs:ExpressionList, userIdToRole:Map, value:KItem)  [function, functional]
  rule countCanSignFunction([.], _:Map) => 0
  rule countCanSignFunction([UserId:Usize, Es:ExpressionCSV], UserId |-> Role:UserRole M:Map)
      => 1 +Int countCanSignFunction([Es], M)  // Remove UserId from the map since each user is counted at most once.
    requires canSignFunction(Role)
  rule countCanSignFunction([_:Expression, Es:ExpressionCSV], M)
      => countCanSignFunction([Es], M)
    [owise]
  rule countCanSignFunction([#pushList(Es:ExpressionCSV, UserId:Usize)], UserId |-> Role:UserRole M:Map)
      => 1 +Int countCanSignFunction([Es], M)  // Remove UserId from the map since each user is counted at most once.
    requires canSignFunction(Role)
    [simplification]
  rule countCanSignFunction([#pushList(Es:ExpressionCSV, UserId:Usize)], UserId |-> Role:UserRole M:Map)
      => countCanSignFunction([Es], M)  // Remove UserId from the map since each user is counted at most once.
    requires notBool canSignFunction(Role)
    [simplification]
  rule countCanSignFunction(Es:ExpressionList, UserId |-> _:UserRole M:Map)
      => countCanSignFunction(Es, M)
    requires notBool #listContains(Es, UserId)
    [simplification]
  rule countCanSignFunction(Es:ExpressionList, concat(UserId, _:UserRole, M:Map))
      => countCanSignFunction(Es, M)
    requires notBool #listContains(Es, UserId)
    [simplification]

  rule countCanSignFunction([UserId:Usize, Es:ExpressionCSV], concat(UserId1:KItem, Role:UserRole, M:Map))
    => #countCanSignFunction(UserId, [Es], concat(UserId1, Role, M), concat(UserId1, Role, M)[UserId] orDefault None)
    [simplification]
  rule countCanSignFunction([#pushList(Es:ExpressionCSV, UserId:Usize)], concat(UserId1:KItem, Role:UserRole, M:Map))
    => #countCanSignFunction(UserId, [Es], concat(UserId1, Role, M), concat(UserId1, Role, M)[UserId] orDefault None)
    [simplification]
  rule #countCanSignFunction(UserId:Usize, Es:ExpressionList, M:Map, Value:UserRole)
      => 1 +Int countCanSignFunction(Es, M[UserId <- undef])
    requires canSignFunction(Value)
    [simplification]
  rule #countCanSignFunction(_:Usize, Es:ExpressionList, M:Map, Value:UserRole)
      => countCanSignFunction(Es, M)
    requires notBool canSignFunction(Value)
    [simplification]

endmodule

module CONCRETIZE-INSTRUMENTATION
  imports MAP

  imports PSEUDOCODE

  syntax KItem ::= concretizeValue(KItem)
  rule concretizeValue([CSV:ExpressionCSV]) => concretizeValue(CSV)
  rule concretizeValue(u(V:Int)) => concretizeValue(V)
  rule concretizeValue(address(V:Int)) => concretizeValue(V)
  rule concretizeValue(BoardMember) => .K
  rule concretizeValue(Proposer) => .K
  rule concretizeValue(None) => .K

  rule concretizeValue(_) => .K [priority(200)]

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

  syntax KItem ::= makeConcreteValue(key:KItem, valueType:ReflectionType, Map)
  rule makeConcreteValue(Key:KItem, ValueType:ReflectionType, M:Map)
    =>    splitMap(Key, M, ?_Value:KItem, ?_Remainder:Map)
      ~>  cast(M[Key], ValueType)
      ~>  removeValue
      ~> concretizeValue(M[Key])
    requires Key in_keys(M)
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