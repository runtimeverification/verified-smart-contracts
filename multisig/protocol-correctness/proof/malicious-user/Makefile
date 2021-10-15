include ../settings.mak

.PHONY: default
default: all ;

SCRIPT_DIR=..

PROOF_DIR := ..
include ../proof-dependency.mak

# MAP_DIR := ../map
# include $(MAP_DIR)/map.mak

INVARIANT_DIR := ../invariant
include $(INVARIANT_DIR)/invariant.mak

MALICIOUS_USER_DIR := .
include malicious-user.mak

.PHONY: all clean execution

all: out/malicious-user.proof.timestamp

execution: out/malicious-user.execution.timestamp

clean: malicious-user.clean
