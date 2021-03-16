module MAP-EXECUTE-SYNTAX
endmodule

module MAP-EXECUTE
  imports MAP
  imports INT

  // The Haskell backend does not send functions applied to things
  // that can be bottom to the SMT solver, even if the side condition restricts
  // the arguments to non-bottom things.
  //
  // A (K |-> V M:Map) map representation is bottom if `K in_keys(M)`, hence
  // the function-based representation below. This means that whatever function
  // is using these can manipulate them only through simplification rules.
  syntax Map  ::= opaque(Map)  [function, functional]
                | concat(key:KItem, value:KItem, Map)  [function, functional, no-evaluators]
                | extractMap(Map)   [function, functional]
  rule opaque(K:KItem |-> V:KItem M:Map) => concat(K, V, opaque(M))
    ensures notBool K in_keys(M)
    [simplification]
  rule extractMap(opaque(M:Map)) => M
    [simplification]
  rule extractMap(concat(K:KItem, V:KItem, M:Map)) => K |-> V extractMap(M)
    [simplification]

  rule K:KItem in_keys(opaque(M)) => K in_keys(M)
    [simplification]
  rule K1:KItem in_keys(concat(K2:KItem, _:KItem, M:Map))
      => K1 ==K K2 orBool K1 in_keys(M)
    [simplification]

  rule opaque(M:Map)[K:KItem] orDefault V:KItem => M[K] orDefault V
    [simplification]
  rule concat(K2:KItem, V2:KItem, _:Map)[K1:KItem] orDefault _:KItem
      => V2
    requires K1 ==K K2
    [simplification(20)]
  rule concat(K2:KItem, _:KItem, M:Map)[K1:KItem] orDefault V1:KItem
      => M[K1] orDefault V1
    requires notBool (K1 ==K K2)
    [simplification(20)]
  // TODO: Is this needed? Is this good?
  rule concat(K2:KItem, V2:KItem, M:Map)[K1:KItem] orDefault V1:KItem
      => extractMap(concat(K2:KItem, V2:KItem, M:Map))[K1:KItem] orDefault V1:KItem
    requires K1 ==K K2
    [simplification(50)]

  rule opaque(M:Map)[K:KItem <- undef] => opaque(M[K <- undef])
    [simplification]
  rule concat(K2:KItem, _:KItem, M:Map)[K1:KItem <- undef] => M
    requires K1 ==K K2
    [simplification]
  rule concat(K2:KItem, V2:KItem, M:Map)[K1:KItem <- undef]
      => concat(K2, V2, M[K1 <- undef])
    requires notBool (K1 ==K K2)
    [simplification]

  syntax MapElementProperty ::= "MEP.AlwaysFalse"
                              | "MEP.AlwaysTrue"
                              | "MEP.AnyProperty"
                              | "MEP.IsValue" "(" KItem ")"
  syntax Bool ::= applyMapElementProperty(
          MapElementProperty,
          key:KItem,
          value:KItem
      )  [function, functional]
  syntax Bool ::= uninterpretedElementProperty(key:KItem, value:KItem)
      [function, functional, no-evaluators]

  rule applyMapElementProperty(MEP.AlwaysFalse, _:KItem, _:KItem) => false
  rule applyMapElementProperty(MEP.AlwaysTrue, _:KItem, _:KItem) => true
  rule applyMapElementProperty(MEP.AnyProperty, Key:KItem, Value:KItem)
      => uninterpretedElementProperty(Key, Value)
  rule applyMapElementProperty(MEP.IsValue(V:KItem), _Key:KItem, Value:KItem)
      => V ==K Value

  syntax Int ::= countMapElementProperty(
          MapElementProperty,
          key:KItem,
          value:KItem
      )  [function, functional]

  rule countMapElementProperty(Property:MapElementProperty, Key:KItem, Value:KItem)
      => 0
    requires notBool applyMapElementProperty(Property, Key, Value)
  rule countMapElementProperty(Property:MapElementProperty, Key:KItem, Value:KItem)
      => 1
    requires applyMapElementProperty(Property, Key, Value)

  syntax Int ::= mapCount(Map, MapElementProperty)  [function, functional, smtlib(mapCount)]

  // TODO: Use this everywhere
  rule mapCount(.Map, _:MapElementProperty) => 0
  rule mapCount(K:KItem |-> V:KItem M:Map, Property:MapElementProperty)
      => countMapElementProperty(Property, K, V) +Int mapCount(M, Property)
    [simplification]

  rule mapCount(_:Map, _:MapElementProperty) >=Int 0 => true
    [simplification, smt-lemma]

  rule mapCount(M:Map, MEP.AlwaysTrue) >Int 0 => notBool (M ==K .Map)
    [simplification]

  syntax SelectPropertyIntermediateResult ::= found(key:KItem, value:KItem, Map)
                                            | notFoundYet(inner:Map, MapElementProperty, checked:Map)
  syntax KItem ::= lazyMapSelectProperty(Map, MapElementProperty)
  syntax KItem ::= #lazyMapSelectProperty(result:SelectPropertyIntermediateResult)
  syntax KItem ::= mapSelectPropertyAddBack(Map)
  syntax KItem ::= "mapSelectPropertyEnd"

  syntax KItem ::= findInnerMap(Map, MapElementProperty, SelectPropertyIntermediateResult)  [function, functional]
  syntax KItem ::= #findInnerMap(Map, MapElementProperty, checked:Map, SelectPropertyIntermediateResult)  [function, functional]

  rule lazyMapSelectProperty(M:Map, P:MapElementProperty)
      => findInnerMap(M, P, ?Result:SelectPropertyIntermediateResult)
      ~> #lazyMapSelectProperty(?Result)

  rule #lazyMapSelectProperty(notFoundYet(Inner:Map, Property:MapElementProperty, Checked:Map))
      => mapSelectProperty(Inner, Property) ~> mapSelectPropertyAddBack(Checked)
  rule #lazyMapSelectProperty(found(Key:KItem, Value:KItem, M:Map)) => mapSelected(Key, Value, M)

  rule mapSelected(Key:KItem, Value:KItem, M:Map) ~> mapSelectPropertyAddBack(N:Map)
      => mapSelected(Key, Value, M N)
  rule mapNotFound ~> mapSelectPropertyAddBack(_:Map)
      => mapNotFound

  rule mapSelectPropertyEnd => .K

  rule findInnerMap(M:Map, P:MapElementProperty, Result:SelectPropertyIntermediateResult)
      => #findInnerMap(M, P, .Map, Result)
  rule #findInnerMap(K:KItem |-> V:KItem M:Map, P:MapElementProperty, Checked:Map, Result:SelectPropertyIntermediateResult)
      => #findInnerMap(M, P, K |-> V Checked, Result)
    requires notBool applyMapElementProperty(P, K, V)
    [simplification(20)]
  rule #findInnerMap(K:KItem |-> V:KItem M:Map, P:MapElementProperty, Checked:Map, Result:SelectPropertyIntermediateResult)
      => mapSelectPropertyEnd
    requires applyMapElementProperty(P, K, V)
    ensures Result ==K found(K, V, iterateConcat(M, Checked))
    [simplification(20)]
  rule #findInnerMap(M:Map, P:MapElementProperty, Checked:Map, Result:SelectPropertyIntermediateResult)
      => mapSelectPropertyEnd
    ensures Result ==K notFoundYet(M, P, Checked)
    [simplification(50)]

  // TODO: Remove after https://github.com/kframework/kore/issues/2494 is fixed
  syntax Map ::= iterateConcat(Map, Map)  [function]
  rule iterateConcat(M:Map, .Map) => M
  rule iterateConcat(M:Map, K:KItem |-> V:KItem N) => iterateConcat(K |-> V M, N)
    requires notBool K in_keys(M)
    ensures notBool K in_keys(N)
    [simplification(20)]
  rule iterateConcat(M, N) => M N
    [simplification(50)]

  syntax KItem ::= mapSelectProperty(Map, MapElementProperty)
  syntax KItem ::= #mapSelectProperty(
                      toProcess:Map, MapElementProperty, processed:Map)
  syntax KItem ::= #mapSelectedProperty(
                      key:KItem, value:KItem,
                      toProcess:Map, MapElementProperty, processed:Map)

  syntax KItem ::= mapSelected(key:KItem, value:KItem, Map)
  syntax KItem ::= "mapNotFound"

  rule mapSelectProperty(M:Map, Property:MapElementProperty)
      => #mapSelectProperty(M, Property, .Map)

  rule #mapSelectProperty(.Map, _:MapElementProperty, _:Map)
      => mapNotFound
  rule #mapSelectProperty(
          M:Map,
          Property:MapElementProperty,
          Processed:Map)
      => #mapSelectedProperty(?Key, ?Value, ?M, Property, Processed)
    requires notBool (M ==K .Map)
    ensures (M ==K (?Key:KItem |-> ?Value:KItem ?M:Map))

  rule #mapSelectedProperty(
          Key:KItem,
          Value:KItem,
          M:Map,
          Property:MapElementProperty,
          Processed:Map)
      => mapSelected(Key, Value, M Processed)
    requires applyMapElementProperty(Property, Key, Value)
  rule #mapSelectedProperty(
          Key:KItem,
          Value:KItem,
          M:Map,
          Property:MapElementProperty,
          Processed:Map)
      => #mapSelectProperty(M, Property, Key |-> Value Processed)
    requires notBool applyMapElementProperty(Property, Key, Value)

endmodule
