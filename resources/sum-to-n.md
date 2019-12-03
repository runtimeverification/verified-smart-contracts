The Sum To N Specification
==========================

### Sum to N

As a demonstration of simple reachability claims involving a circularity, we prove the EVM [Sum to N](proofs/sum-to-n.md) program correct.
This program sums the numbers from 1 to N (for sufficiently small N), including pre-conditions dis-allowing integer under/overflow and stack overflow.

```{.k .sum-to-n}
requires "edsl.k"
requires "../lemmas.k"

module VERIFICATION
    imports EDSL
    imports LEMMAS
    imports EVM-ASSEMBLY

    rule #sizeWordStack ( WS , N:Int )
      => N +Int #sizeWordStack ( WS , 0 )
      requires N =/=K 0
      [lemma]

    syntax ByteArray ::= "sumToN" [function]
 // ----------------------------------------
    rule sumToN
      => #asmOpCodes(PUSH(1, 0) ; SWAP(1)                   // s = 0 ; n = N
                    ; JUMPDEST                              // label:loop
                    ; DUP(1) ; ISZERO ; PUSH(1, 20) ; JUMPI // if n == 0, jump to end
                    ; DUP(1) ; SWAP(2) ; ADD                // s = s + n
                    ; SWAP(1) ; PUSH(1, 1) ; SWAP(1) ; SUB  // n = n - 1
                    ; PUSH(1, 3) ; JUMP                     // jump to loop
                    ; JUMPDEST                              // label:end
                    ; .OpCodes
                    ) [macro]
endmodule
```

### Overview

Here we provide a specification file containing two reachability rules:
(1) Main rule stating the functional correctness of the program, including the gas that it needs; and
(2) The helper circularity rule stating the functional correctness of its loop and the gas it needs.
Note that the program behaves incorrectly/unexpectedly if arithmetic overflow occurs during its execution.
One challenge in verifying this program is to identify the conditions under which overflow does not occur.

```{.k .sum-to-n}
module SUM-TO-N-SPEC
    imports VERIFICATION
```

Sum To N Program and Claim
--------------------------

### High Level

A canonical "hello world" verification example, in no particular language:

```
s = 0;
n = N;
while (n > 0) {
    s = s + n;
    n = n - 1;
}
return s;
```

### Claim

$$s = \sum_{i = 1}^N i = \frac{N * (N + 1)}{2}$$

Proof Claims
------------

### Static Configuration

The first part of the claim is largely static (or abstracted away, like `<callGas>`).

```{.k .sum-to-n}
    rule <k> #execute ... </k>
         <mode> NORMAL </mode>
         <schedule> DEFAULT </schedule>
         <callStack> .List </callStack>
         <memoryUsed> 0   </memoryUsed>
         <localMem> .Map </localMem>
         <callGas> _ => _ </callGas>
         <program> sumToN </program>
         <jumpDests> #computeValidJumpDests(sumToN) </jumpDests>
```

### Main Claim

-   We start at program counter 0 and end at 53.
-   The `<wordStack>` starts small enough and ends with the correct sum.
-   The gas consumed is no more than `(52 * N) + 27`.
-   `N` is sufficiently low that overflow will not occur in execution.

```{.k .sum-to-n}
     <pc>        0  => 21                                </pc>
     <wordStack> N : WS => 0 : N *Int (N +Int 1) /Int 2 : WS </wordStack>
     <gas>       G  => G -Int (52 *Int N +Int 27)        </gas>

  requires N >=Int 0
   andBool N <=Int 340282366920938463463374607431768211455
   andBool #sizeWordStack(WS) <Int 1021
   andBool G >=Int 52 *Int N +Int 27
```

Proof Claims
------------

### Static Circularity

The circularity is in the same static environment as the overall proof-goal.

```{.k .sum-to-n}
    rule <k> #execute ... </k>
         <mode> NORMAL </mode>
         <schedule> DEFAULT </schedule>
         <callStack> .List </callStack>
         <memoryUsed> 0   </memoryUsed>
         <localMem> .Map </localMem>
         <callGas> _ => _ </callGas>
         <program> sumToN </program>
         <jumpDests> #computeValidJumpDests(sumToN) </jumpDests>
```

### Circularity (Loop Invariant)

We specify the behaviour of the rest of the program any time it reaches the loop head:

-   We start at program counter 35 (beginning of loop) and end at 53.
-   `<wordStack>` starts with the counter `I` and the partial sum `S`, and
-   `<wordStack>` ends with the correct sum.
-   The gas consumed for this fragment is no more than `(52 * I) + 21`.
-   `S` and `I` are sufficiently low that overflow will not occur during execution.

```{.k .sum-to-n}
     <pc>  3 => 21                         </pc>
     <gas> G => G -Int (52 *Int I +Int 21) </gas>

     <wordStack> I : S                               : WS
              => 0 : S +Int I *Int (I +Int 1) /Int 2 : WS </wordStack>

  requires I >=Int 0
   andBool S >=Int 0
   andBool S +Int I *Int (I +Int 1) /Int 2 <Int pow256
   andBool #sizeWordStack(WS) <Int 1021
   andBool G >=Int 52 *Int I +Int 21

endmodule
```
