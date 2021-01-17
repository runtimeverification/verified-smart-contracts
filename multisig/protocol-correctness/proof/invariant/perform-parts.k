module PERFORM-PARTS

  imports EXECUTION-PROOF-HELPERS
  imports INVARIANT-HELPERS
  imports PSEUDOCODE

  syntax Bool ::= performRequires(
      action:Action,
      numUsers:Usize,
      userIdToAddress:Map,
      addressToUserId:Map,
      numBoardMembers:Usize,
      numProposers:Usize,
      userIdToRole:Map,
      quorum:Usize)
    [function, functional]
  syntax Bool ::= performEnsures(
      numUsers:Usize,
      userIdToAddress:Map,
      addressToUserId:Map,
      numBoardMembers:Usize,
      numProposers:Usize,
      userIdToRole:Map,
      quorum:Usize)
    [function, functional]
  syntax Bool ::= performInvariant(
      numUsers:Usize,
      userIdToAddress:Map,
      addressToUserId:Map,
      numBoardMembers:Usize,
      numProposers:Usize,
      userIdToRole:Map,
      quorum:Usize,
      handling:PropertyHandling)
    [function, functional]
  syntax TTCell ::= performLhs(
      action:Action,
      K,
      numUsers:Usize,
      userIdToAddress:Map,
      addressToUserId:Map,
      numBoardMembers:Usize,
      numProposers:Usize,
      userIdToRole:Map,
      quorum:Usize,
      ActionStateCell,
      stack:List,
      callerAddress:Address)
    [function, functional]
  syntax TTCell ::= performRhs(
          result:KItem,
          K,
          numUsers:Usize,
          userIdToAddress:Map,
          addressToUserId:Map,
          numBoardMembers:Usize,
          numProposers:Usize,
          userIdToRole:Map,
          quorum:Usize,
          ActionStateCell,
          variables:Map,
          stack:List,
          callerAddress:Address)
      [function, functional]

  rule performRequires(
          Action:Action,
          UNumUsers:Usize,
          UserIdToAddress:Map,
          AddressToUserId:Map,
          u(NumBoardMembers:Int),
          u(NumProposers:Int),
          UserIdToRole:Map,
          u(Quorum:Int))
    => true
      andBool isKResult(Action)
      andBool performInvariant(
          UNumUsers:Usize,
          UserIdToAddress:Map,
          AddressToUserId:Map,
          u(NumBoardMembers:Int),
          u(NumProposers:Int),
          UserIdToRole:Map,
          u(Quorum:Int),
          expand(expanded))

  rule performEnsures(
          UNumUsers:Usize,
          UserIdToAddress:Map,
          AddressToUserId:Map,
          u(NumBoardMembers:Int),
          u(NumProposers:Int),
          UserIdToRole:Map,
          u(Quorum:Int))
    => true
      andBool performInvariant(
          UNumUsers:Usize,
          UserIdToAddress:Map,
          AddressToUserId:Map,
          u(NumBoardMembers:Int),
          u(NumProposers:Int),
          UserIdToRole:Map,
          u(Quorum:Int),
          usesExpanded)

  // TODO: Use the main invariant.
  rule performInvariant(
          u(NumUsers:Int),
          UserIdToAddress:Map,
          AddressToUserId:Map,
          u(NumBoardMembers:Int),
          u(NumProposers:Int),
          UserIdToRole:Map,
          u(Quorum:Int),
          Handling:PropertyHandling)
    => true
      andBool notBool u(0) in_keys(UserIdToAddress)
      andBool notBool u(0) in_keys(UserIdToRole)

      andBool allValuesBecomeKeys(AddressToUserId, UserIdToAddress)
      andBool allValuesBecomeKeys(UserIdToAddress, AddressToUserId)

      andBool addressToUserIdInvariant(AddressToUserId)
      // andBool valuesAreOfType(AddressToUserId, rUsize)
      // andBool valuesAreKResult(AddressToUserId)
      // andBool valuesAreNotEmpty(AddressToUserId, rUsize)
      // andBool valuesAreDistinct(AddressToUserId)
      andBool unusedIdsInMapValues(NumUsers +Int 1, AddressToUserId, Handling)
      andBool noReusedIndexValue(NumUsers +Int 1, AddressToUserId, Handling)

      andBool userIdToRoleInvariant(UserIdToRole)
      // andBool valuesAreOfType(UserIdToRole, rUserRole)
      // andBool valuesAreKResult(UserIdToRole)
      // andBool valuesAreNotEmpty(UserIdToRole, rUserRole)
      andBool unusedIdsInMapKeys(NumUsers +Int 1, keysMap(UserIdToRole), Handling)

      andBool NumUsers >=Int 0 // TODO: Strict >?
      andBool NumBoardMembers >=Int 0
      andBool NumProposers >=Int 0

      andBool Quorum <=Int NumBoardMembers
      andBool (NumBoardMembers +Int NumProposers >Int 0)

      andBool NumBoardMembers ==Int countMapValues(UserIdToRole, BoardMember)
      andBool NumProposers ==Int countMapValues(UserIdToRole, Proposer)
  rule performLhs(
          Action:Action,
          K:K,
          NumUsers:Usize,
          UserIdToAddress:Map,
          AddressToUserId:Map,
          NumBoardMembers:Usize,
          NumProposers:Usize,
          UserIdToRole:Map,
          Quorum:Usize,
          ActionState:ActionStateCell,
          Stack:List,
          CallerAddress:Address)
        =>
        <TT>
          <k> call(performAction(Action)) ~> K </k>
          <state>
            <multisig-state>
              <users>
                <num-users>NumUsers</num-users>
                <user-id-to-address>UserIdToAddress</user-id-to-address>
                <address-to-user-id>AddressToUserId</address-to-user-id>
              </users>
              <board-state>
                <num-board-members>NumBoardMembers</num-board-members>
                <num-proposers>NumProposers</num-proposers>
                <user-roles>UserIdToRole</user-roles>
                <quorum>Quorum</quorum>
              </board-state>
              ActionState
            </multisig-state>
            <pseudocode-state>
              <variables>
                .Map
              </variables>
              <stack> Stack </stack>
            </pseudocode-state>
            <external-call-env>
              <caller-address>CallerAddress</caller-address>
            </external-call-env>
            <proof-state>
              <last-instrumented> .K </last-instrumented>
            </proof-state>
          </state>
        </TT>

  rule performRhs(
          Result:KItem,
          K:K,
          NumUsers:Usize,
          UserIdToAddress:Map,
          AddressToUserId:Map,
          NumBoardMembers:Usize,
          NumProposers:Usize,
          UserIdToRole:Map,
          Quorum:Usize,
          ActionState:ActionStateCell,
          Variables:Map,
          Stack:List,
          CallerAddress:Address)
        =>
        <TT>
          <k> Result ~> K </k>
          <state>
            <multisig-state>
              <users>
                <num-users>NumUsers</num-users>
                <user-id-to-address>UserIdToAddress</user-id-to-address>
                <address-to-user-id>AddressToUserId</address-to-user-id>
              </users>
              <board-state>
                <num-board-members>NumBoardMembers</num-board-members>
                <num-proposers>NumProposers</num-proposers>
                <user-roles>UserIdToRole</user-roles>
                <quorum>Quorum</quorum>
              </board-state>
              ActionState
            </multisig-state>
            <pseudocode-state>
              <variables>
                Variables
              </variables>
              <stack> Stack </stack>
            </pseudocode-state>
            <external-call-env>
              <caller-address>CallerAddress</caller-address>
            </external-call-env>
            <proof-state>
              <last-instrumented> .K </last-instrumented>
            </proof-state>
          </state>
        </TT>

endmodule
