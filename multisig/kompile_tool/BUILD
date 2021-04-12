sh_binary(
  name = "kompile_tool",
  srcs = ["kompile.sh"],
  deps = [":k_release"],
  data = [":k_release"],
  visibility = ["//visibility:public"],
)

sh_binary(
  name = "kompile_e_tool",
  srcs = ["kompile-e.sh"],
  deps = [":k_release"],
  data = [":k_release"],
  visibility = ["//visibility:public"],
)

sh_binary(
  name = "kprove_tool",
  srcs = ["kprove.sh"],
  deps = [":k_release"],
  data = [":k_release"],
  visibility = ["//visibility:public"],
)

sh_binary(
  name = "kdebug_tool",
  srcs = ["kdebug.sh"],
  deps = [":k_release", ":kast_script"],  # TODO: Use either deps or data.
  data = [":k_release", ":kast_script"],
  visibility = ["//visibility:public"],
)

sh_binary(
  name = "ktrusted_tool",
  srcs = ["make-trusted.py"],
  visibility = ["//visibility:public"],
)

sh_binary(
  name = "kmerge_tool",
  srcs = ["kmerge.sh"],
  visibility = ["//visibility:public"],
)

sh_library(
  name = "k_release",
  data = glob(["k/**"]),
  visibility = ["//visibility:public"],
)

sh_library(
  name = "kast_script",
  srcs = ["kast.kscript"],
  visibility = ["//visibility:public"],
)
