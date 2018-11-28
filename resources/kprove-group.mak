SUBCLEAN=$(addsuffix .clean,$(SUBDIRS))
SUBDEPS=$(addsuffix .deps,$(SUBDIRS))
SUBPROOF=$(addsuffix .proof,$(SUBDIRS))
SUBTEST=$(addsuffix .test,$(SUBDIRS))

.PHONY: all clean $(SUBDIRS) $(SUBCLEAN) $(SUBDEPS) $(SUBPROOF) $(SUBTEST)

all: $(SUBDIRS)
clean: $(SUBCLEAN)
deps: $(SUBDEPS)
split-proof-tests: $(SUBPROOF)
test: $(SUBTEST)

$(SUBDIRS):
	$(MAKE) -C $@

$(SUBCLEAN): %.clean:
	$(MAKE) -C $* clean

$(SUBDEPS): %.deps:
	$(MAKE) -C $* deps

$(SUBPROOF): %.proof:
	$(MAKE) -C $* split-proof-tests

$(SUBTEST): %.test:
	$(MAKE) -C $* test
