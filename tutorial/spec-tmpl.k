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
        <callStack> _ => _ </callStack>
        <interimStates> _ => _ </interimStates>
        <touchedAccounts> _ => _ </touchedAccounts>
        <callState>
          //
          <program> #asMapOpCodes(#dasmOpCodes(#parseByteStack({PERSON_CODE}), BYZANTIUM)) </program>
          <programBytes> #parseByteStack({PERSON_CODE}) </programBytes>
          <id> #PERSON_ID  </id> // this
          <caller> #ORIGIN_ID </caller> // msg.sender
          <callData> {CALLDATA} </callData> // msg.data
          <callValue> {CALLVALUE} </callValue> // msg.value
          //
          <wordStack> .WordStack => _ </wordStack>
          <localMem> .Map => _ </localMem>
          <pc> 0 => _ </pc>
          <gas> 10000000 => _ </gas>
          <memoryUsed> 0 => _ </memoryUsed>
          <previousGas> _ => _ </previousGas>
          <static> false </static> // NOTE: non-static call
          <callDepth> CD </callDepth>
        </callState>
        <substate>
          <selfDestruct> _ </selfDestruct>
          <log> _ => _ </log>
          <refund> _ => _ </refund>
        </substate>
        <gasPrice> _ </gasPrice>
        <origin> #ORIGIN_ID </origin> // tx.origin
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
        <activeAccounts> SetItem(51966) SetItem(#PERSON_ID) SetItem(#ORIGIN_ID) </activeAccounts>
        <accounts>
          <account>
            <acctID> 51966 </acctID>
            <balance> {CAFE_BALANCE} </balance>
            <code> #parseByteStack({CAFE_CODE}) </code>
            <storage> _ </storage>
            <origStorage> _ </origStorage>
            <nonce> _ </nonce>
          </account>
          <account>
            <acctID> #PERSON_ID </acctID>
            <balance> {PERSON_BALANCE} </balance>
            <code> #parseByteStack({PERSON_CODE}) </code>
            <storage> _ </storage>
            <origStorage> _ </origStorage>
            <nonce> _ </nonce>
          </account>
          <account>
            <acctID> #ORIGIN_ID </acctID>
            <balance> {ORIGIN_BALANCE} </balance>
            <code> _ </code>
            <storage> _ </storage>
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
    requires #range(0 <= CD < 1024)
     andBool #rangeAddress(#PERSON_ID)
     andBool #rangeAddress(#ORIGIN_ID)
     andBool 51966 =/=Int #PERSON_ID
     andBool 51966 =/=Int #ORIGIN_ID
     andBool #PERSON_ID =/=Int #ORIGIN_ID
     andBool #PERSON_ID >Int 0 andBool (notBool #PERSON_ID in #precompiledAccounts(BYZANTIUM))
     andBool #ORIGIN_ID >Int 0 andBool (notBool #ORIGIN_ID in #precompiledAccounts(BYZANTIUM))
{REQUIRES}
    ensures true
{ENSURES}
