#BUILD_DIR:=../erc20/.build

SPEC_INI:=forwardToHotWallet-spec.ini

SPEC_NAMES:=collectToken \
            forwardToHotWallet-success-1 \
            forwardToHotWallet-success-2 \
            forwardToHotWallet-failure-1 \
            forwardToHotWallet-failure-2 \
            forwardToHotWallet-failure-3 \
            forwardToHotWallet-failure-4

include ../resources/kprove.mak

COLLECTION_TOKEN_INI:=collectToken-spec.ini

# non-standard spec generation
$(SPECS_DIR)/$(SPEC_GROUP)/collectToken-spec.k: $(TMPLS) $(COLLECTION_TOKEN_INI) $(LEMMAS)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(COLLECTION_TOKEN_INI) collectToken collectToken loop ds-math-mul > $@
