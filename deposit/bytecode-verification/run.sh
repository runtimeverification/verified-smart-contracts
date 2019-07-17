  export OPTS="--z3-impl-timeout 500"
  export OPTS+=" --no-exc-wrap"
  export OPTS+=" --deterministic-functions"
  export OPTS+=" --cache-func-optimized"
  export OPTS+=" --no-alpha-renaming"
  export OPTS+=" --format-failures"
  export OPTS+=" --branching-allowed 0"
# export OPTS+=" --branching-allowed 1"
  export OPTS+=" --boundary-cells k,pc"
  export OPTS+=" --log"
# export OPTS+=" --log-basic"
  export OPTS+=" --log-rules"
  export OPTS+=" --log-success"
  export OPTS+=" --log-success-pc-diff"
  export OPTS+=" --log-cells k"
  export OPTS+=",pc"
  export OPTS+=",wordStack"
  export OPTS+=",localMem"
  export OPTS+=",output"
  export OPTS+=",gas"
  export OPTS+=",memoryUsed"
  export OPTS+=",statusCode"
  export OPTS+=",callData"
  export OPTS+=",log"
  export OPTS+=",refund"
# export OPTS+=",accounts"
  export OPTS+=",#pc,#result"
  export OPTS+=" --debug-z3-queries"

  make clean
  make split-proof-tests

# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/to_little_endian_64-spec.k
# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/to_little_endian_64-forloop-spec.k
  kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/to_little_endian_64-return-spec.k
# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/getHashTreeRoot-init-beforeLoop-spec.k
# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/getHashTreeRoot-init-afterFirstLoopIter-1-spec.k
# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/getHashTreeRoot-init-afterFirstLoopIter-2-spec.k
# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/getHashTreeRoot-loop-1-spec.k
# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/getHashTreeRoot-loop-2-spec.k
# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/getHashTreeRoot-loop-exit-spec.k
