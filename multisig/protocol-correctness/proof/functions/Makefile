include ../settings.mak

.PHONY: default
default: all ;

SCRIPT_DIR = ..

PROOF_DIR = ..
include $(PROOF_DIR)/proof-dependency.mak

FUNCTIONS_DIR = .
include functions.mak

.PHONY: all clean execution

all: $(FUNCTIONS_OUT_PREFIX)proof.timestamp

execution: $(FUNCTIONS_OUT_PREFIX)execution.timestamp $(FUNCTIONS_OUT_PREFIX)trusted.timestamp

clean: functions.clean
