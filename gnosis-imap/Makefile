BUILD_DIR:=../gnosis/.build

LOCAL_LEMMAS:=../gnosis/abstract-semantics.k ../gnosis/verification.k
TMPLS:=../gnosis/module-tmpl.k ../gnosis/spec-tmpl.k

SPEC_GROUP:=gnosis-imap
SPEC_INI:=gnosis-imap-spec.ini

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/../gnosis/evm.smt2)

SPEC_NAMES:=encodeTransactionData

include ../resources/kprove.mak
