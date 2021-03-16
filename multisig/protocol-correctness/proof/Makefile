include settings.mak

.PHONY: default
default: all ;

SCRIPT_DIR=.

PROOF_DIR := .
include proof-dependency.mak

MAP_DIR := map
include map/map.mak

INVARIANT_DIR := invariant
include invariant/invariant.mak

.PHONY: all invariant map clean

all: invariant map

invariant: $(INVARIANT_OUT_PREFIX)proof.timestamp

map: $(MAP_OUT_PREFIX)proof.timestamp

clean: invariant.clean map.clean
