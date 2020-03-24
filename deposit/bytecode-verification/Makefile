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

SPEC_NAMES:=init-success \
            init-revert \
            to_little_endian_64 \
            get_deposit_root-success-loop1-then \
            get_deposit_root-success-loop1-else \
            get_deposit_root-success-loop-body-then \
            get_deposit_root-success-loop-body-else \
            get_deposit_root-success-loop-exit \
            get_deposit_root-revert \
            get_deposit_count-success \
            get_deposit_count-revert \
            deposit-init \
            deposit-subcall_1 \
            deposit-subcall_2 \
            deposit-log \
            deposit-data \
            deposit-add-init-then \
            deposit-add-init-else \
            deposit-add-loop-enter-then \
            deposit-add-loop-enter-else \
            deposit-add-loop-exit \
            deposit-init-calldata \
            deposit-init-calldata-revert-1 \
            deposit-init-calldata-revert-2 \
            deposit-init-calldata-revert-3 \
            deposit-init-calldata-revert-4 \
            deposit-init-calldata-revert-5 \
            deposit-init-calldata-revert-6 \
            deposit-init-revert-1 \
            deposit-init-revert-2 \
            deposit-data-revert \
            revert-invalid_function_identifier-lt_4 \
            revert-invalid_function_identifier-ge_4-lt_32 \
            revert-invalid_function_identifier-ge_4-ge_32

include ../../resources/kprove.mak

# non-standard spec generation

$(SPECS_DIR)/$(SPEC_GROUP)/deposit-subcall_1-spec.k: $(TMPLS) $(SPEC_INI) $(LEMMAS)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) deposit-subcall_1            to_little_endian_64-trusted deposit-subcall_1            > $@

$(SPECS_DIR)/$(SPEC_GROUP)/deposit-subcall_2-spec.k: $(TMPLS) $(SPEC_INI) $(LEMMAS)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) deposit-subcall_2            to_little_endian_64-trusted deposit-subcall_2            > $@
