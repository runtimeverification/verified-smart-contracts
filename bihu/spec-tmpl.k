  // {RULENAME}
  rule
    <k> {K} </k>
    <exit-code> 1 </exit-code>
    <mode> NORMAL </mode>
    <schedule> BYZANTIUM </schedule>

    <ethereum>
      <evm>
        <output> {OUTPUT} </output>
        <statusCode> {STATUSCODE} </statusCode>
        <callStack> _ => _ </callStack>
        <interimStates> _ </interimStates>
        <touchedAccounts> _ => _ </touchedAccounts>

        <callState>
          <program> #parseByteStack({CODE}) </program>
          <jumpDests> #computeValidJumpDests(#parseByteStack({CODE})) </jumpDests>

          <id> ACCT_ID </id> // contract owner
          <caller> CALLER_ID </caller> // who called this contract; in the begining, origin // msg.sender

          <callData> {CALLDATA} </callData>

          <callValue> 0 </callValue>
          <wordStack> {WORDSTACK} </wordStack>
          <localMem> {LOCALMEM} </localMem>
          <pc> {PC} </pc>
          <gas> {GAS} </gas>
          <memoryUsed> {MEMORYUSED} </memoryUsed>
          <callGas> _ => _ </callGas>

          <static> false </static> // NOTE: non-static call
          <callDepth> CALL_DEPTH </callDepth>
        </callState>

        <substate>
          <selfDestruct> _ </selfDestruct>
          <log> {LOG} </log>
          <refund> {REFUND} </refund> // TODO: more detail
        </substate>

        <gasPrice> _ </gasPrice>
        <origin> ORIGIN_ID </origin> // who fires tx
        <blockhashes> _ </blockhashes>
        <block>
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
          <timestamp> NOW </timestamp> // block.timestamp // now
          <extraData> _ </extraData>
          <mixHash> _ </mixHash>
          <blockNonce> _ </blockNonce>

          <ommerBlockHeaders> _ </ommerBlockHeaders>
        </block>
      </evm>

      <network>
        <activeAccounts> SetItem(ACCT_ID) _:Set </activeAccounts>

        <accounts>
          <account>
            <acctID> ACCT_ID </acctID>
            <balance> _ </balance>
            <code> #parseByteStack({CODE}) </code>
            <storage>
{STORAGE}
            </storage>
            <origStorage> _ </origStorage>
            <nonce> _ </nonce>
          </account>
       // ... // TODO: fix
        </accounts>

        <txOrder> _ </txOrder>
        <txPending> _ </txPending>
        <messages> _ </messages>
      </network>
    </ethereum>
    requires 0 <=Int ACCT_ID    andBool ACCT_ID    <Int (2 ^Int 160)
     andBool 0 <=Int CALLER_ID  andBool CALLER_ID  <Int (2 ^Int 160)
     andBool 0 <=Int ORIGIN_ID  andBool ORIGIN_ID  <Int (2 ^Int 160)
     andBool 0 <=Int NOW        andBool NOW        <Int (2 ^Int 256)
     andBool 0 <=Int CALL_DEPTH andBool CALL_DEPTH <Int 1024
{REQUIRES}
{ENSURES}
{ATTRIBUTE}
