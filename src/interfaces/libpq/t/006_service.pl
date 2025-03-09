# Copyright (c) 2023-2024, PostgreSQL Global Development Group
use strict;
use warnings FATAL => 'all';
use Config;
use PostgreSQL::Test::Utils;
use PostgreSQL::Test::Cluster;
use Test::More;

# This tests "service" and "servicefile"

# Cluster setup which is shared for testing both load balancing methods
my $node = PostgreSQL::Test::Cluster->new('node');

# Create a data directory with initdb
$node->init();

# Start the PostgreSQL server
$node->start();

my $td = PostgreSQL::Test::Utils::tempdir;
my $srvfile = "$td/pgsrv.conf";

open my $fh, '>', $srvfile or die $!;
print $fh "[my_srv]\n";
print $fh +($node->connstr =~ s/ /\n/gr), "\n";
close $fh;

{
	local $ENV{PGSERVICEFILE} = $srvfile;
	$node->connect_ok(
		'service=my_srv',
		'service=my_srv',
		sql => "SELECT 'connect1'",
		expected_stdout => qr/connect1/);

	$node->connect_ok(
		'postgres://?service=my_srv',
		'postgres://?service=my_srv',
		sql => "SELECT 'connect2'",
		expected_stdout => qr/connect2/);

	local $ENV{PGSERVICE} = 'my_srv';
	$node->connect_ok(
		'',
		'envvar: PGSERVICE=my_srv',
		sql => "SELECT 'connect3'",
		expected_stdout => qr/connect3/);

	$node->connect_fails(
		'service=non-existent-service',
		'service=non-existent-service',
		expected_stderr => qr/definition of service "non-existent-service" not found/);
}

{
	$node->connect_ok(
		q{service=my_srv servicefile='}.$srvfile.q{'},
		'service=my_srv servicefile=...',
		sql => "SELECT 'connect4'",
		expected_stdout => qr/connect4/);

	$node->connect_ok(
		'postgresql:///?service=my_srv&servicefile='.($srvfile =~ s!/!%2F!gr),
		'postgresql:///?service=my_srv&servicefile=...',
		sql => "SELECT 'connect5'",
		expected_stdout => qr/connect5/);

	local $ENV{PGSERVICE} = 'my_srv';
	$node->connect_ok(
		q{servicefile='}.$srvfile.q{'},
		'envvar: PGSERVICE=my_srv + servicefile=...',
		sql => "SELECT 'connect6'",
		expected_stdout => qr/connect6/);

	$node->connect_ok(
		'postgresql://?servicefile='.($srvfile =~ s!/!%2F!gr),
		'envvar: PGSERVICE=my_srv + postgresql://?servicefile=...',
		sql => "SELECT 'connect6'",
		expected_stdout => qr/connect6/);
}

{
	local $ENV{PGSERVICEFILE} = 'non-existent-file.conf';

	$node->connect_fails(
		'service=my_srv',
		'service=... fails with wrong PGSERVICEFILE',
		expected_stderr => qr/service file "non-existent-file\.conf" not found/);

	$node->connect_ok(
		q{service=my_srv servicefile='}.$srvfile.q{'},
		'servicefile= takes precedence over PGSERVICEFILE',
		sql => "SELECT 'connect7'",
		expected_stdout => qr/connect7/);
}

done_testing();
