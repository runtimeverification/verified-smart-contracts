Verification Lemmas
===================

Version for specs that only use `#buf` abstraction for `WordStack/ByteArray`, `not nthbyteof()`.
 
```k
requires "evm.k"
requires "edsl.k"

module LEMMAS
    imports EVM
    imports EDSL
    imports K-REFLECTION
```

### Memory Abstraction

We present an abstraction for the EVM memory to allow the word-level reasoning.
The word is considered as the smallest unit of values in the surface language level (thus in the contract developers’ mind as well), but the EVM memory is byte-addressable.
Our abstraction helps to fill the gap and make the reasoning easier.

Another type of byte-array manipulating operation is used to extract the function signature from the call data.
The function signature is located in the first four bytes of the call data, but there is no atomic EVM instruction that can load only the four bytes, thus some kind of byte-twiddling operations are necessary.

The extraction mechanism varies by language compilers.
For example, in Vyper, the first 32 bytes of the call data are loaded into the memory at the starting location 28 (i.e., in the memory range of 28 to 59), and the memory range of 0 to 31, which consists of 28 zero bytes and the four signature bytes, is loaded into the stack.
In Solidity, however, the first 32 bytes of the call data are loaded into the stack, and the loaded word (i.e., a 256-bit integer) is divided by `2^(28*8)` (i.e., right-shifted by 28 bytes), followed by masked by 0xffffffff (i.e., 4 bytes of bit 1’s).

The following lemmas essentially capture the signature extraction mechanisms.
It reduces the reasoning efforts of the underlying theorem prover, factoring out the essence of the byte-twiddling operations.

```k
    // for Solidity
    rule #asWord(WS) /Int D => #asWord(#take(#sizeWordStack(WS) -Int log256Int(D), WS))
      requires D ==Int 256 ^Int log256Int(D) andBool D >=Int 0
       andBool #sizeWordStack(WS) >=Int log256Int(D)
       andBool #noOverflow(WS)

    syntax Bool ::= #noOverflow    ( WordStack ) [function]
                  | #noOverflowAux ( WordStack ) [function]
 // -------------------------------------------------------
    rule #noOverflow(WS) => #sizeWordStack(WS) <=Int 32 andBool #noOverflowAux(WS)

    rule #noOverflowAux(W : WS)     => 0 <=Int W andBool W <Int 256 andBool #noOverflowAux(WS)
    rule #noOverflowAux(.WordStack) => true
```

### Hashed Location

```k
    // TODO: drop hash1 and keccakIntList once new vyper hashed location scheme is captured in edsl.md

    syntax Int ::= hash1(Int)      [function, smtlib(smt_hash1)]
                 | hash2(Int, Int) [function, smtlib(smt_hash2)]

    rule hash1(V) => keccak(#padToWidth(32, #asByteStack(V)))
      requires 0 <=Int V andBool V <Int pow256
      [concrete]

    rule hash2(V1, V2) => keccak(   #padToWidth(32, #asByteStack(V1))
                                 ++ #padToWidth(32, #asByteStack(V2)))
      requires 0 <=Int V1 andBool V1 <Int pow256
       andBool 0 <=Int V2 andBool V2 <Int pow256
      [concrete]

    rule keccakIntList(V:Int .IntList) => hash1(V)
    rule keccakIntList(V1:Int V2:Int .IntList) => hash2(V1, V2)

    // for terms came from bytecode not via #hashedLocation
    rule keccak(WS) => keccakIntList(byteStack2IntList(WS))
      requires ( notBool #isConcrete(WS) )
       andBool ( #sizeWordStack(WS) ==Int 32 orBool #sizeWordStack(WS) ==Int 64 )
```

### Integer Expression Simplification Rules

We introduce simplification rules that capture arithmetic properties, which reduce the given terms into smaller ones.
These rules help to improve the performance of the underlying theorem prover’s symbolic reasoning.

Below are universal simplification rules that are free to be used in any context.

```k
    rule N +Int 0 => N

    rule N -Int 0 => N

    rule 1 *Int N => N
    rule N *Int 1 => N
    rule 0 *Int _ => 0
    rule _ *Int 0 => 0

    rule N /Int 1 => N

    rule 0 |Int N => N
    rule N |Int 0 => N
    rule N |Int N => N

    rule 0 &Int N => 0
    rule N &Int 0 => 0
    rule N &Int N => N
```

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

    // 0xffff...f &Int N = N
    rule MASK &Int N => N  requires MASK ==Int (2 ^Int (log2Int(MASK) +Int 1)) -Int 1 // MASK = 0xffff...f
                            andBool 0 <=Int N andBool N <=Int MASK

    // N &Int 0xffff...f = N
    rule N &Int MASK => N  requires MASK ==Int (2 ^Int (log2Int(MASK) +Int 1)) -Int 1 // MASK = 0xffff...f
                            andBool 0 <=Int N andBool N <=Int MASK



    // for gas calculation
    rule A -Int (#if C #then B1 #else B2 #fi) => #if C #then (A -Int B1) #else (A -Int B2) #fi
    rule (#if C #then B1 #else B2 #fi) +Int A => #if C #then (B1 +Int A) #else (B2 +Int A) #fi
```

Operator direction normalization rules. Required to reduce the number of forms of inequalities that can be matched by
general lemmas. We chose to keep `<Int` and `<=Int` because those operators are used in all range lemmas and in
`#range` macros. Operators `>Int` and `>=Int` are still allowed anywhere except rules LHS.
In all other places they will be matched and rewritten by rules below.
```k
    rule X >Int Y => Y <Int X
    rule X >=Int Y => Y <=Int X

    rule notBool (X <Int Y) => Y <=Int X
    rule notBool (X <=Int Y) => Y <Int X
```

### Boolean

In EVM, no boolean value exist but instead, 1 and 0 are used to represent true and false respectively.
`bool2Word` is used to convert from booleans to integers, and lemmas are provided here for it.

```k
    rule bool2Word(A) |Int bool2Word(B) => bool2Word(A  orBool B)
    rule bool2Word(A) &Int bool2Word(B) => bool2Word(A andBool B)

    rule 1 |Int bool2Word(B) => 1
    rule 1 &Int bool2Word(B) => bool2Word(B)

    rule bool2Word(B) |Int 1 => 1
    rule bool2Word(B) &Int 1 => bool2Word(B)

    rule bool2Word(A)  ==K 0 => notBool(A)
    rule bool2Word(A)  ==K 1 => A
    rule bool2Word(A) =/=K 0 => A
    rule bool2Word(A) =/=K 1 => notBool(A)

    rule chop(bool2Word(B)) => bool2Word(B)
```

Some lemmas over the comparison operators are also provided.

```k
    rule 0 <=Int X &Int Y             => true requires 0 <=Int X andBool X <Int pow256 andBool 0 <=Int Y andBool Y <Int pow256
    rule         X &Int Y <Int pow256 => true requires 0 <=Int X andBool X <Int pow256 andBool 0 <=Int Y andBool Y <Int pow256
```

### Range Matching Lemmas
Many rules both in KEVM and in this file contain range-related side conditions, like
`requires 0 <=Int V andBool V <Int pow256`. These expressions have to be reduced to `true` in order to side condition to match.
This can generally happen in 3 ways.
- If expression is concrete, then regular rules from KEVM will apply and eventually reduce it to true or false.
- Otherwise, side condition can be matched by an inequality in the term constraint (path condition).
If side condition cannot be matched exactly, Z3 will be invoked and can still deduct it indirectly from the entire constraint,
through boolean and arithmetic reasoning.
- Otherwise, we can extend the semantics with specific "lemma" rules for symbolic expression that can be proved true
from their concrete semantics.

Below are the most common such range matching lemmas.

```k
    rule 0 <=Int #asWord(WS)          => true
    rule #asWord(WS) <Int pow256      => true

    rule 0 <=Int hash1(_)             => true
    rule         hash1(_) <Int pow256 => true

    rule 0 <=Int hash2(_,_)             => true
    rule         hash2(_,_) <Int pow256 => true

    rule 0 <=Int chop(V)             => true
    rule         chop(V) <Int pow256 => true

    rule 0 <=Int keccak(V)             => true
    rule         keccak(V) <Int pow256 => true

    rule 0 <=Int keccakIntList(_)             => true
    rule         keccakIntList(_) <Int pow256 => true

    rule 0 <=Int N &Int X => true
      requires 0 <=Int N

    rule         N &Int X <Int pow256 => true
      requires N <Int pow256

    rule 0 <=Int bool2Word(_)             => true
    rule         bool2Word(_) <Int 2      => true
    rule         bool2Word(_) <Int 256    => true
    rule         bool2Word(_) <Int pow256 => true
```

Because lemmas are applied as plain K rewrite rule, they have to match exactly, without any deductive reasoning.
For example the lemma `rule A < 100 => true` won't match the side condition `requires A <= 99` or
`requires 100 > A`.
To avoid such mismatching situations we need additional expression normalization rules.
First rule below converts `maxUInt256` to `pow256`.
It allows side conditions that use `maxUInt256` or `#range` macros
match the range lemmas above. Note that lemmas above all use `<Int pow256` for the upper range.
The other rules are similar.

```k
    rule X <=Int maxUInt256 => X <Int pow256
    rule X <=Int maxUInt160 => X <Int pow160
    rule X <=Int 255        => X <Int 256
```

Range transformation, required for example for chop reduction rules below.

WARNING: Denis: I suspect these 3 lemmas were all necessary since I introduced #symEcrec construct which
pretty much caused most query build operations to fail and thus rendered z3 unusable.
Now since Z3 translation was fixed in K they must not be needd.
They cause a major increase in the number of Z3 queries and slowdown.
```k
    /*rule X <Int pow256 => true
      requires X <Int 256

    rule X <Int pow256 => true
      requires X <Int pow160

    rule 0 <=Int X => true
      requires 0 <Int X*/
```

### `chop` Reduction

```k
    rule chop(I) => I requires 0 <=Int I andBool I <Int pow256
```

### Wordstack

These lemmas abstract some properties about `#sizeWordStack`:

```k
    rule 0 <=Int #sizeWordStack ( _ , _ ) => true [smt-lemma]

endmodule
```
