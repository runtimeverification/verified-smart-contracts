#!/bin/bash

cat <<EOF
requires "edsl.k"

module LEMMAS
    imports K-REFLECTION
    imports EDSL
EOF

cat lemmas/macro.k \
    lemmas/range.k \
    lemmas/arith.k \
    lemmas/buf.k \
    lemmas/map.k \
    lemmas/hash.k \
    lemmas/gas.k

cat <<EOF
endmodule
EOF
