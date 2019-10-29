# Inspecting compatibility with our ERC20 verification template
Source: https://etherscan.io/tokens?ps=100&p=1

- Top 15 in this list are as of 21/10
- Top 16-30 as of 29/10
- Top 31-41 as of 30/10

## 1 Tether
Status: not compatible
- ERC20 functions do external calls.

## 2 BNB
Status: compatible
- 4 failures because contract is not compliant with ERC20.

## 3 Bitfinex
Status: not compatible
- external calls, very complex logic

## 4 ChainLink
Status: compatible
- Slightly extended with an extra check. Otherwise would fit extended template.
- 11 specs out of 12 pass.
- totalSupply fails because is constant, we can adapt that in our template.

## 5 Huobi
Status: compatible

## 6 Maker
Status: compatible

## 7 USD Coin
Status: proxy pattern

## 8 Crypto.com Coin (CRO)
Status: relaxed template
- Has extra checks, otherwise standard.

## 9 Ino Coin (INO)
Status: compatible

## 10 BAT (BAT)
Status: compatible

## 11 Insight Chain (INB)
Status: relaxed template

## 12 Paxos Standard (PAX)
Status: proxy pattern

## 13 HEDG
Status: relaxed template

## 14 ZRX (ZRX)
Status: compatible
- nr 16 on 29/10

## 15 VeChain (VEN)
Status: not compatible
- Non-standard data model.

## 15.2 TrueUSD (TUSD)
Status: proxy pattern
- nr 15 as of 29/10.

## 17 HoloToken (HOT)
Status: relaxed template
- standard data structures

## 18 OmiseGO (OMG)
Status: relaxed template
- operations allowed when paused == false
- I saw this #11 Insight, possibly same code.

## 19 ZBToken (ZB)
Status: source code not available

## 20 Centrality Token (CENNZ)
Status: compatible
- Source code also contains a proxy, so it depends who's bytecode is on etherscan page: master or proxy.

## 21 Bytom (BTM)
Status: compatible
- No overflow check!

## Kucoin Shares (KCS)
Status: incomplete ERC20
- only transfer() present, standard implementation.

## 23 EKT (EKT)
Status: compatible
- transfer() allows burning tokens by sending to 0x00
- this is not compliant with ERC20. Otherwise fully compatible.

## 24 Synthetix Network Token (SNX)
Status: proxy pattern

## 25 Reputation (REP)
Status: source code not available
- They submitted some code, but it has nothing to do with either ERC20 implementation or proxy pattern.

## 26 Theta Token (THETA)
Status: relaxed template
- Extra checks access block.number This probably needs extra preconditions.

## 27 Swipe (SXP)
Status: relaxed template

## 28 Dai Stablecoin v1.0 (DAI)
Status: relaxed template
- transfer() calls transferFrom()

## 29 ICON (ICX)
Status: relaxed template

## 30 KaratBank Coin (KBC)
Status: compatible

## 31 Mixin (XIN)
Status: compatible

## 32 - nothing new
On 30/10 KaratBank is #32, already reviewed.

## 33 IOSToken (IOST)
Status: compatible
- No overflow checks!

## 34 Quant (QNT)
Status: compatible

## 35 MCO (MCO)
Status: relaxed template
- A unique check for short address attack. Probably requires unique lemma/check.
- It is worth studying whether it is necessary to protect from this attack and craft a spec for it.

## 36 Aeternity (AE)
Status: relaxed template

## 37 OKB (OKB)
Status: source code not available

## 38 BitForex Token (BF)
Status: source code not available

## 39 Nexo (NEXO)
Status: compatible
- constant totalSupply

## 40 Clipper Coin Capital (CCCX)
Status: relaxed template

## 41 RLC (RLC)
Status: relaxed template
- Required to have 40 in total. #32 is missing.


# Summary for top 40 (30/10)
- Compatible:                   15
- Relaxed template:             13
- Not compatible:                3
- Proxy pattern:                 4
- Source code not available:     4
- Incomplete ERC20:              1

Total compatible out of contracts with full code: 28/31 = 90%
