Verification Lemmas for the Java backend
========================================

```k
requires "evm.k"
requires "edsl.k"
requires "lemmas-common.k"

module LEMMAS-JAVA
    imports EVM
    imports EDSL
    imports K-REFLECTION
    imports LEMMAS-COMMON
```

### Hashed Location

```k
    // TODO: drop keccakIntList once new vyper hashed location scheme is captured in edsl.md

    // for terms coming from bytecode not via #hashedLocation
    rule keccak(WS) => keccakIntList(byteStack2IntList(WS))
      requires ( notBool #isConcrete(WS) )
       andBool ( #sizeWordStack(WS) ==Int 32 orBool #sizeWordStack(WS) ==Int 64 )
```

### Integer Expression Simplification Rules

The following simplification rules are local, meant to be used in specific contexts.
The rules are applied only when the side-conditions are met.
These rules are specific to reasoning about EVM programs.

```k
    //orienting symbolic term to be first, converting -Int to +Int for concrete values.
    rule I +Int B => B          +Int I when #isConcrete(I) andBool notBool #isConcrete(B)
    rule A -Int I => A +Int (0 -Int I) when notBool #isConcrete(A) andBool #isConcrete(I)

    rule (A +Int I2) +Int I3 => A +Int (I2 +Int I3) when notBool #isConcrete(A) andBool #isConcrete(I2) andBool #isConcrete(I3)

    rule I1 +Int (B +Int I3) => B +Int (I1 +Int I3) when #isConcrete(I1) andBool notBool #isConcrete(B) andBool #isConcrete(I3)
    rule I1 -Int (B +Int I3) => (I1 -Int I3) -Int B when #isConcrete(I1) andBool notBool #isConcrete(B) andBool #isConcrete(I3)
    rule (I1 -Int B) +Int I3 => (I1 +Int I3) -Int B when #isConcrete(I1) andBool notBool #isConcrete(B) andBool #isConcrete(I3)

    rule I1 +Int (I2 +Int C) => (I1 +Int I2) +Int C when #isConcrete(I1) andBool #isConcrete(I2) andBool notBool #isConcrete(C)
    rule I1 +Int (I2 -Int C) => (I1 +Int I2) -Int C when #isConcrete(I1) andBool #isConcrete(I2) andBool notBool #isConcrete(C)
    rule I1 -Int (I2 +Int C) => (I1 -Int I2) -Int C when #isConcrete(I1) andBool #isConcrete(I2) andBool notBool #isConcrete(C)
    rule I1 -Int (I2 -Int C) => (I1 -Int I2) +Int C when #isConcrete(I1) andBool #isConcrete(I2) andBool notBool #isConcrete(C)

    rule I1 &Int (I2 &Int C) => (I1 &Int I2) &Int C when #isConcrete(I1) andBool #isConcrete(I2) andBool notBool #isConcrete(C)

    // for gas calculation
    rule (#if C #then B1 #else B2 #fi) -Int A => #if C #then (B1 -Int A) #else (B2 -Int A) #fi
        when notBool #isConcrete(A) andBool #notKLabel(A, "#if_#then_#else_#fi_K-EQUAL")
```

### #getKLabelString helpers

Function below returns true if the KLabel of `T` is not `L`, or if `T` is a variable.
```k
    syntax Bool ::= #notKLabel ( K , String ) [function]
    rule #notKLabel(T, L) => #getKLabelString(T) =/=String L orBool #isVariable(T)
```


```k

endmodule
```
