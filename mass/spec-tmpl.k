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
        <statusCode> {STATUSCODE} </statusCode>
        <callStack> {CALLSTACK} </callStack>
        <interimStates> {INTERIMSTATES} </interimStates>
        <touchedAccounts> _ => _ </touchedAccounts>
        <callState>
          //
          <program> _ => #asMapOpCodes(#dasmOpCodes(#parseByteStack("{CODE}"), BYZANTIUM)) </program>
          <programBytes> _ => #parseByteStack("{CODE}") </programBytes>
          <id> _ => {CONTRACT_ADDRESS} </id> // this
          <caller> _ => #CALLER_ID </caller> // msg.sender
          <callData> _ => {CALLDATA} </callData> // msg.data
          <callValue> _ => {CALLVALUE} </callValue> // msg.value
          //
          <wordStack> .WordStack => _ </wordStack>
          <localMem> .Map => _ </localMem>
          <pc> 0 => _ </pc>
          <gas> #gas(INITGAS, 0, 0) => _ </gas>
          <memoryUsed> 0 => _ </memoryUsed>
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
        <activeAccounts> {ACTIVEACCOUNTS} </activeAccounts>
        <accounts>
          <account>
            <acctID> {CONTRACT_ADDRESS} </acctID>
            <balance> {ACCT_BALANCE} </balance>
            <code> #parseByteStack("{CODE}") </code>
            <storage> {STORAGE} </storage>
            <origStorage> _ </origStorage>
            <nonce> _ </nonce>
          </account>
          <account>
            <acctID> #CALLER_ID </acctID>
            <balance> {CALLER_BALANCE} </balance>
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
    requires #range(0 <= CALLDEPTH < 1024)
     /* andBool #rangeAddress({CONTRACT_ADDRESS}) */
     andBool #rangeAddress(#CALLER_ID)
     andBool #rangeAddress(ORIGIN_ID)
     andBool {CONTRACT_ADDRESS} =/=Int #CALLER_ID
     /* andBool #ACCT_ID   >Int 0 andBool (notBool #ACCT_ID   in #precompiledAccounts(BYZANTIUM)) */
     andBool #CALLER_ID >Int 0 andBool (notBool #CALLER_ID in #precompiledAccounts(BYZANTIUM))
{REQUIRES}
    ensures true
{ENSURES}
