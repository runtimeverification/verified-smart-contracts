  // {RULENAME} {COMMENT}
  rule
    <k> {K} </k>
    <exit-code> 1 </exit-code>
    <mode> NORMAL </mode>
    <schedule> BYZANTIUM </schedule>

    <ethereum>
      <evm>
        <output> {OUTPUT} </output>
        <statusCode> {STATUSCODE} </statusCode>
        <callStack> _ </callStack>
        <interimStates> _ </interimStates>
        <touchedAccounts> _ => _ </touchedAccounts>

        <callState>
          <program> #parseByteStack({CODE}) </program>
          <jumpDests> #computeValidJumpDests(#parseByteStack({CODE})) </jumpDests>

          <id> PROXY_ID </id> // `this`
          <caller> {MSG_SENDER} </caller> // `msg.sender`

          <callData> {CALLDATA} </callData> // msg.data

          <callValue> {CALLVALUE} </callValue> // msg.value
          <wordStack> .WordStack => _ </wordStack>
          <localMem> .Map => _ </localMem>
          <pc> 0 => _ </pc>
          <gas> 100000 => _ </gas>
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
        <blockhashes> _ </blockhashes> // block.blockhash
        <block>
          <previousHash> _ </previousHash>
          <ommersHash> _ </ommersHash>
          <coinbase> _ </coinbase> // block.coinbase
          <stateRoot> _ </stateRoot>
          <transactionsRoot> _ </transactionsRoot>
          <receiptsRoot> _ </receiptsRoot>
          <logsBloom> _ </logsBloom>
          <difficulty> _ </difficulty>
          <number> _ </number> // block.number
          <gasLimit> _ </gasLimit>
          <gasUsed> _ </gasUsed>
          <timestamp> _ </timestamp> // now = block.timestamp
          <extraData> _ </extraData>
          <mixHash> _ </mixHash>
          <blockNonce> _ </blockNonce>

          <ommerBlockHeaders> _ </ommerBlockHeaders>
        </block>
      </evm>
      <network>
        <chainID> 0 </chainID>
        <activeAccounts> SetItem(MASTER_COPY_ID) SetItem(PROXY_ID) SetItem(CREATOR_ID) _:Set </activeAccounts>
        <accounts>
          <account>
            <acctID> MASTER_COPY_ID </acctID>
            <balance> _ </balance>
            <code> #parseByteStack({MASTER_COPY_CODE}) </code>
            <storage> _ </storage>
            <origStorage> _ </origStorage>
            <nonce> _ </nonce>
          </account>
          <account>
            <acctID> PROXY_ID </acctID>
            <balance> PROXY_BALANCE </balance>
            <code> #parseByteStack({PROXY_CODE}) </code>
            <storage>
              {STORAGE}
              _:Map
            </storage>
            <origStorage> _ </origStorage>
            <nonce> _ </nonce>
          </account>
          <account>
            <acctID> CREATOR_ID </acctID>
            <balance> CREATOR_BALANCE </balance>
            <code> _ </code>
            <storage> _ </storage>
            <origStorage> _ </origStorage>
            <nonce> _ </nonce>
          </account>
          <account>
            <acctID> RANDOM_ID </acctID>
            <balance> RANDOM_BALANCE </balance>
            <code> _ </code>
            <storage> _ </storage>
            <origStorage> _ </origStorage>
            <nonce> _ </nonce>
          </account>
          ...
        </accounts>
        <txOrder> _ </txOrder>
        <txPending> _ </txPending>
        <messages> _ </messages>
      </network>
    </ethereum>
    requires #rangeAddress(MASTER_COPY_ID)
    andBool #rangeAddress(PROXY_ID)
    andBool #rangeAddress(ORIGIN_ID)
    andBool #rangeAddress(CREATOR_ID)
    andBool #rangeAddress(RANDOM_ID)

    //
    andBool MASTER_COPY_ID =/=Int PROXY_ID
    andBool MASTER_COPY_ID =/=Int ORIGIN_ID
    andBool PROXY_ID       =/=Int ORIGIN_ID
    andBool CREATOR_ID     =/=Int PROXY_ID
    andBool CREATOR_ID     =/=Int MASTER_COPY_ID
    andBool RANDOM_ID      =/=Int CREATOR_ID
    andBool RANDOM_ID      =/=Int PROXY_ID

    // Account address normality
    andBool MASTER_COPY_ID >Int 0 andBool (notBool MASTER_COPY_ID in #precompiledAccounts(BYZANTIUM))
    andBool PROXY_ID       >Int 0 andBool (notBool PROXY_ID       in #precompiledAccounts(BYZANTIUM))
    andBool ORIGIN_ID      >Int 0 andBool (notBool ORIGIN_ID      in #precompiledAccounts(BYZANTIUM))
    andBool CREATOR_ID     >Int 0 andBool (notBool CREATOR_ID     in #precompiledAccounts(BYZANTIUM))
    //
    // K branches during delegatecall without assuming 0 <= BALANCE
    andBool #rangeUInt(256, PROXY_BALANCE)
    andBool #rangeUInt(256, CREATOR_BALANCE)
    andBool #rangeUInt(256, RANDOM_BALANCE)
    //
    andBool 0 <=Int CALL_DEPTH andBool CALL_DEPTH <Int 1023

{REQUIRES}
