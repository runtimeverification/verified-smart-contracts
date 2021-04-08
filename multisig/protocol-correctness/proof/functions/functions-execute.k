require "protocol-correctness/proof/execution-proof.k"

module FUNCTIONS-EXECUTE-SYNTAX
  imports EXECUTION-PROOF-SYNTAX
endmodule

module PROPOSE-ACTION-INSTRUMENTATION
  imports PROOF-INSTRUMENTATION
  imports PSEUDOCODE

  syntax KItem ::= "split-propose-action"
  syntax KItem ::= "split-propose-action1"

  rule preCall ~> (.K => split-propose-action) ~> call(proposeAction(_Action:Action))
  [priority(20)]

  rule  <k> split-propose-action
            =>  branchK(
                  Caller in_keys(AddressToUserId),
                  makeConcreteValue(Caller, rUsize, AddressToUserId)
                    ~>  split-propose-action1,
                  .K
                )
        ... </k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <caller-address>Caller:KItem</caller-address>

  rule  <k> split-propose-action1
            =>  branchK(
                  AddressToUserId[Caller] in_keys(UserIdToRole),
                  makeConcreteValue(AddressToUserId[Caller], rUserRole, UserIdToRole),
                  .K
                )
        ... </k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <user-roles> UserIdToRole:Map </user-roles>
        <caller-address>Caller:KItem</caller-address>
endmodule

module FUNCTIONS-INSTRUMENTATION
  imports PROOF-INSTRUMENTATION

  rule  preCall
      ~> (.K => concretizeValue(Role))
      ~> call(canSign(Role:UserRole))
  [priority(20)]
endmodule

module FUNCTIONS-HELPERS
  imports PSEUDOCODE

  // TODO: Move to pseudocode.k
  syntax Int ::= metadataToInt(CodeMetadata)  [function, functional]
  rule metadataToInt(meta(Value:Int)) => Value

  syntax CodeMetadata ::= codeMetadataFunction(upgradeable:Bool, payable:Bool, readable:Bool)
      [function, functional]
  rule codeMetadataFunction(Upgradeable:Bool, Payable:Bool, Readable:Bool)
      => meta(
               metadataToInt(CodeMetadata::DEFAULT)
          |Int #if Upgradeable #then metadataToInt(CodeMetadata::UPGRADEABLE) #else 0 #fi
          |Int #if Payable #then metadataToInt(CodeMetadata::PAYABLE) #else 0 #fi
          |Int #if Readable #then metadataToInt(CodeMetadata::READABLE) #else 0 #fi
        )
endmodule

module FUNCTIONS-EXECUTE
  imports EXECUTION-PROOF

  imports FUNCTIONS-INSTRUMENTATION
  imports PROPOSE-ACTION-INSTRUMENTATION

  imports FUNCTIONS-HELPERS
endmodule
