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
                        checkSignatures-success \
                        checkSignatures-failure-1 \
                        checkSignatures-failure-2 \
                        checkSignatures-loop-success \
                        checkSignatures-loop-failure \
                        checkSignatures-loop-body-success-v1-owner \
                        checkSignatures-loop-body-success-v1-not-owner \
                        checkSignatures-loop-body-failure-v1-owner \
                        checkSignatures-loop-body-failure-v1-not-owner-approved \
                        checkSignatures-loop-body-failure-v1-not-owner-not-approved \
                        checkSignatures-loop-body-success-v_else \
                        checkSignatures-loop-body-failure-v_else-ecrecEmpty \
                        checkSignatures-loop-body-failure-v_else-not-ecrecEmpty \
                        execTransaction-checkSigs1-gas1-safetxgas0-gasprice0-call1-to \
                        execTransaction-checkSigs1-gas1-safetxgas1-call1-to-gasprice1-send1-origin

SPEC_NAMES_OWNER_MANAGER:=addOwnerWithThreshold-success-1 \
                          addOwnerWithThreshold-success-2 \
                          addOwnerWithThreshold-failure-1-a \
                          addOwnerWithThreshold-failure-1-b \
                          addOwnerWithThreshold-failure-2 \
                          addOwnerWithThreshold-failure-3-a \
                          addOwnerWithThreshold-failure-3-b \
                          removeOwner-success-1 \
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

$(SPECS_DIR)/$(SPEC_GROUP)/execTransaction-checkSigs1-gas1-safetxgas0-gasprice0-call1-to-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) execTransaction-checkSigs1-gas1-safetxgas0-gasprice0-call1-to encodeTransactionData-internal-trusted checkSignatures_dummy execTransaction-checkSigs1-gas1-safetxgas0-gasprice0-call1-to > $@

$(SPECS_DIR)/$(SPEC_GROUP)/execTransaction-checkSigs1-gas1-safetxgas1-call1-to-gasprice1-send1-origin-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) execTransaction-checkSigs1-gas1-safetxgas1-call1-to-gasprice1-send1-origin encodeTransactionData-internal-trusted checkSignatures_dummy handlePayment-send-success-origin-trusted execTransaction-checkSigs1-gas1-safetxgas1-call1-to-gasprice1-send1-origin > $@

# Identical execution path with execution path of encodeTransactionData-public, so no point to activate it.
$(SPECS_DIR)/$(SPEC_GROUP)/getTransactionHash-1-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) getTransactionHash-1 encodeTransactionData-internal-trusted getTransactionHash-1 > $@

$(SPECS_DIR)/$(SPEC_GROUP)/getTransactionHash-2-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) getTransactionHash-2 encodeTransactionData-internal-trusted getTransactionHash-2 > $@


$(SPECS_DIR)/$(SPEC_GROUP)/checkSignatures-success-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) checkSignatures-success checkSignatures-loop-success-trusted checkSignatures-success > $@

$(SPECS_DIR)/$(SPEC_GROUP)/checkSignatures-failure-1-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) checkSignatures-failure-1 checkSignatures-loop-failure-trusted checkSignatures-failure-1 > $@

$(SPECS_DIR)/$(SPEC_GROUP)/checkSignatures-failure-2-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) checkSignatures-failure-2 checkSignatures-loop-failure-trusted checkSignatures-failure-2 > $@

$(SPECS_DIR)/$(SPEC_GROUP)/checkSignatures-loop-success-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) checkSignatures-loop-success signatureSplit-trusted checkSignatures-loop-body-success-trusted checkSignatures-loop-success > $@

$(SPECS_DIR)/$(SPEC_GROUP)/checkSignatures-loop-failure-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) checkSignatures-loop-failure signatureSplit-trusted checkSignatures-loop-body-success-trusted checkSignatures-loop-body-failure-trusted checkSignatures-loop-failure-now checkSignatures-loop-failure-later checkSignatures-loop-failure-trusted > $@

$(SPECS_DIR)/$(SPEC_GROUP)/checkSignatures-loop-body-success-v1-owner-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) checkSignatures-loop-body-success-v1-owner signatureSplit-trusted checkSignatures-loop-body-success-v1-owner > $@

$(SPECS_DIR)/$(SPEC_GROUP)/checkSignatures-loop-body-success-v1-not-owner-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) checkSignatures-loop-body-success-v1-not-owner signatureSplit-trusted checkSignatures-loop-body-success-v1-not-owner > $@

$(SPECS_DIR)/$(SPEC_GROUP)/checkSignatures-loop-body-failure-v1-owner-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) checkSignatures-loop-body-failure-v1-owner signatureSplit-trusted checkSignatures-loop-body-failure-v1-owner > $@

$(SPECS_DIR)/$(SPEC_GROUP)/checkSignatures-loop-body-failure-v1-not-owner-approved-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) checkSignatures-loop-body-failure-v1-not-owner-approved signatureSplit-trusted checkSignatures-loop-body-failure-v1-not-owner-approved > $@

$(SPECS_DIR)/$(SPEC_GROUP)/checkSignatures-loop-body-failure-v1-not-owner-not-approved-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) checkSignatures-loop-body-failure-v1-not-owner-not-approved signatureSplit-trusted checkSignatures-loop-body-failure-v1-not-owner-not-approved > $@

$(SPECS_DIR)/$(SPEC_GROUP)/checkSignatures-loop-body-success-v_else-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) checkSignatures-loop-body-success-v_else signatureSplit-trusted checkSignatures-loop-body-success-v_else > $@

$(SPECS_DIR)/$(SPEC_GROUP)/checkSignatures-loop-body-failure-v_else-ecrecEmpty-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) checkSignatures-loop-body-failure-v_else-ecrecEmpty signatureSplit-trusted checkSignatures-loop-body-failure-v_else-ecrecEmpty > $@

$(SPECS_DIR)/$(SPEC_GROUP)/checkSignatures-loop-body-failure-v_else-not-ecrecEmpty-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) checkSignatures-loop-body-failure-v_else-not-ecrecEmpty signatureSplit-trusted checkSignatures-loop-body-failure-v_else-not-ecrecEmpty > $@
