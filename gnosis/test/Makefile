BUILD_DIR:=../.build

LOCAL_LEMMAS:=../abstract-semantics.k ../verification.k
TMPLS:=../module-tmpl.k ../spec-tmpl.k

SPEC_GROUP:=gnosis-test
SPEC_INI:=api-test.ini

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/../evm.smt2) \
						 --deterministic-functions --cache-func-optimized

SPEC_NAMES:=testKeccak-1 \
            testKeccak-2 \
            testAbiEncode \
            testAbiEncode-AndKeccak-1 \
            testAbiEncode-AndKeccak-2 \
            testAbiEncodePacked \
            testEcrecover-non-empty \
            testEcrecover-empty

include ../../resources/kprove.mak
