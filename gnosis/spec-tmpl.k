  // {RULENAME} {COMMENT}
  rule
    <k> {K} </k>
    <exit-code> 1 </exit-code>
    <mode> NORMAL </mode>
    <schedule> BYZANTIUM </schedule>
    <analysis> .Map </analysis> // not part of evm
    <ethereum>
      <evm>
        <output> {OUTPUT} </output>
        <statusCode> {STATUSCODE} </statusCode>
        <callStack> {CALLSTACK} </callStack>
        <interimStates> _ </interimStates>
        <touchedAccounts> _ => _ </touchedAccounts>
        <callState>
          <program> #asMapOpCodes(#dasmOpCodes(#parseByteStack({CODE}), BYZANTIUM)) </program>
          <programBytes> #parseByteStack({CODE}) </programBytes>
          <id> {THIS} </id> // `this`
          <caller> {MSG_SENDER} </caller> // `msg.sender`
          <callData> {CALLDATA} </callData> // msg.data
          <callValue> {CALLVALUE} </callValue> // msg.value
          <wordStack> {WORDSTACK} </wordStack>
          <localMem> {LOCALMEM} </localMem>
          <pc> {PC} </pc>
          <gas> {GAS} </gas>
          <memoryUsed> {MEMORYUSED} </memoryUsed>
          <previousGas> _ => _ </previousGas>
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
        <blockhash> BLOCK_HASHES </blockhash> // block.blockhash
      </evm>
      <network>
        <activeAccounts> {ACTIVEACCOUNTS} </activeAccounts>
        <accounts>
          <account>
            <acctID> MASTER_COPY_ID </acctID>
            <balance> {MASTER_COPY_BAL} </balance>
            <code> #parseByteStack({MASTER_COPY_CODE}) </code>
            <storage>
{MASTER_COPY_STORAGE}
            </storage>
            <origStorage> _ </origStorage>
            <nonce> {MASTER_COPY_NONCE} </nonce>
          </account>
          <account>
            <acctID> PROXY_ID </acctID>
            <balance> {PROXY_BAL} </balance>
            <code> #parseByteStack({PROXY_CODE}) </code>
            <storage>
{PROXY_STORAGE}
            </storage>
            <origStorage> _ </origStorage>
            <nonce> {PROXY_NONCE} </nonce>
          </account>
          <account>
            <acctID> ORIGIN_ID </acctID>
            <balance> {ORIGIN_BAL} </balance>
            <code> #parseByteStack({ORIGIN_CODE}) </code>
            <storage>
{ORIGIN_STORAGE}
            </storage>
            <origStorage> _ </origStorage>
            <nonce> {ORIGIN_NONCE} </nonce>
          </account>
{ACCOUNTS}
          ...
        </accounts>
        <txOrder> _ </txOrder>
        <txPending> _ </txPending>
        <messages> _ </messages>
      </network>
    </ethereum>
    requires #rangeAddress(MASTER_COPY_ID)
     andBool #rangeAddress(PROXY_ID)
     andBool #rangeAddress(ORIGIN_ID)
     andBool #rangeUInt(256, MASTER_BAL)
     andBool #rangeUInt(256, PROXY_BAL)
     andBool #rangeUInt(256, ORIGIN_BAL)
     andBool #rangeUInt(256, NOW)
     andBool #rangeUInt(128, BLOCK_NUM) // Solidity
     //
     andBool MASTER_COPY_ID =/=Int PROXY_ID
     andBool MASTER_COPY_ID =/=Int ORIGIN_ID
     andBool PROXY_ID       =/=Int ORIGIN_ID
     // Account address normality
     andBool MASTER_COPY_ID >Int 0 andBool (notBool MASTER_COPY_ID in #precompiledAccounts(BYZANTIUM))
     andBool PROXY_ID       >Int 0 andBool (notBool PROXY_ID       in #precompiledAccounts(BYZANTIUM))
     andBool ORIGIN_ID      >Int 0 andBool (notBool ORIGIN_ID      in #precompiledAccounts(BYZANTIUM))
{REQUIRES}
{ENSURES}
{ATTRIBUTE}
