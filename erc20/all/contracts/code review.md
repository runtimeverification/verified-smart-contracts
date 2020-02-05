# Inspecting compatibility with our ERC20 verification template
Source: https://etherscan.io/tokens?ps=100&p=1

- Top 15 in this list are as of 21/10
- Top 16-30 as of 29/10
- Top 31-41 as of 30/10
- Top 44-57 as of 03/02/2020
Total contracts: 53 Numbers are not consecutive.

## 1 Tether
Status: not compatible

Multiple features outside our scope:
  - calls to external contracts
  - transfer of fee alongside the main transfer
  - senders blacklist system.

## 2 BNB
Status: compatible
- 3 failures because contract is not compliant with ERC20.

Extra functionality:
    - burn() - standard functionality. reduces balance and totalSupply.
    - freeze/unfreeze - allows certain balance to be frozen. Straightforward impl.
    - withdrawEther - contract-specific

## 3 Bitfinex
Status: not compatible
- external calls, very complex logic

## 4 ChainLink
Status: compatible
- Slightly extended with an extra check. Otherwise would fit extended template.
- 11 specs out of 12 pass.
- totalSupply fails because is constant, we can adapt that in our template.

Extra functionality:
    - also implements ERC677 - transferAndCall
    - increaseApproval/decreaseApproval - straightforward extensions to approve.

## 5 Huobi
Status: compatible
    - completely standard ERC20.

## 6 Maker
Status: compatible

Extra functionality:
    - mint/burn, but with custom authorization procedure that includes external call.
    - stoppable functionality - fits relaxed principle.

## 7 USD Coin
Status: proxy pattern

## 8 Crypto.com Coin (CRO)
Status: relaxed template (lock flag, whitelist)

Extra functionality:
    - mint() functionality with extra checks. Fits relaxed principle.

## 9 Ino Coin (INO)
Status: compatible

Extra:
    - approveAndCall from ERC677.
    - burn() - standard
    - burnFrom() - similar principle to transferFrom(), standard.

## 10 BAT (BAT)
Status: compatible

Extra:
    - createTokens() - Accepts ether and creates new BAT tokens. Totally custom.
    - finalize() - custom: Ends the funding period and sends the ETH home
    - refund() - custom: Allows contributors to recover their ether in the case of a failed funding campaign.

Summary: an ERC20 token with a crowdsale initial period in ether, that allows refunds.

## 11 Insight Chain (INB)
Status: relaxed template (Pausable)

Extra:
    - increaseApproval/decreaseApproval. Standard.

## 12 Paxos Standard (PAX)
Status: proxy pattern

## 13 HEDG
Status: relaxed template (Pausable, but with different names)

Extra:
    - mint, burn. Standard. 2 events fired for a function call.

## 14 ZRX (ZRX)
Status: compatible
- nr 16 on 29/10

Extra: none

## 15 VeChain (VEN)
Status: not compatible
- Non-standard data model.

## 15.2 TrueUSD (TUSD)
Status: proxy pattern
- nr 15 as of 29/10.

## 17 HoloToken (HOT)
Status: relaxed template (lock flag)
- standard data structures

Extra: 
    - increaseApproval, decreaseApproval. Standard.
    - mint/burn with some security checks. Only minter/destroyer can mint/burn and they are set by the owner. 

## 18 OmiseGO (OMG)
Status: relaxed template (Pausable)
- operations allowed when paused == false
- I saw this #11 Insight, possibly same code.

Extra:
    - mintTimelocked - totally custom
    - mint() with some security checks - only owner can mint

## 19 ZBToken (ZB)
Status: source code not available

## 20 Centrality Token (CENNZ)
Status: compatible
- Source code also contains a proxy, so it depends who's bytecode is on etherscan page: master or proxy.

Extra: 2 custom functions, out of scope.

## 21 Bytom (BTM)
Status: compatible
- No overflow check!

Extra:
    - approveAndCall

## Kucoin Shares (KCS)
Status: incomplete ERC20
- only transfer() present, standard implementation.

## 23 EKT (EKT)
Status: compatible
- transfer() allows burning tokens by sending to 0x00
- this is not compliant with ERC20. Otherwise fully compatible.

Extra:
    - burn

## 24 Synthetix Network Token (SNX)
Status: proxy pattern

## 25 Reputation (REP)
Status: source code not available
- They submitted some code, but it has nothing to do with either ERC20 implementation or proxy pattern.

## 26 Theta Token (THETA)
Status: relaxed template (lock flag)
- Extra checks access block.number This probably needs extra preconditions.

Extra:
    - mint

## 27 Swipe (SXP)
Status: relaxed template (blacklist, lock flag)

Extra:
    - approveAndCall
    - burn
    - burnForAllowance - totally custom

## 28 Dai Stablecoin v1.0 (DAI)
Status: relaxed template (lock flag)
- transfer() calls transferFrom()

Extra:
    - burn/mint
    - burn/mint from another account. Should be burnFrom/mintFrom.

## 29 ICON (ICX)
Status: relaxed template (whitelist)

Extra:
    - burnTokens. Same as Burn in others. logs TokenBurned event.

## 30 KaratBank Coin (KBC)
Status: compatible

Extra:
    - increaseApproval, decreaseApproval
    - a couple of totally custom functions.

## 31 Mixin (XIN)
Status: compatible

Extra: none

## 32 - nothing new
On 30/10 KaratBank is #32, already reviewed.

## 33 IOSToken (IOST)
Status: compatible
- No overflow checks!

Extra: none

## 34 Quant (QNT)
Status: compatible

Extra:
    - increaseApproval, decreaseApproval
    - mint

## 35 MCO (MCO)
Status: relaxed template (whitelist)
- A unique check for short address attack. Probably requires unique lemma/check.
- It is worth studying whether it is necessary to protect from this attack and craft a spec for it.

Extra:
    - multiple custom functions
    - mint

## 36 Aeternity (AE)
Status: relaxed template (time-based lock)

Extra:
    - approveAndCall

## 37 OKB (OKB)
Status: source code not available

## 38 BitForex Token (BF)
Status: source code not available

## 39 Nexo (NEXO)
Status: compatible
- constant totalSupply

Extra:
    - very custom logic.
    - increaseApproval, decreaseApproval

## 40 Clipper Coin Capital (CCCX)
Status: relaxed template (blacklist)

Extra:
    - burn, burnFrom, approveAndCall

## 41 RLC (RLC)
Status: relaxed template (lock flag)
- Required to have 40 in total. #32 is missing.

Extra:
    - approveAndCall, burn

# Summary for top 40 (30/10)
- Compatible:                   15
- Relaxed template:             13
- Not compatible:                3
- Proxy pattern:                 4
- Source code not available:     4
- Incomplete ERC20:              1

Total compatible out of contracts with full code: 28/31 = 90%

## 44 NOAHCOIN (NOAH)
Status: compatible
Extra: increaseApproval, decreaseApproval

## 45 KyberNetwork (KNC)
Status: relaxed template (time-based lock)
Extra: burn, burnFrom

## 46 BitMax token (BTMX)
Status: relaxed template (pausable)
Extra: burn, increaseApproval, decreaseApproval

## 47 DxChain Token (DX)
Status: relaxed template (pausable)
Extra: increaseApproval, decreaseApproval

## 48 Matic Token (MATIC)
Status: relaxed template (pausable)
Extra: increaseAllowance, decreaseAllowance

## 49 StatusNetwork (SNT)
Status: not compatible

## 51 Cryptoindex 100 (CIX100)
Status: relaxed template (lock flag)
Extra: burn 
Non-common extra: batchMint, batchTransfer

## 52 Banker Token (BNK)
Status: not compatible. External function calls.

## 53 Golem (GNT)
Status: incomplete ERC20

## 54 Decentraland (MANA)
Status: relaxed template (pausable)
Extra: burn, mint

## 55 ELF (ELF)
Status: relaxed template (lock flag)
Extra: increaseApproval, decreaseApproval
    - mintTokens - custom functionality
    - burnTokens - standard burn
    - multiple custom functions

## 56 AION (AION)
Status: not compatible. Transfer functionality forwarded to other contracts.

## 57 Republic (REN)
Status: relaxed template (pausable)
Extra: burn, increaseApproval, decreaseApproval

# Summary for top 53 (02/03/2020)
- Compatible:                   16 
- Relaxed template:             21
- Not compatible:                6
- Proxy pattern:                 4
- Source code not available:     4
- Incomplete ERC20:              2

# Common extra functionality
Total contracts that fit our template: 37

- mint:                                10
- burn:                                17
- burnFrom:                             3
- increaseApproval/decreaseApproval:   12
- approveAndCall:                       6

# Causes for relaxed template
- lock flag only (Pausable):       14
- time-based lock:                  2
- whitelist/blacklist:              3
- whitelist/blacklist + lock flag:  2 
Total: 21

# Variance in mint/burn functionality
Events triggered:
    - Some mint/burn calls trigger only Mint or Burn event, some trigger Transfer, some trigger both.
    - burnFrom is sometimes implemented as burn() with 3 arguments.

Other common functionality in many contracts:
    - Pausable, Ownable.
    - Pausable usually has 2 functions: pause() - pauses transfers. unpause() - resumes transfers.
    - Ownable allows transfer of ownership to another account.
    - Certain operations, like mint/burn are only allowed by the owner.

# Pure contracts, that only contain ERC20 and common extension functions
Order numbers: 04, 05, 09, 14, 21, 23, 31, 33, 34, 44
Total: 10/37 (from all compatible and relaxed template)
