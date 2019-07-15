BUILD_DIR:=../../.build

LOCAL_LEMMAS:=verification.k \
			  abstract-semantics.k \
			  ../../resources/abstract-semantics-segmented-gas.k \
			  ../../resources/evm-symbolic.k \
			  ../../resources/evm-data-map-symbolic.k
TMPLS:=module-tmpl.k spec-tmpl.k

SPEC_GROUP:=deposit
SPEC_INI:=deposit-spec.ini

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/evm.smt2)

SPEC_NAMES:=getHashTreeRoot-init-beforeLoop \
            getHashTreeRoot-init-afterFirstLoopIter-1 \
            getHashTreeRoot-init-afterFirstLoopIter-2 \
            getHashTreeRoot-loop-1 \
            getHashTreeRoot-loop-2 \
            getHashTreeRoot-loop-exit

include ../../resources/kprove.mak
