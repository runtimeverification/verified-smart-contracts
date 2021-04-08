load("//:proof.bzl", "klibrary")

klibrary(
  name = "execution-proof-files",
  srcs = ["execution-proof.k"],
  deps = [
      ":invariant-files",
      ":execution-proof-helpers-files",
  ],
  visibility = ["//visibility:public"],
)

klibrary(
  name = "execution-proof-helpers-files",
  srcs = ["execution-proof-helpers.k"],
  deps = [
      "//protocol-correctness:pseudocode-files",
      "//protocol-correctness/proof/map:map-files",
  ],
  visibility = ["//visibility:public"],
)

klibrary(
  name = "invariant-files",
  srcs = ["invariant.k"],
  deps = [
      ":execution-proof-helpers-files",
      "//protocol-correctness:pseudocode-files"
  ],
  visibility = ["//visibility:public"],
)
