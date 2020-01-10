module NOT-KLABEL     [symbolic]
    imports K-REFLECTION

    //Returns true if the KLabel of `T` is not `L`, or if `T` is a variable.
    syntax Bool ::= #notKLabel ( K , String ) [function]
    rule #notKLabel(T, L) => #getKLabelString(T) =/=String L orBool #isVariable(T)

endmodule
