#!perl -w

use strict;
use Test::More tests => 1;
eval "use Test::Spelling";
plan skip_all => "Test::Spelling required for testing POD spelling" if $@;

add_stopwords(<DATA>);
pod_file_spelling_ok('lib/URI/db.pm');

__DATA__
JDBC
GitHub
IP
subprotocol
namespace
DSN
