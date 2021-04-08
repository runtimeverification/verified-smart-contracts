def _kompile_impl(ctx):
  output_dir = ctx.actions.declare_directory(ctx.label.name + '-kompiled')
  if len(ctx.files.srcs) != 1:
    fail
  input_names = [s.path for s in ctx.files.srcs]
  # TODO: Make this work if the file name is not based on the target name.
  ctx.actions.run(
      inputs=ctx.files.srcs,
      outputs=[output_dir],
      arguments=input_names,
      progress_message="Kompiling %s." % ctx.files.srcs[0].path,
      # tools=depset(["//kompile_tool"]),
      executable=ctx.executable.kompile_tool)
  print("here")
  return [
      DefaultInfo(
          files = depset([ output_dir ]),
      )
  ]

kompile = rule(
    implementation = _kompile_impl,
    attrs = {
        "deps": attr.label_list(),
        "srcs": attr.label_list(allow_files = [".k"]),
        "kompile_tool": attr.label(
            executable = True,
            cfg = "exec",
            allow_files = True,
            default = Label("//kompile_tool"),
        ),
    },
)
