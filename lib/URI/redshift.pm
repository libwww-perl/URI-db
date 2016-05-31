package URI::redshift;
use base 'URI::_db';
our $VERSION = '0.18';

sub default_port { 5432 }
sub dbi_driver   { 'Pg' }
sub canonical_engine { 'redshift' }

1;
