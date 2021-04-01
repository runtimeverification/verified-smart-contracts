include settings.mak

.PHONY: default
default: all ;

SCRIPT_DIR=.

PROOF_DIR := .
include proof-dependency.mak

MAP_DIR := map
include map/map.mak

FUNCTIONS_DIR := functions
include functions/functions.mak

INVARIANT_DIR := invariant
include invariant/invariant.mak

PROPERTIES_DIR := properties
include properties/properties.mak

.PHONY: all functions invariant map properties clean

all: functions invariant map properties

functions: $(FUNCTIONS_OUT_PREFIX)proof.timestamp

invariant: $(INVARIANT_OUT_PREFIX)proof.timestamp

map: $(MAP_OUT_PREFIX)proof.timestamp

properties: $(PROPERTIES_OUT_PREFIX)proof.timestamp

clean: functions.clean invariant.clean map.clean properties.clean
	rm -r *-kompiled
	rm -r out
