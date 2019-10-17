  // {RULENAME} {COMMENT}
  rule
    <k> {K} </k>
    <exit-code> 1 </exit-code>
    <mode> NORMAL </mode>
    <schedule> BYZANTIUM </schedule>
    <ethereum>
      <evm>
        <output> {OUTPUT} </output>
        <statusCode> {STATUSCODE} </statusCode>
        <callStack> {CALLSTACK} </callStack>
        <interimStates> _ </interimStates>
        <touchedAccounts> _ => _ </touchedAccounts>
        <callState>
          <program> #parseByteStack({CODE}) </program>
          <jumpDests> #computeValidJumpDests(#parseByteStack({CODE})) </jumpDests>

          <id> CASPER_ACCT_ID </id> // this
          <caller> CALLER_ID </caller> // msg.sender
          <callData> {CALLDATA} </callData> // msg.data
          <callValue> {CALLVALUE} </callValue> // msg.value
          <wordStack> {WORDSTACK} </wordStack>
          <localMem> {LOCALMEM} </localMem>
          <pc> {PC} </pc>
          <gas> {GAS} </gas>
          <memoryUsed> {MEMORYUSED} </memoryUsed>
          <callGas> _ => _ </callGas>
          <static> false </static> // NOTE: non-static call
          <callDepth> {CALLDEPTH} </callDepth>
        </callState>
        <substate>
          <selfDestruct> _ </selfDestruct>
          <log> {LOG} </log>
          <refund> {REFUND} </refund>
        </substate>
        <gasPrice> _ </gasPrice>
        <origin> ORIGIN_ID </origin> // tx.origin
        <blockhashes> BLOCK_HASHES </blockhashes> // block.blockhash
        <block>
          <previousHash> _ </previousHash>
          <ommersHash> _ </ommersHash>
          <coinbase> {COINBASE} </coinbase> // block.coinbase
          <stateRoot> _ </stateRoot>
          <transactionsRoot> _ </transactionsRoot>
          <receiptsRoot> _ </receiptsRoot>
          <logsBloom> _ </logsBloom>
          <difficulty> _ </difficulty>
          <number> BLOCK_NUM </number> // block.number
          <gasLimit> _ </gasLimit>
          <gasUsed> _ </gasUsed>
          <timestamp> NOW </timestamp> // now = block.timestamp
          <extraData> _ </extraData>
          <mixHash> _ </mixHash>
          <blockNonce> _ </blockNonce>
          <ommerBlockHeaders> _ </ommerBlockHeaders>
        </block>
      </evm>
      <network>
        <activeAccounts> {ACTIVEACCOUNTS} </activeAccounts>
        <accounts>
          <account>
            <acctID> CASPER_ACCT_ID </acctID>
            <balance> {CASPERBALANCE} </balance>
            <code> #parseByteStack({CODE}) </code>
            <storage>
{STORAGE}
            </storage>
            <origStorage> _ </origStorage>
            <nonce> _ </nonce>
          </account>
{ACCOUNTS}
          ...
        </accounts>
        <txOrder> _ </txOrder>
        <txPending> _ </txPending>
        <messages> _ </messages>
      </network>
    </ethereum>
    requires #rangeAddress(CASPER_ACCT_ID)
     andBool #rangeAddress(CALLER_ID)
     andBool #rangeAddress(ORIGIN_ID)
     andBool #rangeUInt(256, NOW)
  // andBool #rangeUInt(128, BLOCK_NUM) // Solidity
     andBool #range(0 <= BLOCK_NUM <= maxSInt128) // Vyper (for now)
     // Account address normality
     andBool CASPER_ACCT_ID >Int 0 andBool (notBool CASPER_ACCT_ID in #precompiledAccounts(BYZANTIUM))
{REQUIRES}
{ENSURES}
{ATTRIBUTE}
