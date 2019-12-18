#BUILD_DIR:=../.build

LOCAL_LEMMAS:=verification.k \
			  ../../resources/abstract-semantics-segmented-gas.k \
			  ../../resources/evm-symbolic.k \
			  ../../resources/evm-data-map-concrete-buf.k
TMPLS:=../module-tmpl.k spec-tmpl.k

SPEC_NAMES:=totalSupply-success \
            totalSupply-failure \
            balanceOf-success \
            balanceOf-failure \
            allowance-success \
            allowance-failure \
            approve-success \
            approve-failure \
            transfer-success-1 \
            transfer-success-2 \
            transfer-failure-1 \
            transfer-failure-2 \
            transfer-failure-3 \
            transferFrom-success-1 \
            transferFrom-success-2 \
            transferFrom-failure-1 \
            transferFrom-failure-2 \
            transferFrom-failure-3

include ../../resources/kprove.mak
