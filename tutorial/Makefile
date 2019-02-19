BUILD_DIR:=.build

LOCAL_LEMMAS:=abstract-semantics.k verification.k
TMPLS:=module-tmpl.k spec-tmpl.k

SPEC_GROUP:=tutorial
SPEC_INI:=tutorial-spec.ini

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/../resources/evm.smt2) \
             --deterministic-functions --cache-func-optimized

SPEC_NAMES:=getCoffee \

include ../resources/kprove.mak
