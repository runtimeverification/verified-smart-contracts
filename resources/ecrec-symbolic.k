requires "edsl.k"
requires "evm-symbolic.k"

module ECREC-SYMBOLIC     [symbolic]
    imports K-REFLECTION
    imports EVM
    imports EDSL
    imports EVM-SYMBOLIC

  // ########################
  // ECRECOVER
  // ########################

  rule <k> ECREC => #end EVMC_SUCCESS ... </k>
       <callData> DATA </callData>
       <output> _ => #ecrec(#symEcrec(DATA)) </output>
    requires notBool #isConcrete(DATA) andBool #sizeWordStack(DATA) ==Int 128 andBool notBool #ecrecEmpty(DATA)
    [trusted]

  rule <k> ECREC => #end EVMC_SUCCESS ... </k>
       <callData> DATA </callData>
       <output> _ => #ecrec(.Account) </output>
    requires notBool #isConcrete(DATA) andBool #sizeWordStack(DATA) ==Int 128 andBool #ecrecEmpty(DATA)
    [trusted]

endmodule
