  export OPTS="--z3-impl-timeout 500"
  export OPTS+=" --no-exc-wrap"
  export OPTS+=" --deterministic-functions"
  export OPTS+=" --cache-func-optimized"
  export OPTS+=" --no-alpha-renaming"
  export OPTS+=" --format-failures"
  export OPTS+=" --branching-allowed 1"
  export OPTS+=" --boundary-cells k,pc"
  export OPTS+=" --log"
# export OPTS+=" --log-basic"
  export OPTS+=" --log-rules"
  export OPTS+=" --log-success"
  export OPTS+=" --log-success-pc-diff"
  export OPTS+=" --log-cells k,output,statusCode,pc,gas,callData,memoryUsed"
  export OPTS+=",localMem"
  export OPTS+=",wordStack"
# export OPTS+=",accounts"
  export OPTS+=",#pc,#result"
# export OPTS+=" --debug-z3-queries"

  make clean
  make split-proof-tests

# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/getHashTreeRoot-init-spec.k
  kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/getHashTreeRoot-loop-1-spec.k
