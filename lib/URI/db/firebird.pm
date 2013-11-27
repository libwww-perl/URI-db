package URI::db::firebird;
use base 'URI::db';
our $VERSION = '0.10';

sub default_port { 3050 }
sub dbi_driver   { 'Firebird' }

1;
