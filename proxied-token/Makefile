BUILD_DIR:=../.build

SPEC_GROUP:=proxied-token
SPEC_INI:=proxied-token-spec.ini

SPEC_NAMES:=changeMasterCopy-failure-3

KPROVE_OPTS+=--debug-z3-queries --log-rules --log-cells k,output,statusCode,localMem,pc,gas,wordStack,callData,accounts,#pc,#result,memoryUsed

include ../resources/kprove.mak
