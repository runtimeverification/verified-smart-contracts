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
        <callStack> {CALLSTACK} </callStack>
        <interimStates> _ </interimStates>
        <callLog> .Set </callLog> // for vmtest only
        <touchedAccounts> _ => _ </touchedAccounts>

        <callState>
          <program> #asMapOpCodes(#dasmOpCodes(#parseByteStack({CODE}), BYZANTIUM)) </program>
          <programBytes> #parseByteStack({CODE}) </programBytes>

          <id> CASPER_ACCT_ID </id> // contract owner
          <caller> CALLER_ID </caller> // who called this contract; in the begining, origin // msg.sender

          <callData> {CALLDATA} </callData>

          <callValue> 0 </callValue>
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
          <refund> {REFUND} </refund> // TODO: more detail
        </substate>

        <gasPrice> _ </gasPrice>
        <origin> ORIGIN_ID </origin> // who fires tx

        <previousHash> _ </previousHash>
        <ommersHash> _ </ommersHash>
        <coinbase> COINBASE_ACCT_ID </coinbase>
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
        <activeAccounts> {ACTIVEACCOUNTS} </activeAccounts>

        <accounts>

          <account>
            <acctID> CASPER_ACCT_ID </acctID>
            <balance> CASPER_BAL </balance>
            <code> #parseByteStack({CODE}) </code>
            <storage>
{STORAGE}
            </storage>
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
    requires 0 <=Int CASPER_ACCT_ID   andBool CASPER_ACCT_ID   <=Int maxUInt160
     andBool (notBool CASPER_ACCT_ID in #precompiledAccounts(BYZANTIUM))
     andBool 0 <=Int CALLER_ID        andBool CALLER_ID        <=Int maxUInt160
     andBool 0 <=Int ORIGIN_ID        andBool ORIGIN_ID        <=Int maxUInt160
     andBool 0 <=Int COINBASE_ACCT_ID andBool COINBASE_ACCT_ID <=Int maxUInt160
     andBool 0 <=Int BLOCK_NUM        andBool BLOCK_NUM        <=Int maxSInt128
     andBool 0 <=Int NOW              andBool NOW              <=Int maxUInt256
     andBool 0 <=Int CASPER_BAL       andBool CASPER_BAL       <=Int maxUInt256
{REQUIRES}
{ENSURES}
{ATTRIBUTE}
