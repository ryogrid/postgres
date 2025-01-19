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


cmd_out_exe = executable(
  'cmd_out',
  [
    'cmd_out.c',
    'cmd_out_util.c',
  ],
  c_args: cflags_no_missing_var_decls,
  dependencies: [],
  include_directories: [],
  link_with: [],
  build_by_default: false,
  install: false,
)

cmd_out_informix_exe = executable(
  'cmd_out_informix',
  [
    'cmd_out_informix.c',
    'cmd_out_util.c',
  ],
  c_args: cflags_no_missing_var_decls,
  dependencies: [],
  include_directories: [],
  link_with: [],
  build_by_default: false,
  install: false,
)

cmd_out_clean = custom_target(
  'clean_cmd_out_c',
  output: 'preproc-cmd_out_dummy.c',
  command: [
    'rm',
    '-f',
    join_paths(meson.current_source_dir(), '..', 'expected', 'preproc-cmd_out.c'),
  ],
  build_by_default: false,
  depend_files: ['cmd_out.c'],
  depends: cmd_out_exe,
  install: false,
)

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
  depends: cmd_out_clean,
  install: false,
)

cmd_out_informix_clean = custom_target(
  'clean_cmd_out_informix_c',
  output: 'preproc-cmd_out_informix_dummy.c',
  command: [
    'rm',
    '-f',
    join_paths(meson.current_source_dir(), '..', 'expected', 'preproc-cmd_out_informix.c'),
  ],
  build_by_default: false,
  depends: cmd_out_informix_exe,
  install: false,
)

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
  depends: cmd_out_informix_clean,
  install: false,
)

ecpg_test_dependencies += [
  cmd_out_exe,
  cmd_out_clean,
  cmd_out_copy,
  cmd_out_informix_exe,
  cmd_out_informix_clean,
  cmd_out_informix_copy,
]