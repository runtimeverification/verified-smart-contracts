  date

  export K_OPTS=-Xmx24g

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
# export OPTS+=" --log-rules"
  export OPTS+=" --log-success"
  export OPTS+=" --log-success-pc-diff"
# export OPTS+=" --log-func-eval"
  export OPTS+=" --log-cells k"
  export OPTS+=",pc"
  export OPTS+=",wordStack"
  export OPTS+=",localMem"
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

  SPECS=

  SPECS+=" "~/verified-smart-contracts/specs/deposit/init-init-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/init-loop0-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/init-loop-enter-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/init-loop-exit-spec.k
  #
  SPECS+=" "~/verified-smart-contracts/specs/deposit/to_little_endian_64-spec.k
 #SPECS+=" "~/verified-smart-contracts/specs/deposit/to_little_endian_64-forloop-spec.k
 #SPECS+=" "~/verified-smart-contracts/specs/deposit/to_little_endian_64-return-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/get_deposit_root-init-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/get_deposit_root-loop0-then-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/get_deposit_root-loop0-else-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/get_deposit_root-loop-body-then-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/get_deposit_root-loop-body-else-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/get_deposit_root-loop-exit-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/get_deposit_count-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-init-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-subcall_1-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-subcall_2-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-log-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-data-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-add-init-then-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-add-init-else-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-add-loop-enter-then-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-add-loop-enter-else-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-add-loop-exit-spec.k
  #
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-init-calldata-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-init-calldata-revert-1-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-init-calldata-revert-2-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-init-calldata-revert-3-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-init-calldata-revert-4-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-init-calldata-revert-5-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-init-calldata-revert-6-spec.k
  #
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-init-revert-1-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-init-revert-2-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/deposit-data-revert-spec.k
  #
  SPECS+=" "~/verified-smart-contracts/specs/deposit/revert-invalid_function_identifier-lt_4-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/revert-invalid_function_identifier-ge_4-lt_32-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/revert-invalid_function_identifier-ge_4-ge_32-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/revert-init-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/revert-get_deposit_root-spec.k
  SPECS+=" "~/verified-smart-contracts/specs/deposit/revert-get_deposit_count-spec.k

  export LOGDIR=log.`date "+%F-%T-%Z" | sed 's/://g'`
  mkdir $LOGDIR

  bash lemmas.sh >lemmas.k

  make clean
  make split-proof-tests

  run_kprove() {
    kprove -v --debug \
      -d ~/evm-semantics/.build/defn/java \
      -m VERIFICATION $OPTS \
      --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 \
      --concrete-rules "EVM-DATA.take.zero-pad" \
      `eval echo $1` \
      >$LOGDIR/`basename $1`.log 2>&1
    tail -100 $LOGDIR/`basename $1`.log
  }
  export -f run_kprove

  echo $SPECS | xargs -d ' ' -n 1 -P 2 -I {} bash -c 'run_kprove "{}"'

  date
