include settings.mak

.PHONY: default
default: all ;

SCRIPT_DIR=.

PROOF_DIR := .
include proof-dependency.mak

INVARIANT_DIR := invariant
include invariant/invariant.mak

.PHONY: all invariant clean

all: invariant

invariant: $(INVARIANT_OUT_PREFIX)proof.timestamp

clean: invariant.clean
