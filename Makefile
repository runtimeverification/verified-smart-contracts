.NOTPARALLEL:

MINIMAL_DIRS:=   resources erc20/vyper erc20/zeppelin
KTEST_DIRS:=     k-test
ERC20_DIRS:=     erc20/hkg erc20/hobby erc20/ds-token
GNOSIS_DIRS:=    gnosis gnosis/test
GNOSIS_BMC_DIRS:=gnosis/bmc
BIHU_DIRS:=      bihu
DOM_DIRS:=       proxied-token
# fails
#DOM_DIRS+=       proxied-token
# fails
CASPER_DIRS:=    casper
# fails
UNISWAP_DIRS:=   uniswap

#JENKINS_DIRS:=$(MINIMAL_DIRS) $(KTEST_DIRS) $(ERC20_DIRS) $(GNOSIS_DIRS)
# probably work for: $(GNOSIS_BMC_DIRS) $(BIHU_DIRS)
JENKINS_DIRS:=$(DOM_DIRS)
ALL_DIRS:=    $(JENKINS_DIRS) $(GNOSIS_BMC_DIRS) $(BIHU_DIRS) $(DOM_DIRS) $(CASPER_DIRS) $(UNISWAP_DIRS)

# For MODE=foo, SUBDIRS will be FOO_DIRS
SUBDIRS:=$($(shell echo $(MODE) | tr a-z A-Z)_DIRS)

include resources/kprove-group.mak
