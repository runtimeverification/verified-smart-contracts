#BUILD_DIR:=../.build

LOCAL_LEMMAS:=verification.k \
			  ../../resources/abstract-semantics-segmented-gas.k \
			  ../../resources/evm-symbolic.k \
			  ../../resources/evm-data-map-concrete.k
TMPLS:=../module-tmpl.k ../spec-tmpl.k

SPEC_NAMES:=totalSupply \
            balanceOf \
            allowance \
            approve-success \
            approve-failure \
            transfer-success-1 \
            transfer-success-2 \
            transfer-failure-1-a \
            transfer-failure-1-b \
            transfer-failure-1-c \
            transfer-failure-2-a \
            transfer-failure-2-b \
            transferFrom-success-1 \
            transferFrom-success-2 \
            transferFrom-failure-1-a \
            transferFrom-failure-1-b \
            transferFrom-failure-1-c \
            transferFrom-failure-1-d \
            transferFrom-failure-2-a \
            transferFrom-failure-2-b \
            transferFrom-failure-2-c

include ../../resources/kprove.mak
