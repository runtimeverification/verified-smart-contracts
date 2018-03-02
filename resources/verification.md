KEVM Verification
=================

Using K's reachability logic theorem prover, we're able to verify many properties about EVM programs as reachability claims.
Safety properties (and some of the liveness properties) can be naturally specified in the reachability claims.
Liveness properties can be specified by using the reduction to safety properties, while some of the liveness properties can be directly specified in the reachability claims as well.

This module defines some helpers which make writing specifications simpler.

```k
requires "evm.k"

module VERIFICATION [symbolic]
    imports EVM
```

### Abstraction for Hash

The following syntactic sugars capture the storage layout schemes of Solidity and Viper.

```k
    syntax IntList ::= List{Int, ""}                             [klabel(intList)]
    syntax Int     ::= #hashedLocation( String , Int , IntList ) [function]
 // -----------------------------------------------------------------------
    rule #hashedLocation(LANG, BASE, .IntList) => BASE

    rule #hashedLocation("Viper",    BASE, OFFSET OFFSETS) => #hashedLocation("Viper",    keccakIntList(BASE) +Word OFFSET, OFFSETS)
    rule #hashedLocation("Solidity", BASE, OFFSET OFFSETS) => #hashedLocation("Solidity", keccakIntList(OFFSET BASE),       OFFSETS)

    syntax Int ::= keccakIntList( IntList ) [function]
 // --------------------------------------------------
    rule keccakIntList(VS) => keccak(intList2ByteStack(VS))

    syntax WordStack ::= intList2ByteStack( IntList ) [function]
 // ------------------------------------------------------------
    rule intList2ByteStack(.IntList) => .WordStack
    rule intList2ByteStack(V VS)     => #asByteStackInWidth(V, 32) ++ intList2ByteStack(VS)
      requires 0 <=Int V andBool V <Int pow256
```

ABI Abstraction DSL
-------------------

### Calldata

Below is the ABI call abstraction, a formalization for ABI encoding of the call data, that helps to keep the specification succinct.

```k
    syntax TypedArg ::= #uint160 ( Int )
                      | #address ( Int )
                      | #uint256 ( Int )
 // ------------------------------------

    syntax TypedArgs ::= List{TypedArg, ","} [klabel(typedArgs)]
 // ------------------------------------------------------------

    syntax WordStack ::= #abiCallData ( String , TypedArgs ) [function]
 // -------------------------------------------------------------------
    rule #abiCallData( FNAME , ARGS )
      => #parseByteStack(substrString(Keccak256(#generateSignature(FNAME, ARGS)), 0, 8))
      ++ #encodeArgs(ARGS)

    syntax String ::= #generateSignature     ( String, TypedArgs ) [function]
                    | #generateSignatureArgs ( TypedArgs )         [function]
 // -------------------------------------------------------------------------
    rule #generateSignature( FNAME , ARGS ) => FNAME +String "(" +String #generateSignatureArgs(ARGS) +String ")"

    rule #generateSignatureArgs(.TypedArgs)                            => ""
    rule #generateSignatureArgs(TARGA:TypedArg, .TypedArgs)            => #typeName(TARGA)
    rule #generateSignatureArgs(TARGA:TypedArg, TARGB:TypedArg, TARGS) => #typeName(TARGA) +String "," +String #generateSignatureArgs(TARGB, TARGS)

    syntax String ::= #typeName ( TypedArg ) [function]
 // ---------------------------------------------------
    rule #typeName(#uint160( _ )) => "uint160"
    rule #typeName(#address( _ )) => "address"
    rule #typeName(#uint256( _ )) => "uint256"

    syntax WordStack ::= #encodeArgs ( TypedArgs ) [function]
 // ---------------------------------------------------------
    rule #encodeArgs(ARG, ARGS)  => #getData(ARG) ++ #encodeArgs(ARGS)
    rule #encodeArgs(.TypedArgs) => .WordStack

    syntax WordStack ::= #getData ( TypedArg ) [function]
 // -----------------------------------------------------
    rule #getData(#uint160( DATA )) => #asByteStackInWidth( DATA , 32 )
    rule #getData(#address( DATA )) => #asByteStackInWidth( DATA , 32 )
    rule #getData(#uint256( DATA )) => #asByteStackInWidth( DATA , 32 )
```

### Event Logs

```k
    syntax EventArg ::= TypedArg
                      | #indexed ( TypedArg )
 // -----------------------------------------

    syntax EventArgs ::= List{EventArg, ","} [klabel(eventArgs)]
 // ------------------------------------------------------------

    syntax SubstateLogEntry ::= #abiEventLog ( Int , String , EventArgs ) [function]
 // --------------------------------------------------------------------------------
    rule #abiEventLog(ACCT_ID, EVENT_NAME, EVENT_ARGS)
      => { ACCT_ID | #getEventTopics(EVENT_NAME, EVENT_ARGS) | #getEventData(EVENT_ARGS) }

    syntax WordStack ::= #getEventTopics ( String , EventArgs ) [function]
 // ----------------------------------------------------------------------
    rule #getEventTopics(ENAME, EARGS)
      => #parseHexWord(Keccak256(#generateSignature(ENAME, #getTypedArgs(EARGS))))
       : #getIndexedArgs(EARGS)

    syntax TypedArgs ::= #getTypedArgs ( EventArgs ) [function]
 // -----------------------------------------------------------
    rule #getTypedArgs(#indexed(E), ES) => E, #getTypedArgs(ES)
    rule #getTypedArgs(E:TypedArg,  ES) => E, #getTypedArgs(ES)
    rule #getTypedArgs(.EventArgs)      => .TypedArgs

    syntax WordStack ::= #getIndexedArgs ( EventArgs ) [function]
 // -------------------------------------------------------------
    rule #getIndexedArgs(#indexed(E), ES) => #getValue(E) : #getIndexedArgs(ES)
    rule #getIndexedArgs(_:TypedArg,  ES) =>                #getIndexedArgs(ES)
    rule #getIndexedArgs(.EventArgs)      => .WordStack

    syntax WordStack ::= #getEventData ( EventArgs ) [function]
 // -----------------------------------------------------------
    rule #getEventData(#indexed(_), ES) =>                #getEventData(ES)
    rule #getEventData(E:TypedArg,  ES) => #getData(E) ++ #getEventData(ES)
    rule #getEventData(.EventArgs)      => .WordStack

    syntax Int ::= #getValue ( TypedArg ) [function]
 // ------------------------------------------------
    rule #getValue(#uint160(V)) => V
    rule #getValue(#address(V)) => V
    rule #getValue(#uint256(V)) => V
endmodule
```
