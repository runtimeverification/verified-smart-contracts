KEVM_VERSION_FILE:=.build/.kevm.rev

LOCAL_LEMMAS:=verification.k \
              abstract-semantics.k \
              lemmas.k
TMPLS:=module-tmpl.k spec-tmpl.k

SPEC_GROUP:=deposit
SPEC_INI:=deposit-spec.ini

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/evm.smt2) \
             --branching-allowed 0 \
             --z3-cnstr-timeout 100

SPEC_NAMES:=

SPEC_NAMES += init-success
SPEC_NAMES += init-revert

SPEC_NAMES += get_deposit_root-success-init-then
SPEC_NAMES += get_deposit_root-success-init-else
SPEC_NAMES += get_deposit_root-success-loop-enter-then
SPEC_NAMES += get_deposit_root-success-loop-enter-else
SPEC_NAMES += get_deposit_root-success-loop-exit
SPEC_NAMES += get_deposit_root-revert

SPEC_NAMES += get_deposit_count-success
SPEC_NAMES += get_deposit_count-revert

SPEC_NAMES += deposit-success-data
SPEC_NAMES += deposit-success-insert-init-then
SPEC_NAMES += deposit-success-insert-init-else
SPEC_NAMES += deposit-success-insert-loop-enter-then
SPEC_NAMES += deposit-success-insert-loop-enter-else
SPEC_NAMES += deposit-success-insert-loop-exit

SPEC_NAMES += deposit-revert-1
SPEC_NAMES += deposit-revert-2
SPEC_NAMES += deposit-revert-3

SPEC_NAMES += deposit-calldata-decoding-success
SPEC_NAMES += deposit-calldata-decoding-revert-1
SPEC_NAMES += deposit-calldata-decoding-revert-2
SPEC_NAMES += deposit-calldata-decoding-revert-3
SPEC_NAMES += deposit-calldata-decoding-revert-4
SPEC_NAMES += deposit-calldata-decoding-revert-5
SPEC_NAMES += deposit-calldata-decoding-revert-6

SPEC_NAMES += revert-invalid_function_identifier-lt_4
SPEC_NAMES += revert-invalid_function_identifier-ge_4-lt_32
SPEC_NAMES += revert-invalid_function_identifier-ge_4-ge_32

export K_OPTS=-Xmx16g

include ../../resources/kprove.mak
