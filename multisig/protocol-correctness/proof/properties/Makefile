include ../settings.mak

.PHONY: default
default: all ;

SCRIPT_DIR=..

PROOF_DIR := ..
include ../proof-dependency.mak

MAP_DIR := ../map
include $(MAP_DIR)/map.mak

INVARIANT_DIR := ../invariant
include $(INVARIANT_DIR)/invariant.mak

PROPERTIES_DIR := .
include properties.mak

.PHONY: all clean execution

all: out/properties.proof.timestamp

execution: out/properties.execution.timestamp

clean: properties.clean
