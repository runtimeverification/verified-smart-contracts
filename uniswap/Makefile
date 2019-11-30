# Hack to have specs/uniswap/lemmas.k separate from specs/lemmas.k
SPEC_GROUP:=uniswap/uniswap

KEVM_VERSION_FILE:=.build/.kevm.rev

LOCAL_LEMMAS:=abstract-semantics.k verification.k
TMPLS:=module-tmpl.k spec-tmpl.k

SPEC_NAMES:=addLiquidity-1 \
            addLiquidity-2 \
            removeLiquidity \
            ethToTokenSwapInput \
            ethToTokenSwapOutput

include ../resources/kprove.mak

$(SPECS_DIR)/lemmas.k: lemmas.md $(TANGLER)
	pandoc --from markdown --to "$(TANGLER)" --metadata=code:".k" $< > $@
