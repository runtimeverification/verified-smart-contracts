load("//:proof.bzl", "kprove_test", "ktrusted")

kprove_test(
  name = "proof-cannot-perform",
  srcs = ["proof-cannot-perform.k"],
  trusted = [
  ],
  semantics = "//protocol-correctness/proof/malicious-user:malicious-user-execute",
  timeout = "eternal",
)
