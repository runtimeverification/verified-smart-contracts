  make clean
  make split-proof-tests

  kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION --z3-impl-timeout 500 --deterministic-functions --no-exc-wrap --cache-func-optimized --no-alpha-renaming --format-failures --boundary-cells k,pc --log-cells k,output,statusCode,localMem,pc,gas,wordStack,callData,accounts,memoryUsed,#pc,#result --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2  ~/verified-smart-contracts/specs/deposit/getHashTreeRoot-spec.k
