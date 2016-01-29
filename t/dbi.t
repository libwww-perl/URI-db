#!/usr/bin/perl -w

use strict;
use Test::More;
use Test::Exception;
use utf8;
use URI;

for my $spec (
    {
        uri => 'db:',
        dsn => '',
        dbi => [ [host => undef], ['port' => undef], [dbname => undef] ],
        qry => [],
    },
    {
        uri => 'db:pg:',
        dsn => 'dbi:Pg:',
        dbi => [ [host => undef], [port => undef], [dbname => undef] ],
        qry => [],
    },
    {
        uri => 'db:pg://localhost',
        dsn => 'dbi:Pg:host=localhost',
        dbi => [ [host => 'localhost'], [port => undef], [dbname => undef] ],
        qry => [],
    },
    {
        uri => 'db:pg://localhost',
        dsn => 'dbi:Pg:host=localhost',
        dbi => [ [host => 'localhost'], [port => undef], [dbname => undef] ],
        qry => [],
    },
    {
        uri => 'db:pg://me:secret@example.com/foodb',
        dsn => 'dbi:Pg:host=example.com;dbname=foodb',
        dbi => [ [host => 'example.com'], [port => undef], [dbname => 'foodb'] ],
        qry => [],
    },
    {
        uri => 'db:pg://foo:123/try?foo=1&foo=2&lol=yes',
        dsn => 'dbi:Pg:host=foo;port=123;dbname=try;foo=1;foo=2;lol=yes',
        dbi => [ [host => 'foo'], [port => 123], [dbname => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes' ],
    },
    {
        uri => 'db:postgresql://foo:123/try?foo=1&foo=2&lol=yes',
        dsn => 'dbi:Pg:host=foo;port=123;dbname=try;foo=1;foo=2;lol=yes',
        dbi => [ [host => 'foo'], [port => 123], [dbname => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes' ],
    },
    {
        uri => 'db:postgres://foo:123/try?foo=1&foo=2&lol=yes',
        dsn => 'dbi:Pg:host=foo;port=123;dbname=try;foo=1;foo=2;lol=yes',
        dbi => [ [host => 'foo'], [port => 123], [dbname => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes' ],
    },
    {
        uri => 'db:postgresxc://foo:123/try?foo=1&foo=2&lol=yes',
        dsn => 'dbi:Pg:host=foo;port=123;dbname=try;foo=1;foo=2;lol=yes',
        dbi => [ [host => 'foo'], [port => 123], [dbname => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes' ],
    },
    {
        uri => 'db:pgsql://foo:123/try?foo=1&foo=2&lol=yes',
        dsn => 'dbi:Pg:host=foo;port=123;dbname=try;foo=1;foo=2;lol=yes',
        dbi => [ [host => 'foo'], [port => 123], [dbname => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes' ],
    },
    {
        uri => 'db:pgxc://foo:123/try?foo=1&foo=2&lol=yes',
        dsn => 'dbi:Pg:host=foo;port=123;dbname=try;foo=1;foo=2;lol=yes',
        dbi => [ [host => 'foo'], [port => 123], [dbname => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes' ],
    },
    {
        uri => 'db:sqlite:',
        dsn => 'dbi:SQLite:',
        dbi => [ [dbname => undef] ],
        qry => [],
    },
    {
        uri => 'db:sqlite:foo.db',
        dsn => 'dbi:SQLite:dbname=foo.db',
        dbi => [ [dbname => 'foo.db'] ],
        qry => [],
    },
    {
        uri => 'db:sqlite:/path/foo.db',
        dsn => 'dbi:SQLite:dbname=/path/foo.db',
        dbi => [ [dbname => '/path/foo.db'] ],
        qry => [],
    },
    {
        uri => 'db:sqlite:///path/foo.db',
        dsn => 'dbi:SQLite:dbname=path/foo.db',
        dbi => [ [dbname => 'path/foo.db'] ],
        qry => [],
    },
    {
        uri => 'db:cubrid://localhost:33/foo',
        dsn => 'dbi:cubrid:host=localhost;port=33;database=foo',
        dbi => [ [host => 'localhost'], [port => 33], [database => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:db2://localhost:33/foo',
        dsn => 'dbi:DB2:HOSTNAME=localhost;PORT=33;DATABASE=foo',
        dbi => [ [HOSTNAME => 'localhost'], [PORT => 33], [DATABASE => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:firebird://localhost:33/foo',
        dsn => 'dbi:Firebird:host=localhost;port=33;dbname=foo',
        dbi => [ [host => 'localhost'], [port => 33], [dbname => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:informix:foo.db',
        dsn => 'dbi:Informix:foo.db',
        dbi => [],
        qry => [],
    },
    {
        uri => 'db:informix:foo.db?foo=1',
        dsn => 'dbi:Informix:foo.db;foo=1',
        dbi => [],
        qry => [foo => 1],
    },
    {
        uri => 'db:ingres:foo.db',
        dsn => 'dbi:Ingres:foo.db',
        dbi => [],
        qry => [],
    },
    {
        uri => 'db:ingres:foo.db?foo=1',
        dsn => 'dbi:Ingres:foo.db;foo=1',
        dbi => [],
        qry => [foo => 1],
    },
    {
        uri => 'db:interbase://localhost:33/foo',
        dsn => 'dbi:InterBase:host=localhost;port=33;dbname=foo',
        dbi => [ [host => 'localhost'], [port => 33], [dbname => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:ldapdb://localhost:33/foo',
        dsn => 'dbi:LDAP:foo',
        dbi => [ [ dbname => 'foo' ] ],
        qry => [],
    },
    {
        uri => 'db:ldapdb://localhost/foo',
        dsn => 'dbi:LDAP:foo',
        dbi => [ [ dbname => 'foo' ] ],
        qry => [],
    },
    {
        uri => 'db:ldapdb://./foo',
        dsn => 'dbi:LDAP:foo',
        dbi => [ [ dbname => 'foo' ] ],
        qry => [],
    },
    {
        uri => 'db:maxdb://localhost:33/foo',
        dsn => 'dbi:MaxDB:localhost:33/foo',
        dbi => [],
        qry => [],
    },
    {
        uri => 'db:maxdb://localhost/foo',
        dsn => 'dbi:MaxDB:localhost/foo',
        dbi => [],
        qry => [],
    },
    {
        uri => 'db:monetdb://localhost:1222?foo=1',
        dsn => 'dbi:monetdb:host=localhost;port=1222;foo=1',
        dbi => [ [host => 'localhost'], [port => 1222] ],
        qry => [foo => 1],
    },
    {
        uri => 'db:monetdb://localhost/lolz',
        dsn => 'dbi:monetdb:host=localhost',
        dbi => [ [host => 'localhost'], [port => undef] ],
        qry => [],
    },
    {
        uri => 'db:mysql://localhost:33/foo',
        dsn => 'dbi:mysql:host=localhost;port=33;database=foo',
        dbi => [ [host => 'localhost'], [port => 33], [database => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:mariadb://localhost:33/foo',
        dsn => 'dbi:mysql:host=localhost;port=33;database=foo',
        dbi => [ [host => 'localhost'], [port => 33], [database => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:oracle://localhost:33/foo',
        dsn => 'dbi:Oracle:host=localhost;port=33;sid=foo',
        dbi => [ [host => 'localhost'], [port => 33], [sid => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:oracle:foo',
        dsn => 'dbi:Oracle:foo',
        dbi => [ [host => undef], [port => undef], [sid => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:mssql:',
        dsn => 'dbi:ODBC:',
        dbi => [ [DSN => undef] ],
        qry => [],
    },
    {
        uri => 'db:mssql:dbadmin',
        dsn => 'dbi:ODBC:DSN=dbadmin',
        dbi => [ [DSN => 'dbadmin'] ],
        qry => [],
    },
    {
        uri => 'db:mssql://localhost',
        dsn => 'dbi:ODBC:Server=localhost;Port=1433',
        dbi => [ [Server => 'localhost'], [Port => 1433], [Database => undef] ],
        qry => [],
    },
    {
        uri => 'db:mssql://localhost:33',
        dsn => 'dbi:ODBC:Server=localhost;Port=33',
        dbi => [ [Server => 'localhost'], [Port => 33], [Database => undef] ],
        qry => [],
    },
    {
        uri => 'db:mssql://foo:123/try?foo=1&foo=2&lol=yes&Driver=HPMssql',
        dsn => 'dbi:ODBC:Server=foo;Port=123;Database=try;foo=1;foo=2;lol=yes;Driver=HPMssql',
        dbi => [ [Server => 'foo'], [Port => 123], [Database => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes', Driver => 'HPMssql' ],
    },
    {
        uri => 'db:mssql://localhost:33/foo',
        dsn => 'dbi:ODBC:Server=localhost;Port=33;Database=foo',
        dbi => [ [Server => 'localhost'], [Port => 33], [Database => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:mssql:',
        dsn => 'dbi:ODBC:',
        dbi => [ [DSN => undef] ],
        qry => [],
        alt => 'ODBC',
    },
    {
        uri => 'db:mssql:dbadmin',
        dsn => 'dbi:ODBC:DSN=dbadmin',
        dbi => [ [DSN => 'dbadmin'] ],
        qry => [],
        alt => 'ODBC',
    },
    {
        uri => 'db:mssql://localhost',
        dsn => 'dbi:ODBC:Server=localhost;Port=1433',
        dbi => [ [Server => 'localhost'], [Port => 1433], [Database => undef] ],
        qry => [],
        alt => 'ODBC',
    },
    {
        uri => 'db:mssql://localhost:33',
        dsn => 'dbi:ODBC:Server=localhost;Port=33',
        dbi => [ [Server => 'localhost'], [Port => 33], [Database => undef] ],
        qry => [],
        alt => 'ODBC',
    },
    {
        uri => 'db:mssql://foo:123/try?foo=1&foo=2&lol=yes&Driver=HPMssql',
        dsn => 'dbi:ODBC:Server=foo;Port=123;Database=try;foo=1;foo=2;lol=yes;Driver=HPMssql',
        dbi => [ [Server => 'foo'], [Port => 123], [Database => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes', Driver => 'HPMssql' ],
        alt => 'ODBC',
    },
    {
        uri => 'db:mssql://localhost:33/foo',
        dsn => 'dbi:ODBC:Server=localhost;Port=33;Database=foo',
        dbi => [ [Server => 'localhost'], [Port => 33], [Database => 'foo'] ],
        qry => [],
        alt => 'ODBC',
    },
    {
        uri => 'db:mssql:',
        dsn => 'dbi:Sybase:',
        dbi => [],
        qry => [],
        alt => "Sybase",
    },
    {
        uri => 'db:mssql://localhost',
        dsn => 'dbi:Sybase:host=localhost',
        dbi => [ [host => 'localhost'], [dbname => undef] ],
        qry => [],
        alt => "Sybase",
    },
    {
        uri => 'db:mssql://localhost:33',
        dsn => 'dbi:Sybase:host=localhost;port=33',
        dbi => [ [host => 'localhost'], [port => 33], [dbname => undef] ],
        qry => [],
        alt => "Sybase",
    },
    {
        uri => 'db:mssql://foo:123/try?foo=1&foo=2&lol=yes&Driver=HPMssql',
        dsn => 'dbi:Sybase:host=foo;port=123;dbname=try;foo=1;foo=2;lol=yes;Driver=HPMssql',
        dbi => [ [host => 'foo'], [port => 123], [dbname => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes', Driver => 'HPMssql' ],
        alt => "Sybase",
    },
    {
        uri => 'db:mssql://localhost:33/foo',
        dsn => 'dbi:Sybase:host=localhost;port=33;dbname=foo',
        dbi => [ [host => 'localhost'], [port => 33], [dbname => 'foo'] ],
        qry => [],
        alt => "Sybase",
    },
    {
        uri => 'db:mssql:',
        dsn => 'dbi:ADO:',
        dbi => [ [DSN => undef] ],
        qry => [],
        alt => "ADO",
    },
    {
        uri => 'db:mssql:dbadmin',
        dsn => 'dbi:ADO:DSN=dbadmin',
        dbi => [ [DSN => 'dbadmin'] ],
        qry => [],
        alt => "ADO",
    },
    {
        uri => 'db:mssql://localhost',
        dsn => 'dbi:ADO:Server=localhost;Port=1433',
        dbi => [ [Server => 'localhost'], [Port => 1433], [Database => undef] ],
        qry => [],
        alt => "ADO",
    },
    {
        uri => 'db:mssql://localhost:33',
        dsn => 'dbi:ADO:Server=localhost;Port=33',
        dbi => [ [Server => 'localhost'], [Port => 33], [Database => undef] ],
        qry => [],
        alt => "ADO",
    },
    {
        uri => 'db:mssql://foo:123/try?foo=1&foo=2&lol=yes&Driver=HPMssql',
        dsn => 'dbi:ADO:Server=foo;Port=123;Database=try;foo=1;foo=2;lol=yes;Driver=HPMssql',
        dbi => [ [Server => 'foo'], [Port => 123], [Database => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes', Driver => 'HPMssql' ],
        alt => "ADO",
    },
    {
        uri => 'db:mssql://localhost:33/foo',
        dsn => 'dbi:ADO:Server=localhost;Port=33;Database=foo',
        dbi => [ [Server => 'localhost'], [Port => 33], [Database => 'foo'] ],
        qry => [],
        alt => "ADO",
    },
    {
        uri => 'db:mssql:',
        dbi => [ [DSN => undef] ],
        qry => [],
        alt => sub { return ("Derp", qr/Unknown driver: Derp\n/) },
    },
    {
        uri => 'db:mssql:dbadmin',
        dbi => [ [DSN => 'dbadmin'] ],
        qry => [],
        alt => sub { return ("Derp", qr/Unknown driver: Derp\n/) },
    },
    {
        uri => 'db:mssql://localhost',
        dbi => [ [Server => 'localhost'], [Port => 1433], [Database => undef] ],
        qry => [],
        alt => sub { return ("Derp", qr/Unknown driver: Derp\n/) },
    },
    {
        uri => 'db:mssql://localhost:33',
        dbi => [ [Server => 'localhost'], [Port => 33], [Database => undef] ],
        qry => [],
        alt => sub { return ("Derp", qr/Unknown driver: Derp\n/) },
    },
    {
        uri => 'db:mssql://foo:123/try?foo=1&foo=2&lol=yes&Driver=HPMssql',
        dbi => [ [Server => 'foo'], [Port => 123], [Database => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes', Driver => 'HPMssql' ],
        alt => sub { return ("Derp", qr/Unknown driver: Derp\n/) },
    },
    {
        uri => 'db:mssql://localhost:33/foo',
        dbi => [ [Server => 'localhost'], [Port => 33], [Database => 'foo'] ],
        qry => [],
        alt => sub { return ("Derp", qr/Unknown driver: Derp\n/) },
    },
    {
        uri => 'db:sqlserver://localhost:33/foo',
        dsn => 'dbi:ODBC:Server=localhost;Port=33;Database=foo',
        dbi => [ [Server => 'localhost'], [Port => 33], [Database => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:sybase://localhost:33/foo',
        dsn => 'dbi:Sybase:host=localhost;port=33;dbname=foo',
        dbi => [ [host => 'localhost'], [port => 33], [dbname => 'foo'] ],
        qry => [],
    },
    {
        uri => 'db:teradata://localhost',
        dsn => 'dbi:Teradata:localhost',
        dbi => [ [DATABASE => undef] ],
        qry => [],
    },
    {
        uri => 'db:teradata://localhost:33/foo?hi=1',
        dsn => 'dbi:Teradata:localhost:33;DATABASE=foo;hi=1',
        dbi => [ [DATABASE => 'foo'] ],
        qry => [ hi => 1],
    },
    {
        uri => 'db:unify:foo.db',
        dsn => 'dbi:Unify:foo.db',
        dbi => [],
        qry => [],
    },
    {
        uri => 'db:unify:',
        dsn => 'dbi:Unify:',
        dbi => [],
        qry => [],
    },
    {
        uri => 'db:unify:?foo=1&bar=2',
        dsn => 'dbi:Unify:foo=1;bar=2',
        dbi => [],
        qry => [ foo => 1, bar => 2 ],
    },
    {
        uri => 'db:vertica:',
        dsn => 'dbi:ODBC:',
        dbi => [ [DSN => undef] ],
        qry => [],
    },
    {
        uri => 'db:vertica:dbadmin',
        dsn => 'dbi:ODBC:DSN=dbadmin',
        dbi => [ [DSN => 'dbadmin'] ],
        qry => [],
    },
    {
        uri => 'db:vertica://localhost',
        dsn => 'dbi:ODBC:Server=localhost;Port=5433',
        dbi => [ [Server => 'localhost'], [Port => 5433], [Database => undef] ],
        qry => [],
    },
    {
        uri => 'db:vertica://localhost:33',
        dsn => 'dbi:ODBC:Server=localhost;Port=33',
        dbi => [ [Server => 'localhost'], [Port => 33], [Database => undef] ],
        qry => [],
    },
    {
        uri => 'db:vertica://foo:123/try?foo=1&foo=2&lol=yes&Driver=HPVertica',
        dsn => 'dbi:ODBC:Server=foo;Port=123;Database=try;foo=1;foo=2;lol=yes;Driver=HPVertica',
        dbi => [ [Server => 'foo'], [Port => 123], [Database => 'try'] ],
        qry => [ foo => 1, foo => 2, lol => 'yes', Driver => 'HPVertica' ],
    },
) {
    my $uri = $spec->{uri};
    my $end = exists $spec->{alt} ? (ref($spec->{alt}) ? " - " . ($spec->{alt}->())[0] : " - $spec->{alt}") : "";
    ok my $u = URI->new($uri), "URI $uri$end";

    my $failure_expected = 0;
    if ($spec->{alt}) {
        if (ref($spec->{alt}) eq 'CODE') {
            my ($alt, $err) = $spec->{alt}->();
            throws_ok { $u->dbi_dsn($alt) } $err, "... $uri ALT DSN $alt fails as expected";
            $failure_expected = 1;
        }
        else {
            is $u->dbi_dsn($spec->{alt}), $spec->{dsn}, "... $uri ALT DSN $spec->{alt} ok";
        }
    }
    else {
        is $u->dbi_dsn, $spec->{dsn}, "... $uri DSN$end";
    }

    if (!$failure_expected) {
        is_deeply [ $u->query_params ], $spec->{qry}, "... $uri query params$end";
        is_deeply [ $u->_dbi_param_map ], $spec->{dbi}, "... $uri DBI param map$end";
        is_deeply [ $u->dbi_params ], [
            (
                map { @{ $_ } }
                grep { defined $_->[1] && length $_->[1] } @{ $spec->{dbi} }
            ),
            @{ $spec->{qry} },
        ], "... $uri DBI params$end";
    }
}

done_testing;
