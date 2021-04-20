load("//:proof.bzl", "kompile", "kprove_test", "ktrusted", "klibrary", "kore_test", "kprove_kompile")

kompile(
  name = "invariant-execution",
  srcs = ["invariant-execution.k"],
  deps = [
      ":count-can-sign-parts-files",
      ":init-loop-parts-files",
      ":perform-parts-files",
      "//protocol-correctness/proof:execution-proof-files",
      "//protocol-correctness/proof/functions:functions-execute-files",
  ],
)

# TODO: Delete.
klibrary(
  name = "count-can-sign-parts-files",
  srcs = ["count-can-sign-parts.k"],
  deps = [
      "//protocol-correctness/proof:execution-proof-helpers-files",
      "//protocol-correctness/proof:invariant-files",
      "//protocol-correctness:pseudocode-files",
  ],
)

klibrary(
  name = "init-loop-parts-files",
  srcs = ["init-loop-parts.k"],
  deps = [
      "//protocol-correctness/proof:execution-proof-helpers-files",
      "//protocol-correctness/proof:invariant-files",
      "//protocol-correctness:pseudocode-files",
  ],
)

# TODO: Delete.
klibrary(
  name = "perform-parts-files",
  srcs = ["perform-parts.k"],
  deps = [
      "//protocol-correctness/proof:execution-proof-helpers-files",
      "//protocol-correctness/proof:invariant-files",
      "//protocol-correctness:pseudocode-files",
  ],
)

# kprove_test(
#   name = "proof-discard-action",
#   srcs = ["proof-discard-action.k"],
#   trusted = [
#       "//protocol-correctness/proof/functions:trusted-discard-action-has-signers",
#       "//protocol-correctness/proof/functions:trusted-discard-action-no-role",
#       "//protocol-correctness/proof/functions:trusted-discard-action-no-signers",
#       "//protocol-correctness/proof/functions:trusted-discard-action-no-signers-no-action",
#       "//protocol-correctness/proof/functions:trusted-discard-action-no-user",
#       "//protocol-correctness/proof/functions:trusted-discard-action-no-valid-signers",
#       "//protocol-correctness/proof/functions:trusted-discard-action-no-valid-signers-no-action",
#   ],
#   semantics = ":invariant-execution",
# )

# kprove_test(
#   name = "proof-perform-action-endpoint",
#   srcs = ["proof-perform-action-endpoint.k"],
#   trusted = [
#   ],
#   semantics = ":invariant-execution",
# )

kprove_test(
  name = "proof-perform-parts-change-quorum",
  srcs = ["proof-perform-parts-change-quorum.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-change-quorum",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-change-quorum-no-quorum",
  srcs = ["proof-perform-parts-change-quorum-no-quorum.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-change-quorum-no-quorum",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-New",
  srcs = ["proof-perform-parts-New.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-New",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-None",
  srcs = ["proof-perform-parts-None.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-None",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-no-quorum",
  srcs = ["proof-perform-parts-no-quorum.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-no-quorum",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-nothing",
  srcs = ["proof-perform-parts-nothing.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-nothing",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-sc-call",
  srcs = ["proof-perform-parts-sc-call.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-sc-call",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-sc-deploy",
  srcs = ["proof-perform-parts-sc-deploy.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-sc-deploy",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-send-egld",
  srcs = ["proof-perform-parts-send-egld.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-send-egld",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-add-board-member",
  srcs = ["proof-perform-parts-add-board-member.k"],
  trusted = [
      ":trusted-perform-parts-add-board-member-boardmember-eq",
      ":trusted-perform-parts-add-board-member-boardmember",
      ":trusted-perform-parts-add-board-member-new",
      ":trusted-perform-parts-add-board-member-none",
      ":trusted-perform-parts-add-board-member-proposer-eq",
      ":trusted-perform-parts-add-board-member-proposer",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-add-proposer",
  srcs = ["proof-perform-parts-add-proposer.k"],
  trusted = [
      ":trusted-perform-parts-add-proposer-BoardMember-eq",
      ":trusted-perform-parts-add-proposer-BoardMember-no-quorum-eq",
      ":trusted-perform-parts-add-proposer-BoardMember-no-quorum",
      ":trusted-perform-parts-add-proposer-BoardMember",
      ":trusted-perform-parts-add-proposer-New",
      ":trusted-perform-parts-add-proposer-None",
      ":trusted-perform-parts-add-proposer-Proposer-eq",
      ":trusted-perform-parts-add-proposer-Proposer",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-add-board-member-boardmember-eq",
  srcs = ["proof-perform-parts-add-board-member-boardmember-eq.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-add-board-member-BoardMember-eq",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-add-board-member-boardmember",
  srcs = ["proof-perform-parts-add-board-member-boardmember.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-add-board-member-BoardMember",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-add-board-member-new",
  srcs = ["proof-perform-parts-add-board-member-new.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-add-board-member-New",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-add-board-member-none",
  srcs = ["proof-perform-parts-add-board-member-none.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-add-board-member-None",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-add-board-member-proposer-eq",
  srcs = ["proof-perform-parts-add-board-member-proposer-eq.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-add-board-member-Proposer-eq",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-add-board-member-proposer",
  srcs = ["proof-perform-parts-add-board-member-proposer.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-add-board-member-Proposer",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-add-proposer-BoardMember-eq",
  srcs = ["proof-perform-parts-add-proposer-BoardMember-eq.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-add-proposer-BoardMember-eq",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-add-proposer-BoardMember",
  srcs = ["proof-perform-parts-add-proposer-BoardMember.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-add-proposer-BoardMember",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-add-proposer-BoardMember-no-quorum-eq",
  srcs = ["proof-perform-parts-add-proposer-BoardMember-no-quorum-eq.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-add-proposer-BoardMember-no-quorum-eq",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-add-proposer-BoardMember-no-quorum",
  srcs = ["proof-perform-parts-add-proposer-BoardMember-no-quorum.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-add-proposer-BoardMember-no-quorum",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-add-proposer-New",
  srcs = ["proof-perform-parts-add-proposer-New.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-add-proposer-New",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-add-proposer-None",
  srcs = ["proof-perform-parts-add-proposer-None.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-add-proposer-None",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-add-proposer-Proposer-eq",
  srcs = ["proof-perform-parts-add-proposer-Proposer-eq.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-add-proposer-Proposer-eq",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-add-proposer-Proposer",
  srcs = ["proof-perform-parts-add-proposer-Proposer.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-add-proposer-Proposer",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-remove-user-BoardMember-eq",
  srcs = ["proof-perform-parts-remove-user-BoardMember-eq.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-remove-user-BoardMember-eq",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-remove-user-BoardMember",
  srcs = ["proof-perform-parts-remove-user-BoardMember.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-remove-user-BoardMember",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-remove-user-BoardMember-too-few-eq",
  srcs = ["proof-perform-parts-remove-user-BoardMember-too-few-eq.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-remove-user-BoardMember-too-few-eq",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-remove-user-BoardMember-too-few",
  srcs = ["proof-perform-parts-remove-user-BoardMember-too-few.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-remove-user-BoardMember-too-few",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-remove-user-New",
  srcs = ["proof-perform-parts-remove-user-New.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-remove-user-New",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-remove-user-None",
  srcs = ["proof-perform-parts-remove-user-None.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-remove-user-None",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-remove-user-Proposer-eq",
  srcs = ["proof-perform-parts-remove-user-Proposer-eq.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-remove-user-Proposer-eq",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-remove-user-Proposer",
  srcs = ["proof-perform-parts-remove-user-Proposer.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-remove-user-Proposer",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-remove-user-Proposer-nobody-left-eq",
  srcs = ["proof-perform-parts-remove-user-Proposer-nobody-left-eq.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-remove-user-Proposer-nobody-left-eq",
  ],
  semantics = ":invariant-execution",
)

kprove_test(
  name = "proof-perform-parts-remove-user-Proposer-nobody-left",
  srcs = ["proof-perform-parts-remove-user-Proposer-nobody-left.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-perform-action-endpoint-remove-user-Proposer-nobody-left",
  ],
  semantics = ":invariant-execution",
)

ktrusted(
  name = "trusted-perform-parts-add-board-member-boardmember-eq",
  srcs = ["proof-perform-parts-add-board-member-boardmember-eq.k"],
  visibility = ["//visibility:public"],
)

ktrusted(
  name = "trusted-perform-parts-add-board-member-boardmember",
  srcs = ["proof-perform-parts-add-board-member-boardmember.k"],
  visibility = ["//visibility:public"],
)

ktrusted(
  name = "trusted-perform-parts-add-board-member-new",
  srcs = ["proof-perform-parts-add-board-member-new.k"],
  visibility = ["//visibility:public"],
)

ktrusted(
  name = "trusted-perform-parts-add-board-member-none",
  srcs = ["proof-perform-parts-add-board-member-none.k"],
  visibility = ["//visibility:public"],
)

ktrusted(
  name = "trusted-perform-parts-add-board-member-proposer-eq",
  srcs = ["proof-perform-parts-add-board-member-proposer-eq.k"],
  visibility = ["//visibility:public"],
)

ktrusted(
  name = "trusted-perform-parts-add-board-member-proposer",
  srcs = ["proof-perform-parts-add-board-member-proposer.k"],
  visibility = ["//visibility:public"],
)

ktrusted(
  name = "trusted-perform-parts-add-proposer-BoardMember-eq",
  srcs = ["proof-perform-parts-add-proposer-BoardMember-eq.k"],
  visibility = ["//visibility:public"],
)

ktrusted(
  name = "trusted-perform-parts-add-proposer-BoardMember-no-quorum-eq",
  srcs = ["proof-perform-parts-add-proposer-BoardMember-no-quorum-eq.k"],
  visibility = ["//visibility:public"],
)

ktrusted(
  name = "trusted-perform-parts-add-proposer-BoardMember-no-quorum",
  srcs = ["proof-perform-parts-add-proposer-BoardMember-no-quorum.k"],
  visibility = ["//visibility:public"],
)

ktrusted(
  name = "trusted-perform-parts-add-proposer-BoardMember",
  srcs = ["proof-perform-parts-add-proposer-BoardMember.k"],
  visibility = ["//visibility:public"],
)

ktrusted(
  name = "trusted-perform-parts-add-proposer-New",
  srcs = ["proof-perform-parts-add-proposer-New.k"],
  visibility = ["//visibility:public"],
)

ktrusted(
  name = "trusted-perform-parts-add-proposer-None",
  srcs = ["proof-perform-parts-add-proposer-None.k"],
  visibility = ["//visibility:public"],
)

ktrusted(
  name = "trusted-perform-parts-add-proposer-Proposer-eq",
  srcs = ["proof-perform-parts-add-proposer-Proposer-eq.k"],
  visibility = ["//visibility:public"],
)

ktrusted(
  name = "trusted-perform-parts-add-proposer-Proposer",
  srcs = ["proof-perform-parts-add-proposer-Proposer.k"],
  visibility = ["//visibility:public"],
)
