#
# VSC-wide Settings
#

# path to this file
THIS_FILE:=$(abspath $(lastword $(MAKEFILE_LIST)))
# path to root directory
ROOT:=$(abspath $(dir $(THIS_FILE))/..)

RESOURCES:=$(ROOT)/resources
SPECS_DIR:=$(ROOT)/specs

#
# Parameters
#

# path to a directory that contains .k.rev and .kevm.rev
BUILD_DIR?=$(ROOT)/.build

# check if the build directory exists (note: $(wildcard $(BUILD_DIR)) is not enough since it doesn't check if it is a directory)
ifeq ($(wildcard $(BUILD_DIR)/.),)
$(error BUILD_DIR does not exist)
endif

K_REPO_URL?=https://github.com/kframework/k
KEVM_REPO_URL?=https://github.com/kframework/evm-semantics

# Current dir path suffix after $(ROOT), if $(ROOT) is prefix of $(CURDIR)
SPEC_GROUP?=$(strip $(patsubst $(ROOT)/%, %, $(filter $(ROOT)/%, $(CURDIR))))
ifndef SPEC_GROUP
$(error SPEC_GROUP is not set)
endif

SPEC_INI?=$(strip $(wildcard *-spec.ini))
ifneq ($(words $(SPEC_INI)), 1)
$(error SPEC_INI should have 1 element. Actual value: $(SPEC_INI))
endif

ifndef SPEC_NAMES
$(error SPEC_NAMES is not set)
endif

LOCAL_LEMMAS?=../resources/abstract-semantics-direct-gas.k ../resources/evm-direct-gas.k \
              ../resources/evm-data-map-concrete.k verification.k
TMPLS?=module-tmpl.k spec-tmpl.k

# additional options to kprove command
KPROVE_OPTS?=
KPROVE_OPTS+=$(EXT_KPROVE_OPTS)

# Define variable DEBUG to enable debug options below
# DEBUG=true
ifdef DEBUG
KPROVE_OPTS+=--debug-z3-queries --log-rules
endif

# Example: 10ms/10s/10m/10h
TIMEOUT?=
# Above format
SHUTDOWN_WAIT_TIME?=5s

#
# Settings
#

K_VERSION_FILE   :=$(BUILD_DIR)/.k.rev
KEVM_VERSION_FILE:=$(BUILD_DIR)/.kevm.rev
K_VERSION        :=$(shell cat $(K_VERSION_FILE))
KEVM_VERSION     :=$(shell cat $(KEVM_VERSION_FILE))

K_REPO_DIR:=$(abspath $(BUILD_DIR)/k)
KEVM_REPO_DIR:=$(abspath $(BUILD_DIR)/evm-semantics)

K_BIN:=$(abspath $(K_REPO_DIR)/k-distribution/target/release/k/bin)

ifneq ($(SHUTDOWN_WAIT_TIME),)
  SHUTDOWN_WAIT_TIME_OPT:=--shutdown-wait-time $(SHUTDOWN_WAIT_TIME)
endif

ifneq ($(TIMEOUT),)
  TIMEOUT_OPT:=--timeout $(TIMEOUT)
endif

KPROVE:=$(K_BIN)/kprove -v --debug -d $(KEVM_REPO_DIR)/.build/defn/java -m VERIFICATION \
        --z3-impl-timeout 500 $(SHUTDOWN_WAIT_TIME_OPT) $(TIMEOUT_OPT) \
        --deterministic-functions --no-exc-wrap \
        --cache-func-optimized --no-alpha-renaming --format-failures --boundary-cells k,pc \
        --log-cells k,output,statusCode,localMem,pc,gas,wordStack,callData,accounts,memoryUsed,\#pc,\#result \
        $(KPROVE_OPTS)

SPEC_FILES:=$(patsubst %,$(SPECS_DIR)/$(SPEC_GROUP)/%-spec.k,$(SPEC_NAMES))
LEMMAS:=$(SPECS_DIR)/$(SPEC_GROUP)/lemmas.timestamp $(dir $(SPECS_DIR)/$(SPEC_GROUP))/lemmas.k

PANDOC_TANGLE_SUBMODULE:=$(ROOT)/.build/pandoc-tangle
TANGLER:=$(PANDOC_TANGLE_SUBMODULE)/tangle.lua
LUA_PATH:=$(PANDOC_TANGLE_SUBMODULE)/?.lua;;
export TANGLER
export LUA_PATH

#
# Dependencies
#

.PHONY: all clean clean-deps clean-k clean-kevm clean-kevm-cache deps deps-tangle deps-k deps-kevm split-proof-tests test

all: deps split-proof-tests

clean:
	rm -rf $(SPECS_DIR)

clean-deps: clean clean-k clean-kevm
clean-k:
	rm -rf $(K_REPO_DIR)
clean-kevm:
	rm -rf $(KEVM_REPO_DIR)
clean-kevm-cache:
	rm -rf $(KEVM_REPO_DIR)/.build/defn/java/driver-kompiled/cache.bin

deps: deps-tangle deps-k deps-kevm
deps-tangle: $(PANDOC_TANGLE_SUBMODULE)/submodule.timestamp
deps-k:      $(K_REPO_DIR)/mvn.timestamp
deps-kevm:   $(KEVM_REPO_DIR)/make.timestamp

%/submodule.timestamp:
	git submodule update --init --recursive -- $*
	touch $@

$(K_REPO_DIR)/mvn.timestamp: $(K_VERSION_FILE) | $(K_REPO_DIR)
	cd $(K_REPO_DIR) \
		&& git fetch \
		&& git reset --hard $(K_VERSION) \
		&& git submodule update --init --recursive \
		&& mvn package -DskipTests -Dllvm.backend.skip -Dhaskell.backend.skip
	touch $@

$(K_REPO_DIR):
	git clone $(K_REPO_URL) $(K_REPO_DIR)

$(KEVM_REPO_DIR)/make.timestamp: $(KEVM_VERSION_FILE) $(K_REPO_DIR)/mvn.timestamp | $(KEVM_REPO_DIR)
	cd $(KEVM_REPO_DIR) \
		&& git fetch \
		&& git clean -fdx \
		&& git reset --hard $(KEVM_VERSION) \
		&& make tangle-deps \
		&& make defn \
		&& $(K_BIN)/kompile -v --debug --backend java -I .build/defn/java -d .build/defn/java --main-module ETHEREUM-SIMULATION --syntax-module ETHEREUM-SIMULATION .build/defn/java/driver.k
	touch $@

$(KEVM_REPO_DIR):
	git clone $(KEVM_REPO_URL) $(KEVM_REPO_DIR)

#
# Specs
#

# makes all these files non-intermediary
split-proof-tests: $(SPEC_FILES) $(LEMMAS)

$(SPECS_DIR)/$(SPEC_GROUP)/lemmas.timestamp: $(LOCAL_LEMMAS)
	mkdir -p $(SPECS_DIR)/$(SPEC_GROUP)
ifneq ($(strip $(LOCAL_LEMMAS)),)
	cp $(LOCAL_LEMMAS) $(SPECS_DIR)/$(SPEC_GROUP)
endif
	touch $@

ifneq ($(wildcard $(SPEC_INI:.ini=.md)),)
$(SPEC_INI): $(SPEC_INI:.ini=.md) $(PANDOC_TANGLE_SUBMODULE)/submodule.timestamp
	pandoc --from markdown --to "$(TANGLER)" --metadata=code:".ini" $< > $@
endif

%/lemmas.k: $(RESOURCES)/lemmas.md $(PANDOC_TANGLE_SUBMODULE)/submodule.timestamp
	pandoc --from markdown --to "$(TANGLER)" --metadata=code:".k" $< > $@

# When building a -spec.k file, build all run dependencies.
$(SPECS_DIR)/$(SPEC_GROUP)/%-spec.k: $(TMPLS) $(SPEC_INI) $(LEMMAS)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) $* $* > $@

#
# Kprove
#

test: $(addsuffix .test,$(SPEC_FILES))

$(SPECS_DIR)/$(SPEC_GROUP)/%-spec.k.test: $(SPECS_DIR)/$(SPEC_GROUP)/%-spec.k
	$(KPROVE) $<
