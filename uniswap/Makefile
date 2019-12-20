# Hack to have specs/uniswap/lemmas.k separate from specs/lemmas.k
SPEC_GROUP:=uniswap/uniswap

KEVM_VERSION_FILE:=.build/.kevm.rev

BASEDIR_LEMMAS:=lemmas.md
LOCAL_LEMMAS:=abstract-semantics.k verification.k
TMPLS:=module-tmpl.k spec-tmpl.k

SPEC_NAMES:=addLiquidity-1 \
            addLiquidity-2 \
            removeLiquidity \
            ethToTokenSwapInput \
            ethToTokenSwapOutput

override KEVM_BUILD_DIR=$(KEVM_REPO_DIR)/.build/$(K_BACKEND)

include ../resources/kprove.mak
