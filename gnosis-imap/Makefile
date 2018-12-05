BUILD_DIR:=.build

LOCAL_LEMMAS:=../gnosis/abstract-semantics.k ../gnosis/test/verification.k
TMPLS:=../gnosis/module-tmpl.k ../gnosis/test/spec-tmpl.k

SPEC_GROUP:=gnosis-imap
SPEC_INI:=gnosis-imap-spec.ini

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(THIS_FILE))/../gnosis/evm.smt2)

SPEC_NAMES:=encodeTransactionData

include ../resources/kprove.mak
