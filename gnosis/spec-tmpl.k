  // {RULENAME}
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
        <callStack> _ </callStack>
        <interimStates> _ </interimStates>
        <touchedAccounts> _ => _ </touchedAccounts>

        <callState>
          <program> #asMapOpCodes(#dasmOpCodes(#parseByteStack({CUR_CODE}), BYZANTIUM)) </program>
          <programBytes> #parseByteStack({CUR_CODE}) </programBytes>

          //<id> PROXY_ACCT_ID </id> // `this`
          //<caller> CALLER_ID </caller> // `msg.sender`

          <id> {THIS} </id> // `this`
          <caller> {MSG_SENDER} </caller> // `msg.sender`

          <callData> {CALLDATA} </callData>

          <callValue> 0 </callValue>
          <wordStack> {WORDSTACK} </wordStack>
          <localMem> {LOCALMEM} </localMem>
          <pc> {PC} </pc>
          <gas> {GAS} </gas>
          <memoryUsed> 0 => _ </memoryUsed>
          <previousGas> _ => _ </previousGas>

          <static> false </static> // NOTE: non-static call
          <callDepth> CD </callDepth>
        </callState>

        <substate>
          <selfDestruct> _ </selfDestruct>
          <log> {LOG} </log>
          <refund> {REFUND} </refund> // TODO: more detail
        </substate>

        <gasPrice> _ </gasPrice>
        <origin> ORIGIN_ID </origin> // who fires tx

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
            <acctID> MASTER_COPY_ACCT_ID </acctID>
            <balance> MASTER_BAL </balance>
            <code> #parseByteStack({MASTER_COPY_CODE}) </code>
            <storage>
              _:Map
            </storage>
            <nonce> _ </nonce>
          </account>
          <account>
            <acctID> PROXY_ACCT_ID </acctID>
            <balance> PROXY_BAL </balance>
            <code> #parseByteStack({PROXY_CODE}) </code>
            <storage>
              {STORAGE}
            </storage>
            <nonce> _ </nonce>
          </account>
          <account>
            <acctID> CALLER_ID </acctID>
            <balance> CALLER_BAL </balance>
            <code> {CALLER_CODE} </code>
            <storage> _  </storage>
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
    requires #rangeAddress(MASTER_COPY_ACCT_ID)
     andBool #rangeAddress(PROXY_ACCT_ID)
     andBool #rangeAddress(CALLER_ID)
     andBool #rangeAddress(ORIGIN_ID)
     andBool #rangeUInt(256, NOW)
     andBool #rangeUInt(128, BLOCK_NUM) // Solidity
     // Account address normality
     andBool MASTER_COPY_ACCT_ID >Int 0
     andBool (notBool MASTER_COPY_ACCT_ID in #precompiledAccounts(BYZANTIUM))
     andBool PROXY_ACCT_ID >Int 0
     andBool (notBool PROXY_ACCT_ID in #precompiledAccounts(BYZANTIUM))
{REQUIRES}
{ENSURES}
{ATTRIBUTE}
