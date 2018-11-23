# Formal Verification of GNO ERC20 Token

By Dominik Teiml (dominik@gnosis.pm), [Gnosis](https://www.gnosis.pm)

We formally verified the GNO ERC20 token contract [runtime bytecode](./gno-erc20.bytes).

We found the following deviations from [ERC20-EVM](../vyper/vyper-erc20-spec.ini):

- In the [high-level Solidity code](https://etherscan.io/address/0x6810e776880c02933d47db1b9fc05908e5386b96#code), mapping of users' allowances is called `allowed`, hence we use that in our [spec template](./gno-erc20-spec.ini).
- To verify full security, we have added failure cases to every function for when the `callValue` is not 0. 
- In `transfer-failure-1` and `transferFrom-failure-1`, `BAL_TO +Int VALUE >=Int (2 ^Int 256)` was removed from the constraint. The reason is the GNO was constructed with a fixed supply of 10 M. We present a pen & paper proof that the sum will always be 10 M below.
- A new lemma was added to be added to [lemmas.md](../../resources/lemmas.md) to help K tool with the reduction of a specific term. We present the lemma as well as its soundness proof:

## Token Balances Sum Invariant

Proposition:

Except during a tx execution, sum of all token balances will always be 10 M.

Proof:

In the [spec](./gno-erc20-spec.ini), the `<storage>` term is always of the form `Location_i |-> Expr_i _:Map` for $0\leq i \leq 3$, where `Expr_i` is either a variable or a rewrite rules.

Due to the way K framework works, the only storage locations that can be different after execution will be `Location_i` for $0 \leq i \leq 3$. It follows that the invariance must be checked only on the `Expr_i` terms for all function cases. We present such a proof:

- totalSupply, balanceOf, allowances - do not modify storage
- approve - does not modify `balances`
- transfer-success-1 & transferFrom-success-1
    - sum of expressions before: `BAL_FROM + BAL_TO`
    - sum of expressions after: `(BAL_FROM - VALUE) + (BAL_TO + VALUE)` = `BAL_FROM + BAL_TO` since we are assuming neither expression overflows
- transfer-success-2 & transferFrom-success-2 - do not modify storage
- transfer-failure & transferFrom-failure - all 3 cases lead to either EVMC_REVERT or EVMC_INVALID_INSTRUCTION, reverting all state changes

QED


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

QED

## Conlusion

In conclusion, the contract adheres to the desired behavior & our formal specification.
