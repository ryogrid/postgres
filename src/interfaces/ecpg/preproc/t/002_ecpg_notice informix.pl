
# Copyright (c) 2021-2025, PostgreSQL Global Development Group

use strict;
use warnings FATAL => 'all';
use PostgreSQL::Test::Utils;
use Test::More;

program_help_ok('ecpg');
program_version_ok('ecpg');
program_options_handling_ok('ecpg');
command_fails(['ecpg'], 'ecpg without arguments fails');

command_checks_all(
	[ 'ecpg', 't/notice_informix.pgc' ],
	3,
	[qr//],
	[
		qr/ERROR: AT option not allowed in CLOSE DATABASE statement/,
		qr/ERROR: "database" cannot be used as cursor name in INFORMIX mode/
	],
	'ecpg with warnings');

done_testing();
