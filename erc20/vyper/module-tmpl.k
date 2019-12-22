requires "abstract-semantics-segmented-gas.k"
requires "vyper-verification.k"

// Custom module-tmpl needed to import VYPER-VERIFICATION, in turn needed to import NOT-KLABEL
module {MODULE}-SPEC
  imports ABSTRACT-SEMANTICS-SEGMENTED-GAS
  imports VYPER-VERIFICATION

{RULES}

endmodule
