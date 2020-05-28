K_VERSION_FILE:=.build/.k.rev
KEVM_VERSION_FILE:=.build/.kevm.rev

LOCAL_LEMMAS:=verification.k \
              abstract-semantics.k \
              lemmas.k
TMPLS:=module-tmpl.k spec-tmpl.k

SPEC_GROUP:=deposit
SPEC_INI:=deposit-spec.ini

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/evm.smt2) \
             --branching-allowed 0 \
             --z3-cnstr-timeout 100

SPEC_NAMES:=

SPEC_NAMES += init-success
SPEC_NAMES += init-revert

SPEC_NAMES += get_deposit_root-success
SPEC_NAMES += loop-get_deposit_root
SPEC_NAMES += get_deposit_root-revert

SPEC_NAMES += get_deposit_count-success
SPEC_NAMES += get_deposit_count-revert

SPEC_NAMES += deposit-success
SPEC_NAMES += loop-deposit

SPEC_NAMES += deposit-revert-1
SPEC_NAMES += deposit-revert-2
SPEC_NAMES += deposit-revert-3
SPEC_NAMES += deposit-revert-4
SPEC_NAMES += deposit-revert-5

SPEC_NAMES += deposit-calldata-decoding-success
SPEC_NAMES += deposit-calldata-decoding-revert

SPEC_NAMES += deposit-calldata-decoding-revert-1
SPEC_NAMES += deposit-calldata-decoding-revert-2
SPEC_NAMES += deposit-calldata-decoding-revert-3
SPEC_NAMES += deposit-calldata-decoding-revert-4
SPEC_NAMES += deposit-calldata-decoding-revert-5
SPEC_NAMES += deposit-calldata-decoding-revert-6

SPEC_NAMES += revert-invalid_function_identifier-lt_4
SPEC_NAMES += revert-invalid_function_identifier-ge_4

export K_OPTS=-Xmx16g

include ../../resources/kprove.mak

# non-standard spec generation

$(SPECS_DIR)/$(SPEC_GROUP)/get_deposit_root-success-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) get_deposit_root-success loop-get_deposit_root-trusted get_deposit_root-success > $@

$(SPECS_DIR)/$(SPEC_GROUP)/deposit-success-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) deposit-success loop-deposit-trusted deposit-success > $@
