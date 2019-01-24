BUILD_DIR:=../.build

SPEC_GROUP:=examples
SPEC_INI:=proxied-token-spec.ini

KPROVE_OPTS:=--smt-prelude $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/evm.smt2)

SPEC_NAMES:=sum-to-n

LOCAL_LEMMAS:=
TMPLS:=

include kprove.mak

# non-standard spec generation
$(SPECS_DIR)/$(SPEC_GROUP)/sum-to-n-spec.k: $(RESOURCES)/sum-to-n.md $(TANGLER)
	pandoc --from markdown --to "$(TANGLER)" --metadata="code:.sum-to-n" $< > $@
