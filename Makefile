.NOTPARALLEL:

ERC20:=
SUBDIRS:=

ifneq (,$(or $(findstring all,$(MODE)),$(findstring minimal,$(MODE))))
ERC20+=vyper zeppelin
SUBDIRS+=resources
endif

ifneq (,$(or $(findstring all,$(MODE)),$(findstring erc20,$(MODE))))
ERC20+=hkg hobby ds-token gno
SUBDIRS+=proxied-token
endif

ifneq (,$(or $(findstring all,$(MODE)),$(findstring custom,$(MODE))))
SUBDIRS+=bihu gnosis gnosis/test
endif

SUBDIRS+=$(addprefix erc20/,$(ERC20))

include resources/kprove-group.mak
