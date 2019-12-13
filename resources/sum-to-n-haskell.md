The Sum To N Specification for the Haskell backend
==================================================

Uses the right imports for adapting the sum-to-n-common proof for the Haskell
backend.

```{.k .sum-to-n}
requires "sum-to-n-common.k"
requires "../lemmas-haskell.k"

module VERIFICATION
    imports VERIFICATION-COMMON
    imports LEMMAS-HASKELL
endmodule

module SUM-TO-N-HASKELL-SPEC
    imports VERIFICATION
    imports SUM-TO-N-COMMON
endmodule
```
