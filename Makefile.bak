ERC20:=vyper zeppelin
ifeq ($(MODE),all)
ERC20+=hkg hobby ds-token gno
endif
ERC20_DIRS:=$(addprefix erc20/,$(ERC20))

SUBDIRS:=resources $(ERC20_DIRS)
ifeq ($(MODE),all)
SUBDIRS+=bihu gnosis gnosis/test proxied-token
endif

include resources/kprove-group.mak
