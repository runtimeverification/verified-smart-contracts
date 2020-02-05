THIS_FILE_DIR:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))
SOLAR_DIR=$(ROOT_DIR)/erc20/solar

KEVM_VERSION_FILE=$(ROOT_DIR)/erc20/.build/.kevm.rev
KOMPILE_COMMAND=make build-specs K_BIN=$(K_BIN)
override KEVM_BUILD_DIR=$(KEVM_REPO_DIR)/.build/defn/specs

DEFINITION_MODULE:=VERIFICATION-SOLAR
override LOCAL_LEMMAS=$(SOLAR_DIR)/verification-solar.k \
					  $(ROOT_DIR)/erc20/verification.k \
					  $(RESOURCES_DIR)/abstract-semantics-segmented-gas.k \
					  $(RESOURCES_DIR)/evm-symbolic.k \
					  $(RESOURCES_DIR)/evm-data-map-symbolic.k \
					  $(SOLAR_DIR)/solar-abstract-semantics.k
override TMPLS=$(SOLAR_DIR)/module-tmpl.k $(SOLAR_DIR)/spec-tmpl.k

include $(THIS_FILE_DIR)/kprove-erc20.mak
