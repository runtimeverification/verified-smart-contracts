//@ proof
module PROOF-PROPOSE-SC-DEPLOY-FRAGMENT
//@ trusted
// module TRUSTED-PROPOSE-SC-DEPLOY-FRAGMENT
//@ end
  imports FUNCTIONS-EXECUTE

  claim <T><TT>
          <k> runPseudoCode(
                  code_metadata = CodeMetadata::DEFAULT;
                  if (Upgradeable) {
                    code_metadata = code_metadata | CodeMetadata::UPGRADEABLE;
                  }
                  if (Payable) {
                    code_metadata = code_metadata | CodeMetadata::PAYABLE;
                  }
                  if (Readable) {
                    code_metadata = code_metadata | CodeMetadata::READABLE;
                  }
                  proposeActionSCDeploy(Amount, Code, code_metadata, Args);
              )
              ~> K:K
          </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              UserIdToRole:Map,
              Quorum:Usize,
              u(ActionLastIndex:Int),
              ActionData:Map,
              ActionSigners:Map,
              CallerAddress:Address,
              //@ proof
              .List,  // TODO: Stack:List,
              //@ trusted
              // Stack:List,
              //@ end
              .Map
              )
        </TT></T>
      =>
        <T><TT>
          <k> runPseudoCode(
                  proposeActionSCDeploy(Amount, Code, code_metadata, Args);
              )
              ~> K:K
          </k>
          invariantStateFull(
              NumUsers:Usize,
              UserIdToAddress:Map,
              AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              UserIdToRole:Map,
              Quorum:Usize,
              u(ActionLastIndex:Int),
              ActionData:Map,
              ActionSigners:Map,
              CallerAddress:Address,
              //@ proof
              .List,  // TODO: Stack:List,
              //@ trusted
              // Stack:List,
              //@ end
              code_metadata |-> codeMetadataFunction(Upgradeable, Payable, Readable)
              )
        </TT></T>
    requires true
    ensures true
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule
