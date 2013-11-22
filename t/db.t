#!/usr/bin/perl -w

use strict;
use Test::More;
use utf8;
use URI::QueryParam;


BEGIN { use_ok 'URI::db' or die; }

isa_ok my $uri = URI->new('db:'), 'URI::db';
is $uri->scheme, 'db', 'Scheme should be "db"';
is $uri->db_name, undef, 'Simple URI db name should be undef';
is $uri->host, undef, 'Simple URI host should be ""';
is $uri->port, undef, 'Simple URI port should be undef';
is $uri->user, undef, 'Simple URI user should be undef';
is $uri->password, undef, 'Simple URI password should be undef';
is_deeply $uri->query_form_hash, {}, 'Query params should be empty by default';


done_testing;
