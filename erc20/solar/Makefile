KEVM_VERSION_FILE:=.build/.kevm.rev

# Required to have different lemmas dir from non-#buf ERC20 specs.
SPEC_GROUP:=erc20/buf/solar

BASEDIR_LEMMAS=$(RESOURCES)/lemmas-buf.md
LOCAL_LEMMAS:=../verification.k \
			  ../../resources/abstract-semantics-segmented-gas.k \
			  ../../resources/evm-symbolic.k \
			  ../../resources/evm-data-map-symbolic.k \
			  solar-abstract-semantics.k
TMPLS:=module-tmpl.k spec-tmpl.k

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/../../resources/evm.smt2)

SPEC_NAMES:=balanceOf \
            transfer-success-1 \
            transfer-success-2 \
            transfer-failure-1-a \
            transfer-failure-1-b \
            transfer-failure-2

include ../../resources/kprove.mak
