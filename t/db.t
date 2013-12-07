#!/usr/bin/perl -w

use strict;
use Test::More;
use utf8;
use URI;
use URI::QueryParam;

isa_ok my $uri = URI->new('db:'), 'URI::db', 'Opaque DB URI';
is $uri->engine, undef, 'DB URI with no engine should have undef engine';
is $uri->scheme, 'db', 'DB URI with no engine should have scheme "db"';
ok !$uri->has_recognized_engine, 'Engineless should not have recognized engine';

# Try changing the engine.
is $uri->engine('foo'), undef, 'Assign engine';
is $uri->engine, 'foo', 'Engine should now be "foo"';
is $uri->as_string, 'db:foo:', 'Engine should be included in stringified URI';
isa_ok $uri, 'URI::db', 'Updated engine URI';

# Try changing to a known engine.
is $uri->engine('pg'), 'foo', 'Assign engine';
is $uri->engine, 'pg', 'Engine should now be "pg"';
is $uri->as_string, 'db:pg:', 'Engine should be included in stringified URI';
isa_ok $uri, 'URI::db::pg', 'Pg engine URI';

# Try setting to an undefined engine.
is $uri->engine(undef), 'pg', 'Assign undef engine';
is $uri->engine, undef, 'DB URI with undef engine should have undef engine';
is $uri->scheme, 'db', 'DB URI with undef engine should have scheme "db"';
isa_ok $uri, 'URI::db', 'Undef engine URI';

# Test dbname with opaque URI.
isa_ok $uri = URI->new('db:'), 'URI::db', 'Another opaque DB URI';
is $uri->dbname, undef, 'DB name should be undef';
is $uri->dbname('foo'), "", 'Assign a database name';
is $uri->dbname, 'foo', 'DB name should be "foo"';
is $uri->path, 'foo', 'Path should be "foo"';

# Pass a path.
is $uri->dbname('/tmp/foo'), 'foo', 'Assign a database name path';
is $uri->dbname, '/tmp/foo', 'DB name should be "/tmp/foo"';
is $uri->path, '/tmp/foo', 'Path should be "/tmp/foo"';

# Try a Windows path.
WARN: {
    my $msg;
    local $SIG{__WARN__} = sub { $msg = shift };
    $uri->dbname('C:/temp/foo');
    like $msg, qr{'[.]/' prepended}, 'Should warn about prepending ./ to path';
}
pass 'Assign a database Windows path';
is $uri->dbname, './C:/temp/foo', 'DB name should be "./C:/temp/foo"';
is $uri->path, './C:/temp/foo', 'Path should be "./C:/temp/foo"';

# Create a full URI with authority section.
isa_ok $uri = URI->new('db://localhost'), 'URI::db', 'Full DB URI';
$uri->dbname('foo');
pass 'Assign a database name';
is $uri->dbname, 'foo', 'DB name should be "foo"';
is $uri->path, '/foo', 'Path should be "/foo"';

# Pass a path.
$uri->dbname('/tmp/foo');
pass 'Assign a database name path';
is $uri->dbname, '/tmp/foo', 'DB name should be "/tmp/foo"';
is $uri->path, '//tmp/foo', 'Path should be "//tmp/foo"';

# Try a Windows path.
$uri->dbname('C:/temp/foo');
pass 'Assign a database Windows path';
is $uri->dbname, 'C:/temp/foo', 'DB name should be "C:/temp/foo"';
is $uri->path, '/C:/temp/foo', 'Path should be "/C:/temp/foo"';

for my $spec (
    [ db         => undef ],
    [ unknown    => undef ],
    [ postgresql => 5432  ],
    [ postgres   => 5432  ],
    [ pgsql      => 5432  ],
    [ pg         => 5432  ],
    [ mysql      => 3306  ],
    [ mariadb    => 3306  ],
    [ maria      => 3306  ],
    [ sqlite     => undef ],
    [ sqlite3    => undef ],
    [ oracle     => 1521  ],
    [ cubrid     => 1523  ], # ?
    [ firebird   => 3050  ],
    [ sqlserver  => 1433  ],
    [ mssql      => 1433  ],
    [ db2        => 50000 ], # ?
    [ ingres     => 1524  ],
    [ sybase     => 2638  ],
    [ informix   => 1526  ], # ?
    [ teradata   => 1025  ],
    [ interbase  => 3050  ],
    [ unify      => 27117 ], # ?
    [ mongodb    => 27017 ],
    [ mongo      => 27017 ],
    [ monetdb    => 50000 ], # ?
    [ monet      => 50000 ], # ?
    [ maxdb      => 7673  ], # ?
    [ max        => 7673  ], # ?
    [ impala     => 21000 ],
    [ couchdb    => 5984  ],
    [ couch      => 5984  ],
    [ hive       => 10000 ],
    [ cassandra  => 9160  ],
    [ derby      => 1527  ],
    [ vertica    => 5433  ],
) {
    my ($engine, $port) = @{ $spec };
    my $prefix = "db:$engine";
    my $class  = "URI::db::$engine";
    my $label  = $engine;
    if ($engine eq 'db' || $engine eq 'unknown') {
        $prefix = 'db';
        $class  = 'URI::db';
        $engine = undef;
        $label  = '';
    }

    isa_ok my $uri = URI->new("$prefix:"), $class;
    isa_ok $uri, 'URI::db' unless $prefix eq 'db';
    is $uri->scheme, 'db', 'Scheme should be "db"';
    is $uri->engine, $engine, qq{Simple URI engine should be "$label"};
    is $uri->dbname, undef, 'Simple URI db name should be undef';
    is $uri->host, undef, 'Simple URI host should be undef';
    is $uri->port, $port, 'Simple URI port should be undef';
    is $uri->user, undef, 'Simple URI user should be undef';
    is $uri->password, undef, 'Simple URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Simple URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [], 'Simple URI query params should be empty';
    is $uri->as_string, "$prefix:", 'Simple URI string should be correct';
    is "$uri", "$prefix:", 'Simple URI should correctly strigify';

    if ($engine) {
        ok $uri->has_recognized_engine, "$engine should be recognized engine";
    } else {
        ok !$uri->has_recognized_engine, "$prefix should not be recognized engine";
    }

    isa_ok $uri = URI->new("$prefix:foo.db"), $class;
    isa_ok $uri, 'URI::db' unless $prefix eq 'db';
    is $uri->scheme, 'db', 'Scheme should be "db"';
    is $uri->engine, $engine, qq{Path URI engine should be "$label"};
    is $uri->dbname, 'foo.db', 'Path URI db name should be "foo.db"';
    is $uri->host, undef, 'Path URI host should be undef';
    is $uri->port, $port, 'Path URI port should be undef';
    is $uri->user, undef, 'Path URI user should be undef';
    is $uri->password, undef, 'Path URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Path URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [], 'Path URI query params should be empty';
    is $uri->as_string, "$prefix:foo.db", 'Path URI string should be correct';
    is "$uri", "$prefix:foo.db", 'Simple URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix:/path/to/foo.db"), $class;
    isa_ok $uri, 'URI::db' unless $prefix eq 'db';
    is $uri->scheme, 'db', 'Scheme should be "db"';
    is $uri->engine, $engine, qq{Absolute Path URI engine should be "$label"};
    is $uri->dbname, '/path/to/foo.db',
        'Absolute Path URI db name should be "/path/to/foo.db"';
    is $uri->host, undef, 'Absolute Path URI host should be undef';
    is $uri->port, $port, 'Absolute Path URI port should be undef';
    is $uri->user, undef, 'Absolute Path URI user should be undef';
    is $uri->password, undef, 'Absolute Path URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Absolute Path URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Absolute Path URI query params should be empty';
    is $uri->as_string, "$prefix:/path/to/foo.db",
        'Absolute Path URI string should be correct';
    is "$uri", "$prefix:/path/to/foo.db",
        'Simple URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix:///path/to/foo.db"), $class;
    isa_ok $uri, 'URI::db' unless $prefix eq 'db';
    is $uri->scheme, 'db', 'Scheme should be "db"';
    is $uri->engine, $engine, qq{No host, full path URI engine should be "$label"};
    is $uri->dbname, '/path/to/foo.db',
        'No host, full path URI db name should be "/path/to/foo.db"';
    is $uri->host, '', 'No host, full path URI host should be empty';
    is $uri->port, $port, 'No host, full path URI port should be undef';
    is $uri->user, undef, 'No host, full path URI user should be undef';
    is $uri->password, undef, 'No host, full path URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'No host, full path URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'No host, full path URI query params should be empty';
    is $uri->as_string, "$prefix:///path/to/foo.db",
        'No host, full path URI string should be correct';
    is "$uri", "$prefix:///path/to/foo.db",
        'Simple URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://"), $class;
    is $uri->engine, $engine, qq{Hostless URI engine should be "label"};
    is $uri->dbname, undef, 'Hostless URI db name should be undef';
    is $uri->host, '', 'Hostless URI host should be ""';
    is $uri->port, $port, 'Hostless URI port should be undef';
    is $uri->user, undef, 'Hostless URI user should be undef';
    is $uri->password, undef, 'Hostless URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Hostless URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Hostless URI query params should be empty';
    is $uri->as_string, "$prefix://", 'Hostless URI string should be correct';
    is "$uri", "$prefix://", 'Hostless URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://localhost//foo.db"), $class;
    is $uri->engine, $engine, qq{Host+FullPath URI engine should be "label"};
    is $uri->dbname, '/foo.db', 'Host+FullPath URI db name should be "/foo.db"';
    is $uri->host, 'localhost', 'Host+FullPath URI host should be "localhost"';
    is $uri->port, $port, 'Host+FullPath URI port should be undef';
    is $uri->user, undef, 'Host+FullPath URI user should be undef';
    is $uri->password, undef, 'Host+FullPath URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Host+FullPath URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Host+FullPath URI query params should be empty';
    is $uri->as_string, "$prefix://localhost//foo.db",
        'Host+FullPath URI string should be correct';
    is "$uri", "$prefix://localhost//foo.db",
        'Host+FullPath URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://localhost/%2Ftmp/test.gdb"), $class;
    is $uri->engine, $engine, qq{Host+PcntPath URI engine should be "label"};
    is $uri->dbname, '/tmp/test.gdb', 'Host+PcntPath URI db name should be "/tmp/test.gdb"';
    is $uri->host, 'localhost', 'Host+PcntPath URI host should be "localhost"';
    is $uri->port, $port, 'Host+PcntPath URI port should be undef';
    is $uri->user, undef, 'Host+PcntPath URI user should be undef';
    is $uri->password, undef, 'Host+PcntPath URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Host+PcntPath URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Host+PcntPath URI query params should be empty';
    is $uri->as_string, "$prefix://localhost/%2Ftmp/test.gdb",
        'Host+PcntPath URI string should be correct';
    is "$uri", "$prefix://localhost/%2Ftmp/test.gdb",
        'Host+PcntPath URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://localhost/C:/tmp/foo.db"), $class;
    is $uri->engine, $engine, qq{Host+WinPath URI engine should be "label"};
    is $uri->dbname, 'C:/tmp/foo.db', 'Host+WinPath URI db name should be "C:/tmp/foo.db"';
    is $uri->host, 'localhost', 'Host+WinPath URI host should be "localhost"';
    is $uri->port, $port, 'Host+WinPath URI port should be undef';
    is $uri->user, undef, 'Host+WinPath URI user should be undef';
    is $uri->password, undef, 'Host+WinPath URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Host+WinPath URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Host+WinPath URI query params should be empty';
    is $uri->as_string, "$prefix://localhost/C:/tmp/foo.db",
        'Host+WinPath URI string should be correct';
    is "$uri", "$prefix://localhost/C:/tmp/foo.db",
        'Host+WinPath URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix:////foo.db"), $class;
    is $uri->engine, $engine, qq{Hostless+FullPath URI engine should be "label"};
    is $uri->dbname, '/foo.db', 'Hostless+FullPath URI db name should be "/foo.db"';
    is $uri->host, '', 'Hostless+FullPath URI host should be ""';
    is $uri->port, $port, 'Hostless+FullPath URI port should be undef';
    is $uri->user, undef, 'Hostless+FullPath URI user should be undef';
    is $uri->password, undef, 'Hostless+FullPath URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Hostless+FullPath URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Hostless+FullPath URI query params should be empty';
    is $uri->as_string, "$prefix:////foo.db",
        'Hostless+FullPath URI string should be correct';
    is "$uri", "$prefix:////foo.db",
        'Hostless+FullPath URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://localhost"), $class;
    is $uri->engine, $engine, qq{Localhost URI engine should be "label"};
    is $uri->dbname, undef, 'Localhost URI db name should be undef';
    is $uri->host, 'localhost', 'Localhost URI host should be "localhost"';
    is $uri->port, $port, 'Localhost URI port should be undef';
    is $uri->user, undef, 'Localhost URI user should be undef';
    is $uri->password, undef, 'Localhost URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Localhost URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Localhost URI query params should be empty';
    is $uri->as_string, "$prefix://localhost",
        'Localhost URI string should be correct';
    is "$uri", "$prefix://localhost",
        'Localhost URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://example.com:5433"), $class;
    is $uri->engine, $engine, qq{Host+Port URI engine should be "label"};
    is $uri->dbname, undef, 'Host+Port URI db name should be undef';
    is $uri->host, 'example.com', 'Host+Port URI host should be "example.com"';
    is $uri->port, 5433, 'Host+Port URI port should be 5433';
    is $uri->user, undef, 'Host+Port URI user should be undef';
    is $uri->password, undef, 'Host+Port URI password should be undef';
    is_deeply $uri->query_form_hash, {},
        'Host+Port URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Host+Port URI query params should be empty';
    is $uri->as_string, "$prefix://example.com:5433",
        'Host+Port URI string should be correct';
    is "$uri", "$prefix://example.com:5433",
        'Host+Port URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://example.com/mydb"), $class;
    is $uri->engine, $engine, qq{DB URI engine should be "label"};
    is $uri->dbname, 'mydb', 'DB URI db name should be "mydb"';
    is $uri->host, 'example.com', 'DB URI host should be "example.com"';
    is $uri->port, $port, 'DB URI port should be undef';
    is $uri->user, undef, 'DB URI user should be undef';
    is $uri->password, undef, 'DB URI password should be undef';
    is_deeply $uri->query_form_hash, {}, 'DB URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'DB URI query params should be empty';
    is $uri->as_string, "$prefix://example.com/mydb",
        'DB URI string should be correct';
    is "$uri", "$prefix://example.com/mydb",
        'DB URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://example.com/"), $class;
    is $uri->engine, $engine, qq{DBless URI engine should be "label"};
    is $uri->dbname, '', 'DBless URI db name should be ""';
    is $uri->host, 'example.com', 'DBless URI host should be "example.com"';
    is $uri->port, $port, 'DBless URI port should be undef';
    is $uri->user, undef, 'DBless URI user should be undef';
    is $uri->password, undef, 'DBless URI password should be undef';
    is_deeply $uri->query_form_hash, {}, 'DBless URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'DBless URI query params should be empty';
    is $uri->as_string, "$prefix://example.com/",
        'DBless URI string should be correct';
    is "$uri", "$prefix://example.com/",
        'DBless URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://user\@localhost//fullpathdb"), $class;
    is $uri->engine, $engine, qq{User URI engine should be "label"};
    is $uri->dbname, '/fullpathdb', 'User URI db name should be "/fullpathdb"';
    is $uri->host, 'localhost', 'User URI host should be "localhost"';
    is $uri->port, $port, 'User URI port should be undef';
    is $uri->user, 'user', 'User URI user should be "user"';
    is $uri->password, undef, 'User URI password should be undef';
    is_deeply $uri->query_form_hash, {}, 'User URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'User URI query params should be empty';
    is $uri->as_string, "$prefix://user\@localhost//fullpathdb",
        'User URI string should be correct';
    is "$uri", "$prefix://user\@localhost//fullpathdb",
        'User URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://user\@//fullpathdb"), $class;
    is $uri->engine, $engine, qq{User w/o host URI engine should be "label"};
    is $uri->dbname, '/fullpathdb', 'User w/o host URI db name should be "/fullpathdb"';
    is $uri->host, '', 'User w/o host URI host should be ""';
    is $uri->port, $port, 'User w/o host URI port should be undef';
    is $uri->user, 'user', 'User w/o host URI user should be "user"';
    is $uri->password, undef, 'User w/o host URI password should be undef';
    is_deeply $uri->query_form_hash, {}, 'User w/o host URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'User w/o host URI query params should be empty';
    is $uri->as_string, "$prefix://user\@//fullpathdb",
        'User w/o host URI string should be correct';
    is "$uri", "$prefix://user\@//fullpathdb",
        'User w/o host URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://user:secret\@localhost"), $class;
    is $uri->engine, $engine, qq{Password URI engine should be "label"};
    is $uri->dbname, undef, 'Password URI db name should be undef';
    is $uri->host, 'localhost', 'Password URI host should be "localhost"';
    is $uri->port, $port, 'Password URI port should be undef';
    is $uri->user, 'user', 'Password URI user should be "user"';
    is $uri->password, 'secret', 'Password URI password should be "secret"';
    is_deeply $uri->query_form_hash, {},
        'Password URI query params should be empty by default';
    is_deeply [ $uri->query_params ], [],
        'Password URI query params should be empty';
    is $uri->as_string, "$prefix://user:secret\@localhost",
        'Password URI string should be correct';
    is "$uri", "$prefix://user:secret\@localhost",
        'Password URI should correctly strigify';

    isa_ok $uri = URI->new("$prefix://other\@localhost/otherdb?foo=bar&foo=baz&baz=yow"),
        $class;
    is $uri->engine, $engine, qq{Query URI engine should be "label"};
    is $uri->dbname, 'otherdb', 'Query URI db name should be "otherdb"';
    is $uri->host, 'localhost', 'Query URI host should be "localhost"';
    is $uri->port, $port, 'Query URI port should be undef';
    is $uri->user, 'other', 'Query URI user should be "other"';
    is $uri->password, undef, 'Query URI password should be undef';
    is_deeply $uri->query_form_hash, { foo => [qw(bar baz)], baz => 'yow'},
        'Query URI query params should be populated';
    is_deeply [ $uri->query_params ], [ foo => 'bar', foo => 'baz', baz => 'yow' ],
        'query URI query params should be populated';
    is $uri->as_string, "$prefix://other\@localhost/otherdb?foo=bar&foo=baz&baz=yow",
        'Query URI string should be correct';
    is "$uri", "$prefix://other\@localhost/otherdb?foo=bar&foo=baz&baz=yow",
        'Query URI should correctly strigify';
}

done_testing;
