include ../settings.mak

.PHONY: default
default: all ;

SCRIPT_DIR=..

MAP_DIR := .
include map.mak

.PHONY: all clean execution

all: .out/map.proof.timestamp

execution: .out/map.execution.timestamp

clean: map.clean
