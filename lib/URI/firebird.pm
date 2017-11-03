package URI::firebird;
use base 'URI::_db';
our $VERSION = '0.19';

sub default_port { 3050 }
sub dbi_driver   { 'Firebird' }

1;
