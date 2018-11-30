PROCS?=1

GOALS:=all clean clean-deps deps split-proof-tests test

.PHONY: $(GOALS)

$(GOALS):
	$(MAKE) -C resources      -j$(PROCS) $@
	$(MAKE) -C erc20/vyper    -j$(PROCS) $@
	$(MAKE) -C erc20/zeppelin -j$(PROCS) $@
ifeq ($(MODE),all)
	$(MAKE) -C erc20/hkg      -j$(PROCS) $@
	$(MAKE) -C erc20/hobby    -j$(PROCS) $@
	$(MAKE) -C erc20/ds-token -j$(PROCS) $@
	$(MAKE) -C erc20/gno      -j$(PROCS) $@
	$(MAKE) -C bihu           -j$(PROCS) $@
	$(MAKE) -C gnosis         -j$(PROCS) $@
	$(MAKE) -C gnosis/test    -j$(PROCS) $@
	$(MAKE) -C proxied-token  -j$(PROCS) $@
endif
