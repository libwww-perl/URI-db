#!perl -w

use strict;
use Test::More;
eval "use Test::Spelling";
plan skip_all => "Test::Spelling required for testing POD spelling" if $@;
plan tests  => 1;

add_stopwords(<DATA>);
pod_file_spelling_ok('lib/URI/db.pm');

__DATA__
JDBC
GitHub
IP
subprotocol
namespace
DSN
Hackor

