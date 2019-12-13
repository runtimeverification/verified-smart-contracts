The Sum To N Specification for the Java backend
==================================================

Uses the right imports for adapting the sum-to-n-common proof for the Java
backend.

```{.k .sum-to-n}
requires "sum-to-n-common.k"
requires "../lemmas-java.k"

module VERIFICATION
    imports VERIFICATION-COMMON
    imports LEMMAS-JAVA
endmodule

module SUM-TO-N-JAVA-SPEC
    imports VERIFICATION
    imports SUM-TO-N-COMMON
endmodule
```
