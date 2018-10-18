# Formal Verification of GNO ERC20 Token

By Dominik Teiml (dominik@gnosis.pm), [Gnosis](https://www.gnosis.pm)

We formally verified the GNO ERC20 token contract [runtime bytecode](./gno-erc20.bytes).

We found the following deviations from [ERC20-EVM](../erc20/vyper/vyper-erc20-spec.ini):

- In the [high-level Solidity code](https://etherscan.io/address/0x6810e776880c02933d47db1b9fc05908e5386b96#code), mapping of users' allowances is called `allowed`, hence we use that in our [eDSL spec](./gno-erc20-spec.ini).
- In `transfer-failure-1` and `transferFrom-failure-1`, `BAL_TO +Int VALUE >=Int (2 ^Int 256)` was removed from the constraint. The reason is the GNO was constructed with a fixed supply of 10 M. Hence no overflow protections are necessary (and so none are present)
- A new lemma was added to be added to [lemmas.k](../../specs/lemmas.k) to help K tool with the reduction of a specific term. We present the lemma as well as its soundness proof:

## Lemma

Lemma:
```
rule chop ( W0:Int +Int W1:Int ) -Word W1:Int => chop ( W0 )
```

Proof:
We start with the definition of chop:

```
rule chop ( I:Int ) => I modInt pow256
```

where modInt is java's `mod` operator on BigIntegers.

Hence:

chop ( X ) = chop ( Y ) iff X ≡ Y (mod 2^256), and

chop ( X ) ≡ X (mod 2^256)

-Word is defined:

```
rule W0 -Word W1 => chop( W0 -Int W1 ) requires W0 >=Int W1
rule W0 -Word W1 => chop( (W0 +Int pow256) -Int W1 ) requires W0 <Int W1
```

Let a=W0 and b=W1. We start with the case chop ( a + b ) >= b

Then LHS = chop ( chop ( a + b) - b)

Now chop ( a + b ) ≡ a + b (mod 2^256),

so chop ( a + b ) - b ≡ a,

so chop ( chop ( a + b) - b) = chop ( a )


When chop ( a + b ) < b, we get

LHS = chop ( chop ( a + b) + 2^256 - b) and the rest is analogous.

## Conlusion

In conclusion, the contract adheres to the desired behavior & our formal specification.