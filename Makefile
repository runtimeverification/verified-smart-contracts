.NOTPARALLEL:

SUBDIRS:=
ERC20:=

ifneq (,$(or $(findstring all,$(MODE)),$(findstring minimal,$(MODE))))
SUBDIRS+=resources
ERC20+=vyper zeppelin
endif

ifneq (,$(or $(findstring all,$(MODE)),$(findstring k-test,$(MODE))))
SUBDIRS+=k-test
endif

ifneq (,$(or $(findstring all,$(MODE)),$(findstring erc20,$(MODE))))
ERC20+=hkg hobby ds-token
endif

ifneq (,$(or $(findstring all,$(MODE)),$(findstring bihu,$(MODE))))
#SUBDIRS+=bihu
endif

ifneq (,$(or $(findstring all,$(MODE)),$(findstring gnosis,$(MODE))))
SUBDIRS+=gnosis/test gnosis-imap
endif

ifneq (,$(or $(findstring all,$(MODE)),$(findstring dom,$(MODE))))
#SUBDIRS+=proxied-token
ERC20+=gno
endif

SUBDIRS+=$(addprefix erc20/,$(ERC20))

# FIXME: temporary
SUBDIRS:=gnosis-imap

include resources/kprove-group.mak
