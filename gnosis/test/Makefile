LOCAL_LEMMAS:=../verification.k \
			  ../abstract-semantics.k \
			  ../abstract-semantics-segmented-gas.k \
			  ../../resources/evm-symbolic.k \
			  ../../resources/evm-data-map-symbolic.k \
			  ../../resources/ecrec-symbolic.k
TMPLS:=../module-tmpl.k ../spec-tmpl.k

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/../evm.smt2)

SPEC_NAMES:=testKeccak-1 \
            testKeccak-2 \
            testAbiEncode \
            testAbiEncode-AndKeccak-1 \
            testAbiEncode-AndKeccak-2 \
            testAbiEncodePacked \
            testEcrecover-non-empty \
            testEcrecover-empty

include ../../resources/kprove.mak
