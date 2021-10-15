load("//:proof.bzl", "kompile", "klibrary")

kompile(
  name = "malicious-user-execute",
  srcs = ["malicious-user-execute.k"],
  deps = [
      "//protocol-correctness/proof:execution-proof-files",
      "//protocol-correctness/proof/invariant:invariant-execution-files",
      # "//protocol-correctness/proof/functions:functions-execute-files",
  ],
  visibility = ["//visibility:public"],
)
