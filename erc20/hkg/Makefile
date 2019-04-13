BUILD_DIR:=../.build

LOCAL_LEMMAS:=verification.k \
			  ../../resources/evm-symbolic.k ../../resources/abstract-semantics-common.k
TMPLS:=../module-tmpl.k ../spec-tmpl.k

SPEC_GROUP:=hkg-erc20
SPEC_INI:=hkg-erc20-spec.ini

SPEC_NAMES:=totalSupply \
            balanceOf \
            allowance \
            approve \
            transfer-success-1 \
            transfer-success-2 \
            transfer-failure-1 \
            transfer-failure-2 \
            transferFrom-success-1 \
            transferFrom-success-2 \
            transferFrom-failure-1 \
            transferFrom-failure-2

include ../../resources/kprove.mak
