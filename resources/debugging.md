# EVM Verifier Debugging Cheatsheet


### Internal commands for running kprover

```
$ cd evm-semantics
$ make deps defn split-proof-tests
$ export PATH=`pwd`/.build/k/k-distribution/target/release/k/bin:$PATH
$ kompile --debug --backend java -I .build/defn/java -d .build/defn/java --main-module ETHEREUM-SIMULATION --syntax-module ETHEREUM-SIMULATION .build/defn/java/driver.k
$ kprove tests/proofs/specs/vyper-erc20/totalSupply-spec.k -d .build/defn/java -m VERIFICATION --z3-executable
```


### IntelliJ debugger setup

1. Install Intellij (remember to install scala plugin)
1. In the `k5` dir, `mvn package`
1. Import k5 project:
   1. Import Project -> Path to the pom.xml
   2. Select project SDK: JDK1.8
1. Edit Configuration
   1. Click Edit Configuration, click `+` and choose Application
   2. Enter
      * Main class: `org.kframework.main.Main`
      * VM options: `-Xms64m -Xmx4g -Xss32m -XX:+TieredCompilation -ea`
      * Program arguments: `-kprove /path/to/spec.k -d .build/defn/java -m VERIFICATION <additional-arguments>` see [kprove tutorial](https://github.com/runtimeverification/verified-smart-contracts/blob/master/resources/kprove-tutorial.md)
      * Working dir: `/path/to/evm-semantics`
      * Env Variables:
        * `LD_LIBRARY_PATH` : `$LD_LIBRARY_PATH:$MODULE_DIR$/../k-distribution/target/release/k/lib/native/linux64`
        * `PATH`            : `$PATH:$MODULE_DIR$/../k-distribution/target/release/k/bin:$MODULE_DIR$/../k-distribution/target/release/k/lib/native/linux:$MODULE_DIR$/../k-distribution/target/release/k/lib/native/linux64:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin`
      * Use classpath of module: `k-distribution`

1. Breakpoints
   * Start from `proveRule()` in `SymbolicRewriter.java`.
   * At line `if (term.implies(targetTerm)) {`.
     Set a breakpoint with the following condition, which will stop at the begining of the execution of each opcode.
     ```
     ((KList) ((KItem) ((KList) ((KItem) term.term()).kList()).get(0)).kList()).get(0).toString().startsWith("#KSequence(#exec[_]")
     ```
     You can also add `step >= N` to constrain the number of steps.
   * More recent versions of K have updated versions of the method `proveRule()`. You can move the breakpoint to one of the first lines of `for (ConstrainedTerm term : queue)`, such as `v++`, and use the same condition as above.
2. Using the debugger
   * The debugger should stop at each opcode. You can see the current opcode at the top of the `<k>` cell of the current configuration. The current configuration is stored in the `term` variable.

### FAQ
**Q:** The following error was thrown while I was trying to run the debugger. What should I do?
```
java.lang.OutOfMemoryError: GC overhead limit exceeded
```
**A:** This error was thrown most likely because the memory heap size of the VM was not big enough. In order to fix this error try to increase the heap size by editing the current configuration and replace in the `VM Options` the `-Xmx4g` with `-Xmx12g`. This will allocate 12GB for the VM memory heap.