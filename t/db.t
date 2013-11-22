#!/usr/bin/perl -w

use strict;
use Test::More;
use utf8;
use URI::QueryParam;


BEGIN { use_ok 'URI::db' or die; }

isa_ok my $uri = URI->new('db:'), 'URI::db';
is $uri->scheme, 'db', 'Simple URI scheme should be "db"';
is $uri->db_name, undef, 'Simple URI db name should be undef';
is $uri->host, undef, 'Simple URI host should be undef';
is $uri->port, undef, 'Simple URI port should be undef';
is $uri->user, undef, 'Simple URI user should be undef';
is $uri->password, undef, 'Simple URI password should be undef';
is_deeply $uri->query_form_hash, {}, 'Simple URI query params should be empty by default';

isa_ok $uri = URI->new('db://'), 'URI::db';
is $uri->scheme, 'db', 'Smple URI scheme should be "db"';
is $uri->db_name, undef, 'Hostless URI db name should be undef';
is $uri->host, '', 'Hostless URI host should be ""';
is $uri->port, undef, 'Hostless URI port should be undef';
is $uri->user, undef, 'Hostless URI user should be undef';
is $uri->password, undef, 'Hostless URI password should be undef';
is_deeply $uri->query_form_hash, {}, 'Hostless URI query params should be empty by default';

isa_ok $uri = URI->new('db://localhost'), 'URI::db';
is $uri->scheme, 'db', 'Localhost URI scheme should be "db"';
is $uri->db_name, undef, 'Localhost URI db name should be undef';
is $uri->host, 'localhost', 'Localhost URI host should be "localhost"';
is $uri->port, undef, 'Localhost URI port should be undef';
is $uri->user, undef, 'Localhost URI user should be undef';
is $uri->password, undef, 'Localhost URI password should be undef';
is_deeply $uri->query_form_hash, {}, 'Localhost URI query params should be empty by default';

isa_ok $uri = URI->new('db://example.com:5433'), 'URI::db';
is $uri->scheme, 'db', 'Host+Port URI scheme should be "db"';
is $uri->db_name, undef, 'Host+Port URI db name should be undef';
is $uri->host, 'example.com', 'Host+Port URI host should be "example.com"';
is $uri->port, 5433, 'Host+Port URI port should be 5433';
is $uri->user, undef, 'Host+Port URI user should be undef';
is $uri->password, undef, 'Host+Port URI password should be undef';
is_deeply $uri->query_form_hash, {}, 'Host+Port URI query params should be empty by default';

isa_ok $uri = URI->new('db://example.com/mydb'), 'URI::db';
is $uri->scheme, 'db', 'DB URI scheme should be "db"';
is $uri->db_name, 'mydb', 'DB URI db name should be "mydb"';
is $uri->host, 'example.com', 'DB URI host should be "example.com"';
is $uri->port, undef, 'DB URI port should be undef';
is $uri->user, undef, 'DB URI user should be undef';
is $uri->password, undef, 'DB URI password should be undef';
is_deeply $uri->query_form_hash, {}, 'DB URI query params should be empty by default';

isa_ok $uri = URI->new('db://user@localhost//fullpathdb'), 'URI::db';
is $uri->scheme, 'db', 'User URI scheme should be "db"';
is $uri->db_name, '/fullpathdb', 'User URI db name should be "/fullpathdb"';
is $uri->host, 'localhost', 'User URI host should be "localhost"';
is $uri->port, undef, 'User URI port should be undef';
is $uri->user, 'user', 'User URI user should be "user"';
is $uri->password, undef, 'User URI password should be undef';
is_deeply $uri->query_form_hash, {}, 'User URI query params should be empty by default';

isa_ok $uri = URI->new('db://user:secret@localhost'), 'URI::db';
is $uri->scheme, 'db', 'Password URI scheme should be "db"';
is $uri->db_name, undef, 'Password URI db name should be undef';
is $uri->host, 'localhost', 'Password URI host should be "localhost"';
is $uri->port, undef, 'Password URI port should be undef';
is $uri->user, 'user', 'Password URI user should be "user"';
is $uri->password, 'secret', 'Password URI password should be "secret"';
is_deeply $uri->query_form_hash, {}, 'Password URI query params should be empty by default';

isa_ok $uri = URI->new('db://other@localhost/otherdb?foo=bar&baz=yow'), 'URI::db';
is $uri->scheme, 'db', 'Query URI scheme should be "db"';
is $uri->db_name, 'otherdb', 'Query URI db name should be "otherdb"';
is $uri->host, 'localhost', 'Query URI host should be "localhost"';
is $uri->port, undef, 'Query URI port should be undef';
is $uri->user, 'other', 'Query URI user should be "other"';
is $uri->password, undef, 'Query URI password should be undef';
is_deeply $uri->query_form_hash, { foo => 'bar', baz => 'yow'},
    'Query URI query params should be populated';

done_testing;
