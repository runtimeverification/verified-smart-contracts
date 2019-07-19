BUILD_DIR:=../../.build

LOCAL_LEMMAS:=verification.k \
			  abstract-semantics.k \
			  ../../resources/abstract-semantics-segmented-gas.k \
			  ../../resources/evm-symbolic.k \
			  ../../resources/evm-data-map-symbolic.k
TMPLS:=module-tmpl.k spec-tmpl.k

SPEC_GROUP:=deposit
SPEC_INI:=deposit-spec.ini

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/evm.smt2)

SPEC_NAMES:=to_little_endian_64 \
            to_little_endian_64-forloop \
            to_little_endian_64-return \
            get_hash_tree_root-init \
            get_hash_tree_root-loop0-then \
            get_hash_tree_root-loop0-else \
            get_hash_tree_root-loop-body-then \
            get_hash_tree_root-loop-body-else \
            get_hash_tree_root-loop-exit

include ../../resources/kprove.mak

# non-standard spec generation

$(SPECS_DIR)/$(SPEC_GROUP)/get_hash_tree_root-loop-exit-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) get_hash_tree_root-loop-exit to_little_endian_64-trusted get_hash_tree_root-loop-exit > $@
