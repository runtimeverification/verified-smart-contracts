BUILD_DIR:=../gnosis/.build

LOCAL_LEMMAS:=../gnosis/abstract-semantics.k ../gnosis/verification.k
TMPLS:=../gnosis/module-tmpl.k ../gnosis/spec-tmpl.k

SPEC_GROUP:=gnosis-imap
SPEC_INI:=gnosis-imap-spec.ini

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/../gnosis/evm.smt2) \
             --deterministic-functions --cache-func-optimized

SPEC_NAMES:=encodeTransactionData-1 \
            encodeTransactionData-2 \
            signatureSplit-proof \
            removeOwner-success-1 \
            removeOwner-success-2 \
            removeOwner-failure-1-a \
            removeOwner-failure-1-b \
            removeOwner-failure-2 \

include ../resources/kprove.mak
