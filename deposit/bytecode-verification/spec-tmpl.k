// {RULENAME} {COMMENT}
rule
<kevm>
  <k> {K} </k>
  <mode> NORMAL </mode>
  <schedule> {SCHEDULE} </schedule>
  <ethereum>
    <evm>
      <output> {OUTPUT} </output>
      <statusCode> {STATUS_CODE} </statusCode>
      <touchedAccounts> _ => ?_ </touchedAccounts>
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
        <callGas> _ => ?_ </callGas>
        <static> false </static> // NOTE: non-static call
        <callDepth> {CALL_DEPTH} </callDepth>
      </callState>
      <substate>
        <log> {LOG} </log>
        <refund> {REFUND} </refund>
        ...
      </substate>
      ...
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
      ...
    </network>
  </ethereum>
  ...
</kevm>
  requires true
   {REQUIRES}
  ensures true
   {ENSURES}
{ATTRIBUTE}
