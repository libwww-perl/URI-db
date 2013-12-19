#!/usr/bin/perl -w

use strict;
use Test::More;
use utf8;
use lib '/Users/david/dev/cpan/uri';
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
isa_ok $uri->uri, 'URI::_db';

# Try changing to a known engine.
is $uri->engine('pg'), 'foo', 'Assign engine';
is $uri->engine, 'pg', 'Engine should now be "pg"';
is $uri->as_string, 'db:pg:', 'Engine should be included in stringified URI';
isa_ok $uri, 'URI::db', 'Pg engine URI';
isa_ok $uri->uri, 'URI::pg';

# Try setting to an undefined engine.
is $uri->engine(undef), 'pg', 'Assign undef engine';
is $uri->engine, 'pg', 'DB URI should not have had its engine undefined';
is $uri->scheme, 'db', 'DB URI with undef engine should have scheme "db"';
isa_ok $uri, 'URI::db', 'Undef engine URI';
isa_ok $uri->uri, 'URI::_db';

# Try changing the scheme.
is $uri->scheme('Db'), 'db', 'Change scheme to "Db"';
isa_ok $uri, 'URI::db';
is $uri->scheme, 'db', 'New scheme should still be "db"';
is $uri->as_string, 'Db:pg:', 'Should stringify with the new scheme';

# Change the scheme to something other than db.
eval { $uri->scheme('foo') };
ok my $err = $@, 'Should get error changing to non-DB scheme';
like $err, qr/Cannot change URI::db scheme/, 'Should be the proper error';

# Now use a non-db-qalified URI.
isa_ok $uri = URI->new('pg:'), 'URI::pg', 'Opaque Pg URI';
is $uri->engine, 'pg', 'Pg URI engine should be "pg"';
is $uri->scheme, 'pg', 'Pg URI scheme should be "pg"';
ok $uri->has_recognized_engine, 'Pg URI should be a recognized engine';

# Change it to another engine.
is $uri->engine('vertica'), 'pg', 'Change the engine to "vertica"';
isa_ok $uri, 'URI::vertica';
is $uri->engine, 'vertica', 'Vertica URI engine should be "vertica"';
is $uri->scheme, 'vertica', 'Vertica URI scheme should be "vertica"';
ok $uri->has_recognized_engine, 'Vertica URI should be a recognized engine';

# Try using an unknown engine.
is $uri->engine('foo'), 'vertica', 'Change the engine to "foo"';
isa_ok $uri, 'URI::_db';
is $uri->scheme, 'foo', 'Foo URI scheme should be "foo"';
is $uri->engine, 'foo', 'Foo URI engine should be "foo"';
ok !$uri->has_recognized_engine, 'Foo URI should not be a recognized engine';

# Try using an undefined engine.
is $uri->engine(undef), 'foo', 'Change the engine to undef';
isa_ok $uri, 'URI::_db';
is $uri->scheme, 'foo', 'Foo URI scheme should still be "foo"';
is $uri->engine, 'foo', 'Foo URI engine should still be "foo"';
ok !$uri->has_recognized_engine, 'Foo URI should not be a recognized engine';
is $uri->as_string, 'foo:', 'URI string should be foo:';

# Test dbname with opaque URI.
isa_ok $uri = URI->new('db:'), 'URI::db', 'Another opaque DB URI';
is $uri->dbname, undef, 'DB name should be undef';
is $uri->dbname('foo'), "", 'Assign a database name';
is $uri->dbname, 'foo', 'DB name should be "foo"';
is $uri->path, 'foo', 'Path should be "foo"';
isa_ok $uri, 'URI::db', 'Unknown engine URI';
isa_ok $uri->uri, 'URI::_db';

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
isa_ok $uri->uri, 'URI::_db';

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

# Try constructor.
isa_ok $uri = URI::db->new('pg:'), 'URI::db', 'pg URI';
isa_ok $uri->uri, 'URI::pg', 'pg URI URI';
is $uri->as_string, 'db:pg:', 'pg URI should be correct';

# Should convert non-db URI to a db URI.
isa_ok $uri = URI::db->new('foo:'), 'URI::db', 'foo URI';
isa_ok $uri->uri, 'URI::_db', 'foo URI URI';
is $uri->as_string, 'db:foo:', 'foo URI should be correct';

# Should pay attention to base URI.
isa_ok $uri = URI::db->new('foo', 'pg:'), 'URI::db', 'db URI with pg base';
isa_ok $uri->uri, 'URI::pg', 'db:pg URI';
is $uri->as_string, 'db:pg:foo', 'db URI with pg: base should be correct';

# Should pay attention to db: base URI.
isa_ok $uri = URI::db->new('foo', 'db:'), 'URI::db', 'db URI with db base';
isa_ok $uri->uri, 'URI::_db', 'db base URI';
is $uri->as_string, 'db:foo', 'db URI with db: base should be correct';

# Should pay attention to db:pg base URI.
isa_ok $uri = URI::db->new('foo', 'db:pg'), 'URI::db', 'db URI with db:pg base';
isa_ok $uri->uri, 'URI::pg', 'db:pg base URI';
is $uri->as_string, 'db:pg:foo', 'db URI with db:pg base should be correct';

# Try with a db:pg base.
my $base = URI->new('db:pg');
isa_ok $uri = URI::db->new('foo', $base), 'URI::db', 'db URI with obj base';
isa_ok $uri->uri, 'URI::pg', 'obj base URI';
is $uri->as_string, 'db:pg:foo', 'db URI with obj base should be correct';
isa_ok $base, 'URI::db', 'base URI';

# Try with a db: base.
$base = URI->new('db:');
isa_ok $uri = URI::db->new('foo', $base), 'URI::db', 'db URI with db obj base';
isa_ok $uri->uri, 'URI::_db', 'db obj base URI';
is $uri->as_string, 'db:foo', 'db URI with db obj base should be correct';
isa_ok $base, 'URI::db', 'base URI';

# Try db:unknown.
$base = URI->new('db:unknown:');
isa_ok $uri = URI::db->new('foo', $base), 'URI::db', 'db URI with obj base';
isa_ok $uri->uri, 'URI::_db', 'obj base URI';
is $uri->as_string, 'db:unknown:foo', 'db URI with obj base should be correct';
isa_ok $base, 'URI::db', 'base URI';

# Try with some other base.
$base = URI->new('bar:');
isa_ok $uri = URI::db->new('foo', $base), 'URI::db', 'db URI with obj base';
isa_ok $uri->uri, 'URI::_db', 'obj base URI';
is $uri->as_string, 'db:bar:foo', 'db URI with obj base should be correct';
isa_ok $base, 'URI', 'bar base URI';

# Try new_abs.
isa_ok $uri = URI::db->new_abs('foo', 'pg:'), 'URI::pg';
is $uri->as_string, 'pg:/foo', 'Should have pg: URI';
isa_ok $uri = URI::db->new_abs('foo', 'db:pg:'), 'URI::db';
is $uri->as_string, 'db:pg:/foo', 'Should have db:pg: URI';
isa_ok $uri = URI::db->new_abs('foo', 'db:'), 'URI::db';
is $uri->as_string, 'db:foo', 'Should have db: URI';
isa_ok $uri = URI::db->new_abs('foo', 'bar:'), 'URI::_generic';
isa_ok $uri = URI::db->new_abs('foo', 'file::'), 'URI::file';
isa_ok $uri = URI::db->new_abs('pg:foo', 'pg:'), 'URI::pg';
is $uri->as_string, 'pg:foo', 'Should have pg:foo URI';
isa_ok $uri = URI::db->new_abs('db:foo', 'db:'), 'URI::db';
is $uri->as_string, 'db:foo', 'Should have db:foo URI';
isa_ok $uri = URI::db->new_abs('db:pg:foo', 'db:pg:'), 'URI::db';
is $uri->as_string, 'db:pg:foo', 'Should have db:pg:foo URI';

# Test abs.
isa_ok $uri = URI->new('db:pg:'), 'URI::db';
is overload::StrVal( $uri->abs('file:/hi') ),
   overload::StrVal($uri),
    'abs should return URI object itself';

# Test rel.
is overload::StrVal( $uri->rel('file:/hi') ),
   overload::StrVal($uri),
    'rel should return URI object itself';

# Test clone.
is $uri->clone, $uri, 'Clone should return dupe URI';
isnt overload::StrVal( $uri->clone ), overload::StrVal($uri),
    'Clone should not return self';

# Test eq.
can_ok $uri, 'eq';
ok $uri->eq($uri), 'URI should equal itself';
ok $uri->eq($uri->as_string), 'URI should equal itself stringified';
ok $uri->eq(URI->new( $uri->as_string )), 'URI should equal equiv URI';
ok $uri->eq($uri->clone), 'URI should equal itself cloned';
ok $uri->eq('pg:'), 'URI should not equal non-DB URI';

done_testing;
