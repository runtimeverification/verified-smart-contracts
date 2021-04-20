require "protocol-correctness/proof/execution-proof.k"
require "protocol-correctness/proof/functions/functions-execute.k"

require "protocol-correctness/proof/invariant/count-can-sign-parts.k"
require "protocol-correctness/proof/invariant/init-loop-parts.k"
require "protocol-correctness/proof/invariant/perform-parts.k"

module INVARIANT-EXECUTION-SYNTAX
  imports EXECUTION-PROOF-SYNTAX
endmodule

module INVARIANT-INSTRUMENTATION
  imports MAP

  imports PROOF-INSTRUMENTATION
  imports PSEUDOCODE

  rule  nullableMapLookup(_:KItem, M:Map, _:ReflectionType)
        ~> (.K => lazyConcretizeKeys(M))
        ~> K:KItem
    requires notBool isLazyConcretize(K)
     [priority(20)]
  rule (E:Expression => .K) ~> lazyConcretizeKeys(_) ~> (.K => E)
    [priority(20)]

  rule  nullableMapSet(_:KItem, _:KItem, _:Map, _:ReflectionType)  // This may be needed only for addressToUserID, in init.
        ~> (.K => lazyConcretizeKeysFreezer)
        ~> K:KItem
    requires notBool isLazyConcretize(K)
    [priority(20)]
  rule (M:Map ~> lazyConcretizeKeysFreezer) => (lazyConcretizeKeys(M) ~> M)
    [priority(20)]

  // syntax KItem ::= lazySplitMap(k:KItem, m:Map, value:KItem, remainder:Map)
  // rule lazySplitMap(K:KItem, M:Map, Value:KItem, Remainder:Map)
  //     => splitMap(K, M, Value, Remainder)
endmodule

module PERFORM-SPLIT-ACTION-INSTRUMENTATION
  imports PSEUDOCODE
  imports CONCRETIZE-INSTRUMENTATION

  syntax KItem ::= "splitting-action"
  rule  <k> pushContext ~> (.K => splitAction(A) ~> splitting-action) ~> call(performAction(A:Action))
        ...</k>
    [priority(10)]
  rule  <k> (splitting-action => .K) ...</k>
    [priority(20)]

  syntax KItem ::= splitAction(Action)
  rule splitAction(Nothing) => .K
  rule splitAction(AddBoardMember(A:Address)) => concretizeValue(A)
  rule splitAction(AddProposer(A:Address)) => concretizeValue(A)
  rule splitAction(RemoveUser(A:Address)) => concretizeValue(A)
  rule splitAction(ChangeQuorum(Q:Usize)) => concretizeValue(Q)
  rule splitAction(SendEgld(To:Address, Amount:BigUint, Data:BoxedBytes)) =>
      concretizeValue(To) ~> concretizeValue(Amount) ~> concretizeValue(Data)
  rule splitAction(SCDeploy(
          Amount:BigUint,
          Code:BoxedBytes,
          CodeMetadata:CodeMetadata,
          Arguments:ExpressionList))
      =>   concretizeValue(Amount)
        ~> concretizeValue(Code)
        ~> concretizeValue(CodeMetadata)
        ~> concretizeValue(Arguments)
  rule splitAction(SCCall(
          To:Address,
          Amount:BigUint,
          Function:BoxedBytes,
          Arguments:ExpressionList))
      =>   concretizeValue(To)
        ~> concretizeValue(Amount)
        ~> concretizeValue(Function)
        ~> concretizeValue(Arguments)

endmodule

module PERFORM-ACTION-REMOVE-USER-INSTRUMENTATION
  imports INVARIANT-INSTRUMENTATION
  imports PERFORM-SPLIT-ACTION-INSTRUMENTATION
  imports PSEUDOCODE

  syntax KItem ::= splittingDeleteCaller(Address)
  syntax KItem ::= splittingDeleteCaller1(Address)
  syntax KItem ::= splittingDeleteCaller2(Usize)
  rule  (splitting-action => splittingDeleteCaller(A))
        ~> call(performAction(RemoveUser(A:Address)))
    [priority(10)]

  rule  <k> splittingDeleteCaller(A:Address)
            =>  branchK(
                  A in_keys(AddressToUserId),
                  splittingDeleteCaller1(A),
                  .K
                )
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
  rule  <k> (
              splittingDeleteCaller1(A:Address)
              => makeConcreteValue(A, rUsize, AddressToUserId)
                ~> branchK(
                      AddressToUserId[A] in_keys(UserIdToRole),
                      splittingDeleteCaller2({AddressToUserId[A]}:>Usize),
                      .K
                )
            )
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <user-roles>UserIdToRole:Map</user-roles>
    requires A in_keys(AddressToUserId)

  rule  <k> (
              splittingDeleteCaller2(UserId:Usize)
              => makeConcreteValue(UserId, rUserRole, UserIdToRole)
                ~> lazyConcretizeKeys(UserIdToRole)  // TODO: Likely not needed.
                ~> branchK(
                      UserIdToRole[UserId] ==K BoardMember,
                      splitBoolean(Quorum <=Int NumBoardMembers -Int 1),
                      splitBoolean(Quorum <=Int NumBoardMembers)
                  )
                ~> splitBoolean(NumBoardMembers -Int 1 +Int NumProposers >Int 0)
            )
        ...</k>
        <user-roles>UserIdToRole:Map</user-roles>
        <num-board-members>u(NumBoardMembers:Int)</num-board-members>
        <num-proposers>u(NumProposers:Int)</num-proposers>
        <quorum>u(Quorum:Int)</quorum>
    requires UserId in_keys(UserIdToRole)
endmodule

module PERFORM-ACTION-SC-DEPLOY-INSTRUMENTATION
  imports PERFORM-SPLIT-ACTION-INSTRUMENTATION
  imports INVARIANT-INSTRUMENTATION

  rule  <k> (splitting-action => concretizeValue(Arguments))
            ~> call(performAction(SCDeploy(
                        _Amount:BigUint,
                        _Code:BoxedBytes,
                        _CodeMetadata:CodeMetadata,
                        Arguments:ExpressionList)))
        ...</k>
    [priority(10)]

endmodule

module PROPOSE-SC-DEPLOY-INSTRUMENTATION
  imports PROOF-INSTRUMENTATION
  imports PSEUDOCODE

  syntax KItem ::= "split-sc-deploy"
  syntax KItem ::= "split-sc-deploy1"

  rule  preCall
        ~> (.K => split-sc-deploy)
        ~> call(proposeSCDeploy(_:BigUint, _:BoxedBytes, _:Bool, _:Bool, _:Bool, _:ExpressionList))
  [priority(20)]

  rule  <k> split-sc-deploy
            =>  branchK(
                  Caller in_keys(AddressToUserId),
                  makeConcreteValue(Caller, rUsize, AddressToUserId)
                    ~>  split-sc-deploy1,
                  .K
                )
        ... </k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <caller-address>Caller:KItem</caller-address>

  rule  <k> split-sc-deploy1
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

module PERFORM-ACTION-ADD-PROPOSER-INSTRUMENTATION
  imports INVARIANT-INSTRUMENTATION
  imports PERFORM-SPLIT-ACTION-INSTRUMENTATION
  imports PSEUDOCODE

  syntax KItem ::= splittingActionProposer(Address)

  rule  <k> (
              splitting-action
              =>  branchK(
                    A1 in_keys(AddressToUserId),
                    splittingActionProposer(A1),
                    .K
                  )
            )
            ~> call(performAction(AddProposer(A1:Address)))
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
    [priority(10)]

  rule  <k> splittingActionProposer(A1:Address)
            =>    makeConcreteValue(A1, rUsize, AddressToUserId)
              ~>  branchK(
                    AddressToUserId[A1] in_keys(UserIdToRole),
                    makeConcreteValue(AddressToUserId[A1], rUserRole, UserIdToRole),
                    .K
                  )
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <user-roles> UserIdToRole:Map </user-roles>
    requires A1 in_keys(AddressToUserId)
      // TODO: Do I need AddressToUserId[A1] in_keys(UserIdToRole)?
endmodule

module CHANGE-USER-ROLE-INSTRUMENTATION
  imports INVARIANT-INSTRUMENTATION
  imports PSEUDOCODE

  syntax KItem ::= splitChangeUserRole(Address)
  syntax KItem ::= splitChangeUserRole2(Address)
  syntax KItem ::= splitChangeUserRole3(Usize)

  rule  preCall
        ~> (.K => splitChangeUserRole(UserAddress))
        ~> call(changeUserRole(UserAddress:Address, _NewRole:UserRole))
  [priority(20)]

  rule  <k> splitChangeUserRole(Address:Address)
            =>  branchK(
                  Address in_keys(AddressToUserId),
                  splitChangeUserRole2(Address),
                  .K
                )
        ... </k>
        <address-to-user-id> AddressToUserId:Map </address-to-user-id>

  rule  <k> splitChangeUserRole2(Address:Address)
            =>    makeConcreteValue(Address, rUsize, AddressToUserId)
              ~>  branchK(
                    AddressToUserId[Address] in_keys(UserIdToRole),
                    makeConcreteValue(AddressToUserId[Address], rUserRole, UserIdToRole),
                    .K
                  )
        ... </k>
        <address-to-user-id> AddressToUserId:Map </address-to-user-id>
        <user-roles>UserIdToRole:Map</user-roles>
    requires Address in_keys(AddressToUserId)
endmodule

module SIGN-INSTRUMENTATION
  imports PSEUDOCODE
  imports INVARIANT-INSTRUMENTATION

  syntax KItem ::= splitSign(Usize)
  syntax KItem ::= splitSign2(Usize)
  syntax KItem ::= splitSign3(Usize)

  rule  preCall
        ~> (.K => splitSign(ActionId))
        ~> call(sign(ActionId:Usize))
  [priority(20)]

  rule  <k> splitSign(ActionId:Usize)
            =>  branchK(
                    ActionId in_keys(ActionData),
                    branchK(
                      CallerAddress in_keys(AddressToUserId),
                      splitSign2(ActionId),
                      .K
                    ),
                    .K
                  )
        ... </k>
        <address-to-user-id> AddressToUserId:Map </address-to-user-id>
        <caller-address>CallerAddress:KItem</caller-address>
        <action-data>ActionData:Map</action-data>

  rule  <k> splitSign2(ActionId:Usize)
            =>    makeConcreteValue(CallerAddress, rUsize, AddressToUserId)
              ~>  branchK(
                    AddressToUserId[CallerAddress] in_keys(UserIdToRole),
                    splitSign3(ActionId),
                    .K
                  )
        ... </k>
        <address-to-user-id> AddressToUserId:Map </address-to-user-id>
        <user-roles>UserIdToRole:Map</user-roles>
        <caller-address>CallerAddress:KItem</caller-address>
    requires CallerAddress in_keys(AddressToUserId)

  rule  <k> splitSign3(ActionId:Usize)
            =>    makeConcreteValue(AddressToUserId[CallerAddress], rUserRole, UserIdToRole)
              ~>  branchK(
                    UserIdToRole[AddressToUserId[CallerAddress]] ==K BoardMember,
                    branchK(
                      ActionId in_keys(ActionSigners),
                      makeConcreteValue(ActionId, rExpressionList, ActionSigners),
                      .K
                    ),
                    .K
                  )
        ... </k>
        <address-to-user-id> AddressToUserId:Map </address-to-user-id>
        <user-roles>UserIdToRole:Map</user-roles>
        <caller-address>CallerAddress:KItem</caller-address>
        <action-signers>ActionSigners:Map</action-signers>
    requires CallerAddress in_keys(AddressToUserId)
      andBool AddressToUserId[CallerAddress] in_keys(UserIdToRole)
endmodule

module UNSIGN-INSTRUMENTATION
  imports INVARIANT-INSTRUMENTATION

  syntax KItem ::= splitUnsign(actionId:Usize)
  syntax KItem ::= splitUnsign2(actionId:Usize)
  syntax KItem ::= splitUnsign3(actionId:Usize)
  syntax KItem ::= splitUnsign4(actionId:Usize)
  syntax KItem ::= splitUnsign5(signers:ExpressionList, userId:Usize)

  rule  preCall
        ~> (.K => splitUnsign(ActionId))
        ~> call(unsign(ActionId:Usize))
  [priority(20)]

  rule  <k> splitUnsign(ActionId:Usize)
            =>  branchK(
                    ActionId in_keys(ActionData),
                    makeConcreteValue(ActionId, rAction, ActionData)
                        ~>  branchK(
                              CallerAddress in_keys(AddressToUserId),
                              splitUnsign2(ActionId),
                              .K
                            ),
                    .K
                )
        ... </k>
        <action-data>ActionData:Map</action-data>
        <address-to-user-id> AddressToUserId:Map </address-to-user-id>
        <caller-address>CallerAddress:KItem</caller-address>

  rule  <k> splitUnsign2(ActionId:Usize)
            =>    makeConcreteValue(CallerAddress, rUsize, AddressToUserId)
              ~>  branchK(
                      AddressToUserId[CallerAddress] in_keys(UserIdToRole),
                      splitUnsign3(ActionId),
                      .K
                  )
        ... </k>
        <address-to-user-id> AddressToUserId:Map </address-to-user-id>
        <user-roles>UserIdToRole:Map</user-roles>
        <caller-address>CallerAddress:KItem</caller-address>
    requires CallerAddress in_keys(AddressToUserId)

  rule  <k> splitUnsign3(ActionId:Usize)
            =>    makeConcreteValue(AddressToUserId[CallerAddress], rUserRole, UserIdToRole)
              ~>  branchK(
                      UserIdToRole[AddressToUserId[CallerAddress]] ==K BoardMember,
                      branchK(
                          ActionId in_keys(ActionSigners),
                          makeConcreteValue(ActionId, rExpressionList, ActionSigners)
                            ~>  splitUnsign4(ActionId),
                          .K
                      ),
                      .K
                  )
        ... </k>
        <address-to-user-id> AddressToUserId:Map </address-to-user-id>
        <user-roles>UserIdToRole:Map</user-roles>
        <caller-address>CallerAddress:KItem</caller-address>
        <action-signers>ActionSigners:Map</action-signers>
    requires true
        andBool CallerAddress in_keys(AddressToUserId)
        andBool AddressToUserId[CallerAddress] in_keys(UserIdToRole)

  rule  <k> splitUnsign4(ActionId:Usize)
            =>  splitUnsign5(
                    {ActionSigners[ActionId]}:>ExpressionList,
                    {AddressToUserId[CallerAddress]}:>Usize
                )
        ...</k>
        <action-signers>ActionSigners:Map</action-signers>
        <address-to-user-id> AddressToUserId:Map </address-to-user-id>
        <caller-address>CallerAddress:KItem</caller-address>
    requires true
        andBool ActionId in_keys(ActionSigners)
        andBool isExpressionList(ActionSigners[ActionId])
        andBool CallerAddress in_keys(AddressToUserId)
        andBool isUsize(AddressToUserId[CallerAddress])

  rule  splitUnsign5(Signers:ExpressionList, UserId:Usize)
        =>  branchK(
                #listFind(Signers, UserId) >=Int 0,
                concretizeExpressionList(Signers, 2)
                ~>  branchK(
                        pListLen(Signers) >=Int 1,
                        makeConcrete(expressionListGetOrDefault(Signers, 0, void), rUsize)
                          ~>  branchK(
                                  pListLen(Signers) ==Int 1,
                                  branchK(
                                      expressionListGetOrDefault(Signers, 0, void) ==K UserId,
                                      .K,
                                      .K
                                  ),
                                  branchK(
                                      pListLen(Signers) >=Int 2,
                                      makeConcrete(expressionListGetOrDefault(Signers, 1, void), rUsize)
                                        ~>  branchK(
                                                expressionListGetOrDefault(Signers, 0, void) ==K UserId,
                                                .K,
                                                branchK(
                                                    expressionListGetOrDefault(Signers, 1, void) ==K UserId,
                                                    .K,
                                                    .K
                                                )
                                            ),
                                      stuck
                                  )
                              ),
                        stuck
                    ),
                // branchK(
                //     ActionSigners[ActionId] ==K [?UserId1:Expression, .],
                //     makeConcrete(?UserId1, rUsize)
                //       ~>  branchK(
                //               ?UserId1 ==K AddressToUserId[CallerAddress],
                //               .K,
                //               .K
                //           ),
                //     branchK(
                //         ActionSigners[ActionId] ==K [?UserId2:Expression, ?UserId3:Expression, ?_:ExpressionCSV],
                //         makeConcrete(?UserId2, rUsize)
                //           ~>  makeConcrete(?UserId3, rUsize)
                //           ~>  branchK(
                //                   ?UserId2 ==K AddressToUserId[CallerAddress],
                //                   .K,
                //                   .K
                //               ),
                //         .K
                //     )
                // ),
                .K
            )
    requires true

  // rule  splitUnsign6(ActionId:Usize, Signers:ExpressionList, UserId:Usize)
  //       =>  branchK(
  //               #listFind(Signers, UserId) >=Int 0,
  //               concretizeExpressionList(Signers, 2)
  //               ~>  branchK(
  //                       pListLen(Signers) >=Int 1,
  //                       makeConcrete(expressionListGetOrDefault(Signers, 0, void), rUsize)
  //                         ~>  branchK(
  //                                 pListLen(Signers) ==Int 1,
  //                                 branchK(
  //                                     expressionListGetOrDefault(Signers, 0, void) ==K UserId,
  //                                     .K,
  //                                     .K
  //                                 ),
  //                                 branchK(
  //                                     pListLen(Signers) >=Int 2,
  //                                     makeConcrete(expressionListGetOrDefault(Signers, 1, void), rUsize)
  //                                       ~>  branchK(
  //                                               expressionListGetOrDefault(Signers, 1, void) ==K UserId,
  //                                               .K,
  //                                               .K
  //                                           ),
  //                                     stuck
  //                                 )
  //                             ),
  //                       stuck
  //                   ),
  //               .K
  //           )
  //   requires true
endmodule

module DISCARD-ACTION-INSTRUMENTATION
  imports INVARIANT-INSTRUMENTATION
  imports PROOF-INSTRUMENTATION
  imports EXECUTION-PROOF
  imports PSEUDOCODE

  syntax KItem ::= splitDiscardAction(actionId:Usize)
  syntax KItem ::= splitDiscardAction1(actionId:Usize)
  syntax KItem ::= splitDiscardAction2(actionId:Usize)
  syntax KItem ::= splitDiscardAction3(actionId:Usize)
  syntax KItem ::= splitDiscardAction4(actionId:Usize)

  rule  preCall
        ~> (.K => splitDiscardAction(ActionId))
        ~> call(discardAction(ActionId:Usize))
    [priority(20)]

  rule  <k> splitDiscardAction(ActionId:Usize)
            =>  branchK(
                  Caller in_keys(AddressToUserId),
                  splitDiscardAction1(ActionId),
                  .K
                )
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <caller-address>Caller:KItem</caller-address>

  rule  <k> splitDiscardAction1(ActionId:Usize)
            =>    makeConcreteValue(Caller, rUsize, AddressToUserId)
              ~>  branchK(
                    AddressToUserId[Caller] in_keys(UserIdToRole),
                    splitDiscardAction2(ActionId),
                    .K
                  )
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <user-roles> UserIdToRole:Map </user-roles>
        <caller-address>Caller:KItem</caller-address>
    requires Caller in_keys(AddressToUserId)

  rule  <k> splitDiscardAction2(ActionId:Usize)
            =>    makeConcreteValue(AddressToUserId[Caller], rUserRole, UserIdToRole)
              ~>  branchK(
                    ActionId in_keys(ActionSigners),
                    splitDiscardAction3(ActionId),
                    branchK(
                      ActionId in_keys(ActionData),
                      makeConcreteValue(ActionId, rAction, ActionData),
                      .K
                    )
                  )
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <user-roles> UserIdToRole:Map </user-roles>
        <caller-address>Caller:KItem</caller-address>
        <action-signers>ActionSigners:Map</action-signers>
        <action-data>ActionData</action-data>
    requires Caller in_keys(AddressToUserId)

  rule  <k> splitDiscardAction3(ActionId:Usize)
            =>    makeConcreteValue(ActionId, rExpressionList, ActionSigners)
              ~>  branchK(
                    ActionId in_keys(ActionData),
                    makeConcreteValue(ActionId, rAction, ActionData),
                    splitDiscardAction4(ActionId)
                  )
        ...</k>
        <action-data>ActionData</action-data>
        <action-signers>ActionSigners</action-signers>
    requires ActionId in_keys(ActionSigners)
  rule  <k> splitDiscardAction4(ActionId:Usize)
            =>    branchK(
                    countCanSignFunction({ActionSigners[ActionId]}:>ExpressionList, opaque(UserIdToRole)) >Int 0,
                    .K,
                    .K
                  )
        ...</k>
        <action-signers>ActionSigners</action-signers>
        <user-roles> UserIdToRole:Map </user-roles>
    requires ActionId in_keys(ActionSigners)
      andBool isExpressionList(ActionSigners[ActionId])

endmodule

module PERFORM-ACTION-ENDPOINT-INSTRUMENTATION
  // This is a diagram of the splits attempted here. The k files have only
  // their suffix. The missing prefix is 'proof-perform-action-endpoint-'.
  //
  // Has caller user?
  // No: New.k
  // Yes: Has caller role?
  //   No: None.k
  //   Yes: Has quorum?
  //     No: TODO: merge no-quorum-has-signers.k + no-quorum-no-signers.k
  //     Yes: Has action?
  //       No: TODO: nothing.k
  //       Yes: split action
  //         action=add-board-member: Is same as caller?
  //           No: New user?
  //             Yes: add-board-member-New.k
  //             No: Has role?
  //               No: add-board-member-None.k
  //               Yes: split role
  //                 role=proposer? add-board-member-Proposer.k
  //                 role=board-member? add-board-member-BoardMember.k
  //           Yes: split role
  //             role=proposer? add-board-member-Proposer-eq.k
  //             role=board-member? add-board-member-BoardMember-eq.k
  //         action=add-proposer: Is same as caller?
  //           No: New user?
  //             Yes: add-proposer-New.k
  //             No: Has role?
  //               No: add-proposer-None.k
  //               Yes: split role
  //                 role=proposer? add-proposer-Proposer.k
  //                 role=board-member? goes-below-quorum?
  //                   Yes: add-proposer-BoardMember-no-quorum.k
  //                   No: add-proposer-BoardMember.k
  //           Yes: split role
  //             role=proposer? add-proposer-Proposer-eq.k
  //             role=board-member? goes-below-quorum?
  //               Yes: add-proposer-BoardMember-no-quorum-eq.k
  //               No: add-proposer-BoardMember-eq.k
  //         action=change-quorum: goes-below-quorum?
  //           Yes: change-quorum-no-quorum.k
  //           No: change-quorum.k
  //         action=remove-user: Is same as caller?
  //           No: New user?
  //             Yes: remove-user-New.k
  //             No: Has role?
  //               No: remove-user-None.k
  //               Yes: split role
  //                 role = proposer: has-people-left?
  //                   Yes: remove-user-Proposer.k
  //                   No: remove-user-Proposer-nobody-left.k
  //                 role = board-member: can-still-vote-execute?
  //                   Yes: remove-user-BoardMember.k
  //                   No: remove-user-BoardMember-too-few.k
  //           Yes: split role
  //             role = proposer: has-people-left?
  //               Yes: remove-user-Proposer-eq.k
  //               No: remove-user-Proposer-nobody-left-eq.k
  //             role = board-member: can-still-vote-execute?
  //               Yes: remove-user-BoardMember-eq.k
  //               No: remove-user-BoardMember-too-few-eq.k
  //         action=sc-call? sc-call.k
  //         action=sc-deploy? sc-deploy.k
  //         action=send-egld? send-egld.k

  imports PERFORM-SPLIT-ACTION-INSTRUMENTATION
  imports PROOF-INSTRUMENTATION
  imports EXECUTION-PROOF
  imports PSEUDOCODE

  // The Haskell backend sometimes leaves traces of
  // (trusted) claims that failed to apply in the predicate.
  // Sometimes, these traces increase the execution time by a lot,
  // so we have to work around this.
  //
  // The symbols below allow us to wrap those claims in another set of claims,
  // which can be attemped without leaving traces.
  syntax ProofBranch ::= "new.k"
  syntax ProofBranch ::= "none.k"
  syntax ProofBranch ::= "no-quorum.k"
  syntax ProofBranch ::= "add-board-member-New.k"
  syntax ProofBranch ::= "add-board-member-None.k"
  syntax ProofBranch ::= "add-board-member-BoardMember.k"
  syntax ProofBranch ::= "add-board-member-Proposer.k"
  syntax ProofBranch ::= "add-board-member-BoardMember-eq.k"
  syntax ProofBranch ::= "add-board-member-Proposer-eq.k"
  syntax ProofBranch ::= "add-proposer-New.k"
  syntax ProofBranch ::= "add-proposer-None.k"
  syntax ProofBranch ::= "add-proposer-BoardMember.k"
  syntax ProofBranch ::= "add-proposer-BoardMember-no-quorum.k"
  syntax ProofBranch ::= "add-proposer-Proposer.k"
  syntax ProofBranch ::= "add-proposer-BoardMember-eq.k"
  syntax ProofBranch ::= "add-proposer-BoardMember-no-quorum-eq.k"
  syntax ProofBranch ::= "add-proposer-Proposer-eq.k"
  syntax ProofBranch ::= "change-quorum.k"
  syntax ProofBranch ::= "change-quorum-no-quorum.k"
  syntax ProofBranch ::= "nothing.k"
  syntax ProofBranch ::= "remove-user-New.k"
  syntax ProofBranch ::= "remove-user-None.k"
  syntax ProofBranch ::= "remove-user-BoardMember-too-few.k"
  syntax ProofBranch ::= "remove-user-BoardMember.k"
  syntax ProofBranch ::= "remove-user-Proposer-nobody-left.k"
  syntax ProofBranch ::= "remove-user-Proposer.k"
  syntax ProofBranch ::= "remove-user-Proposer-nobody-left-eq.k"
  syntax ProofBranch ::= "remove-user-Proposer-eq.k"
  syntax ProofBranch ::= "remove-user-BoardMember-too-few-eq.k"
  syntax ProofBranch ::= "remove-user-BoardMember-eq.k"
  syntax ProofBranch ::= "sc-call.k"
  syntax ProofBranch ::= "sc-deploy.k"
  syntax ProofBranch ::= "send-egld.k"

  syntax KItem ::= ProofBranch

  // TODO: It might be faster to enumerate all cases separately.
  rule _:ProofBranch => .K

  syntax KItem ::= splitPerformActionEndpoint(actionId:Usize)
  syntax KItem ::= splitPerformActionEndpoint1(actionId:Usize)
  syntax KItem ::= splitPerformActionEndpoint2(actionId:Usize)
  syntax KItem ::= splitPerformActionEndpoint3(action:Action)
  syntax KItem ::= splitPerformActionEndpoint4(action:Action)
  syntax KItem ::= splitActionSigners(actionId:Usize, signers:Map)

  rule  <k> preCall
            ~> (.K => splitPerformActionEndpoint(ActionId))
            ~> call(performActionEndpoint(ActionId:Usize))
            ~> _:KItem
            ~> _:KItem
            ~> _:KItem
            ~> (.K => splitActionSigners(ActionId, ActionSigners))
            ~> runExternalCalls(_:ExternalCommands)
        ...</k>
        <action-signers>ActionSigners:Map</action-signers>
    [priority(20)]

  rule  splitActionSigners(ActionId:Usize, ActionSigners:Map)
        =>  branchK(
                ActionId in_keys(ActionSigners),
                makeConcreteValue(ActionId, rExpressionList, ActionSigners),
                .K
            )

  rule <k> splitPerformActionEndpoint(ActionId:Usize)
          =>  branchK(
                CallerAddress in_keys(AddressToUserId),
                splitPerformActionEndpoint1(ActionId),
                new.k
              )
        ... </k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <caller-address>CallerAddress:Address</caller-address>

  rule <k> splitPerformActionEndpoint1(ActionId:Usize)
          =>  makeConcreteValue(CallerAddress, rUsize, AddressToUserId)
              ~>  branchK(
                    AddressToUserId[CallerAddress] in_keys(UserIdToRole),
                    branchK(
                      Quorum <=Int countCanSignFunction({ActionSigners[ActionId] orDefault [.]}:>ExpressionList, opaque(UserIdToRole)),
                      branchK(
                        ActionId in_keys(ActionData),
                        splitPerformActionEndpoint2(ActionId),
                        nothing.k
                      ),
                      no-quorum.k
                    ),
                    none.k
                  )
        ... </k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <quorum>u(Quorum:Int)</quorum>
        <user-roles> UserIdToRole:Map </user-roles>
        <caller-address>CallerAddress:Address</caller-address>
        <action-signers>ActionSigners:Map</action-signers>
        <action-data>ActionData:Map</action-data>
    requires CallerAddress in_keys(AddressToUserId)

  syntax Bool ::= isAddBoardMember(Action)  [function, functional]
  rule isAddBoardMember(AddBoardMember(_)) => true
  rule isAddBoardMember(_) => false [owise]

  syntax Bool ::= isAddProposer(Action)  [function, functional]
  rule isAddProposer(AddProposer(_)) => true
  rule isAddProposer(_) => false [owise]

  syntax Bool ::= isChangeQuorum(Action)  [function, functional]
  rule isChangeQuorum(ChangeQuorum(_)) => true
  rule isChangeQuorum(_) => false [owise]

  syntax Bool ::= isRemoveUser(Action)  [function, functional]
  rule isRemoveUser(RemoveUser(_)) => true
  rule isRemoveUser(_) => false [owise]

  syntax Bool ::= isScCall(Action)  [function, functional]
  rule isScCall(SCCall(_, _, _, _)) => true
  rule isScCall(_) => false [owise]

  syntax Bool ::= isScDeploy(Action)  [function, functional]
  rule isScDeploy(SCDeploy(_, _, _, _)) => true
  rule isScDeploy(_) => false [owise]

  syntax Bool ::= isSendEgld(Action)  [function, functional]
  rule isSendEgld(SendEgld(_, _, _)) => true
  rule isSendEgld(_) => false [owise]

  rule  <k> splitPerformActionEndpoint2(ActionId)
          =>  makeConcreteValue(ActionId, rAction, ActionData)
              ~> splitPerformActionEndpoint3({ActionData[ActionId]}:>Action)
        </k>
        <action-data>ActionData:Map</action-data>
    requires ActionId in_keys(ActionData)

  syntax KItem ::= "action-splitted"
  rule action-splitted => .K

  rule  splitPerformActionEndpoint3(Action:Action)
        =>  splitAction(Action)
            ~> splitPerformActionEndpoint4(Action)

  rule  splitPerformActionEndpoint4(Action:Action)
        =>  branchK(
              isAddBoardMember(Action),
              splitAddBoardMember(Action),
              branchK(
                isAddProposer(Action),
                splitAddProposer(Action),
                branchK(
                  isChangeQuorum(Action),
                  splitChangeQuorum(Action),
                  branchK(
                    isRemoveUser(Action),
                    splitRemoveUser(Action),
                    branchK(
                      isScCall(Action),
                      sc-call.k,
                      branchK(
                        isScDeploy(Action),
                        sc-deploy.k,
                        branchK(
                          isSendEgld(Action),
                          send-egld.k,
                          stuck
                        )
                      )
                    )
                  )
                )
              )
          )

  syntax KItem ::= splitAddBoardMember(Action)
  syntax KItem ::= splitAddBoardMember1(Address)
  syntax KItem ::= splitAddBoardMember2(Address)
  syntax KItem ::= splitAddBoardMember3(Address)

  rule  <k>
          splitAddBoardMember(AddBoardMember(UserAddress:Address))
          =>  branchK(
                UserAddress ==K CallerAddress,
                splitAddBoardMember1(UserAddress),
                branchK(
                  UserAddress in_keys(AddressToUserId),
                  splitAddBoardMember2(UserAddress),
                  add-board-member-New.k
                )
              )
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <caller-address>CallerAddress:Address</caller-address>

  rule  <k>
          splitAddBoardMember1(CallerAddress:Address)
          =>  makeConcreteValue(CallerId, rUserRole, UserIdToRole)
              ~>  branchK(
                    UserIdToRole[CallerId] ==K BoardMember,
                    add-board-member-BoardMember-eq.k,
                    branchK(
                      UserIdToRole[CallerId] ==K Proposer,
                      add-board-member-Proposer-eq.k,
                      stuck
                    )
                  )
        ...</k>
        <user-roles>UserIdToRole:Map</user-roles>
        <address-to-user-id>CallerAddress |-> CallerId:Usize _AddressToUserId:Map</address-to-user-id>
        <caller-address>CallerAddress:Address</caller-address>
    requires CallerId in_keys(UserIdToRole)

  // TODO: Delete.
  syntax KItem ::= makeConcreteValueTmp(key:KItem, valueType:ReflectionType, Map)
  rule makeConcreteValueTmp(Key:KItem, ValueType:ReflectionType, M:Map)
    =>    splitMapTmp(Key, M, ?_Value:KItem, ?_Remainder:Map)
      // ~>  cast(M[Key], ValueType)
      // ~>  removeValue
      // ~>  concretizeValue(M[Key])
    requires Key in_keys(M)

  syntax KItem ::= splitMapTmp(key:KItem, toSplit:Map, value:KItem, remainder:Map)
    [function, functional]

  // rule splitMapTmp(Key:KItem, M:Map, _Value:KItem, _Remainder:Map) => stuck
  //   requires notBool Key in_keys(M)
  // rule splitMapTmp(Key:KItem, (Key |-> _:KItem) _:Map, _Value:KItem, _Remainder:Map)
  //     => endSplitMap
  //   [simplification(30)]
  rule splitMapTmp(Key:KItem, (K1:KItem |-> _SomeValue:KItem) M:Map, Value:KItem, Remainder:Map)
      => splitMapTmp(Key, M, Value, Remainder)
    requires notBool (Key ==K K1) andBool Key in_keys(M)
    [simplification(30)]
  rule splitMapTmp(Key:KItem, M:Map, Value:KItem, Remainder:Map)
      => endSplitMap
    requires Key in_keys(M)
    ensures M ==K (Key |-> Value Remainder)
    [simplification(50)]

  rule  <k>
          splitAddBoardMember2(UserAddress:Address)
          =>  makeConcreteValueTmp(UserAddress, rUsize, AddressToUserId)
              ~> branchK(
                AddressToUserId[UserAddress] in_keys(UserIdToRole),
                splitAddBoardMember3(UserAddress),
                add-board-member-None.k
              )
        ...</k>
        <user-roles>UserIdToRole:Map</user-roles>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
    requires UserAddress in_keys(AddressToUserId)

  rule  <k>
          splitAddBoardMember3(UserAddress:Address)
          =>  makeConcreteValue(UserId, rUserRole, UserIdToRole)
              ~>  branchK(
                    UserIdToRole[UserId] ==K BoardMember,
                    add-board-member-BoardMember.k,
                    branchK(
                      UserIdToRole[UserId] ==K Proposer,
                      add-board-member-Proposer.k,
                      stuck
                    )
              )
        ...</k>
        <user-roles>UserIdToRole:Map</user-roles>
        <address-to-user-id>UserAddress |-> UserId:Usize _AddressToUserId:Map</address-to-user-id>
    requires UserId in_keys(UserIdToRole)

  syntax KItem ::= splitAddProposer(Action)
  syntax KItem ::= splitAddProposer1(Address)
  syntax KItem ::= splitAddProposer2(Address)
  syntax KItem ::= splitAddProposer3(Address)
  rule  <k>
          splitAddProposer(AddProposer(UserAddress:Address))
          =>  branchK(
                UserAddress ==K CallerAddress,
                splitAddProposer1(UserAddress),
                branchK(
                  UserAddress in_keys(AddressToUserId),
                  splitAddProposer2(UserAddress),
                  add-proposer-New.k
                )
              )
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <caller-address>CallerAddress:Address</caller-address>

  rule  <k>
          splitAddProposer1(CallerAddress:Address)
          =>  makeConcreteValue(CallerId, rUserRole, UserIdToRole)
              ~>  branchK(
                    UserIdToRole[CallerId] ==K BoardMember,
                    branchK(
                      Quorum <=Int NumBoardMembers -Int 1,
                      add-proposer-BoardMember-eq.k,
                      add-proposer-BoardMember-no-quorum-eq.k
                    ),
                    branchK(
                      UserIdToRole[CallerId] ==K Proposer,
                      add-proposer-Proposer-eq.k,
                      stuck
                    )
              )
        ...</k>
        <num-board-members>u(NumBoardMembers)</num-board-members>
        <quorum>u(Quorum)</quorum>
        <user-roles>UserIdToRole:Map</user-roles>
        <address-to-user-id>CallerAddress |-> CallerId:Usize _AddressToUserId:Map</address-to-user-id>
        <caller-address>CallerAddress:Address</caller-address>
    requires CallerId in_keys(UserIdToRole)

  rule  <k>
          splitAddProposer2(UserAddress:Address)
          =>  makeConcreteValue(UserAddress, rUsize, AddressToUserId)
              ~>  branchK(
                    AddressToUserId[UserAddress] in_keys(UserIdToRole),
                    splitAddProposer3(UserAddress),
                    add-proposer-None.k
                  )
        ...</k>
        <user-roles>UserIdToRole:Map</user-roles>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
    requires UserAddress in_keys(AddressToUserId)

  rule  <k>
          splitAddProposer3(UserAddress:Address)
          =>  makeConcreteValue(UserId, rUserRole, UserIdToRole)
              ~>  branchK(
                    UserIdToRole[UserId] ==K BoardMember,
                    branchK(
                      Quorum ==Int NumBoardMembers,
                      add-proposer-BoardMember-no-quorum.k,
                      add-proposer-BoardMember.k
                    ),
                    branchK(
                      UserIdToRole[UserId] ==K Proposer,
                      add-proposer-Proposer.k,
                      stuck
                    )
                  )
        ...</k>
        <num-board-members>u(NumBoardMembers:Int)</num-board-members>
        <quorum>u(Quorum:Int)</quorum>
        <user-roles>UserIdToRole:Map</user-roles>
        <address-to-user-id>UserAddress |-> UserId:Usize _AddressToUserId:Map</address-to-user-id>
    requires UserId in_keys(UserIdToRole)

  syntax KItem ::= splitChangeQuorum(Action)

  rule  <k>
          splitChangeQuorum(ChangeQuorum(u(NewQuorum:Int)))
          => branchK(
              NewQuorum >Int NumBoardMembers,
              change-quorum-no-quorum.k,
              change-quorum.k
          )
        ...</k>
        <num-board-members>u(NumBoardMembers:Int)</num-board-members>

  syntax KItem ::= splitRemoveUser(Action)
  syntax KItem ::= splitRemoveUser1(Address)
  syntax KItem ::= splitRemoveUser2(Address)
  syntax KItem ::= splitRemoveUser3(Address)

  rule  <k>
          splitRemoveUser(RemoveUser(UserAddress:Address))
          =>  branchK(
                UserAddress ==K CallerAddress,
                splitRemoveUser1(UserAddress),
                branchK(
                  UserAddress in_keys(AddressToUserId),
                  splitRemoveUser2(UserAddress),
                  remove-user-New.k
                )
              )
        ...</k>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
        <caller-address>CallerAddress:Address</caller-address>

  rule  <k>
          splitRemoveUser1(CallerAddress:Address)
          =>  makeConcreteValue(CallerId, rUserRole, UserIdToRole)
              ~>  branchK(
                    UserIdToRole[CallerId] ==K BoardMember,
                    branchK(
                      NumBoardMembers +Int NumProposers ==Int 1
                          orBool Quorum ==Int NumBoardMembers,
                      remove-user-Proposer-nobody-left-eq.k,
                      remove-user-Proposer-eq.k
                    ),
                    branchK(
                      UserIdToRole[CallerId] ==K Proposer,
                      branchK(
                        NumBoardMembers +Int NumProposers ==Int 1,
                        remove-user-BoardMember-too-few-eq.k,
                        remove-user-BoardMember-eq.k
                      ),
                      stuck
                    )
                  )
        ...</k>
        <num-board-members>u(NumBoardMembers)</num-board-members>
        <num-proposers>u(NumProposers)</num-proposers>
        <quorum>u(Quorum)</quorum>
        <user-roles>UserIdToRole:Map</user-roles>
        <address-to-user-id>CallerAddress |-> CallerId:Usize _AddressToUserId:Map</address-to-user-id>
        <caller-address>CallerAddress:Address</caller-address>
    requires CallerId in_keys(UserIdToRole)

  rule  <k>
          splitRemoveUser2(UserAddress:Address)
          =>  makeConcreteValue(UserAddress, rUsize, AddressToUserId)
              ~>  branchK(
                    AddressToUserId[UserAddress] in_keys(UserIdToRole),
                    splitRemoveUser3(UserAddress),
                    remove-user-None.k
                  )
        ...</k>
        <user-roles>UserIdToRole:Map</user-roles>
        <address-to-user-id>AddressToUserId:Map</address-to-user-id>
    requires UserAddress in_keys(AddressToUserId)

  rule  <k>
          splitRemoveUser3(UserAddress:Address)
          =>  makeConcreteValue(UserId, rUserRole, UserIdToRole)
              ~>  branchK(
                    UserIdToRole[UserId] ==K BoardMember,
                    branchK(
                      NumBoardMembers +Int NumProposers ==Int 1
                          orBool Quorum ==Int NumBoardMembers,
                      remove-user-BoardMember-too-few.k,
                      remove-user-BoardMember.k
                    ),
                    branchK(
                      UserIdToRole[UserId] ==K Proposer,
                      branchK(
                        NumBoardMembers +Int NumProposers ==Int 1,
                        remove-user-Proposer-nobody-left.k,
                        remove-user-Proposer.k
                      ),
                      stuck
                    )
                  )
        ...</k>
        <num-board-members>u(NumBoardMembers:Int)</num-board-members>
        <num-proposers>u(NumProposers:Int)</num-proposers>
        <quorum>u(Quorum:Int)</quorum>
        <user-roles>UserIdToRole:Map</user-roles>
        <address-to-user-id>UserAddress |-> UserId:Usize _AddressToUserId:Map</address-to-user-id>
    requires UserId in_keys(UserIdToRole)

endmodule

module INVARIANT-EXECUTION
  imports EXECUTION-PROOF
  imports FUNCTIONS-EXECUTE

  imports INVARIANT-INSTRUMENTATION
  imports SIGN-INSTRUMENTATION
  imports CHANGE-USER-ROLE-INSTRUMENTATION
  imports PROPOSE-ACTION-INSTRUMENTATION
  imports PERFORM-ACTION-ADD-PROPOSER-INSTRUMENTATION
  imports PERFORM-ACTION-SC-DEPLOY-INSTRUMENTATION
  imports PERFORM-ACTION-REMOVE-USER-INSTRUMENTATION
  imports PERFORM-SPLIT-ACTION-INSTRUMENTATION
  imports PROPOSE-SC-DEPLOY-INSTRUMENTATION
  imports DISCARD-ACTION-INSTRUMENTATION
  imports UNSIGN-INSTRUMENTATION
  imports PERFORM-ACTION-ENDPOINT-INSTRUMENTATION

  imports COUNT-CAN-SIGN-PARTS
  imports INIT-LOOP-PARTS
  imports PERFORM-PARTS
endmodule