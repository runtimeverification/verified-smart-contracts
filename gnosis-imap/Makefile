BUILD_DIR:=../gnosis/.build

LOCAL_LEMMAS:=../gnosis/abstract-semantics.k ../gnosis/verification.k
TMPLS:=../gnosis/module-tmpl.k ../gnosis/spec-tmpl.k

SPEC_GROUP:=gnosis-imap
SPEC_INI:=gnosis-imap-spec.ini

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/../gnosis/evm.smt2) \
             --deterministic-functions --cache-func-optimized

SPEC_NAMES_GNOSIS_SAFE:=encodeTransactionData-1 \
                        encodeTransactionData-2 \
                        signatureSplit-proof \
                        handlePayment-arithmetic-overflow-1 \
                        handlePayment-arithmetic-overflow-2 \
                        handlePayment-send-success-origin \
                        handlePayment-send-success-receiver \

SPEC_NAMES_OWNER_MANAGER:=removeOwner-success-1 \
                          removeOwner-success-2 \
                          removeOwner-failure-1-a \
                          removeOwner-failure-1-b \
                          removeOwner-failure-2 \

SPEC_NAMES_MODULE_MANAGER:=disableModule-success \
                           disableModule-failure-1 \
                           disableModule-failure-2 \

SPEC_NAMES:=$(SPEC_NAMES_GNOSIS_SAFE) \
            $(SPEC_NAMES_OWNER_MANAGER) \
            $(SPEC_NAMES_MODULE_MANAGER)

include ../resources/kprove.mak
