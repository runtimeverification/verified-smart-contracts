#!/usr/bin/env bash

kprove --debugg \
--output-omit "<exit-code>" --output-omit "<mode>" --output-omit "<schedule>" --output-omit "<analysis>" \
--output-omit "<callStack>" --output-omit "<interimStates>" --output-omit "<touchedAccounts>" --output-omit "<program>" \
--output-omit "<programBytes>" --output-omit "<id>" --output-omit "<caller>" --output-omit "<callData>" \
--output-omit "<callValue>" --output-omit "<memoryUsed>" --output-omit "<callGas>" --output-omit "<static>" \
--output-omit "<callDepth>" --output-omit "<substate>" --output-omit "<gasPrice>" --output-omit "<origin>" \
--output-omit "<previousHash>" --output-omit "<ommersHash>" --output-omit "<coinbase>" --output-omit "<stateRoot>" \
--output-omit "<transactionsRoot>" --output-omit "<receiptsRoot>" --output-omit "<logsBloom>" --output-omit "<difficulty>" \
--output-omit "<number>" --output-omit "<gasLimit>" --output-omit "<gasUsed>" --output-omit "<timestamp>" \
--output-omit "<extraData>" --output-omit "<mixHash>" --output-omit "<blockNonce>" --output-omit "<ommerBlockHeaders>" \
--output-omit "<blockhash>" --output-omit "<activeAccounts>" --output-omit "<balance>" --output-omit "<code>" \
--output-omit "<nonce>" --output-omit "<txOrder>" --output-omit "<txPending>" \
--output-tostring "<messages>" \
--output-tokenize "<k>" --output-tostring "<output>" --output-tostring "<statusCode>" --output-tostring "<pc>" \
--output-tostring "<gas>" --output-tostring "<wordStack>" --output-tostring "<acctID>" --output-tostring "<storage>" \
--output-tostring "<localMem>" --output-tokenize "#And" --output-tokenize "_==K_" --output-flatten "_|->_" \
"$@"
