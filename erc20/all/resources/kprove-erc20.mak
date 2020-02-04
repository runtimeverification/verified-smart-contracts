THIS_FILE_DIR:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))
ROOT_DIR:=$(abspath $(THIS_FILE_DIR)/../../..)
RESOURCES_DIR:=$(ROOT_DIR)/resources
LOCAL_RESOURCES_DIR:=$(THIS_FILE_DIR)

KEVM_VERSION_FILE:=$(ROOT_DIR)/erc20/.build/.kevm.rev
BASEDIR_LEMMAS=$(RESOURCES)/lemmas-buf.md
LOCAL_LEMMAS:=$(ROOT_DIR)/erc20/verification.k \
			  $(RESOURCES_DIR)/abstract-semantics-segmented-gas.k \
			  $(RESOURCES_DIR)/evm-symbolic.k \
			  $(ROOT_DIR)/erc20/evm-data-map-symbolic.k
TMPLS:=../../module-tmpl.k $(LOCAL_RESOURCES_DIR)/spec-tmpl.k

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
