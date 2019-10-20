// {RULENAME} {COMMENT}
rule
  <k> {K} </k>
  <exit-code> 1 </exit-code>
  <mode> NORMAL </mode>
  <schedule> {SCHEDULE} </schedule>

  <ethereum>
    <evm>
      <output> {OUTPUT} </output>
      <statusCode> {STATUSCODE} </statusCode>
      <callStack> _ </callStack>
      <interimStates> _ </interimStates>
      <touchedAccounts> _ => _ </touchedAccounts>
      <callState>
        <program> #asMapOpCodes(#dasmOpCodes(#parseByteStack({CODE}), {SCHEDULE})) </program>
        <programBytes> #parseByteStack({CODE}) </programBytes>
        <id> ACCT_ID </id> // this
        <caller> CALLER_ID </caller> // msg.sender
        <callData> {CALLDATA} </callData> // msg.data
        <callValue> 0 </callValue> // msg.value
        <wordStack> .WordStack => _ </wordStack>
        <localMem> .Map => _ </localMem>
        <pc> 0 => _ </pc>
        <gas> {GAS} </gas>
        <memoryUsed> 0 => _ </memoryUsed>
        <callGas> _ => _ </callGas>
        <static> false </static> // NOTE: non-static call
        <callDepth> CALL_DEPTH </callDepth>
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
      <coinbase> _ </coinbase>
      <stateRoot> _ </stateRoot>
      <transactionsRoot> _ </transactionsRoot>
      <receiptsRoot> _ </receiptsRoot>
      <logsBloom> _ </logsBloom>
      <difficulty> _ </difficulty>
      <number> _ </number>
      <gasLimit> _ </gasLimit>
      <gasUsed> _ </gasUsed>
      <timestamp> _ </timestamp>
      <extraData> _ </extraData>
      <mixHash> _ </mixHash>
      <blockNonce> _ </blockNonce>
      <ommerBlockHeaders> _ </ommerBlockHeaders>
      <blockhash> _ </blockhash>
    </evm>
    <network>
      <activeAccounts> SetItem(ACCT_ID) _:Set </activeAccounts>
      <accounts>
        <account>
          <acctID> ACCT_ID </acctID>
          <balance> _ </balance>
          <code> #parseByteStack({CODE}) </code>
          <storage> {STORAGE} </storage>
          <origStorage> {ORIGSTORAGE} </origStorage>
          <nonce> _ </nonce>
        </account>
        ...
      </accounts>
      <txOrder> _ </txOrder>
      <txPending> _ </txPending>
      <messages> _ </messages>
    </network>
  </ethereum>
  requires #rangeAddress(ACCT_ID)
   andBool #rangeAddress(CALLER_ID)
   andBool #rangeAddress(ORIGIN_ID)
   andBool #range(0 <= CALL_DEPTH < 1024)
   {REQUIRES}
  ensures true
   {ENSURES}
{ATTRIBUTE}
