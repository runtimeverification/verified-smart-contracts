sh_binary(
  name = "kompile_tool",
  srcs = ["kompile.sh"],
  deps = [":k_release"],
  data = [":k_release"],
  visibility = ["//visibility:public"],
)

sh_library(
  name = "k_release",
  data = glob(["k/**"]),
)