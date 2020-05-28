  date

  export K_OPTS=-Xmx24g

  export CONCRETE_RULES="EDSL.#ceil32"
  export CONCRETE_RULES+=",EDSL.keccakIntList"
  export CONCRETE_RULES+=",EVM-DATA.#signed.positive"
  export CONCRETE_RULES+=",EVM-DATA.#signed.negative"
  export CONCRETE_RULES+=",EVM-DATA.#unsigned.positive"
  export CONCRETE_RULES+=",EVM-DATA.#unsigned.negative"
  export CONCRETE_RULES+=",EVM-DATA.powmod.nonzero"
  export CONCRETE_RULES+=",EVM-DATA.powmod.zero"
  export CONCRETE_RULES+=",EVM-DATA.signextend.invalid"
  export CONCRETE_RULES+=",EVM-DATA.signextend.negative"
  export CONCRETE_RULES+=",EVM-DATA.signextend.positive"
  export CONCRETE_RULES+=",EVM-DATA.keccak"
  export CONCRETE_RULES+=",EVM-DATA.#take.zero-pad"
  export CONCRETE_RULES+=",EVM-DATA.#asWord.recursive"
  export CONCRETE_RULES+=",EVM-DATA.#asByteStack"
  export CONCRETE_RULES+=",EVM-DATA.#asByteStackAux.recursive"
  export CONCRETE_RULES+=",EVM-DATA.#padToWidth"
  export CONCRETE_RULES+=",EVM-DATA.#padRightToWidth"
  export CONCRETE_RULES+=",EVM-DATA.#newAddr"
  export CONCRETE_RULES+=",EVM-DATA.#newAddrCreate2"
  export CONCRETE_RULES+=",EVM-DATA.mapWriteBytes.recursive"
  export CONCRETE_RULES+=",EVM-DATA.#range"
  export CONCRETE_RULES+=",EVM-DATA.#lookup.some"
  export CONCRETE_RULES+=",EVM-DATA.#lookup.none"
  export CONCRETE_RULES+=",EVM.#memoryUsageUpdate.some"
  export CONCRETE_RULES+=",EVM.Cgascap"
  export CONCRETE_RULES+=",EVM.Csstore.new"
  export CONCRETE_RULES+=",EVM.Csstore.old"
  export CONCRETE_RULES+=",EVM.Rsstore.new"
  export CONCRETE_RULES+=",EVM.Rsstore.old"
  export CONCRETE_RULES+=",EVM.Cextra"
  export CONCRETE_RULES+=",EVM.Cmem"

  export OPTS="--z3-impl-timeout 500"
  export OPTS+=" --no-exc-wrap"
  export OPTS+=" --deterministic-functions"
  export OPTS+=" --cache-func-optimized"
  export OPTS+=" --no-alpha-renaming"
  export OPTS+=" --format-failures"
# export OPTS+=" --branching-allowed 0"
# export OPTS+=" --branching-allowed 1"
# export OPTS+=" --boundary-cells k,pc"
# export OPTS+=" --boundary-cells k"
# export OPTS+=" --boundary-cells pc"
  export OPTS+=" --log"
# export OPTS+=" --log-basic"
# export OPTS+=" --log-rules"
  export OPTS+=" --log-success"
  export OPTS+=" --log-success-pc-diff"
# export OPTS+=" --log-func-eval"
  export OPTS+=" --log-cells k"
  export OPTS+=",pc"
  export OPTS+=",wordStack"
# export OPTS+=",localMem"
  export OPTS+=",output"
  export OPTS+=",gas"
  export OPTS+=",callGas"
  export OPTS+=",memoryUsed"
  export OPTS+=",statusCode"
  export OPTS+=",callData"
  export OPTS+=",log"
  export OPTS+=",refund"
# export OPTS+=",accounts"
  export OPTS+=",#pc,#result"
# export OPTS+=" --debug-z3-queries"

# export OPTS+=" --log-rules"
# export OPTS+=" --debug-z3-queries"

  make clean
  make split-proof-tests

  export OPTS+=" -v --debug"
  export OPTS+=" -d .build/evm-semantics/.build/defn/java"
  export OPTS+=" --smt-prelude evm.smt2"
  export OPTS+=" --concrete-rules $CONCRETE_RULES"

  kprove $OPTS -m VERIFICATION    --branching-allowed 0  --boundary-cells k    ~/deposit2/verified-smart-contracts/specs/java/deposit/init-success-spec.k
  kprove $OPTS -m VERIFICATION    --branching-allowed 0  --boundary-cells k    ~/deposit2/verified-smart-contracts/specs/java/deposit/init-revert-spec.k

  kprove $OPTS -m VERIFICATION    --branching-allowed 0  --boundary-cells k    ~/deposit2/verified-smart-contracts/specs/java/deposit/get_deposit_root-success-spec.k
  kprove $OPTS -m VERIFICATION-L1 --branching-allowed 1  --boundary-cells k,pc ~/deposit2/verified-smart-contracts/specs/java/deposit/loop-get_deposit_root-spec.k
  kprove $OPTS -m VERIFICATION    --branching-allowed 0  --boundary-cells k    ~/deposit2/verified-smart-contracts/specs/java/deposit/get_deposit_root-revert-spec.k

  kprove $OPTS -m VERIFICATION    --branching-allowed 0  --boundary-cells k    ~/deposit2/verified-smart-contracts/specs/java/deposit/get_deposit_count-success-spec.k
  kprove $OPTS -m VERIFICATION    --branching-allowed 0  --boundary-cells k    ~/deposit2/verified-smart-contracts/specs/java/deposit/get_deposit_count-revert-spec.k

  kprove $OPTS -m VERIFICATION    --branching-allowed 31 --boundary-cells k    ~/deposit2/verified-smart-contracts/specs/java/deposit/deposit-success-spec.k
  kprove $OPTS -m VERIFICATION    --branching-allowed 0  --boundary-cells k,pc ~/deposit2/verified-smart-contracts/specs/java/deposit/loop-deposit-spec.k

  kprove $OPTS -m VERIFICATION    --branching-allowed 0  --boundary-cells k    ~/deposit2/verified-smart-contracts/specs/java/deposit/deposit-revert-1-spec.k
  kprove $OPTS -m VERIFICATION    --branching-allowed 0  --boundary-cells k    ~/deposit2/verified-smart-contracts/specs/java/deposit/deposit-revert-2-spec.k
  kprove $OPTS -m VERIFICATION    --branching-allowed 0  --boundary-cells k    ~/deposit2/verified-smart-contracts/specs/java/deposit/deposit-revert-3-spec.k
  kprove $OPTS -m VERIFICATION    --branching-allowed 0  --boundary-cells k    ~/deposit2/verified-smart-contracts/specs/java/deposit/deposit-revert-4-spec.k
  kprove $OPTS -m VERIFICATION    --branching-allowed 0  --boundary-cells k    ~/deposit2/verified-smart-contracts/specs/java/deposit/deposit-revert-5-spec.k

  kprove $OPTS -m VERIFICATION    --branching-allowed 0  --boundary-cells k    ~/deposit2/verified-smart-contracts/specs/java/deposit/revert-invalid_function_identifier-lt_4-spec.k
  kprove $OPTS -m VERIFICATION    --branching-allowed 0  --boundary-cells k    ~/deposit2/verified-smart-contracts/specs/java/deposit/revert-invalid_function_identifier-ge_4-spec.k

  date
