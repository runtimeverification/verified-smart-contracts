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

PROPERTIES_DIR := properties
include properties/properties.mak

.PHONY: all invariant map properties clean

all: invariant map properties

invariant: $(INVARIANT_OUT_PREFIX)proof.timestamp

map: $(MAP_OUT_PREFIX)proof.timestamp

properties: $(PROPERTIES_OUT_PREFIX)proof.timestamp

clean: invariant.clean map.clean properties.clean
