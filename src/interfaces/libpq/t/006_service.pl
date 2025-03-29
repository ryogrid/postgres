# Copyright (c) 2025, PostgreSQL Global Development Group
use strict;
use warnings FATAL => 'all';
use File::Copy;
use PostgreSQL::Test::Utils;
use PostgreSQL::Test::Cluster;
use Test::More;

# This tests scenarios related to the service name and the service file,
# for the connection options and their environment variables.

my $node = PostgreSQL::Test::Cluster->new('node');
$node->init;
$node->start;

my $td = PostgreSQL::Test::Utils::tempdir;

# Windows vs non-Windows: CRLF vs LF for the file's newline, relying on
# the fact that libpq uses fgets() when reading the lines of a service file.
my $newline = $windows_os ? "\r\n" : "\n";

# Create the set of service files used in the tests.
# File that includes a valid service name, that uses a decomposed connection
# string for its contents, split on spaces.
my $srvfile_valid = "$td/pg_service_valid.conf";
append_to_file($srvfile_valid, "[my_srv]", $newline);
append_to_file($srvfile_valid, split(/\s+/, $node->connstr) . $newline);

# File defined with no contents, used as default value for PGSERVICEFILE,
# so as no lookup is attempted in the user's home directory.
my $srvfile_empty = "$td/pg_service_empty.conf";
append_to_file($srvfile_empty, '');

# Default service file in PGSYSCONFDIR.
my $srvfile_default = "$td/pg_service.conf";

# Missing service file.
my $srvfile_missing = "$td/pg_service_missing.conf";

# Set the fallback directory lookup of the service file to the temporary
# directory of this test.  PGSYSCONFDIR is used if the service file
# defined in PGSERVICEFILE cannot be found, or when a service file is
# found but not the service name.
local $ENV{PGSYSCONFDIR} = $td;
# Force PGSERVICEFILE to a default location, so as this test never
# tries to look at a home directory.  This value needs to remain
# at the top of this script before running any tests, and should never
# be changed.
local $ENV{PGSERVICEFILE} = "$srvfile_empty";

# Checks combinations of service name and a valid service file.
{
	local $ENV{PGSERVICEFILE} = $srvfile_valid;
	$node->connect_ok(
		'service=my_srv',
		'connection with correct "service" string and PGSERVICEFILE',
		sql => "SELECT 'connect1_1'",
		expected_stdout => qr/connect1_1/);

	$node->connect_ok(
		'postgres://?service=my_srv',
		'connection with correct "service" URI and PGSERVICEFILE',
		sql => "SELECT 'connect1_2'",
		expected_stdout => qr/connect1_2/);

	$node->connect_fails(
		'service=undefined-service',
		'connection with incorrect "service" string and PGSERVICEFILE',
		expected_stderr =>
		  qr/definition of service "undefined-service" not found/);

	local $ENV{PGSERVICE} = 'my_srv';
	$node->connect_ok(
		'',
		'connection with correct PGSERVICE and PGSERVICEFILE',
		sql => "SELECT 'connect1_3'",
		expected_stdout => qr/connect1_3/);

	local $ENV{PGSERVICE} = 'undefined-service';
	$node->connect_fails(
		'',
		'connection with incorrect PGSERVICE and PGSERVICEFILE',
		expected_stdout =>
		  qr/definition of service "undefined-service" not found/);
}

# Checks case of incorrect service file.
{
	local $ENV{PGSERVICEFILE} = $srvfile_missing;
	$node->connect_fails(
		'service=my_srv',
		'connection with correct "service" string and incorrect PGSERVICEFILE',
		expected_stderr =>
		  qr/service file ".*pg_service_missing.conf" not found/);
}

# Checks case of service file named "pg_service.conf" in PGSYSCONFDIR.
{
	# Create copy of valid file
	my $srvfile_default = "$td/pg_service.conf";
	copy($srvfile_valid, $srvfile_default);

	$node->connect_ok(
		'service=my_srv',
		'connection with correct "service" string and pg_service.conf',
		sql => "SELECT 'connect2_1'",
		expected_stdout => qr/connect2_1/);

	$node->connect_ok(
		'postgres://?service=my_srv',
		'connection with correct "service" URI and default pg_service.conf',
		sql => "SELECT 'connect2_2'",
		expected_stdout => qr/connect2_2/);

	$node->connect_fails(
		'service=undefined-service',
		'connection with incorrect "service" string and default pg_service.conf',
		expected_stderr =>
		  qr/definition of service "undefined-service" not found/);

	local $ENV{PGSERVICE} = 'my_srv';
	$node->connect_ok(
		'',
		'connection with correct PGSERVICE and default pg_service.conf',
		sql => "SELECT 'connect2_3'",
		expected_stdout => qr/connect2_3/);

	local $ENV{PGSERVICE} = 'undefined-service';
	$node->connect_fails(
		'',
		'connection with incorrect PGSERVICE and default pg_service.conf',
		expected_stdout =>
		  qr/definition of service "undefined-service" not found/);

	# Remove default pg_service.conf.
	unlink($srvfile_default);
}

# Backslashes escaped path string for getting collect result at concatenation
# for Windows environment
my $srvfile_win_cared = $srvfile_valid;
$srvfile_win_cared =~ s/\\/\\\\/g;

# Checks combinations of service name and valid "servicefile" string.
{
	$node->connect_ok(
		q{service=my_srv servicefile='} . $srvfile_win_cared . q{'},
		'connection with correct "service" string and correct "servicefile" string',
		sql             => "SELECT 'connect3_1'",
		expected_stdout => qr/connect3_1/);

	local $ENV{PGSERVICE} = 'my_srv';
	$node->connect_ok(
		q{servicefile='} . $srvfile_win_cared . q{'},
		'connection with correct PGSERVICE and collect "servicefile" string',
		sql             => "SELECT 'connect3_2'",
		expected_stdout => qr/connect3_2/);

	$node->connect_fails(
		q{service=undefined-service servicefile='} . $srvfile_win_cared . q{'},
		'connection with incorrect "service" string and collect "servicefile" string',
		expected_stderr =>
			qr/definition of service "undefined-service" not found/);

	local $ENV{PGSERVICE} = 'undefined-service';
	$node->connect_fails(
		q{servicefile='} . $srvfile_win_cared . q{'},
		'connection with incorrect PGSERVICE and collect "servicefile"',
		expected_stderr =>
			qr/definition of service "undefined-service" not found/);
}

# Checks combinations of service name and a valid "servicefile" string in URI format.
{
	# Encode slashes and backslash
	my $encoded_srvfile = $srvfile_valid =~ s{([\\/])}{
        $1 eq '/' ? '%2F' : '%5C'
    }ger;

	# Additionaly encode a colon in servicefile path of Windows
	$encoded_srvfile =~ s/:/%3A/g;

	$node->connect_ok(
		'postgresql:///?service=my_srv&servicefile=' . $encoded_srvfile,
		'connection with correct "service" string and correct "servicefile" in URI format',
		sql => "SELECT 'connect4_1'",
		expected_stdout => qr/connect4_1/);

	local $ENV{PGSERVICE} = 'my_srv';
	$node->connect_ok(
		'postgresql://?servicefile=' . $encoded_srvfile,
		'connection with correct PGSERVICE and collect "servicefile" in URI format',
		sql => "SELECT 'connect4_2'",
		expected_stdout => qr/connect4_2/);

	$node->connect_fails(
		'postgresql:///?service=undefined-service&servicefile=' . $encoded_srvfile,
		'connection with incorrect "service" string and collect "servicefile" in URI format',
		expected_stderr =>
		  qr/definition of service "undefined-service" not found/);
}

# Checks case of incorrect "servicefile" string.
{
	# Backslashes escaped path string for getting collect result at concatenation
	# for Windows environment
	my $srvfile_missing_win_cared = $srvfile_missing;
	$srvfile_missing_win_cared =~ s/\\/\\\\/g;

	$node->connect_fails(
		q{service=my_srv servicefile='} . $srvfile_missing_win_cared . q{'},
		'connection with correct "service" string and incorrect "servicefile" string',
		sql => "SELECT 'connect5_1'",
		expected_stderr =>
			qr/service file ".*pg_service_missing.conf" not found/);
}

# Check that "servicefile" string takes precedence over PGSERVICEFILE environment variable
{
	local $ENV{PGSERVICEFILE} = $srvfile_missing;

	$node->connect_fails(
		'service=my_srv',
		'connecttion with correct "service" string and incorrect PGSERVICEFILE',
		expected_stderr =>
		  qr/service file ".*pg_service_missing.conf" not found/);

	$node->connect_ok(
		q{service=my_srv servicefile='} . $srvfile_win_cared . q{'},
		'connectin with correct "service" string, incorrect PGSERVICEFILE and correct "servicefile" string',
		sql => "SELECT 'connect6_1'",
		expected_stdout => qr/connect6_1/);
}

$node->teardown_node;

done_testing();
