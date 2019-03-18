BUILD_DIR:=../erc20/.build

# verification.k is required to import evm-symbolic.k
LOCAL_LEMMAS:=abstract-semantics.k verification.k ../resources/evm-symbolic.k ../resources/ecrec-symbolic.k

# Just to have the simplest initial config
TMPLS:=../erc20/module-tmpl.k spec-tmpl.k

SPEC_GROUP:=k-test
SPEC_INI:=k-test-spec.ini

MAKEFILE_PATH := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
KPROVE_OPTS:=--smt-prelude $(MAKEFILE_PATH)/smt-prelude.smt2

SPEC_NAMES:=ecrecT-false-implication \
            ecrecT-false-constraint \
            rhsOnlyVar \
            test-getKLabelString

include ../resources/kprove.mak
