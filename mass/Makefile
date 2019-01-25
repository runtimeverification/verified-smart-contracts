BUILD_DIR:=.build

LOCAL_LEMMAS:=abstract-semantics.k verification.k
TMPLS:=module-tmpl.k spec-tmpl.k

SPEC_GROUP:=mass
SPEC_INI:=mass-spec.ini

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/../resources/evm.smt2) \
             --deterministic-functions --cache-func-optimized

SPEC_NAMES:=fallback-run \
            fallback-payable \
						fallback-fail \
						fallback-call \
						fallback-delegatecall \

include ../resources/kprove.mak
