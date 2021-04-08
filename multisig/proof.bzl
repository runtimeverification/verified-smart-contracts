KompileInfo = provider(fields=["files"])
KtrustedInfo = provider(fields=["trusted"])

def _kompile_impl(ctx):
  output_files = [
    ctx.actions.declare_file(ctx.label.name + '-kompiled/' + name)
    for name in [
      'allRules.txt', 'cache.bin', 'compiled.bin', 'compiled.txt',
      'configVars.sh', 'definition.kore', 'macros.kore', 'mainModule.txt',
      'parsed.txt', 'syntaxDefinition.kore', 'timestamp']
  ]
  if len(ctx.files.srcs) != 1:
    fail
  input_names = [output_files[0].path] + [s.path for s in ctx.files.srcs]
  # TODO: Make this work if the file name is not based on the target name.
  ctx.actions.run(
      inputs=depset(ctx.files.srcs, transitive = [dep[DefaultInfo].files for dep in ctx.attr.deps]),
      outputs=output_files,
      arguments=input_names,
      progress_message="Kompiling %s" % ctx.files.srcs[0].path,
      executable=ctx.executable.kompile_tool)

  return [
      DefaultInfo(
          files = depset(
              output_files,
              transitive = [dep[DefaultInfo].files for dep in ctx.attr.deps]
          ),
      ),
      KompileInfo(files=output_files),
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
    executable = False,
)

def _klibrary_impl(ctx):
  if len(ctx.files.srcs) != 1:
    fail
  input_names = [s.path for s in ctx.files.srcs]
  output_dir = ctx.actions.declare_directory(ctx.label.name + '-kompiled')
  # TODO: Make this work if the file name is not based on the target name.
  ctx.actions.run(
      inputs=depset(ctx.files.srcs, transitive = [dep[DefaultInfo].files for dep in ctx.attr.deps]),
      outputs=[output_dir],
      arguments=input_names,
      progress_message="Checking %s" % ctx.files.srcs[0].path,
      executable=ctx.executable.kompile_tool)
  return [
      DefaultInfo(
          files = depset(ctx.files.srcs + [ output_dir ], transitive = [dep[DefaultInfo].files for dep in ctx.attr.deps]),
      )
  ]

klibrary = rule(
    implementation = _klibrary_impl,
    attrs = {
        "deps": attr.label_list(),
        "srcs": attr.label_list(allow_files = [".k"]),
        "kompile_tool": attr.label(
            executable = True,
            cfg = "exec",
            allow_files = True,
            default = Label("//kompile_tool:kompile_e_tool"),
        ),
    },
)

def _ktrusted_impl(ctx):
  if len(ctx.files.srcs) != 1:
    fail

  tmp_file = ctx.actions.declare_file(ctx.label.name + ".tmp.k")
  ctx.actions.run(
      inputs=depset(ctx.files.srcs),
      outputs=[tmp_file],
      arguments=[ctx.files.srcs[0].path, tmp_file.path],
      progress_message="Trusting %s" % ctx.files.srcs[0].path,
      executable=ctx.executable.ktrusted_tool)

  output_file = ctx.actions.declare_file(ctx.label.name + ".k")
  all_trusted = []
  for dep in ctx.attr.trusted:
    all_trusted += dep[KtrustedInfo].trusted
  ctx.actions.run(
      inputs=depset([tmp_file] + all_trusted),
      outputs=[output_file],
      arguments=[output_file.path, tmp_file.path] + [s.path for s in all_trusted],
      progress_message="Merging %s" % ctx.files.srcs[0].path,
      executable=ctx.executable.kmerge_tool)
  return [
      KtrustedInfo(
          trusted = output_file,
      )
  ]

ktrusted = rule(
    implementation = _ktrusted_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".k"]),
        "trusted": attr.label_list(providers=[DefaultInfo, KtrustedInfo]),
        "ktrusted_tool": attr.label(
            executable = True,
            cfg = "exec",
            allow_files = True,
            default = Label("//kompile_tool:ktrusted_tool"),
        ),
        "kmerge_tool": attr.label(
            executable = True,
            cfg = "exec",
            allow_files = True,
            default = Label("//kompile_tool:kmerge_tool"),
        ),
    },
)

def _kprove_impl(ctx):
  if len(ctx.files.srcs) != 1:
    fail
  merged_file = ctx.actions.declare_file(ctx.label.name + '.k')

  all_trusted = []
  for dep in ctx.attr.trusted:
    all_trusted += [dep[KtrustedInfo].trusted]
  ctx.actions.run(
      inputs=depset(ctx.files.srcs + all_trusted),
      outputs=[merged_file],
      arguments=[merged_file.path] + [s.path for s in (ctx.files.srcs + all_trusted)],
      progress_message="Preparing %s" % ctx.files.srcs[0].path,
      executable=ctx.executable.kmerge_tool)

  output_file = ctx.actions.declare_file(ctx.label.name + '-proved-xyzzy')
  tmp_dir = ctx.actions.declare_directory(ctx.label.name + '-kompiled-xyzzy')
  # TODO: Make this work if the file name is not based on the target name.
  ctx.actions.run(
      inputs=depset([merged_file] + ctx.attr.semantics[KompileInfo].files),
      outputs=[output_file, tmp_dir],
      arguments=[output_file.path, ctx.attr.semantics[KompileInfo].files[0].path, tmp_dir.path, merged_file.path],
      progress_message="Proving %s" % ctx.files.srcs[0].path,
      executable=ctx.executable.kprove_tool)
  return [
      DefaultInfo(
          files = depset([ output_file ]),
      )
  ]

kprove = rule(
    implementation = _kprove_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".k"]),
        "trusted": attr.label_list(providers=[DefaultInfo, KtrustedInfo]),
        "semantics": attr.label(mandatory=True, providers=[DefaultInfo, KompileInfo]),
        "kprove_tool": attr.label(
            executable = True,
            cfg = "exec",
            allow_files = True,
            default = Label("//kompile_tool:kprove_tool"),
        ),
        "kmerge_tool": attr.label(
            executable = True,
            cfg = "exec",
            allow_files = True,
            default = Label("//kompile_tool:kmerge_tool"),
        ),
    },
)

# # Given executable_file and runfile_file:
# runfiles_root = executable_file.path + ".runfiles"
# workspace_name = ctx.workspace_name
# runfile_path = runfile_file.short_path
# execution_root_relative_path = "%s/%s/%s" % (
#     runfiles_root, workspace_name, runfile_path)

#Args.add_all