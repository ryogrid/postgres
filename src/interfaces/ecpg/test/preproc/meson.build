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

check_cmd_notice_exe = executable('check_cmd_notice',
  ['check_cmd_notice.c', 'check_cmd_notice_util.c'],
  include_directories: [pg_regress_inc],
  c_args: cflags + ['-DBINARY_PATH="@0@/../../preproc/ecpg"'.format(meson.current_build_dir()), '-DPGC_FILE_NAME="@0@/notice.pgc"'.format(meson.current_source_dir())],
  dependencies: [frontend_code, libpq],
  build_by_default: false,
  install: false,
)

check_cmd_notice_informix_exe = executable('check_cmd_notice_informix',
  ['check_cmd_notice_informix.c', 'check_cmd_notice_util.c'],
  include_directories: [pg_regress_inc],
  c_args: cflags + ['-DBINARY_PATH="@0@/../../preproc/ecpg"'.format(meson.current_build_dir()), '-DPGC_FILE_NAME="@0@/notice_informix.pgc"'.format(meson.current_source_dir())],
  dependencies: [frontend_code, libpq],
  build_by_default: false,
  install: false,
)

# Update test dependencies
ecpg_test_dependencies += [
  check_cmd_notice_exe,
  check_cmd_notice_informix_exe,
]