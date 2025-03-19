# Copyright (c) 2023-2024, PostgreSQL Global Development Group
use strict;
use warnings FATAL => 'all';
use Config;
use PostgreSQL::Test::Utils;
use PostgreSQL::Test::Cluster;
use Test::More;

# This tests "servicefile option" on connection string

# Cluster setup which is shared for testing both load balancing methods
my $node = PostgreSQL::Test::Cluster->new('node');

# Create a data directory with initdb
$node->init();

# Start the PostgreSQL server
$node->start();

my $td = PostgreSQL::Test::Utils::tempdir;
my $srvfile = "$td/pgsrv.conf";

# Open file in binary mode and write CRLF or LF depending on the OS
# Binary mode is for avoiding platform depending behavior related line ending at text mode 
open my $fh, '>:raw', $srvfile or die $!;
if ($PostgreSQL::Test::Utils::windows_os) {
    # Windows: use CRLF
    print $fh "[my_srv]", "\x0d\x0a";
    print $fh join("\x0d\x0a", split(' ', $node->connstr)), "\x0d\x0a";
} else {
    # Non-Windows: use LF
    print $fh "[my_srv]", "\x0a";
    print $fh join("\x0a", split(' ', $node->connstr)), "\x0a";
}
close $fh;

# Check that servicefile option works as expected
{
    $node->connect_ok(
        q{service=my_srv servicefile='}.$srvfile.q{'},
        'service=my_srv servicefile=...',
        sql => "SELECT 'connect1'",
        expected_stdout => qr/connect1/);

    $node->connect_ok(
        'postgresql:///?service=my_srv&servicefile='.($srvfile =~ s!/!%2F!gr),
        'postgresql:///?service=my_srv&servicefile=...',
        sql => "SELECT 'connect2'",
        expected_stdout => qr/connect2/);

    local $ENV{PGSERVICE} = 'my_srv';
    $node->connect_ok(
        q{servicefile='}.$srvfile.q{'},
        'envvar: PGSERVICE=my_srv + servicefile=...',
        sql => "SELECT 'connect3'",
        expected_stdout => qr/connect3/);

    $node->connect_ok(
        'postgresql://?servicefile='.($srvfile =~ s!/!%2F!gr),
        'envvar: PGSERVICE=my_srv + postgresql://?servicefile=...',
        sql => "SELECT 'connect4'",
        expected_stdout => qr/connect4/);
}

# Check that servicefile option takes precedence over PGSERVICEFILE
{    
    local $ENV{PGSERVICEFILE} = 'non-existent-file.conf';

    $node->connect_fails(
        'service=my_srv',
        'service=... fails with wrong PGSERVICEFILE',
        expected_stderr => qr/service file "non-existent-file\.conf" not found/);

    $node->connect_ok(
        q{service=my_srv servicefile='}.$srvfile.q{'},
        'servicefile= takes precedence over PGSERVICEFILE',
        sql => "SELECT 'connect5'",
        expected_stdout => qr/connect5/);
}

done_testing();