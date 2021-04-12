load("//:proof.bzl", "kompile", "kprove", "ktrusted", "kdebug", "kprove_test")

kompile(
  name = "functions-execute",
  srcs = ["functions-execute.k"],
  deps = [
      "//protocol-correctness/proof:execution-proof-files",
      "//protocol-correctness:pseudocode-files",
  ],
)

kprove_test(
  name = "proof-perform-action-remove-user-BoardMember",
  srcs = ["proof-perform-action-remove-user-BoardMember.k"],
  trusted = [":trusted-change-user-role-BoardMember"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-remove-user-BoardMember-too-few",
  srcs = ["proof-perform-action-remove-user-BoardMember-too-few.k"],
  trusted = [":trusted-change-user-role-BoardMember"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-remove-user-Proposer-nobody-left",
  srcs = ["proof-perform-action-remove-user-Proposer-nobody-left.k"],
  trusted = [":trusted-change-user-role-Proposer"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-remove-user-Proposer",
  srcs = ["proof-perform-action-remove-user-Proposer.k"],
  trusted = [":trusted-change-user-role-Proposer"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-remove-user-None",
  srcs = ["proof-perform-action-remove-user-None.k"],
  trusted = [":trusted-change-user-role-None"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-remove-user-New",
  srcs = ["proof-perform-action-remove-user-New.k"],
  trusted = [":trusted-change-user-role-New"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-change-quorum",
  srcs = ["proof-perform-action-change-quorum.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-change-quorum-no-quorum",
  srcs = ["proof-perform-action-change-quorum-no-quorum.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-add-proposer-BoardMember-no-quorum",
  srcs = ["proof-perform-action-add-proposer-BoardMember-no-quorum.k"],
  trusted = [":trusted-change-user-role-BoardMember"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-add-proposer-BoardMember",
  srcs = ["proof-perform-action-add-proposer-BoardMember.k"],
  trusted = [":trusted-change-user-role-BoardMember"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-add-proposer-Proposer",
  srcs = ["proof-perform-action-add-proposer-Proposer.k"],
  trusted = [":trusted-change-user-role-Proposer"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-add-proposer-New",
  srcs = ["proof-perform-action-add-proposer-New.k"],
  trusted = [":trusted-change-user-role-New"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-add-proposer-None",
  srcs = ["proof-perform-action-add-proposer-None.k"],
  trusted = [":trusted-change-user-role-None"],
  semantics = ":functions-execute",
)

kdebug(
  name = "proof-perform-action-add-board-member-None-debug",
  srcs = ["proof-perform-action-add-board-member-None.k"],
  trusted = [":trusted-change-user-role-None"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-add-board-member-New",
  srcs = ["proof-perform-action-add-board-member-New.k"],
  trusted = [":trusted-change-user-role-New"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-add-board-member-BoardMember",
  srcs = ["proof-perform-action-add-board-member-BoardMember.k"],
  trusted = [":trusted-change-user-role-BoardMember"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-add-board-member-Proposer",
  srcs = ["proof-perform-action-add-board-member-Proposer.k"],
  trusted = [":trusted-change-user-role-Proposer"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-add-board-member-None",
  srcs = ["proof-perform-action-add-board-member-None.k"],
  trusted = [":trusted-change-user-role-None"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-send-egld",
  srcs = ["proof-perform-action-send-egld.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-sc-call",
  srcs = ["proof-perform-action-sc-call.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-sc-deploy",
  srcs = ["proof-perform-action-sc-deploy.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-perform-action-nothing",
  srcs = ["proof-perform-action-nothing.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-change-user-role-BoardMember",
  srcs = ["proof-change-user-role-BoardMember.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-change-user-role-New",
  srcs = ["proof-change-user-role-New.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-change-user-role-None",
  srcs = ["proof-change-user-role-None.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-change-user-role-Proposer",
  srcs = ["proof-change-user-role-Proposer.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-count-can-sign",
  srcs = ["proof-count-can-sign.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-discard-action-has-signers",
  srcs = ["proof-discard-action-has-signers.k"],
  trusted = [":trusted-count-can-sign"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-discard-action-no-role",
  srcs = ["proof-discard-action-no-role.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-discard-action-no-signers-no-action",
  srcs = ["proof-discard-action-no-signers-no-action.k"],
  trusted = [":trusted-count-can-sign"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-discard-action-no-signers",
  srcs = ["proof-discard-action-no-signers.k"],
  trusted = [":trusted-count-can-sign"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-discard-action-no-user",
  srcs = ["proof-discard-action-no-user.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-discard-action-no-valid-signers-no-action",
  srcs = ["proof-discard-action-no-valid-signers-no-action.k"],
  trusted = [":trusted-count-can-sign"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-discard-action-no-valid-signers",
  srcs = ["proof-discard-action-no-valid-signers.k"],
  trusted = [":trusted-count-can-sign"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-propose-action-BoardMember",
  srcs = ["proof-propose-action-BoardMember.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-propose-action-error-no-role",
  srcs = ["proof-propose-action-error-no-role.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-propose-action-error-no-user",
  srcs = ["proof-propose-action-error-no-user.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-propose-action-Proposer",
  srcs = ["proof-propose-action-Proposer.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-propose-sc-deploy-BoardMember",
  srcs = ["proof-propose-sc-deploy-BoardMember.k"],
  trusted = [
      ":trusted-propose-action-BoardMember",
      ":trusted-propose-sc-deploy-fragment",
  ],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-propose-sc-deploy-error-no-role",
  srcs = ["proof-propose-sc-deploy-error-no-role.k"],
  trusted = [
      ":trusted-propose-action-error-no-role",
      ":trusted-propose-sc-deploy-fragment",
  ],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-propose-sc-deploy-error-no-user",
  srcs = ["proof-propose-sc-deploy-error-no-user.k"],
  trusted = [
      ":trusted-propose-action-error-no-user",
      ":trusted-propose-sc-deploy-fragment",
  ],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-propose-sc-deploy-fragment",
  srcs = ["proof-propose-sc-deploy-fragment.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-propose-sc-deploy-Proposer",
  srcs = ["proof-propose-sc-deploy-Proposer.k"],
  trusted = [
      ":trusted-propose-action-Proposer",
      ":trusted-propose-sc-deploy-fragment",
  ],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-sign-caller-none",
  srcs = ["proof-sign-caller-none.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-sign-caller-not-user",
  srcs = ["proof-sign-caller-not-user.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-sign-caller-proposer",
  srcs = ["proof-sign-caller-proposer.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-sign-empty-action",
  srcs = ["proof-sign-empty-action.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-sign-existing-signers-in-list",
  srcs = ["proof-sign-existing-signers-in-list.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-sign-existing-signers-not-in-list",
  srcs = ["proof-sign-existing-signers-not-in-list.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-sign-no-signers",
  srcs = ["proof-sign-no-signers.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-unsign-no-action",
  srcs = ["proof-unsign-no-action.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-unsign-no-role",
  srcs = ["proof-unsign-no-role.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-unsign-no-signers",
  srcs = ["proof-unsign-no-signers.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-unsign-no-user",
  srcs = ["proof-unsign-no-user.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-unsign-not-signed",
  srcs = ["proof-unsign-not-signed.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-unsign-only-signer",
  srcs = ["proof-unsign-only-signer.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-unsign-other-signers-first",
  srcs = ["proof-unsign-other-signers-first.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-unsign-other-signers-not-first",
  srcs = ["proof-unsign-other-signers-not-first.k"],
  semantics = ":functions-execute",
)

kprove(
  name = "proof-unsign-Proposer",
  srcs = ["proof-unsign-Proposer.k"],
  semantics = ":functions-execute",
)

ktrusted(
  name = "trusted-count-can-sign",
  srcs = ["proof-count-can-sign.k"],
)

ktrusted(
  name = "trusted-propose-action-BoardMember",
  srcs = ["proof-propose-action-BoardMember.k"],
)

ktrusted(
  name = "trusted-propose-action-Proposer",
  srcs = ["proof-propose-action-Proposer.k"],
)

ktrusted(
  name = "trusted-propose-action-error-no-role",
  srcs = ["proof-propose-action-error-no-role.k"],
)

ktrusted(
  name = "trusted-propose-action-error-no-user",
  srcs = ["proof-propose-action-error-no-user.k"],
)

ktrusted(
  name = "trusted-propose-sc-deploy-fragment",
  srcs = ["proof-propose-sc-deploy-fragment.k"],
)

ktrusted(
  name = "trusted-change-user-role-BoardMember",
  srcs = ["proof-change-user-role-BoardMember.k"],
)

ktrusted(
  name = "trusted-change-user-role-New",
  srcs = ["proof-change-user-role-New.k"],
)

ktrusted(
  name = "trusted-change-user-role-None",
  srcs = ["proof-change-user-role-None.k"],
)

ktrusted(
  name = "trusted-change-user-role-Proposer",
  srcs = ["proof-change-user-role-Proposer.k"],
)

