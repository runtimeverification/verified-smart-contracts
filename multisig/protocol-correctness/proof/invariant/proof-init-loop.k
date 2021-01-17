module TRUSTED-INIT-LOOP
  imports INVARIANT-EXECUTION
  imports INIT-LOOP-PARTS
  imports PSEUDOCODE

  claim <T> initLoopLhs(
              PrevIndex:Usize,
              Addresses:ExpressionList,
              K:K,
              UserIdToAddress0:Map,
              AddressToUserId0:Map,
              UserIdToRole0:Map,
              Quorum:Usize,
              ActionState:ActionStateCell,
              .Map,  // TODO: Variables:Map,
              Stack:List,
              ExternalCallEnv:ExternalCallEnvCell,
              _Address0:Expression,
              _UserId0:Usize)
        </T>
      =>
        <T> initLoopRhs(
              evaluate(void),
              K,
              ?UserIdToAddress1:Map,
              ?AddressToUserId1:Map,
              ?UserIdToRole1,
              Quorum,
              ActionState,
              .Map,  // TODO: Variables,
              Stack,
              ExternalCallEnv,
              add(PrevIndex, u(pListLen(Addresses))),
              ?_Address1:Expression,
              ?_UserId1:Usize)
        </T>
    requires
        initLoopRequires(
            PrevIndex,
            Addresses,
            UserIdToAddress0,
            AddressToUserId0,
            UserIdToRole0)
        andBool noCommonItem(add(PrevIndex, u(2)), AddressToUserId0, Addresses)
    ensures
        initLoopEnsures(
            add(add(PrevIndex, u(pListLen(Addresses))), u(1)),
            Addresses,
            ?UserIdToAddress1,
            ?AddressToUserId1,
            UserIdToRole0,
            ?UserIdToRole1)
  [trusted]

  claim <T> initLoopLhs(
              PrevIndex:Usize,
              Addresses:ExpressionList,
              K:K,
              UserIdToAddress0:Map,
              AddressToUserId0:Map,
              UserIdToRole0:Map,
              Quorum:Usize,
              ActionState:ActionStateCell,
              .Map,  // TODO: Variables:Map,
              Stack:List,
              ExternalCallEnv:ExternalCallEnvCell,
              _Address0:Expression,
              _UserId0:Usize)
        </T>
      =>
        <T> initLoopRhs(
              error,
              K,
              ?_UserIdToAddress1:Map,
              ?_AddressToUserId1:Map,
              ?_UserIdToRole1:Map,
              Quorum,
              ActionState,
              .Map,  // TODO: Variables,
              Stack,
              ExternalCallEnv,
              add(PrevIndex, u(pListLen(Addresses))),
              ?_Address1:Expression,
              ?_UserId1:Usize)
        </T>
    requires
        initLoopRequires(
            PrevIndex,
            Addresses,
            UserIdToAddress0,
            AddressToUserId0,
            UserIdToRole0)
        andBool notBool noCommonItem(add(PrevIndex, u(2)), AddressToUserId0, Addresses)
    [trusted]
endmodule

module PROOF-INIT-LOOP
  imports INIT-LOOP-PARTS

  claim <T> initLoopLhs(
              PrevIndex:Usize,
              Addresses:ExpressionList,
              K:K,
              UserIdToAddress0:Map,
              AddressToUserId0:Map,
              UserIdToRole0:Map,
              Quorum:Usize,
              ActionState:ActionStateCell,
              .Map,  // TODO: Variables:Map,
              Stack:List,
              ExternalCallEnv:ExternalCallEnvCell,
              _Address0:Expression,
              _UserId0:Usize)
        </T>
      =>
        <T> initLoopRhs(
              evaluate(void),
              K,
              ?UserIdToAddress1:Map,
              ?AddressToUserId1:Map,
              ?UserIdToRole1,
              Quorum,
              ActionState,
              .Map,  // TODO: Variables,
              Stack,
              ExternalCallEnv,
              add(PrevIndex, u(pListLen(Addresses))),
              ?_Address1:Expression,
              ?_UserId1:Usize)
        </T>
    requires
        initLoopRequires(
            PrevIndex,
            Addresses,
            UserIdToAddress0,
            AddressToUserId0,
            UserIdToRole0)
        andBool noCommonItem(add(PrevIndex, u(2)), AddressToUserId0, Addresses)
    ensures
        initLoopEnsures(
            add(add(PrevIndex, u(pListLen(Addresses))), u(1)),
            Addresses,
            ?UserIdToAddress1,
            ?AddressToUserId1,
            UserIdToRole0,
            ?UserIdToRole1)

  claim <T> initLoopLhs(
              PrevIndex:Usize,
              Addresses:ExpressionList,
              K:K,
              UserIdToAddress0:Map,
              AddressToUserId0:Map,
              UserIdToRole0:Map,
              Quorum:Usize,
              ActionState:ActionStateCell,
              .Map,  // TODO: Variables:Map,
              Stack:List,
              ExternalCallEnv:ExternalCallEnvCell,
              _Address0:Expression,
              _UserId0:Usize)
        </T>
      =>
        <T> initLoopRhs(
              error,
              K,
              ?_UserIdToAddress1:Map,
              ?_AddressToUserId1:Map,
              ?_UserIdToRole1,
              Quorum,
              ActionState,
              .Map,  // TODO: Variables,
              Stack,
              ExternalCallEnv,
              add(PrevIndex, u(pListLen(Addresses))),
              ?_Address1:Expression,
              ?_UserId1:Usize)
        </T>
    requires
        initLoopRequires(
            PrevIndex,
            Addresses,
            UserIdToAddress0,
            AddressToUserId0,
            UserIdToRole0)
        andBool notBool noCommonItem(add(PrevIndex, u(2)), AddressToUserId0, Addresses)

endmodule
