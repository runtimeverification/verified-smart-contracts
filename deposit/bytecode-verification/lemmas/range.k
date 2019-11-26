
    //////////////////////////
    // Range Predicates
    //////////////////////////

    rule 0 <=Int (X modInt Y)         => true
    rule         (X modInt Y) <Int Y  => true  requires Y >Int 0

    rule 0 <=Int 2 ^Int X             => true
    rule         2 ^Int X <Int pow256 => true  requires X <Int 256

    rule 0 <=Int X &Int Y             => true  requires #rangeUInt(256, X) andBool #rangeUInt(256, Y)
    rule         X &Int Y <Int pow256 => true  requires #rangeUInt(256, X) andBool #rangeUInt(256, Y)

    rule 0 <=Int X |Int Y             => true  requires #rangeUInt(256, X) andBool #rangeUInt(256, Y)
    rule         X |Int Y <Int pow256 => true  requires #rangeUInt(256, X) andBool #rangeUInt(256, Y)

    rule 0 <=Int #blockhash(_, _, _, _)             => true
    rule         #blockhash(_, _, _, _) <Int pow256 => true

    rule 0 <=Int #bufElm(_, _)             => true
    rule         #bufElm(_, _) <Int 256    => true
    rule         #bufElm(_, _) <Int pow256 => true

    // X xorInt (pow256 - 1)
    rule 0 <=Int X xorInt 115792089237316195423570985008687907853269984665640564039457584007913129639935             => true  requires 0<=Int X andBool X <Int pow256
    rule         X xorInt 115792089237316195423570985008687907853269984665640564039457584007913129639935 <Int pow256 => true  requires 0<=Int X andBool X <Int pow256

    rule 0 <=Int nthbyteof(V, I, N)             => true
    rule         nthbyteof(V, I, N) <Int 256    => true
    rule         nthbyteof(V, I, N) <Int pow256 => true

    rule 0 <=Int #asWord(WS)             => true
    rule         #asWord(WS) <Int pow256 => true

    rule 0 <=Int hash1(_)             => true
    rule         hash1(_) <Int pow256 => true

    rule 0 <=Int hash2(_,_)             => true
    rule         hash2(_,_) <Int pow256 => true

    rule 0 <=Int chop(V)             => true
    rule         chop(V) <Int pow256 => true

    rule 0 <=Int keccak(V)             => true
    rule         keccak(V) <Int pow256 => true

    rule 0 <=Int keccakIntList(_)             => true
    rule         keccakIntList(_) <Int pow256 => true

    rule 0 <=Int  #sha256(_)             => true
    rule          #sha256(_) <Int pow256 => true

    syntax Bool ::= isStorage(Map) [function]
    rule 0 <=Int select(M, _)             => true requires isStorage(M)
    rule         select(M, _) <Int pow256 => true requires isStorage(M)

    rule 0 <=Int select(M, _) +Int 1      => true requires isStorage(M)

