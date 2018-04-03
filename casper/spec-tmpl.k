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
        <memoryUsed> {MEMORYUSED} </memoryUsed>
        <callDepth> {CALLDEPTH} </callDepth>
        <callStack> {CALLSTACK} </callStack>
        <interimStates> _ </interimStates>
        <substateStack> _ </substateStack>
        <callLog> .Set </callLog> // for vmtest only
        <touchedAccounts> _ => _ </touchedAccounts>

        <txExecState>
          <program> #asMapOpCodes(#dasmOpCodes(#parseByteStack({CODE}), BYZANTIUM)) </program>
          <programBytes> #parseByteStack({CODE}) </programBytes>

          <id> ACCT_ID </id> // contract owner
          <caller> CALLER_ID </caller> // who called this contract; in the begining, origin // msg.sender

          <callData> {CALLDATA} </callData>

          <callValue> 0 </callValue>
          <wordStack> {WORDSTACK} </wordStack>
          <localMem> {LOCALMEM} </localMem>
          <pc> {PC} </pc>
          <gas> {GAS} </gas>
          <previousGas> _ => _ </previousGas>

          <static> false </static> // NOTE: non-static call
        </txExecState>

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
        <number> BLOCK_NUM </number>
        <gasLimit> _ </gasLimit>
        <gasUsed> _ </gasUsed>
        <timestamp> NOW </timestamp> // block.timestamp // now
        <extraData> _ </extraData>
        <mixHash> _ </mixHash>
        <blockNonce> _ </blockNonce>

        <ommerBlockHeaders> _ </ommerBlockHeaders>
        <blockhash> BLOCK_HASHES </blockhash>
      </evm>

      <network>
        <activeAccounts> SetItem(ACCT_ID) _:Set </activeAccounts>

        <accounts>
          <account>
            <acctID> ACCT_ID </acctID>
            <balance> BAL </balance>
            <code> #parseByteStack({CODE}) </code>
            <storage>
{STORAGE}
            </storage>
            <nonce> _ </nonce>
          </account>
       // ... // TODO: fix
        </accounts>

        <txOrder> _ </txOrder>
        <txPending> _ </txPending>
        <messages> _ </messages>
      </network>
    </ethereum>
    requires 0 <=Int ACCT_ID   andBool ACCT_ID   <Int (2 ^Int 160)
     andBool (notBool ACCT_ID in #precompiledAccounts(BYZANTIUM))
     andBool 0 <=Int CALLER_ID andBool CALLER_ID <Int (2 ^Int 160)
     andBool 0 <=Int ORIGIN_ID andBool ORIGIN_ID <Int (2 ^Int 160)
     andBool 0 <=Int BLOCK_NUM andBool BLOCK_NUM <Int (2 ^Int 127)
     andBool 0 <=Int NOW       andBool NOW       <Int (2 ^Int 256)
     andBool 0 <=Int BAL       andBool BAL       <Int (2 ^Int 256)
{REQUIRES}
{ENSURES}
{ATTRIBUTE}
