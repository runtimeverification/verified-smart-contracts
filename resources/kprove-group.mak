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

#
# For Jenkins Build
#

NPROCS?=1

.PHONY: jenkins

# K bug workaround: Because KEVM parse cache is shared between projects, rules with equal body but different attributes will collide.
# That's why we need clean-kevm-cache below.
jenkins:
	set -e; \
	for i in $(SUBDIRS); do \
		$(MAKE) -C $$i clean-kevm-cache all; \
		$(MAKE) -C $$i test -j$(NPROCS); \
	done
