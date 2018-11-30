SUBCLEAN=$(addsuffix .clean,$(SUBDIRS))
SUBCLEANDEPS=$(addsuffix .clean-deps,$(SUBDIRS))
SUBDEPS=$(addsuffix .deps,$(SUBDIRS))
SUBPROOF=$(addsuffix .proof,$(SUBDIRS))
SUBTEST=$(addsuffix .test,$(SUBDIRS))

.PHONY: all clean clean-deps deps split-proof-tests test $(SUBDIRS) $(SUBCLEAN) $(SUBCLEANDEPS) $(SUBDEPS) $(SUBPROOF) $(SUBTEST)

all: $(SUBDIRS)
clean: $(SUBCLEAN)
clean-deps: $(SUBCLEANDEPS)
deps: $(SUBDEPS)
split-proof-tests: $(SUBPROOF)
test: $(SUBTEST)

$(SUBDIRS):
	$(MAKE) -C $@

$(SUBCLEAN): %.clean:
	$(MAKE) -C $* clean

$(SUBCLEANDEPS): %.clean-deps:
	$(MAKE) -C $* clean-deps

$(SUBDEPS): %.deps:
	$(MAKE) -C $* deps

$(SUBPROOF): %.proof:
	$(MAKE) -C $* split-proof-tests

$(SUBTEST): %.test:
	$(MAKE) -C $* test
