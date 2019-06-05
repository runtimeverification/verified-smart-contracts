module IMAP-SYNTAX
    imports INT
    syntax IMap [smt-prelude] // (define-sort IMap () (Array Int Int))
    syntax IMap ::= IMap "[" Int "<-" Int "]" [function, klabel(store),  smtlib(store),  smt-prelude] //, hook(MAP.update)]
    syntax Int  ::= IMap "[" Int "]"          [function, klabel(select), smtlib(select), smt-prelude] //, hook(MAP.lookup)]
    syntax IMap ::= ".IMap"
endmodule

module IMAP-SYMBOLIC [symbolic]
    imports IMAP-SYNTAX
    rule M [ K0 <- V ] [ K ] => V       requires K0  ==Int K
    rule M [ K0 <- V ] [ K ] => M [ K ] requires K0 =/=Int K
//  rule .IMap [ _ ] => 0

// syntax IntMap
// rule isInt( M:Map [ _ ] ) => isIntMap(M)
// rule isInt( M:Map [ _ <- V:Int ] ) => isIntMap(M)
endmodule

module IMAP
    imports IMAP-SYNTAX
    imports IMAP-SYMBOLIC
endmodule
