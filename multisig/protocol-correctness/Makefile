TESTS = $(wildcard tests/*.golden)
TEST_COMPARISON = ${TESTS:.golden=.cmp}
TEST_GOLDEN = ${TESTS:=.make}

CHECK_RESULT_RUN = if [ $$? -eq 0 ] ; then echo "passed $<"; mv $@.tmp $@; else echo "failed $<"; cat $@.tmp; exit 1; fi

.PRECIOUS: tests/*.out

execution.timestamp: execution.k *.k
	@echo "Compiling $<"
	@kompile $(KOMPILE_FLAGS) $< --backend haskell
	@touch execution.timestamp

test: ${TEST_COMPARISON}

tests/%.cmp: tests/%.out tests/%.golden
	@echo "Comparing $^... "
	@diff --strip-trailing-cr $^ > $@.tmp 2>&1; ${CHECK_RESULT_RUN}

tests/%.out: tests/%.msig execution.timestamp
	@echo "Running $<"
	@krun $< > $@ 2>&1

golden: ${TEST_GOLDEN}

tests/%.golden.make: tests/%.msig execution.timestamp
	@echo "Running $<"
	@krun $< > tests/$*.golden 2>&1

clean:
	-rm *.timestamp tests/*.out tests/*.cmp
	-rm -r execution-kompiled
	-rm -r .krun*
