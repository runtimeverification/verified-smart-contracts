// {RULENAME} {COMMENT}
rule
  <k> {K} </k>
  <exit-code> 1 </exit-code>
  <mode> NORMAL </mode>
  <schedule> {SCHEDULE} </schedule>
  <analysis> .Map </analysis> // not part of evm
  <ethereum>
    <evm>
      <output> {OUTPUT} </output>
      <statusCode> {STATUS_CODE} </statusCode>
      <callStack> {CALL_STACK} </callStack>
      <interimStates> _ </interimStates>
      <touchedAccounts> _ => _ </touchedAccounts>
      <callState>
        <program> #asMapOpCodes(#dasmOpCodes(#parseByteStack({CODE}), {SCHEDULE})) </program>
        <programBytes> #parseByteStack({CODE}) </programBytes>
        <id> {THIS} </id> // this
        <caller> {MSG_SENDER} </caller> // msg.sender
        <callData> {CALL_DATA} </callData> // msg.data
        <callValue> {CALL_VALUE} </callValue> // msg.value
        <wordStack> {WORD_STACK} </wordStack>
        <localMem> {LOCAL_MEM} </localMem>
        <pc> {PC} </pc>
        <gas> {GAS} </gas>
        <memoryUsed> {MEMORY_USED} </memoryUsed>
        <previousGas> _ => _ </previousGas>
        <static> false </static> // NOTE: non-static call
        <callDepth> {CALL_DEPTH} </callDepth>
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
      <activeAccounts> {ACTIVE_ACCOUNTS} </activeAccounts>
      <accounts>
        <account>
          <acctID> {THIS} </acctID>
          <balance> {BALANCE} </balance>
          <code> #parseByteStack({CODE}) </code>
          <storage> {STORAGE} </storage>
          <origStorage> {ORIG_STORAGE} </origStorage>
          <nonce> {NONCE} </nonce>
        </account>
/*
        <account>
          // precompiled account for ECCREC
          <acctID> 1 </acctID>
          <balance> 0 </balance>
          <code> .WordStack </code>
          <storage> .Map </storage>
          <origStorage> .Map </origStorage>
          <nonce> 0 </nonce>
        </account>
*/
        {ACCOUNTS}
        ...
      </accounts>
      <txOrder> _ </txOrder>
      <txPending> _ </txPending>
      <messages> _ </messages>
    </network>
  </ethereum>
  requires #rangeAddress(ORIGIN_ID)
   andBool #rangeAddress({THIS})
   andBool #rangeAddress({MSG_SENDER})
   // builtins
   andBool #rangeUInt(256, NOW)
   andBool #rangeUInt(128, BLOCK_NUM) // Solidity
   // Account address normality
   andBool {THIS} >Int 0 andBool (notBool {THIS} in #precompiledAccounts({SCHEDULE}))
   {REQUIRES}
  ensures true
   {ENSURES}
{ATTRIBUTE}
