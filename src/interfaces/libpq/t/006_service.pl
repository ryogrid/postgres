# Copyright (c) 2025, PostgreSQL Global Development Group
use strict;
use warnings FATAL => 'all';
use Config;
use PostgreSQL::Test::Utils;
use PostgreSQL::Test::Cluster;
use Test::More;

# This tests "service" connection options.

# Cluster setup which is shared for testing both load balancing methods
my $node = PostgreSQL::Test::Cluster->new('node');

# Create a data directory with initdb
$node->init();

# Start the PostgreSQL server
$node->start();

my $td      = PostgreSQL::Test::Utils::tempdir;
my $srvfile = "$td/pgsrv.conf";

# Windows: use CRLF
# Non-Windows: use LF
my $newline = $windows_os ? "\r\n" : "\n";

# Create a service file
open my $fh, '>', $srvfile or die $!;
print $fh "[my_srv]",                                     $newline;
print $fh join( $newline, split( ' ', $node->connstr ) ), $newline;

close $fh;

# Check that service option works as expected
{
    local $ENV{PGSERVICEFILE} = $srvfile;
    $node->connect_ok(
        'service=my_srv',
        'service=my_srv',
        sql             => "SELECT 'connect1'",
        expected_stdout => qr/connect1/
    );

    $node->connect_ok(
        'postgres://?service=my_srv',
        'postgres://?service=my_srv',
        sql             => "SELECT 'connect2'",
        expected_stdout => qr/connect2/
    );

    local $ENV{PGSERVICE} = 'my_srv';
    $node->connect_ok(
        '',
        'envvar: PGSERVICE=my_srv',
        sql             => "SELECT 'connect3'",
        expected_stdout => qr/connect3/
    );
}

# Check that not existing service fails
{
    local $ENV{PGSERVICEFILE} = $srvfile;
    local $ENV{PGSERVICE} = 'non-existent-service';
    $node->connect_fails(
        '',
        'envvar: PGSERVICE=non-existent-service',
        expected_stdout =>
          qr/definition of service "non-existent-service" not found/
    );

    $node->connect_fails(
        'service=non-existent-service',
        'service=non-existent-service',
        expected_stderr =>
          qr/definition of service "non-existent-service" not found/
    );
}

done_testing();