package URI::pg;
use base 'URI::_db';
our $VERSION = '0.15';

sub default_port { 5432 }
sub dbi_driver   { 'Pg' }

1;
