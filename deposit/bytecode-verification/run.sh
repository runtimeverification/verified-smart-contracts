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
##kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/to_little_endian_64-forloop-spec.k
##kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/to_little_endian_64-return-spec.k
# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/get_hash_tree_root-init-spec.k
# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/get_hash_tree_root-loop0-then-spec.k
# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/get_hash_tree_root-loop0-else-spec.k
# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/get_hash_tree_root-loop-body-then-spec.k
# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/get_hash_tree_root-loop-body-else-spec.k
# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/get_hash_tree_root-loop-exit-spec.k
# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/get_deposit_count-spec.k
# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/deposit-init-spec.k
# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/deposit-subcall_1-spec.k
  kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/deposit-subcall_2-spec.k
# kprove -v --debug -d ~/evm-semantics/.build/java -m VERIFICATION $OPTS --smt-prelude ~/verified-smart-contracts/deposit/bytecode-verification/evm.smt2 ~/verified-smart-contracts/specs/deposit/deposit-log-spec.k
