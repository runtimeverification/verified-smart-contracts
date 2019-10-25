ROOT_DIR:=$(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../../..)
RESOURCES_DIR:=$(ROOT_DIR)/resources

LOCAL_LEMMAS:=../verification.k \
			  $(RESOURCES_DIR)/abstract-semantics-segmented-gas.k \
			  $(RESOURCES_DIR)/evm-symbolic.k \
			  $(RESOURCES_DIR)/evm-data-map-symbolic.k
TMPLS:=../../module-tmpl.k ../spec-tmpl.k

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

KPROVE_OPTS:=--smt-prelude $(ROOT_DIR)/resources/evm.smt2

include $(RESOURCES_DIR)/kprove.mak
