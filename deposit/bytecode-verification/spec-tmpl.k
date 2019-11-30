// {RULENAME} {COMMENT}
rule
<kevm>
  <k> {K} </k>
  <exit-code> 1 </exit-code>
  <mode> NORMAL </mode>
  <schedule> {SCHEDULE} </schedule>
  <ethereum>
    <evm>
      <output> {OUTPUT} </output>
      <statusCode> {STATUS_CODE} </statusCode>
      <callStack> {CALL_STACK} </callStack>
      <interimStates> _ </interimStates>
      <touchedAccounts> _ => _ </touchedAccounts>
      <callState>
        <program> #parseByteStack({CODE}) </program>
        <jumpDests> #computeValidJumpDests(#parseByteStack({CODE})) </jumpDests>
        <id> {THIS} </id> // this
        <caller> {MSG_SENDER} </caller> // msg.sender
        <callData> {CALL_DATA} </callData> // msg.data
        <callValue> {CALL_VALUE} </callValue> // msg.value
        <wordStack> {WORD_STACK} </wordStack>
        <localMem> {LOCAL_MEM} </localMem>
        <pc> {PC} </pc>
        <gas> {GAS} </gas>
        <memoryUsed> {MEMORY_USED} </memoryUsed>
        <callGas> _ => _ </callGas>
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
      <activeAccounts> {ACTIVE_ACCOUNTS} SetItem({THIS}) SetItem(2) SetItem(4) _:Set </activeAccounts>
      <accounts>
        <account>
          <acctID> {THIS} </acctID>
          <balance> {BALANCE} </balance>
          <code> #parseByteStack({CODE}) </code>
          <storage> {STORAGE} </storage>
          <origStorage> {ORIG_STORAGE} </origStorage>
          <nonce> {NONCE} </nonce>
        </account>
        <account>
          // precompiled account for SHA256
          <acctID> 2 </acctID>
          <balance> 0 </balance>
          <code> .WordStack </code>
          <storage> .Map </storage>
          <origStorage> .Map </origStorage>
          <nonce> 0 </nonce>
        </account>
        <account>
          // precompiled account for ID
          <acctID> 4 </acctID>
          <balance> 0 </balance>
          <code> .WordStack </code>
          <storage> .Map </storage>
          <origStorage> .Map </origStorage>
          <nonce> 0 </nonce>
        </account>
        {ACCOUNTS}
        ...
      </accounts>
      <txOrder> _ </txOrder>
      <txPending> _ </txPending>
      <messages> _ </messages>
    </network>
  </ethereum>
</kevm>
  requires #rangeAddress(ORIGIN_ID)
   // builtins
   andBool #rangeUInt(256, NOW)
   andBool #rangeUInt(128, BLOCK_NUM) // Solidity
   {REQUIRES}
  ensures true
   {ENSURES}
{ATTRIBUTE}
