BUILD_DIR:=../gnosis/.build

LOCAL_LEMMAS:=../gnosis/abstract-semantics.k ../gnosis/verification.k
TMPLS:=../gnosis/module-tmpl.k ../gnosis/spec-tmpl.k

SPEC_GROUP:=gnosis-imap
SPEC_INI:=gnosis-imap-spec.ini

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/../gnosis/evm.smt2) \
             --deterministic-functions --cache-func-optimized

SPEC_NAMES_GNOSIS_SAFE:=encodeTransactionData-public-1 \
                        encodeTransactionData-public-2 \
                        encodeTransactionData-internal-proof-1 \
                        encodeTransactionData-internal-proof-2 \
                        signatureSplit-proof \
                        handlePayment-arithmetic-overflow-1 \
                        handlePayment-arithmetic-overflow-2 \
                        handlePayment-send-success-origin \
                        handlePayment-send-success-receiver \
                        handlePayment-send-failure-origin \
                        handlePayment-send-failure-receiver \

SPEC_NAMES_OWNER_MANAGER:=removeOwner-success-1 \
                          removeOwner-success-2 \
                          removeOwner-failure-1-a \
                          removeOwner-failure-1-b \
                          removeOwner-failure-2 \
                          swapOwner-success \
                          swapOwner-failure-1 \
                          swapOwner-failure-2 \

SPEC_NAMES_MODULE_MANAGER:=enableModule-success \
                           enableModule-failure-1 \
                           enableModule-failure-2 \
                           disableModule-success \
                           disableModule-failure-1 \
                           disableModule-failure-2 \
                           execTransactionFromModule-failure \

SPEC_NAMES_MASTER_COPY:=changeMasterCopy-success \
                        changeMasterCopy-failure-1 \
                        changeMasterCopy-failure-2 \

SPEC_NAMES:=$(SPEC_NAMES_GNOSIS_SAFE) \
            $(SPEC_NAMES_OWNER_MANAGER) \
            $(SPEC_NAMES_MODULE_MANAGER) \
            $(SPEC_NAMES_MASTER_COPY)

include ../resources/kprove.mak

# non-standard spec generation

$(SPECS_DIR)/$(SPEC_GROUP)/encodeTransactionData-public-1-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) encodeTransactionData-public-1 encodeTransactionData-internal-trusted encodeTransactionData-public-1 > $@

$(SPECS_DIR)/$(SPEC_GROUP)/encodeTransactionData-public-2-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) encodeTransactionData-public-2 encodeTransactionData-internal-trusted encodeTransactionData-public-2 > $@

# Identical execution path with execution path of encodeTransactionData-public, so no point to activate it.
$(SPECS_DIR)/$(SPEC_GROUP)/getTransactionHash-1-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) getTransactionHash-1 encodeTransactionData-internal-trusted getTransactionHash-1 > $@

$(SPECS_DIR)/$(SPEC_GROUP)/getTransactionHash-2-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) getTransactionHash-2 encodeTransactionData-internal-trusted getTransactionHash-2 > $@
