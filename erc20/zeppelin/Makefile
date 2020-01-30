KEVM_VERSION_FILE:=../.build/.kevm.rev

# Required to have different lemmas dir from non-#buf ERC20 specs.
SPEC_GROUP:=erc20/buf/zeppelin

BASEDIR_LEMMAS=$(RESOURCES)/lemmas-buf.md
LOCAL_LEMMAS:=../verification.k \
			  ../../resources/abstract-semantics-segmented-gas.k \
			  ../../resources/evm-symbolic.k \
			  ../evm-data-map-symbolic.k
TMPLS:=../module-tmpl.k ../spec-tmpl.k

KPROVE_OPTS=--smt-prelude $(RESOURCES)/evm.smt2

SPEC_NAMES:=totalSupply \
            balanceOf \
            allowance \
            approve \
            transfer-success-1 \
            transfer-success-2 \
            transfer-failure-1-a \
            transfer-failure-1-b \
            transfer-failure-2 \
            transferFrom-success-1 \
            transferFrom-success-2 \
            transferFrom-failure-1-a \
            transferFrom-failure-1-b \
            transferFrom-failure-2

include ../../resources/kprove.mak
