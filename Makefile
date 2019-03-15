.NOTPARALLEL:

MINIMAL_DIRS:=   resources erc20/vyper erc20/zeppelin
KTEST_DIRS:=     k-test
ERC20_DIRS:=     erc20/hkg erc20/hobby erc20/ds-token
GNOSIS_DIRS:=    gnosis gnosis/test
GNOSIS_BMC_DIRS:=gnosis/bmc
BIHU_DIRS:=      bihu
DOM_DIRS:=       erc20/gno proxied-token
# fails - needs updates in verification.k
CASPER_DIRS:=    casper
# fails - has to get rid of custom lemmas.md
UNISWAP_DIRS:=   uniswap

JENKINS_DIRS:=$(MINIMAL_DIRS) $(ERC20_DIRS)
ALL_DIRS:=    $(JENKINS_DIRS) $(GNOSIS_BMC_DIRS) $(BIHU_DIRS) $(DOM_DIRS) $(CASPER_DIRS) $(UNISWAP_DIRS)

# For MODE=foo, SUBDIRS will be FOO_DIRS
SUBDIRS:=$($(shell echo $(MODE) | tr a-z A-Z)_DIRS)

include resources/kprove-group.mak
