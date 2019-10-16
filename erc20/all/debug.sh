  export K_OPTS=-Xmx24g

  export OPTS="--z3-impl-timeout 500"
  export OPTS+=" --no-exc-wrap"
  export OPTS+=" --deterministic-functions"
  export OPTS+=" --cache-func-optimized"
  export OPTS+=" --no-alpha-renaming"
  export OPTS+=" --format-failures"
# export OPTS+=" --branching-allowed 0"
# export OPTS+=" --branching-allowed 1"
  export OPTS+=" --boundary-cells k,pc"
  export OPTS+=" --log"
# export OPTS+=" --log-basic"
  export OPTS+=" --log-rules"
  export OPTS+=" --log-success"
  export OPTS+=" --log-success-pc-diff"
# export OPTS+=" --log-func-eval"
  export OPTS+=" --log-cells k"
  export OPTS+=",pc"
  export OPTS+=",wordStack"
  export OPTS+=",localMem"
  export OPTS+=",output"
  export OPTS+=",gas"
  export OPTS+=",previousGas"
  export OPTS+=",memoryUsed"
  export OPTS+=",statusCode"
  export OPTS+=",callData"
  export OPTS+=",log"
  export OPTS+=",refund"
  export OPTS+=",accounts"
  export OPTS+=",#pc,#result"
  export OPTS+=" --debug-z3-queries"

# /home/daejunpark/erc20-verifier/verified-smart-contracts/.build/k/k-distribution/target/release/k/bin/kprove -v --debug -d /home/daejunpark/erc20-verifier/verified-smart-contracts/.build/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude /home/daejunpark/erc20-verifier/verified-smart-contracts/resources/evm.smt2  /home/daejunpark/erc20-verifier/verified-smart-contracts/specs/erc20/approve-spec.k

  /home/daejunpark/erc20-verifier/verified-smart-contracts/.build/k/k-distribution/target/release/k/bin/kprove -v --debug -d /home/daejunpark/erc20-verifier/verified-smart-contracts/.build/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude /home/daejunpark/erc20-verifier/verified-smart-contracts/resources/evm.smt2  /home/daejunpark/erc20-verifier/verified-smart-contracts/specs/erc20/transfer-success-regular-overflow-spec.k


