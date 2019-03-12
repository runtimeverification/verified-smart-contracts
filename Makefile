.NOTPARALLEL:

MINIMAL_DIRS:=   resources erc20/vyper erc20/zeppelin
KTEST_DIRS:=     k-test
ERC20_DIRS:=     erc20/hkg erc20/hobby erc20/ds-token
GNOSIS_DIRS:=    gnosis gnosis/test
GNOSIS_BMC_DIRS:=gnosis/bmc
BIHU_DIRS:=      bihu
DOM_DIRS:=       erc20/gno proxied-token
CASPER_DIRS:=    casper
UNISWAP_DIRS:=   uniswap

JENKINS_DIRS:=$(MINIMAL_DIRS) $(KTEST_DIRS) $(ERC20_DIRS) $(GNOSIS_DIRS)
ALL_DIRS:=    $(JENKINS_DIRS) $(GNOSIS_BMC_DIRS) $(BIHU_DIRS) $(DOM_DIRS) $(CASPER_DIRS) $(UNISWAP_DIRS)

SUBDIRS:=

ifneq (,$(findstring minimal,$(MODE)))
SUBDIRS+=$(MINIMAL_DIRS)
endif

ifneq (,$(findstring k-test,$(MODE)))
SUBDIRS+=$(KTEST_DIRS)
endif

ifneq (,$(findstring erc20,$(MODE)))
SUBDIRS+=$(ERC20_DIRS)
endif

ifneq (,$(findstring gnosis,$(MODE)))
SUBDIRS+=$(GNOSIS_DIRS)
endif

ifneq (,$(findstring gnosis_bmc,$(MODE)))
SUBDIRS+=$(GNOSIS_BMC_DIRS)
endif

ifneq (,$(findstring bihu,$(MODE)))
SUBDIRS+=$(BIHU_DIRS)
endif

ifneq (,$(findstring dom,$(MODE)))
SUBDIRS+=$(DOM_DIRS)
endif

ifneq (,$(findstring casper,$(MODE)))
SUBDIRS+=$(CASPER_DIRS)
endif

ifneq (,$(findstring uniswap,$(MODE)))
SUBDIRS+=$(UNISWAP_DIRS)
endif

ifneq (,$(findstring jenkins,$(MODE)))
SUBDIRS+=$(JENKINS_DIRS)
endif

ifneq (,$(findstring all,$(MODE)))
SUBDIRS+=$(ALL_DIRS)
endif


include resources/kprove-group.mak
