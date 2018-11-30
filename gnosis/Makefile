BUILD_DIR:=../.build

SPEC_GROUP:=gnosis
SPEC_INI:=gnosis-spec.ini

KPROVE_OPTS:=--log-basic

SPEC_NAMES:=encodeTransactionData-data32 \
            encodeTransactionData-data33 \
            signatureSplit-pos0 \
            signatureSplit-pos1 \
            signatureSplit-pos2 \
            checkSignatures-threshold-too-large \
            checkSignatures-threshold-1-sigv-2-empty \
            checkSignatures-threshold-1-sigv-2-ne-success \
            checkSignatures-threshold-1-sigv-2-ne-notOwner

include ../resources/kprove.mak
