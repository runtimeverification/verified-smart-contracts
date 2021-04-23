//@ proof
require "trusted-perform-parts-add-board-member.k"  //@ Bazel remove
require "trusted-perform-parts-add-proposer-signers.k"  //@ Bazel remove
require "trusted-perform-parts-add-proposer-no-signers.k"  //@ Bazel remove
require "trusted-perform-parts-change-quorum.k"  //@ Bazel remove
require "trusted-perform-parts-New.k"  //@ Bazel remove
require "trusted-perform-parts-no-quorum.k"  //@ Bazel remove
require "trusted-perform-parts-None.k"  //@ Bazel remove
require "trusted-perform-parts-remove-user.k"  //@ Bazel remove
require "trusted-perform-parts-sc-call.k"  //@ Bazel remove
require "trusted-perform-parts-sc-deploy.k"  //@ Bazel remove
require "trusted-perform-parts-send-egld.k"  //@ Bazel remove


module PROOF-PERFORM-PARTS-1
  imports INVARIANT-EXECUTION

  imports TRUSTED-PERFORM-PARTS-ADD-BOARD-MEMBER
  imports TRUSTED-PERFORM-PARTS-ADD-PROPOSER-SIGNERS
  imports TRUSTED-PERFORM-PARTS-ADD-PROPOSER-NO-SIGNERS
  imports TRUSTED-PERFORM-PARTS-CHANGE-QUORUM
  imports TRUSTED-PERFORM-PARTS-NEW
  imports TRUSTED-PERFORM-PARTS-NO-QUORUM
  imports TRUSTED-PERFORM-PARTS-NONE
  imports TRUSTED-PERFORM-PARTS-REMOVE-USER
  imports TRUSTED-PERFORM-PARTS-SC-CALL
  imports TRUSTED-PERFORM-PARTS-SC-DEPLOY
  imports TRUSTED-PERFORM-PARTS-SEND-EGLD
//@ trusted
// module TRUSTED-PERFORM-PARTS-1
//@ end
  imports PERFORM-ACTION-ENDPOINT-INSTRUMENTATION

  claim <T><TT>
          <k> splitAction(Action:Action)
              ~> splitPerformActionEndpoint4(Action)
              ~> call(performActionEndpoint(ActionId:Usize))
              ~> popContext
              ~> evaluateReturnValue
              ~> clearExternalCallEnv
              ~> splitActionSigners(ActionId:Usize, ActionSigners:Map)
              ~> runExternalCalls(EC:ExternalCommands)
          </k>
          invariantStateStack(
              NumUsers:Usize,
              UserIdToAddress:Map,
              (CallerAddress |-> CallerId:Usize _AddressToUserId:Map) #as AddressToUserId:Map,
              NumBoardMembers:Usize,
              NumProposers:Usize,
              (CallerId |-> CallerRole:UserRole _UserIdToRole:Map) #as UserIdToRole:Map,
              u(Quorum:Int),
              ActionLastIndex0:Usize,
              (ActionId |-> Action _ActionData:Map) #as ActionData:Map,
              (ActionId |-> Signers:ExpressionList _ActionSigners:Map) #as ActionSigners:Map,
              CallerAddress:Address,
              stack(
                  invariantMultisigState(
                      NumUsers,
                      UserIdToAddress,
                      AddressToUserId,
                      NumBoardMembers,
                      NumProposers,
                      UserIdToRole,
                      u(Quorum),
                      ActionLastIndex0,
                      ActionData,
                      ActionSigners),
                  .Map,
                  PerformedActions,
                  .stack),
              PerformedActions:List)
        </TT></T>
      =>
        <T><TT>
          <k> runExternalCalls(EC) </k>
          invariantState(
              ?NumUsers1:Usize,
              ?UserIdToAddress1:Map,
              ?AddressToUserId1:Map,
              ?NumBoardMembers1:Usize,
              ?NumProposers1:Usize,
              ?UserIdToRole1:Map,
              ?Quorum1:Usize,
              ?ActionLastIndex1:Usize,
              ?ActionData1:Map,
              ?ActionSigners1:Map,
              ?_PerformedActions:List):StateCell
        </TT></T>
    requires true
        andBool invariant(
            NumUsers,
            UserIdToAddress,
            AddressToUserId,
            NumBoardMembers,
            NumProposers,
            UserIdToRole,
            u(Quorum),
            ActionLastIndex0,
            ActionData,
            ActionSigners,
            expand(expanded))
        andBool (CallerRole ==K BoardMember orBool CallerRole ==K Proposer)
        andBool Quorum <=Int countCanSignFunction({ActionSigners[ActionId] orDefault [.]}:>ExpressionList, opaque(UserIdToRole))
    ensures invariant(
        ?NumUsers1,
        ?UserIdToAddress1,
        ?AddressToUserId1,
        ?NumBoardMembers1,
        ?NumProposers1,
        ?UserIdToRole1,
        ?Quorum1,
        ?ActionLastIndex1,
        ?ActionData1,
        ?ActionSigners1,
        usesExpanded)
    //@ proof
    //@ trusted
    // [trusted]
    //@ end
endmodule

/*
  #Not ( {
    A
  #Equals
    Nothing
  } )
#And
  #Not ( {
    CSV
  #Equals
    .
  } )
#And
  #Not ( {
    V
  #Equals
    0
  } )
#And
  #Not ( {
    V
  #Equals
    NumUsers0 +Int 1
  } )
#And
  #Not ( {
    V
  #Equals
    NumUsers0 +Int 2
  } )
#And
  #Not ( {
    _ActionId0
  #Equals
    ActionLastIndex1 +Int 1
  } )
#And
  <T>
    <TT>
      <k>
        splitAction ( A ) ~> splitPerformActionEndpoint4 ( A ) ~> call ( performActionEndpoint ( u ( _ActionId0 ) ) ) ~> popContext ~> evaluateReturnValue ~> clearExternalCallEnv ~> splitActionSigners ( u ( _ActionId0 ) , 'QuesUnds'Remainder1
        u ( _ActionId0 ) |-> [ CSV ] ) ~> runExternalCalls ( EC ) ~> .
      </k>
      <state>
        <multisig-state>
          <users>
            <num-users>
              u ( NumUsers0 )
            </num-users>
            <user-id-to-address>
              UserIdToAddress
            </user-id-to-address>
            <address-to-user-id>
              'QuesUnds'Remainder
              address ( _1 ) |-> u ( V )
            </address-to-user-id>
          </users>
          <board-state>
            <num-board-members>
              u ( countMapValues ( 'QuesUnds'Remainder0 , wrap ( BoardMember ) ) )
            </num-board-members>
            <num-proposers>
              u ( countMapValues ( 'QuesUnds'Remainder0 , wrap ( Proposer ) ) +Int 1 )
            </num-proposers>
            <user-roles>
              'QuesUnds'Remainder0
              u ( V ) |-> Proposer
            </user-roles>
            <quorum>
              u ( Quorum0 )
            </quorum>
          </board-state>
          <action-state>
            <action-last-index>
              u ( ActionLastIndex1 )
            </action-last-index>
            <actions>
              <action-data>
                'QuesUnds'Remainder2
                u ( _ActionId0 ) |-> A:Action
              </action-data>
              <action-signers>
                'QuesUnds'Remainder1
                u ( _ActionId0 ) |-> [ CSV ]
              </action-signers>
            </actions>
          </action-state>
        </multisig-state>
        <pseudocode-state>
          <variables>
            .Map
          </variables>
          <stack>
            stack ( <multisig-state>
              <users>
                <num-users>
                  u ( NumUsers0 )
                </num-users>
                <user-id-to-address>
                  UserIdToAddress
                </user-id-to-address>
                <address-to-user-id>
                  'QuesUnds'Remainder
                  address ( _1 ) |-> u ( V )
                </address-to-user-id>
              </users>
              <board-state>
                <num-board-members>
                  u ( countMapValues ( 'QuesUnds'Remainder0 , wrap ( BoardMember ) ) )
                </num-board-members>
                <num-proposers>
                  u ( countMapValues ( 'QuesUnds'Remainder0 , wrap ( Proposer ) ) +Int 1 )
                </num-proposers>
                <user-roles>
                  'QuesUnds'Remainder0
                  u ( V ) |-> Proposer
                </user-roles>
                <quorum>
                  u ( Quorum0 )
                </quorum>
              </board-state>
              <action-state>
                <action-last-index>
                  u ( ActionLastIndex1 )
                </action-last-index>
                <actions>
                  <action-data>
                    'QuesUnds'Remainder2
                    u ( _ActionId0 ) |-> A:Action
                  </action-data>
                  <action-signers>
                    'QuesUnds'Remainder1
                    u ( _ActionId0 ) |-> [ CSV ]
                  </action-signers>
                </actions>
              </action-state>
            </multisig-state> , .Map , _PerformedActions , .stack )
          </stack>
        </pseudocode-state>
        <external-call-env>
          <caller-address>
            address ( _1 )
          </caller-address>
        </external-call-env>
        <log>
          <performed-actions>
            _PerformedActions
          </performed-actions>
        </log>
      </state>
    </TT>
  </T>
#And
  {
    'QuesUnds'Value0
  #Equals
    Proposer
  }
#And
  {
    'QuesUnds'Value1
  #Equals
    [ CSV ]
  }
#And
  {
    'QuesUnds'Value2
  #Equals
    A:Action
  }
#And
  {
    'QuesUnds'Value
  #Equals
    u ( V )
  }
#And
  {
    ActionData0
  #Equals
    'QuesUnds'Remainder2
    u ( _ActionId0 ) |-> A:Action
  }
#And
  {
    ActionSigners0
  #Equals
    'QuesUnds'Remainder1
    u ( _ActionId0 ) |-> [ CSV ]
  }
#And
  {
    AddressToUserId
  #Equals
    'QuesUnds'Remainder
    address ( _1 ) |-> u ( V )
  }
#And
  {
    U0
  #Equals
    Proposer
  }
#And
  {
    U
  #Equals
    u ( V )
  }
#And
  {
    UserRoles
  #Equals
    'QuesUnds'Remainder0
    u ( V ) |-> Proposer
  }
#And
  {
    V0
  #Equals
    [ CSV ]
  }
#And
  {
    false
  #Equals
    address ( _1 ) in_keys ( 'QuesUnds'Remainder )
  }
#And
  {
    false
  #Equals
    u ( 0 ) in_keys ( 'QuesUnds'Remainder0 )
  }
#And
  {
    false
  #Equals
    u ( 0 ) in_keys ( UserIdToAddress )
  }
#And
  {
    false
  #Equals
    u ( ActionLastIndex1 +Int 1 ) in_keys ( 'QuesUnds'Remainder1 )
  }
#And
  {
    false
  #Equals
    u ( ActionLastIndex1 +Int 1 ) in_keys ( 'QuesUnds'Remainder2 )
  }
#And
  {
    false
  #Equals
    u ( NumUsers0 +Int 1 ) in_keys ( 'QuesUnds'Remainder0 )
  }
#And
  {
    false
  #Equals
    u ( NumUsers0 +Int 1 ) in_keys ( UserIdToAddress )
  }
#And
  {
    false
  #Equals
    u ( V ) in_keys ( 'QuesUnds'Remainder0 )
  }
#And
  {
    false
  #Equals
    u ( _ActionId0 ) in_keys ( 'QuesUnds'Remainder1 )
  }
#And
  {
    false
  #Equals
    u ( _ActionId0 ) in_keys ( 'QuesUnds'Remainder2 )
  }
#And
  {
    true
  #Equals
    #allValuesBecomeKeys ( 'QuesUnds'Remainder , keysMap ( UserIdToAddress ) )
  }
#And
  {
    true
  #Equals
    #allValuesBecomeKeys ( UserIdToAddress , address ( _1 ) |-> 0
    keysMap ( 'QuesUnds'Remainder ) )
  }
#And
  {
    true
  #Equals
    #noReusedIndexValue ( NumUsers0 +Int 2 , 'QuesUnds'Remainder , expanded )
  }
#And
  {
    true
  #Equals
    NumUsers0 +Int 1 >Int V
  }
#And
  {
    true
  #Equals
    NumUsers0 >=Int 0
  }
#And
  {
    true
  #Equals
    Quorum0 <=Int countCanSignFunction ( [ CSV ] , concat ( u ( V ) , Proposer , opaque ( 'QuesUnds'Remainder0 ) ) )
  }
#And
  {
    true
  #Equals
    Quorum0 <=Int countMapValues ( 'QuesUnds'Remainder0 , wrap ( BoardMember ) )
  }
#And
  {
    true
  #Equals
    _ActionId0 <=Int ActionLastIndex1
  }
#And
  {
    true
  #Equals
    actionDataInvariant ( 'QuesUnds'Remainder2 )
  }
#And
  {
    true
  #Equals
    actionSignersInvariant ( 'QuesUnds'Remainder1 )
  }
#And
  {
    true
  #Equals
    addressToUserIdInvariant ( 'QuesUnds'Remainder )
  }
#And
  {
    true
  #Equals
    countMapValues ( 'QuesUnds'Remainder0 , wrap ( BoardMember ) ) >=Int 0
  }
#And
  {
    true
  #Equals
    countMapValues ( 'QuesUnds'Remainder0 , wrap ( Proposer ) ) +Int 1 >=Int 0
  }
#And
  {
    true
  #Equals
    isKResult ( CSV:ExpressionCSV ~> . )
  }
#And
  {
    true
  #Equals
    isKResultAction ( A )
  }
#And
  {
    true
  #Equals
    listElementsAreUsize ( [ CSV ] )
  }
#And
  {
    true
  #Equals
    maxMapKey ( u ( ActionLastIndex1 ) , keysMap ( 'QuesUnds'Remainder1 ) )
  }
#And
  {
    true
  #Equals
    maxMapKey ( u ( ActionLastIndex1 ) , keysMap ( 'QuesUnds'Remainder2 ) )
  }
#And
  {
    true
  #Equals
    u ( V ) in_keys ( UserIdToAddress )
  }
#And
  {
    true
  #Equals
    unusedIdsInMapKeys ( ActionLastIndex1 +Int 2 , keysMap ( 'QuesUnds'Remainder1 ) , expanded )
  }
#And
  {
    true
  #Equals
    unusedIdsInMapKeys ( ActionLastIndex1 +Int 2 , keysMap ( 'QuesUnds'Remainder2 ) , expanded )
  }
#And
  {
    true
  #Equals
    unusedIdsInMapKeys ( NumUsers0 +Int 2 , keysMap ( 'QuesUnds'Remainder0 ) , expanded )
  }
#And
  {
    true
  #Equals
    unusedIdsInMapKeys ( NumUsers0 +Int 2 , keysMap ( UserIdToAddress ) , expanded )
  }
#And
  {
    true
  #Equals
    unusedIdsInMapValues ( NumUsers0 +Int 1 , 'QuesUnds'Remainder , expanded )
  }
#And
  {
    true
  #Equals
    userIdToRoleInvariant ( 'QuesUnds'Remainder0 )
  }
#And
  {
    true
  #Equals
    valueNotInMapValues ( u ( NumUsers0 +Int 1 ) , 'QuesUnds'Remainder )
  }
#And
  {
    true
  #Equals
    valueNotInMapValues ( u ( NumUsers0 +Int 2 ) , 'QuesUnds'Remainder )
  }
#And
  {
    true
  #Equals
    valueNotInMapValues ( u ( V ) , 'QuesUnds'Remainder )
  }
*/