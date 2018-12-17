BUILD_DIR:=../.build

LOCAL_LEMMAS:=../abstract-semantics.k ../verification.k
TMPLS:=../module-tmpl.k ../spec-tmpl.k

SPEC_GROUP:=gnosis-test
SPEC_INI:=api-test.ini

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/../evm.smt2) \
             --deterministic-functions --cache-func-optimized --debug --debug-z3-queries

SPEC_NAMES:=testAbiEncode-AndKeccak-2 \

include ../../resources/kprove.mak
