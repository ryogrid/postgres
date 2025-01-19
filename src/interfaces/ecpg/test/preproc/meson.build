# Copyright (c) 2022-2025, PostgreSQL Global Development Group

pgc_files = [
  'array_of_struct',
  'autoprep',
  'comment',
  'cursor',
  'define',
  'init',
  'outofscope',
  'pointer_to_struct',
  'strings',
  'type',
  'variable',
  'whenever',
  'whenever_do_continue',
]

pgc_extra_flags = {
  'array_of_struct': ['-c'],
  'pointer_to_struct': ['-c'],
  'autoprep': ['-r', 'prepare'],
  'strings': ['-i'],
}

foreach pgc_file : pgc_files
  exe_input = custom_target('@0@.c'.format(pgc_file),
    input: '@0@.pgc'.format(pgc_file),
    command: ecpg_preproc_test_command_start +
      pgc_extra_flags.get(pgc_file, []) +
      ecpg_preproc_test_command_end,
    kwargs: ecpg_preproc_kw,
  )

  ecpg_test_dependencies += executable(pgc_file,
    exe_input,
    kwargs: ecpg_test_exec_kw,
  )
endforeach

# For testing syntax error detection of ecpg command
# cmd_out_util = executable('cmd_out_util',
#   'cmd_out_util.c',
#   c_args: cflags_no_missing_var_decls,
#   build_by_default: false,
#   install: false,
# )

# cmd_out executable
cmd_out_exe = executable('cmd_out',
  ['cmd_out.c', 'cmd_out_util.c'],
  c_args: cflags_no_missing_var_decls,
  build_by_default: false,
  install: false,
)

# Clean cmd_out.c target
cmd_out_as_generated = custom_target(
  'cmd_out_as_generated',
  input: 'cmd_out.c',
  output: 'preproc-cmd_out_dummy1.c',
  command: [
    'cp',
    '@INPUT@',
    join_paths(meson.current_build_dir(), 'cmd_out.c'),
  ],
  build_by_default: false,
  install: false,
)

cmd_out_clean = custom_target(
  'clean_cmd_out_c',
  output: 'preproc-cmd_out_dummy2.c',
  command: [
    'rm',
    '-f',
    join_paths(meson.current_source_dir(), '..', 'expected', 'preproc-cmd_out.c'),
  ],
  build_by_default: false,
  depend_files: ['cmd_out.c'],
  depends: [cmd_out_exe, cmd_out_as_generated],
  install: false,
)

# Copy cmd_out.c target
cmd_out_copy = custom_target(
  'copy_cmd_out_c',
  input: 'cmd_out.c',
  output: 'preproc-cmd_out.c',
  command: [
    'cp',
    '@INPUT@',
    join_paths(meson.current_source_dir(), '..', 'expected', 'preproc-cmd_out.c'),
  ],
  build_by_default: false,
  depend_files: ['cmd_out.c'],
  depends: [cmd_out_exe, cmd_out_clean],
  install: false,
)

cmd_out_informix_as_generated = custom_target(
  'cmd_out_informix_as_generated',
  input: 'cmd_out_informix.c',
  output: 'preproc-cmd_out_informix_dummy1.c',
  command: [
    'cp',
    '@INPUT@',
    join_paths(meson.current_build_dir(), 'cmd_out_informix.c'),
  ],
  build_by_default: false,
  install: false,
)

# cmd_out_informix executable
cmd_out_informix_exe = executable('cmd_out_informix',
  ['cmd_out_informix.c', 'cmd_out_util.c'],
  c_args: cflags_no_missing_var_decls,
  build_by_default: false,
  install: false,
)

# Clean cmd_out_informix.c target
cmd_out_informix_clean = custom_target(
  'clean_cmd_out_informix_c',
  output: 'preproc-cmd_out_informix_dummy2.c',
  command: [
    'rm',
    '-f',
    join_paths(meson.current_source_dir(), '..', 'expected', 'preproc-cmd_out_informix.c'),
  ],
  build_by_default: false,
  depends: [cmd_out_informix_exe, cmd_out_informix_as_generated],
  install: false,
)

# Copy cmd_out_informix.c target
cmd_out_informix_copy = custom_target(
  'copy_cmd_out_informix_c',
  input: 'cmd_out_informix.c',
  output: 'preproc-cmd_out_informix.c',
  command: [
    'cp',
    '@INPUT@',
    join_paths(meson.current_source_dir(), '..', 'expected', 'preproc-cmd_out_informix.c'),
  ],
  build_by_default: false,
  depend_files: ['cmd_out_informix.c'],
  depends: cmd_out_informix_clean,
  install: false,
)

# Update test dependencies
ecpg_test_dependencies += [
  cmd_out_exe,
  cmd_out_copy,
  cmd_out_clean,
  cmd_out_as_generated,
  cmd_out_informix_exe,
  cmd_out_informix_copy,
  cmd_out_informix_clean,
  cmd_out_informix_as_generated,
]