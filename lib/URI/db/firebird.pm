package URI::db::firebird;
use base 'URI::db';
our $VERSION = '0.10';

sub is_file_based { 1 }
sub default_port  { 3050 }
sub dbi_driver    { 'Firebird' }

1;
