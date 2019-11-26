
    //////////////////////////
    // Gas Abstraction
    //////////////////////////

    // see also abstract-semantics.k

    syntax Int ::= #symGas(Int, Int, Int, List, Int) [function]
    syntax Int ::= #symMem(Int, Set) [function]

    /* Definition
    rule #symGas(INIT, LB, UB, S, MU) => INIT - [LB, UB] - sum(S) - MU
    rule #symMem(N, S) => maxInt(N, maxIntSet(S)) up/Int 32
    */

    syntax Int ::= Int "-Gas" Int [function]
    syntax Int ::= Int "+Gas" Int [function]

    // interval abstraction -- both bounds must be concrete
    syntax Int ::= #itv(Int, Int) [function]

    syntax Int ::= #makeItv(Int, Int) [function]
    rule #makeItv(X1, X2) => #itv(X1, X2) requires X1  <Int X2 andBool #isConcrete(X1) andBool #isConcrete(X2)
    rule #makeItv(X1, X2) => X1           requires X1 ==Int X2 andBool #isConcrete(X1) andBool #isConcrete(X2)

    // #memoryUsageUpdate

    rule #memoryUsageUpdate(#symMem(MU, MUS), START, WIDTH) => #symMem(maxInt(MU, START +Int WIDTH), MUS)
        requires #isConcrete(MU) andBool #isConcrete(START) andBool #isConcrete(WIDTH)

    rule #memoryUsageUpdate(#symMem(MU, MUS), START, WIDTH) => #symMem(MU, SetItem(START +Int WIDTH) MUS)
        requires notBool (#isConcrete(START) andBool #isConcrete(WIDTH))

    rule #memoryUsageUpdate(        MU,       START, WIDTH) => #symMem(MU, SetItem(START +Int WIDTH) .Set)
        requires #isConcrete(MU) andBool notBool (#isConcrete(START) andBool #isConcrete(WIDTH))

    // deductGas

    rule #symGas(I, LB, UB, S, CMEM) -Gas G              => #symGas(I, LB +Int G,   UB +Int G,               S, CMEM)
        requires #isConcrete(G)

    rule #symGas(I, LB, UB, S, CMEM) -Gas #itv(LB', UB') => #symGas(I, LB +Int LB', UB +Int UB',             S, CMEM)

    rule #symGas(I, LB, UB, S, CMEM) -Gas G              => #symGas(I, LB,          UB,          ListItem(G) S, CMEM)
        requires (notBool #isConcrete(G)) andBool #getKLabelString(G) =/=String "#itv" andBool #getKLabelString(G) =/=String "_+Int_"

    rule G -Gas (G1 +Int G2) => (G -Gas G1) -Gas G2

    // refund

    rule #symGas(X,                   LB,          UB,          ListItem(C) S, CMEM) +Gas #symGas(CGASCAP,                   LB', UB', S', CMEM')
      => #symGas(X,                   LB +Int LB', UB +Int UB', S'          S, CMEM) -Gas CMEM'
        requires C ==K CGASCAP

    rule #symGas(X,                   LB,          UB,          ListItem(C) S, CMEM) +Gas #symGas(CGASCAP +Int CCALLSTIPEND, LB', UB', S', CMEM')
      => #symGas(X +Int CCALLSTIPEND, LB +Int LB', UB +Int UB', S'          S, CMEM) -Gas CMEM'
        requires C ==K CGASCAP

    //  Cs*

    rule Csstore(SCHED, NEW, CURR, ORIG) => #makeItv(Gsstorereset < SCHED >, Gsstoreset < SCHED >)
        requires #isConcrete(SCHED)
         andBool notBool ( #isConcrete(NEW) andBool #isConcrete(CURR) )
         andBool notBool Ghasdirtysstore << SCHED >>

