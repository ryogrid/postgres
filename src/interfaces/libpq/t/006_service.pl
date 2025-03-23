# Copyright (c) 2025, PostgreSQL Global Development Group
use strict;
use warnings FATAL => 'all';
use Config;
use PostgreSQL::Test::Utils;
use PostgreSQL::Test::Cluster;
use Test::More;

# This tests "service" and "servicefile" connection options.

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

# Backslashes escaped path string for getting collect result at concatenation
# for Windows environment
my $srvfile_win_cared = $srvfile;
$srvfile_win_cared =~ s/\\/\\\\/g;

# Check that servicefile option works as expected
{
    $node->connect_ok(
        q{service=my_srv servicefile='} . $srvfile_win_cared . q{'},
        'service=my_srv servicefile=...',
        sql             => "SELECT 'connect4'",
        expected_stdout => qr/connect4/
    );

    # Encode slashes and backslash
    my $encoded_srvfile = $srvfile =~ s{([\\/])}{
        $1 eq '/' ? '%2F' : '%5C'
    }ger;

    # Additionaly encode a colon in servicefile path of Windows
    $encoded_srvfile =~ s/:/%3A/g;

    $node->connect_ok(
        'postgresql:///?service=my_srv&servicefile=' . $encoded_srvfile,
        'postgresql:///?service=my_srv&servicefile=...',
        sql             => "SELECT 'connect5'",
        expected_stdout => qr/connect5/
    );

    local $ENV{PGSERVICE} = 'my_srv';
    $node->connect_ok(
        q{servicefile='} . $srvfile_win_cared . q{'},
        'envvar: PGSERVICE=my_srv + servicefile=...',
        sql             => "SELECT 'connect6'",
        expected_stdout => qr/connect6/
    );

    $node->connect_ok(
        'postgresql://?servicefile=' . $encoded_srvfile,
        'envvar: PGSERVICE=my_srv + postgresql://?servicefile=...',
        sql             => "SELECT 'connect7'",
        expected_stdout => qr/connect7/
    );
}

# Check that servicefile option takes precedence over PGSERVICEFILE environment variable
{
    local $ENV{PGSERVICEFILE} = 'non-existent-file.conf';

    $node->connect_fails(
        'service=my_srv',
        'service=... fails with wrong PGSERVICEFILE',
        expected_stderr => qr/service file "non-existent-file\.conf" not found/
    );

    $node->connect_ok(
        q{service=my_srv servicefile='} . $srvfile_win_cared . q{'},
        'servicefile= takes precedence over PGSERVICEFILE',
        sql             => "SELECT 'connect8'",
        expected_stdout => qr/connect8/
    );
}

done_testing();