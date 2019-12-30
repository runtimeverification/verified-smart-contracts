KEVM_VERSION_FILE:=.build/.kevm.rev
KOMPILE_COMMAND=make build-specs K_BIN=$(K_BIN)
override KEVM_BUILD_DIR=$(KEVM_REPO_DIR)/.build/defn/specs

# Required to have different lemmas dir from non-#buf ERC20 specs.
SPEC_GROUP:=erc20/buf/solar

DEFINITION_MODULE:=VERIFICATION-SOLAR

BASEDIR_LEMMAS=$(RESOURCES)/lemmas-buf.md
LOCAL_LEMMAS:=verification-solar.k \
			  ../verification.k \
			  ../../resources/abstract-semantics-segmented-gas.k \
			  ../../resources/evm-symbolic.k \
			  ../../resources/evm-data-map-symbolic.k \
			  solar-abstract-semantics.k
TMPLS:=module-tmpl.k spec-tmpl.k

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/../../resources/evm.smt2)

SPEC_NAMES:=totalSupply \
            balanceOf \
            allowance \
            approve \
            transfer-success-1 \
            transfer-success-2 \
            transfer-failure-1-a \
            transfer-failure-1-b \
            transfer-failure-2

include ../../resources/kprove.mak
