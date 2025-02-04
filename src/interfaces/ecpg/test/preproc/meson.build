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
copy_materials = [
  'notice.pgc',
  'notice_informix.pgc',
  'notice_check.bat',
  'notice_check.sh',
  'notice_informix_check.bat',
  'notice_informix_check.sh',
]

copy_cmdline = [
  python,
  meson.current_source_dir() / 'copy_files.py',
  meson.current_source_dir(),
  meson.current_build_dir()
]

foreach file : copy_materials
  copy_cmdline += file
endforeach

ecpg_test_dependencies += custom_target('copy_ecpg_test_materials',
  input: meson.current_source_dir() / 'copy_files.py',
  output: copy_materials,
  command: copy_cmdline,
  build_by_default: false,
)