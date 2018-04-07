requires "domains.k"

module REAL-SYNTAX
  syntax Real [hook(REAL.Real)]
  syntax Real ::= r"[\\+-]?[0-9]+\\.[0-9]+" [prefer, token, prec(2)] // [token, prec(1)]
endmodule

module REAL
  imports REAL-SYNTAX
  imports BOOL
  imports INT-SYNTAX

  syntax Real ::= "--Real" Real             [function,       smtlib(-),   hook(REAL.neg)]
                 > Real "^Real" Real        [function, left,              hook(REAL.pow)]
                 > left:
                   Real "*Real" Real        [function, left, smtlib(*),   hook(REAL.mul)]
                 | Real "/Real" Real        [function, left, smtlib(div), hook(REAL.div)]
                 > left:
                   Real "+Real" Real        [function, left, smtlib(+),   hook(REAL.add)]
                 | Real "-Real" Real        [function, left, smtlib(-),   hook(REAL.sub)]

  syntax Bool ::= Real  "<=Real" Real       [function, left, smtlib(<=),  hook(REAL.le)]
                | Real   "<Real" Real       [function, left, smtlib(<),   hook(REAL.lt)]
                | Real  ">=Real" Real       [function, left, smtlib(>=),  hook(REAL.ge)]
                | Real   ">Real" Real       [function, left, smtlib(>),   hook(REAL.gt)]
                | Real  "==Real" Real       [function, left, smtlib(==),  hook(REAL.eq), klabel(_==Real_)]
                | Real "=/=Real" Real       [function, left, smtlib((not (== #1 #2)))]

  rule F1:Real =/=Real F2:Real => notBool (F1 ==Real F2)

  syntax Real ::= rootReal(Real, Int)       [function,              hook(REAL.root)]
                | sqrtReal(Real)            [function]
                | absReal(Real)             [function, smtlib(abs), hook(REAL.abs)]
                | floorReal(Real)           [function,              hook(REAL.floor)]
                | ceilReal(Real)            [function,              hook(REAL.ceil)]
                | expReal(Real)             [function,              hook(REAL.exp)]
                | logReal(Real)             [function,              hook(REAL.log)]
                | sinReal(Real)             [function,              hook(REAL.sin)]
                | cosReal(Real)             [function,              hook(REAL.cos)]
                | tanReal(Real)             [function,              hook(REAL.tan)]
                | asinReal(Real)            [function,              hook(REAL.asin)]
                | acosReal(Real)            [function,              hook(REAL.acos)]
                | atanReal(Real)            [function,              hook(REAL.atan)]
                | atan2Real(Real, Real)     [function,              hook(REAL.atan2)]
                | maxReal(Real, Real)       [function, smtlib(max), hook(REAL.max)]
                | minReal(Real, Real)       [function, smtlib(min), hook(REAL.min)]

  rule sqrtReal(R:Real) => rootReal(R, 2)

  syntax Real ::= Int2Real(Int)             [function, hook(REAL.int2real)]
  syntax Int  ::= Real2Int(Real)            [function, hook(REAL.real2int)]

endmodule

