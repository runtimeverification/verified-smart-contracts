BUILD_DIR:=../../../.build

LOCAL_LEMMAS:=../verification.k \
			  ../../../resources/abstract-semantics-segmented-gas.k \
			  ../../../resources/evm-symbolic.k \
			  ../../../resources/evm-data-map-symbolic.k
TMPLS:=../../module-tmpl.k ../spec-tmpl.k

SPEC_GROUP:=erc20
SPEC_INI:=erc20-spec.ini

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/../../../resources/evm.smt2)

SPEC_NAMES:=totalSupply \
            balanceOf \
            allowance \
            approve \
            transfer-success-regular \
            transfer-success-regular-overflow \
            transfer-success-self \
            transfer-failure \
            transferFrom-success-regular \
            transferFrom-success-regular-overflow \
            transferFrom-success-self \
            transferFrom-failure

include ../../../resources/kprove.mak
