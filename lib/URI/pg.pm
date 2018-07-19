package URI::pg;
use base 'URI::_db';
our $VERSION = '0.20';

sub default_port { 5432 }
sub dbi_driver   { 'Pg' }
sub canonical_engine { 'pg' }

1;
