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

# copy materials for ecpg command notice test

notice_pgc = configure_file(
    input: 'notice.pgc',
    output: 'notice.pgc',
    copy: true,
)

notice_informix_pgc = configure_file(
    input: 'notice_informix.pgc',
    output: 'notice_informix.pgc',
    copy: true,
)

ecpg_wrapper_bat = configure_file(
    input: 'notice_check.bat',
    output: 'notice_check.bat',
    copy: true,
)

ecpg_wrapper_bat = configure_file(
    input: 'notice_check.sh',
    output: 'notice_check.sh',
    copy: true,
)

ecpg_wrapper_bat = configure_file(
    input: 'notice_informix_check.bat',
    output: 'notice_informix_check.bat',
    copy: true,
)

ecpg_wrapper_bat = configure_file(
    input: 'notice_informix_check.sh',
    output: 'notice_informix_check.sh',
    copy: true,
)