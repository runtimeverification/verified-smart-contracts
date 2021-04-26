load("//:proof.bzl", "kprove_test", "ktrusted")

kprove_test(
  name = "proof-cannot-perform",
  srcs = ["proof-cannot-perform.k"],
  trusted = [
      ":trusted-call-invariant",
  ],
  semantics = "//protocol-correctness/proof/malicious-user:malicious-user-execute",
  timeout = "moderate",
  breadth = "2",
  # depth = "5"
)

kprove_test(
  name = "proof-call-invariant",
  srcs = ["proof-call-invariant.k"],
  trusted = [
      ":trusted-propose-add-board-member",
  ],
  semantics = "//protocol-correctness/proof/malicious-user:malicious-user-execute",
  timeout = "eternal",
)

kprove_test(
  name = "proof-propose-add-board-member",
  srcs = ["proof-propose-add-board-member.k"],
  trusted = [
      "//protocol-correctness/proof/functions:trusted-propose-action-BoardMember",
      "//protocol-correctness/proof/functions:trusted-propose-action-Proposer",
      "//protocol-correctness/proof/functions:trusted-propose-action-error-no-user",
      "//protocol-correctness/proof/functions:trusted-propose-action-error-no-role",
  ],
  semantics = "//protocol-correctness/proof/malicious-user:malicious-user-execute",
  timeout = "eternal",
  breadth = "6",
  # depth = ~37
)

ktrusted(
  name = "trusted-call-invariant",
  srcs = ["proof-call-invariant.k"],
  visibility = ["//visibility:public"],
)

ktrusted(
  name = "trusted-propose-add-board-member",
  srcs = ["proof-propose-add-board-member.k"],
  visibility = ["//visibility:public"],
)

