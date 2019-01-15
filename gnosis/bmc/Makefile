BUILD_DIR:=.build

LOCAL_LEMMAS:=abstract-semantics.k verification.k
TMPLS:=module-tmpl.k spec-tmpl.k

SPEC_GROUP:=gnosis
SPEC_INI:=gnosis-spec.ini

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/evm.smt2) \
             --deterministic-functions --cache-func-optimized

SPEC_NAMES:=encodeTransactionData \
            signatureSplit \
            checkSignatures-thres-too-large \
            checkSignatures-thres-1-sig-v0 \
            checkSignatures-thres-1-sig-v2-ec0 \
            checkSignatures-thres-1-sig-v2-not-ec0-success \
            checkSignatures-thres-1-sig-v2-not-ec0-notOwner \
            checkSignatures-thres-2-sig-v2-ec0 \
            checkSignatures-thres-2-sig-v2-o0-eq-o1 \
            checkSignatures-thres-2-sig-v2-o0-neq-o1-success \
            checkSignatures-thres-2-sig-v2-o0-neq-o1-failure

include ../resources/kprove.mak
