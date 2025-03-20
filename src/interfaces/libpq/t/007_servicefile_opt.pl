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

my $td      = PostgreSQL::Test::Utils::tempdir;
my $srvfile = "$td/pgsrv.conf";

# Create a service file
open my $fh, '>', $srvfile or die $!;
if ($windows_os) {

    # Windows: use CRLF
    print $fh "[my_srv]",                                   "\r\n";
    print $fh join( "\r\n", split( ' ', $node->connstr ) ), "\r\n";

    # Escape backslashes for use in connection string later
    $srvfile =~ s/\\/\\\\/g;
}
else {
    # Non-Windows: use LF
    print $fh "[my_srv]",                                 "\n";
    print $fh join( "\n", split( ' ', $node->connstr ) ), "\n";
}
close $fh;

# Check that servicefile option works as expected
{
    $node->connect_ok(
        q{service=my_srv servicefile='} . $srvfile . q{'},
        'service=my_srv servicefile=...',
        sql             => "SELECT 'connect1'",
        expected_stdout => qr/connect1/
    );

    # Escape slashes in servicefile path for use in connection string
    # Consider that the servicefile path may contain backslashes on Windows
    my $encoded_srvfile = $srvfile =~ s{([\\/])}{
        $1 eq '/' ? '%2F' : '%5C'
    }ger;

    # Escape a colon in servicefile path of Windows
    $encoded_srvfile =~ s/:/%3A/g;

    $node->connect_ok(
        'postgresql:///?service=my_srv&servicefile=' . $encoded_srvfile,
        'postgresql:///?service=my_srv&servicefile=...',
        sql             => "SELECT 'connect2'",
        expected_stdout => qr/connect2/
    );

    local $ENV{PGSERVICE} = 'my_srv';
    $node->connect_ok(
        q{servicefile='} . $srvfile . q{'},
        'envvar: PGSERVICE=my_srv + servicefile=...',
        sql             => "SELECT 'connect3'",
        expected_stdout => qr/connect3/
    );

    $node->connect_ok(
        'postgresql://?servicefile=' . $encoded_srvfile,
        'envvar: PGSERVICE=my_srv + postgresql://?servicefile=...',
        sql             => "SELECT 'connect4'",
        expected_stdout => qr/connect4/
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
        q{service=my_srv servicefile='} . $srvfile . q{'},
        'servicefile= takes precedence over PGSERVICEFILE',
        sql             => "SELECT 'connect5'",
        expected_stdout => qr/connect5/
    );
}

done_testing();
