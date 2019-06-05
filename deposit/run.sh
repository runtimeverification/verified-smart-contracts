  set -e

  # concrete test
  rm -rf deposit-test
  kompile --backend java -d deposit-test deposit.k
  krun --smt none -cTREEHEIGHT=3 -d deposit-test test.deposit | diff - test.deposit.out

  # proof
  rm -rf deposit-symbolic-kompiled
  kompile --backend java deposit-symbolic.k --syntax-module DEPOSIT-SYMBOLIC
  kprove deposit-spec.k --smt-prelude imap.smt2 | diff - deposit-spec.k.out
# kprove deposit-spec.k --smt-prelude imap.smt2 -v --debug --log --log-rules --debug-z3-queries --log-cells k,depositCount,branch,zerohashes,#pc,#result >/tmp/x 2>&1
