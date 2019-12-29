THIS_FILE_DIR:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))

#
# Parameters

NPROCS?=2
TIMEOUT?=
FRAGMENT_INI_DIR?=$(abspath $(THIS_FILE_DIR)/../fragments)
KPROVE_MAK_FILE?=$(LOCAL_RESOURCES_DIR)/kprove-erc20.mak

#
# Settings

# java or haskell
K_BACKEND?=java

LOCAL_RESOURCES_DIR:=$(THIS_FILE_DIR)
ROOT:=$(abspath $(THIS_FILE_DIR)/../../..)
RELATIVE_CURDIR:=$(strip $(patsubst $(ROOT)/%, %, $(filter $(ROOT)/%, $(CURDIR))))
SPECS_DIR:=$(ROOT)/specs/$(K_BACKEND)
FRAGMENT_INI_FILES:=$(sort $(wildcard $(FRAGMENT_INI_DIR)/*.ini))
MAIN_INI_FILES:=$(sort $(wildcard *.ini))
SPEC_INI_FILES:=$(patsubst %.ini, $(SPECS_DIR)/$(RELATIVE_CURDIR)/%/erc20-spec.ini, $(MAIN_INI_FILES))

#
# Tasks

.PHONY: test concat split-proof-tests clean deps clean-deps

test: $(SPEC_INI_FILES:=.test)

# Makes $(SPEC_INI_FILES) non-intermediary
concat: $(SPEC_INI_FILES)

split-proof-tests: $(SPEC_INI_FILES:=.split-proof-tests)

clean:
	rm -rf $(SPECS_DIR)

deps:
	$(MAKE) -f $(KPROVE_MAK_FILE) deps SPEC_GROUP=resources SPEC_INI=mock.ini

clean-deps:
	$(MAKE) -f $(KPROVE_MAK_FILE) clean-deps SPEC_GROUP=resources SPEC_INI=mock.ini

.SECONDEXPANSION:
$(SPECS_DIR)/%/erc20-spec.ini: $$(notdir $$*).ini $(FRAGMENT_INI_FILES)
	mkdir -p $(dir $@)
	cat $(FRAGMENT_INI_FILES) $(CURDIR)/$(notdir $*).ini > $@

# Calling "clean-kevm-cache all" here leads to very long parse times on Jenkins, 30m+ on some specs, doesn't finish in 12+ hours.
$(SPECS_DIR)/%/erc20-spec.ini.split-proof-tests: $(SPECS_DIR)/%/erc20-spec.ini
	$(MAKE) -f $(KPROVE_MAK_FILE) all  SPEC_GROUP=$* SPEC_INI=$(basename $@)

$(SPECS_DIR)/%/erc20-spec.ini.test: $(SPECS_DIR)/%/erc20-spec.ini.split-proof-tests
	$(MAKE) -f $(KPROVE_MAK_FILE) test SPEC_GROUP=$* SPEC_INI=$(basename $@) TIMEOUT=$(TIMEOUT) -i -j$(NPROCS)

# Command to run just one spec. Argument: <absolute path to k>.test
# patsubst below needed because $(dir ...) leaves a trailing slash.
# TODO define function mydir - same as dir but without trailing slash
.SECONDEXPANSION:
$(SPECS_DIR)/%-spec.k.test: $$(dir $$@)erc20-spec.ini
	$(MAKE) -f $(KPROVE_MAK_FILE) $@ SPEC_GROUP=$(patsubst %/,%,$(dir $*)) SPEC_INI=$(dir $@)erc20-spec.ini TIMEOUT=$(TIMEOUT)
