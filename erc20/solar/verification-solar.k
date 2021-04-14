requires "verification.k"
requires "evm-imp-specs.k"

module VERIFICATION-SOLAR
    imports VERIFICATION
    imports EVM-IMP-SPECS

    rule #sizeWordStack(#padToWidth(N1, _), N2) => N1 +Int N2

    // #buf unification when size is equal
    rule #buf(SIZE, DATA1) ==K #buf(SIZE, DATA2) => DATA1 ==K DATA2
      //todo is requires needed? Would require lemmas that ensure: rangeUInt(256, select(STORAGE, _))
      /*requires #range(0 <= DATA1 < (2 ^Int (SIZE *Int 8)))
       andBool #range(0 <= DATA2 < (2 ^Int (SIZE *Int 8)))*/

endmodule
